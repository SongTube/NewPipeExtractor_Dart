import 'package:flutter/material.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'newpipeextractor_dart',
      theme: ThemeData(colorSchemeSeed: Colors.red, useMaterial3: true),
      // These two lines are what makes the reCaptcha flow work; without them a
      // challenge surfaces to the caller as a PlatformException instead.
      navigatorKey: NavigationService.instance.navigationKey,
      routes: {ReCaptchaPage.routeName: (_) => const ReCaptchaPage()},
      home: const HomePage(),
    );
  }
}

/// One button per extractor, so every method channel call can be exercised
/// against the live service.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _videoUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
  static const _channelUrl =
      'https://www.youtube.com/channel/UCuAXFkgsw1L7xaCfnd5JJOw';
  static const _playlistUrl =
      'https://www.youtube.com/playlist?list=PLirAqAtl_h2r5g8xGajEwdXd3x1sZh8hC';

  String _title = 'Pick a check';
  String _output = '';
  bool _busy = false;

  Future<void> _run(String title, Future<String> Function() body) async {
    setState(() {
      _busy = true;
      _title = title;
      _output = 'Running…';
    });
    String result;
    try {
      result = await body();
    } catch (e, st) {
      result = 'FAILED: $e\n\n$st';
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _output = result;
    });
  }

  static String _describe(List<StreamInfoItem> items) {
    if (items.isEmpty) return 'No items returned.';
    return '${items.length} items\n\n'
        '${items.take(10).map((e) => '• ${e.name}  —  ${e.uploaderName}').join('\n')}';
  }

  late final Map<String, Future<String> Function()> _checks = {
    'Kiosks': () async {
      final available = await TrendingExtractor.getAvailableKiosks();
      final buffer = StringBuffer('available: ${available.join(', ')}\n\n');
      // The classic Trending kiosk is intentionally absent: YouTube removed
      // that page on 2025-07-21.
      for (final kiosk in [
        YoutubeKiosk.live,
        YoutubeKiosk.trendingMusic,
        YoutubeKiosk.trendingGaming,
        YoutubeKiosk.trendingMoviesAndShows,
        YoutubeKiosk.trendingPodcasts,
      ]) {
        try {
          final items = await TrendingExtractor.getTrendingVideos(kiosk: kiosk);
          buffer.writeln('${kiosk.id}: ${items.length} items');
        } catch (e) {
          buffer.writeln('${kiosk.id}: FAILED — $e');
        }
      }
      return buffer.toString();
    },
    'Live feed': () async => _describe(
        await TrendingExtractor.getTrendingVideos(kiosk: YoutubeKiosk.live)),
    'Search': () async {
      final search = await SearchExtractor.searchYoutube('lofi', []);
      return 'videos: ${search.searchVideos?.length}, '
          'playlists: ${search.searchPlaylists?.length}, '
          'channels: ${search.searchChannels?.length}\n\n'
          '${_describe(search.searchVideos ?? [])}';
    },
    'Search page 2': () async {
      final search = await SearchExtractor.searchYoutube('lofi', []);
      final before = search.searchVideos?.length ?? 0;
      await search.getNextPage();
      return 'page 1: $before videos, '
          'after page 2: ${search.searchVideos?.length} videos';
    },
    'Music search': () async {
      final search = await SearchExtractor.searchYoutubeMusic('daft punk', []);
      return _describe(search.searchVideos ?? []);
    },
    'Video info': () async {
      final video = await VideoExtractor.getInfo(_videoUrl);
      final info = video.videoInfo;
      return 'name: ${info.name}\n'
          'uploader: ${info.uploaderName}\n'
          'length: ${info.length}s\n'
          'views: ${info.viewCount}\n'
          'likes: ${info.likeCount}\n'
          'category: ${info.category}\n'
          'tags: ${info.tags}\n'
          'thumbnails: ${info.thumbnails?.length}\n'
          'avatars: ${info.uploaderAvatars?.length}';
    },
    'Video + streams': () async {
      final video = await VideoExtractor.getStream(_videoUrl);
      return 'name: ${video.videoInfo.name}\n'
          'audio-only: ${video.audioOnlyStreams?.length}\n'
          'video-only: ${video.videoOnlyStreams?.length}\n'
          'muxed: ${video.videoStreams?.length}\n'
          'segments: ${video.segments?.length}\n\n'
          'best audio: ${video.audioWithHighestQuality?.averageBitrate} bps '
          '(${video.audioWithHighestQuality?.formatName})\n'
          'best video: ${video.videoOnlyWithHighestQuality?.resolution}\n\n'
          'first audio url: ${video.audioOnlyStreams?.first.url}';
    },
    'Media streams': () async {
      final streams = await VideoExtractor.getMediaStreams(_videoUrl);
      return 'audio: ${(streams[0] as List).length}\n'
          'video-only: ${(streams[1] as List).length}\n'
          'muxed: ${(streams[2] as List).length}\n'
          'segments: ${(streams[3] as List).length}';
    },
    'Related': () async {
      final related = await VideoExtractor.getRelatedStreams(_videoUrl);
      return '${related.length} related items';
    },
    'Comments': () async {
      final comments = await CommentsExtractor.getComments(_videoUrl);
      if (comments.isEmpty) return 'No comments returned.';
      return '${comments.length} comments\n\n'
          '${comments.take(5).map((c) => '• ${c.author}: ${c.commentText}').join('\n\n')}';
    },
    'Channel info': () async {
      final channel = await ChannelExtractor.channelInfo(_channelUrl);
      return 'name: ${channel.name}\n'
          'subs: ${channel.subscriberCount}\n'
          'avatars: ${channel.avatars?.length}\n'
          'banners: ${channel.banners?.length}\n'
          'feed: ${channel.feedUrl}\n\n'
          '${channel.description}';
    },
    'Channel uploads': () async {
      final first = await ChannelExtractor.getChannelUploads(_channelUrl);
      final second = await ChannelExtractor.getChannelNextUploads();
      return 'page 1: ${first.length}, page 2: ${second.length}\n\n'
          '${_describe(first)}';
    },
    'Playlist': () async {
      final playlist = await PlaylistExtractor.getPlaylistDetails(_playlistUrl);
      final streams = await PlaylistExtractor.getPlaylistStreams(_playlistUrl);
      return 'name: ${playlist.name}\n'
          'uploader: ${playlist.uploaderName}\n'
          'count: ${playlist.streamCount}\n\n'
          '${_describe(streams)}';
    },
    'Url to id': () async {
      return 'stream: ${await YoutubeId.getIdFromStreamUrl(_videoUrl)}\n'
          'playlist: ${await YoutubeId.getIdFromPlaylistUrl(_playlistUrl)}\n'
          'channel: ${await YoutubeId.getIdFromChannelUrl(_channelUrl)}';
    },
    'Error path': () async {
      await VideoExtractor.getInfo('https://www.youtube.com/watch?v=_______');
      return 'Unexpected: no error was thrown.';
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('newpipeextractor_dart')),
      body: Column(
        children: [
          SizedBox(
            height: 88,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final entry in _checks.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Center(
                      child: FilledButton.tonal(
                        onPressed:
                            _busy ? null : () => _run(entry.key, entry.value),
                        child: Text(entry.key),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(_title,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                if (_busy)
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SelectableText(
                _output,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
