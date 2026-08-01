import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:newpipeextractor_dart/utils/parsing.dart';
import 'package:newpipeextractor_dart/utils/streamsParser.dart';

/// Builds a payload shaped exactly like the one the Android side sends:
/// integer-keyed maps whose values are all strings (or null).
Map<int, Map<String, String?>> nativeStreamList(int count) {
  return {
    for (var i = 0; i < count; i++)
      i: {
        'url': 'https://www.youtube.com/watch?v=id$i',
        'id': 'id$i',
        'name': 'video $i',
        'uploaderName': 'uploader $i',
        'uploaderUrl': 'https://www.youtube.com/channel/c$i',
        'uploaderAvatars': '["https://i.ytimg.com/a$i.jpg"]',
        'thumbnails': '["https://i.ytimg.com/t$i.jpg"]',
        'uploadDate': '3 years ago',
        'date': '2022-01-0${i + 1}T00:00:00Z',
        'duration': '${100 + i}',
        'viewCount': '${1000 + i}',
      }
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Parse', () {
    test('imageList decodes the JSON array string the native side sends', () {
      expect(Parse.imageList('["a","b"]'), ['a', 'b']);
    });

    test('imageList accepts an already-decoded list', () {
      // jsonDecode yields List<dynamic>; reading that straight into a
      // List<String> used to throw a TypeError on every model round-trip.
      expect(Parse.imageList(<dynamic>['a', 'b']), ['a', 'b']);
    });

    test('imageList degrades to empty on null/blank/malformed input', () {
      expect(Parse.imageList(null), isEmpty);
      expect(Parse.imageList(''), isEmpty);
      expect(Parse.imageList('not json'), isEmpty);
      expect(Parse.imageList('{"a":1}'), isEmpty);
    });

    test('integer parses strings and falls back instead of throwing', () {
      expect(Parse.integer('42'), 42);
      expect(Parse.integer(42), 42);
      expect(Parse.integer(null), 0);
      expect(Parse.integer('null'), 0);
      expect(Parse.integer('x', fallback: -1), -1);
    });

    test('nullableInteger keeps "absent" distinct from zero', () {
      expect(Parse.nullableInteger('0'), 0);
      expect(Parse.nullableInteger(null), isNull);
      expect(Parse.nullableInteger('null'), isNull);
    });

    test('boolean reads the stringified booleans the native side sends', () {
      expect(Parse.boolean('true'), isTrue);
      expect(Parse.boolean('TRUE'), isTrue);
      expect(Parse.boolean('false'), isFalse);
      expect(Parse.boolean(null), isFalse);
    });
  });

  group('StreamsParser', () {
    test('parses a native stream list', () {
      final streams = StreamsParser.parseStreamListFromMap(nativeStreamList(3));

      expect(streams, hasLength(3));
      expect(streams.first.name, 'video 0');
      expect(streams.first.duration, 100);
      expect(streams.first.viewCount, 1000);
      expect(streams.first.uploaderAvatars, ['https://i.ytimg.com/a0.jpg']);
    });

    test('keeps items in index order regardless of map iteration order', () {
      final shuffled = {
        2: {'name': 'third', 'duration': '0', 'viewCount': '0'},
        0: {'name': 'first', 'duration': '0', 'viewCount': '0'},
        1: {'name': 'second', 'duration': '0', 'viewCount': '0'},
      };

      final streams = StreamsParser.parseStreamListFromMap(shuffled);
      expect(streams.map((e) => e.name), ['first', 'second', 'third']);
    });

    test('missing counts degrade to 0 rather than throwing', () {
      final streams = StreamsParser.parseStreamListFromMap({
        0: {'name': 'no counts', 'duration': null, 'viewCount': null},
      });

      expect(streams.single.duration, 0);
      expect(streams.single.viewCount, 0);
    });

    test('always returns three buckets so callers can index safely', () {
      // Regression: an error payload used to yield [], and every caller then
      // hit a RangeError reading results[1] / results[2].
      for (final payload in <dynamic>[
        null,
        <String, dynamic>{},
        {'error': 'boom'},
        'nonsense',
      ]) {
        final result =
            StreamsParser.parseInfoItemListFromMap(payload, singleList: false);
        expect(result, hasLength(3), reason: 'payload: $payload');
        expect(result[0], isEmpty);
        expect(result[1], isEmpty);
        expect(result[2], isEmpty);
      }
    });

    test('splits streams, playlists and channels', () {
      final result = StreamsParser.parseInfoItemListFromMap({
        'streams': nativeStreamList(2),
        'playlists': {
          0: {
            'url': 'https://youtube.com/playlist?list=PL1',
            'name': 'a playlist',
            'uploaderName': 'someone',
            'thumbnails': '["https://i.ytimg.com/p.jpg"]',
            'streamCount': '12',
          }
        },
        'channels': {
          0: {
            'url': 'https://youtube.com/channel/C1',
            'name': 'a channel',
            'description': 'desc',
            'thumbnails': '["https://i.ytimg.com/c.jpg"]',
            'subscriberCount': '500',
            'streamCount': '7',
          }
        },
      }, singleList: false);

      expect(result[0], hasLength(2));
      final playlist = (result[1] as List<PlaylistInfoItem>).single;
      expect(playlist.name, 'a playlist');
      expect(playlist.streamCount, 12);
      expect(playlist.thumbnails, ['https://i.ytimg.com/p.jpg']);
      final channel = (result[2] as List<ChannelInfoItem>).single;
      expect(channel.subscriberCount, 500);
      expect(channel.thumbnails, ['https://i.ytimg.com/c.jpg']);
    });

    test('parses stream segments', () {
      final segments = StreamsParser.parseStreamSegmentListFromMap({
        0: {
          'url': 'https://youtu.be/x?t=0',
          'title': 'Intro',
          'previewUrl': 'https://i.ytimg.com/s.jpg',
          'startTimeSeconds': '0',
        },
        1: {
          'url': 'https://youtu.be/x?t=30',
          'title': 'Verse',
          'previewUrl': null,
          'startTimeSeconds': '30',
        },
      });

      expect(segments.map((e) => e.title), ['Intro', 'Verse']);
      expect(segments.last.startTimeSeconds, 30);
    });
  });

  group('VideoInfo.fromMap', () {
    test('decodes the JSON-string image fields the native side sends', () {
      // Regression: this used to call List<String>.from on the raw JSON string,
      // so VideoExtractor.getInfo threw on every call.
      final info = VideoInfo.fromMap({
        'id': 'dQw4w9WgXcQ',
        'name': 'a video',
        'thumbnails': '["https://i.ytimg.com/t.jpg"]',
        'uploaderAvatars': '["https://i.ytimg.com/a.jpg"]',
        'length': '212',
        'viewCount': '1000',
        'tags': '["music"]',
      });

      expect(info.name, 'a video');
      expect(info.thumbnails, ['https://i.ytimg.com/t.jpg']);
      expect(info.uploaderAvatars, ['https://i.ytimg.com/a.jpg']);
      expect(info.length, 212);
      expect(info.tags, '["music"]');
    });

    test('unknown counts stay null instead of throwing', () {
      final info = VideoInfo.fromMap({
        'name': 'a video',
        'likeCount': null,
        'dislikeCount': null,
      });

      expect(info.likeCount, isNull);
      expect(info.dislikeCount, isNull);
      expect(info.thumbnails, isEmpty);
    });
  });

  group('model json round-trips', () {
    test('StreamInfoItem survives listToJson / fromJsonString', () {
      final original = StreamsParser.parseStreamListFromMap(nativeStreamList(2));
      final restored =
          StreamInfoItem.fromJsonString(StreamInfoItem.listToJson(original));

      expect(restored, hasLength(2));
      expect(restored.first.name, original.first.name);
      expect(restored.first.uploaderAvatars, original.first.uploaderAvatars);
      expect(restored.first.duration, original.first.duration);
    });

    test('ChannelInfoItem survives listToJson / fromJsonString', () {
      final original = [
        ChannelInfoItem('https://youtube.com/channel/C1', 'chan', 'desc',
            ['https://i.ytimg.com/c.jpg'], 500, 7),
      ];
      final restored =
          ChannelInfoItem.fromJsonString(ChannelInfoItem.listToJson(original));

      expect(restored.single.name, 'chan');
      expect(restored.single.thumbnails, ['https://i.ytimg.com/c.jpg']);
      expect(restored.single.subscriberCount, 500);
    });

    test('ChannelInfoItem with an unknown subscriber count round-trips', () {
      final restored = ChannelInfoItem.fromJsonString(
          ChannelInfoItem.listToJson([
        ChannelInfoItem('u', 'chan', 'desc', const [], null, 0),
      ]));

      expect(restored.single.subscriberCount, isNull);
    });

    test('PlaylistInfoItem survives listToJson / fromJsonString', () {
      final restored = PlaylistInfoItem.fromJsonString(
          PlaylistInfoItem.listToJson([
        PlaylistInfoItem('https://youtube.com/playlist?list=PL1', 'pl', 'who',
            ['https://i.ytimg.com/p.jpg'], 3),
      ]));

      expect(restored.single.name, 'pl');
      expect(restored.single.thumbnails, ['https://i.ytimg.com/p.jpg']);
      expect(restored.single.streamCount, 3);
    });
  });

  group('YoutubeVideo stream selection', () {
    AudioOnlyStream audio(int bitrate, String format) =>
        AudioOnlyStream('t', 'u', bitrate, format, format, 'audio/$format');
    VideoOnlyStream video(String? resolution) =>
        VideoOnlyStream('t', 'u', resolution, 'mp4', 'mp4', 'video/mp4');

    test('picks the highest bitrate audio', () {
      final v = YoutubeVideo(
        videoInfo: VideoInfo(),
        audioOnlyStreams: [audio(128000, 'm4a'), audio(256000, 'm4a')],
      );
      expect(v.audioWithHighestQuality?.averageBitrate, 256000);
    });

    test('falls back to the best audio when no stream matches the format', () {
      final v = YoutubeVideo(
        videoInfo: VideoInfo(),
        audioOnlyStreams: [audio(128000, 'm4a'), audio(256000, 'm4a')],
      );
      expect(v.audioWithBestOggQuality?.averageBitrate, 256000);
    });

    test('picks the highest resolution, ignoring the fps suffix', () {
      final v = YoutubeVideo(
        videoInfo: VideoInfo(),
        videoOnlyStreams: [video('720p'), video('1080p60'), video('360p')],
      );
      expect(v.videoOnlyWithHighestQuality?.resolution, '1080p60');
    });

    test('unlabelled resolutions sort last rather than throwing', () {
      // Regression: resolution is nullable and this used to force-unwrap it.
      final v = YoutubeVideo(
        videoInfo: VideoInfo(),
        videoOnlyStreams: [video(null), video('480p')],
      );
      expect(v.videoOnlyWithHighestQuality?.resolution, '480p');
    });

    test('throws StreamIsNull when the stream list was never fetched', () {
      final v = YoutubeVideo(videoInfo: VideoInfo());
      expect(() => v.audioWithHighestQuality, throwsA(isA<StreamIsNull>()));
      expect(() => v.videoWithHighestQuality, throwsA(isA<StreamIsNull>()));
    });
  });

  group('method channel', () {
    const channel = MethodChannel('newpipeextractor_dart');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    tearDown(() => messenger.setMockMethodCallHandler(channel, null));

    void mock(Future<Object?>? Function(MethodCall call) handler) =>
        messenger.setMockMethodCallHandler(channel, handler);

    test('YoutubeId reads the id out of the response map', () async {
      mock((call) async {
        expect(call.method, 'getIdFromStreamUrl');
        return {'id': 'dQw4w9WgXcQ'};
      });

      expect(
        await YoutubeId.getIdFromStreamUrl(
            'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
        'dQw4w9WgXcQ',
      );
    });

    test('YoutubeId returns null when the native side found no id', () async {
      mock((call) async => {'id': ''});
      expect(await YoutubeId.getIdFromStreamUrl('https://youtu.be/x'), isNull);
    });

    test('YoutubeId rejects urls containing whitespace', () async {
      expect(
        () => YoutubeId.getIdFromStreamUrl('https://youtu.be/x y'),
        throwsA(isA<BadUrlException>()),
      );
    });

    test('extraction errors reach the caller', () async {
      // Regression: failures used to be swallowed and surfaced as null, which
      // turned every error into a null-dereference somewhere further up.
      mock((call) async =>
          throw PlatformException(code: 'extraction_error', message: 'boom'));

      await expectLater(
        TrendingExtractor.getTrendingVideos(),
        throwsA(isA<PlatformException>()
            .having((e) => e.code, 'code', 'extraction_error')),
      );
    });

    test('a reCaptcha challenge is rethrown when no navigator is wired up',
        () async {
      mock((call) async => throw PlatformException(
            code: kReCaptchaErrorCode,
            message: 'reCaptcha Challenge requested',
            details: 'https://www.google.com/sorry/index',
          ));

      await expectLater(
        TrendingExtractor.getTrendingVideos(),
        throwsA(isA<PlatformException>()
            .having((e) => e.code, 'code', kReCaptchaErrorCode)),
      );
    });

    test('trending parses the native payload and defaults to the live kiosk',
        () async {
      mock((call) async {
        expect(call.method, 'getTrendingStreams');
        expect(call.arguments['kiosk'], 'live');
        return nativeStreamList(2);
      });

      final trending = await TrendingExtractor.getTrendingVideos();
      expect(trending.map((e) => e.name), ['video 0', 'video 1']);
    });

    test('trending forwards the requested kiosk', () async {
      String? requested;
      mock((call) async {
        requested = call.arguments['kiosk'];
        return nativeStreamList(1);
      });

      await TrendingExtractor.getTrendingVideos(
          kiosk: YoutubeKiosk.trendingMusic);
      expect(requested, 'trending_music');
    });

    test('getAvailableKiosks returns the native list', () async {
      mock((call) async {
        expect(call.method, 'getAvailableKiosks');
        return <String>['live', 'trending_music'];
      });

      expect(await TrendingExtractor.getAvailableKiosks(),
          ['live', 'trending_music']);
    });

    test('search returns all three buckets', () async {
      mock((call) async => {
            'streams': nativeStreamList(1),
            'playlists': <int, Map<String, String>>{},
            'channels': <int, Map<String, String>>{},
          });

      final search = await SearchExtractor.searchYoutube('lofi', []);
      expect(search.searchVideos, hasLength(1));
      expect(search.searchPlaylists, isEmpty);
      expect(search.searchChannels, isEmpty);
    });

    test('getStream maps the positional stream payload', () async {
      mock((call) async => [
            {'id': 'x', 'name': 'a video', 'length': '212'},
            {
              0: {
                'url': 'https://audio',
                'averageBitrate': '128000',
                'formatName': 'm4a',
                'formatSuffix': 'm4a',
                'formatMimeType': 'audio/mp4',
              }
            },
            {
              0: {
                'url': 'https://videoonly',
                'resolution': '1080p',
                'formatName': 'mp4',
              }
            },
            {
              0: {
                'url': 'https://muxed',
                'resolution': '360p',
                'formatName': 'mp4',
              }
            },
            <int, Map<String, String>>{},
          ]);

      final video = await VideoExtractor.getStream('https://youtu.be/x');
      expect(video.videoInfo.name, 'a video');
      expect(video.audioOnlyStreams?.single.averageBitrate, 128000);
      expect(video.videoOnlyStreams?.single.resolution, '1080p');
      expect(video.videoStreams?.single.url, 'https://muxed');
      expect(video.segments, isEmpty);
    });

    test('comments parse booleans and avatars', () async {
      mock((call) async => {
            0: {
              'commentId': 'c1',
              'author': 'someone',
              'commentText': 'nice',
              'uploaderAvatars': '["https://i.ytimg.com/a.jpg"]',
              'uploadDate': '1 year ago',
              'uploaderUrl': 'https://youtube.com/channel/C1',
              'likeCount': '5',
              'pinned': 'true',
              'hearted': 'false',
            }
          });

      final comments =
          await CommentsExtractor.getComments('https://youtu.be/x');
      final comment = comments.single;
      expect(comment.author, 'someone');
      expect(comment.likeCount, 5);
      expect(comment.pinned, isTrue);
      expect(comment.hearted, isFalse);
      expect(comment.uploaderAvatars, ['https://i.ytimg.com/a.jpg']);
    });

    test('channel info decodes avatars and banners', () async {
      mock((call) async => {
            'id': 'C1',
            'name': 'a channel',
            'url': 'https://youtube.com/channel/C1',
            'avatars': '["https://i.ytimg.com/a.jpg"]',
            'banners': '["https://i.ytimg.com/b.jpg"]',
            'description': 'desc',
            'feedUrl': 'https://youtube.com/feeds/videos.xml?channel_id=C1',
            'subscriberCount': '1234',
          });

      final channel =
          await ChannelExtractor.channelInfo('https://youtube.com/channel/C1');
      expect(channel.avatars, ['https://i.ytimg.com/a.jpg']);
      expect(channel.banners, ['https://i.ytimg.com/b.jpg']);
      expect(channel.subscriberCount, 1234);
    });

    test('playlist details decode uploader avatars that may be absent',
        () async {
      mock((call) async => {
            'id': 'PL1',
            'name': 'a playlist',
            'url': 'https://youtube.com/playlist?list=PL1',
            'uploaderName': null,
            'uploaderAvatars': '[]',
            'uploaderUrl': null,
            'banners': '[]',
            'thumbnails': '["https://i.ytimg.com/p.jpg"]',
            'streamCount': '25',
          });

      final playlist = await PlaylistExtractor.getPlaylistDetails(
          'https://youtube.com/playlist?list=PL1');
      expect(playlist.name, 'a playlist');
      expect(playlist.streamCount, 25);
      expect(playlist.uploaderAvatars, isEmpty);
      expect(playlist.thumbnails, ['https://i.ytimg.com/p.jpg']);
    });
  });
}
