import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:newpipeextractor_dart/utils/parsing.dart';
import 'package:newpipeextractor_dart/utils/streamsParser.dart';
import 'package:newpipeextractor_dart/utils/stringChecker.dart';

class VideoExtractor {
  static void _checkUrl(String? url) {
    if (url == null || StringChecker.hasWhiteSpace(url)) {
      throw BadUrlException('Url is null or contains white space');
    }
  }

  static Future<dynamic> _invoke(String method, String videoUrl) {
    _checkUrl(videoUrl);
    return ReCaptchaPage.run(
      () => NewPipeExtractorDart.extractorChannel
          .invokeMethod(method, {'videoUrl': videoUrl}),
    );
  }

  static AudioOnlyStream _audioStream(Map map) => AudioOnlyStream(
        map['torrentUrl'],
        map['url'],
        Parse.integer(map['averageBitrate']),
        map['formatName'],
        map['formatSuffix'],
        map['formatMimeType'],
      );

  static VideoOnlyStream _videoOnlyStream(Map map) => VideoOnlyStream(
        map['torrentUrl'],
        map['url'],
        map['resolution'],
        map['formatName'],
        map['formatSuffix'],
        map['formatMimeType'],
      );

  static VideoStream _videoStream(Map map) => VideoStream(
        map['torrentUrl'],
        map['url'],
        map['resolution'],
        map['formatName'],
        map['formatSuffix'],
        map['formatMimeType'],
      );

  /// Retrieves a full [YoutubeVideo] with all the information for that video,
  /// including every Video, Audio and Muxed stream (Muxed = Video + Audio).
  static Future<YoutubeVideo> getStream(String? videoUrl) async {
    _checkUrl(videoUrl);
    final info = await _invoke('getVideoInfoAndStreams', videoUrl!) as List;
    return YoutubeVideo(
      videoInfo: VideoInfo.fromMap(Map<String, dynamic>.from(info[0] as Map)),
      audioOnlyStreams: Parse.list(info[1], _audioStream),
      videoOnlyStreams: Parse.list(info[2], _videoOnlyStream),
      videoStreams: Parse.list(info[3], _videoStream),
      segments: StreamsParser.parseStreamSegmentListFromMap(info[4]),
    );
  }

  /// Retrieve only the video information.
  static Future<YoutubeVideo> getInfo(String videoUrl) async {
    final map = await _invoke('getVideoInformation', videoUrl) as Map;
    return YoutubeVideo(
      videoInfo: VideoInfo.fromMap(Map<String, dynamic>.from(map)),
    );
  }

  /// Retrieve all streams as a list in the following order:
  ///
  /// [0] `List<AudioOnlyStream>`
  /// [1] `List<VideoOnlyStream>`
  /// [2] `List<VideoStream>` (muxed)
  /// [3] `List<StreamSegment>`
  ///
  /// This used to hand back the untouched method-channel payload, so callers
  /// received raw maps rather than the documented models.
  static Future<List<dynamic>> getMediaStreams(String videoUrl) async {
    final info = await _invoke('getAllVideoStreams', videoUrl) as List;
    return [
      Parse.list(info[0], _audioStream),
      Parse.list(info[1], _videoOnlyStream),
      Parse.list(info[2], _videoStream),
      StreamsParser.parseStreamSegmentListFromMap(info[3]),
    ];
  }

  /// Retrieve video-only streams.
  static Future<List<VideoOnlyStream>> getVideoOnlyStreams(
      String videoUrl) async {
    return Parse.list(
        await _invoke('getVideoOnlyStreams', videoUrl), _videoOnlyStream);
  }

  /// Retrieve audio-only streams.
  static Future<List<AudioOnlyStream>> getAudioOnlyStreams(
      String videoUrl) async {
    return Parse.list(
        await _invoke('getAudioOnlyStreams', videoUrl), _audioStream);
  }

  /// Retrieve video streams (Muxed = Video + Audio).
  static Future<List<VideoStream>> getVideoStreams(String videoUrl) async {
    return Parse.list(await _invoke('getVideoStreams', videoUrl), _videoStream);
  }

  /// Retrieve related videos by URL.
  static Future<List<dynamic>> getRelatedStreams(String videoUrl) async {
    return StreamsParser.parseInfoItemListFromMap(
        await _invoke('getRelatedStreams', videoUrl),
        singleList: true);
  }

  /// Retrieves all stream segments from a video URL.
  static Future<List<StreamSegment>> getStreamSegments(String videoUrl) async {
    return StreamsParser.parseStreamSegmentListFromMap(
        await _invoke('getVideoSegments', videoUrl));
  }
}
