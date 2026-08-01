import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:newpipeextractor_dart/utils/parsing.dart';
import 'package:newpipeextractor_dart/utils/streamsParser.dart';
import 'package:newpipeextractor_dart/utils/stringChecker.dart';

class PlaylistExtractor {
  /// Extract the details of the given playlist URL into a [YoutubePlaylist].
  static Future<YoutubePlaylist> getPlaylistDetails(String? playlistUrl) async {
    if (playlistUrl == null || StringChecker.hasWhiteSpace(playlistUrl)) {
      throw BadUrlException('Url is null or contains white space');
    }
    final info = await ReCaptchaPage.run(
      () => NewPipeExtractorDart.extractorChannel
          .invokeMethod('getPlaylistDetails', {'playlistUrl': playlistUrl}),
    ) as Map;

    return YoutubePlaylist(
      info['id'],
      info['name'],
      info['url'],
      info['uploaderName'],
      Parse.imageList(info['uploaderAvatars']),
      info['uploaderUrl'],
      Parse.imageList(info['banners']),
      Parse.imageList(info['thumbnails']),
      Parse.integer(info['streamCount']),
    );
  }

  /// Extract the streams of the given playlist URL as [StreamInfoItem]s.
  static Future<List<StreamInfoItem>> getPlaylistStreams(
      String? playlistUrl) async {
    if (playlistUrl == null || StringChecker.hasWhiteSpace(playlistUrl)) {
      throw BadUrlException('Url is null or contains white space');
    }
    final info = await ReCaptchaPage.run(
      () => NewPipeExtractorDart.extractorChannel
          .invokeMethod('getPlaylistStreams', {'playlistUrl': playlistUrl}),
    );
    return StreamsParser.parseStreamListFromMap(info);
  }
}
