import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:newpipeextractor_dart/utils/stringChecker.dart';

class YoutubeId {
  /// Get the ID from any stream URL; returns null on failure.
  static Future<String?> getIdFromStreamUrl(String url) =>
      _id('getIdFromStreamUrl', 'streamUrl', url);

  /// Get the ID from any playlist URL; returns null on failure.
  static Future<String?> getIdFromPlaylistUrl(String url) =>
      _id('getIdFromPlaylistUrl', 'playlistUrl', url);

  /// Get the ID from any channel URL; returns null on failure.
  static Future<String?> getIdFromChannelUrl(String url) =>
      _id('getIdFromChannelUrl', 'channelUrl', url);

  static Future<String?> _id(String method, String argument, String url) async {
    if (StringChecker.hasWhiteSpace(url)) {
      throw BadUrlException('Url is null or contains white space');
    }
    final result = await NewPipeExtractorDart.extractorChannel
        .invokeMapMethod<String, String>(method, {argument: url});
    final id = result?['id'];
    return (id == null || id.isEmpty) ? null : id;
  }
}
