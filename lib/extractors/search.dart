import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:newpipeextractor_dart/utils/streamsParser.dart';

class SearchExtractor {
  /// Search YouTube for the provided query.
  ///
  /// Returns a [YoutubeSearch] holding every [StreamInfoItem],
  /// [PlaylistInfoItem] and [ChannelInfoItem] found; call `getNextPage()` on it
  /// for more results.
  static Future<YoutubeSearch> searchYoutube(
      String query, List<String> filters) async {
    final info = await ReCaptchaPage.run(
      () => NewPipeExtractorDart.extractorChannel
          .invokeMethod('searchYoutube', {'query': query, 'filters': filters}),
    );
    final results = _parseSearchResults(info);
    return YoutubeSearch(
      query: query,
      searchVideos: results[0],
      searchPlaylists: results[1],
      searchChannels: results[2],
    );
  }

  /// Gets the next page of the current [searchYoutube] query.
  static Future<List<dynamic>> getNextPage() async {
    final info = await ReCaptchaPage.run(
      () => NewPipeExtractorDart.extractorChannel.invokeMethod('getNextPage'),
    );
    return _parseSearchResults(info);
  }

  /// Search YouTube Music for the provided query.
  static Future<YoutubeMusicSearch> searchYoutubeMusic(
      String query, List<String> filters) async {
    final info = await ReCaptchaPage.run(
      () => NewPipeExtractorDart.extractorChannel.invokeMethod(
          'searchYoutubeMusic', {'query': query, 'filters': filters}),
    );
    final results = _parseSearchResults(info);
    return YoutubeMusicSearch(
      query: query,
      searchVideos: results[0],
      searchPlaylists: results[1],
      searchChannels: results[2],
    );
  }

  /// Gets the next page of the current [searchYoutubeMusic] query.
  static Future<List<dynamic>> getNextMusicPage() async {
    final info = await ReCaptchaPage.run(
      () =>
          NewPipeExtractorDart.extractorChannel.invokeMethod('getNextMusicPage'),
    );
    return _parseSearchResults(info);
  }

  static List<dynamic> _parseSearchResults(dynamic info) {
    return StreamsParser.parseInfoItemListFromMap(info, singleList: false);
  }
}
