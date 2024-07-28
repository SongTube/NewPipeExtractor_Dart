import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:newpipeextractor_dart/utils/reCaptcha.dart';
import 'package:newpipeextractor_dart/utils/streamsParser.dart';

class SearchExtractor {

  /// Search on Youtube for the provided Query, this will return
  /// a YoutubeSearch object which will contain all StreamInfoItem,
  /// PlaylistInfoItem and ChannelInfoItem found, you can then query
  /// for more results running that object [getNextPage()] function
  static Future<YoutubeSearch> searchYoutube(String query, List<String> filters) async {
    Future<dynamic> task() => NewPipeExtractorDart.extractorChannel.invokeMethod(
      "searchYoutube", { "query": query, "filters": filters }
    );
    var info = await task();
    // Check if we got reCaptcha needed response
    info = await ReCaptchaPage.checkInfo(info, task);
    var parsedList = _parseSearchResults(info);
    return YoutubeSearch(
      query: query,
      searchVideos: parsedList[0],
      searchPlaylists: parsedList[1],
      searchChannels: parsedList[2]
    );
  }

  /// Gets the next page of the current YoutubeSearch Query
  static Future<List<dynamic>> getNextPage() async {
    Future<dynamic> task() => NewPipeExtractorDart.extractorChannel.invokeMethod("getNextPage");
    var info = await task();
    // Check if we got reCaptcha needed response
    info = await ReCaptchaPage.checkInfo(info, task);
    return _parseSearchResults(info);
  }

  /// Search on YoutubeMusic for the provided Query, this will return
  /// a YoutubeSearch object which will contain all StreamInfoItem,
  /// PlaylistInfoItem and ChannelInfoItem found, you can then query
  /// for more results running that object [getNextPage()] function
  static Future<YoutubeMusicSearch> searchYoutubeMusic(String query, List<String> filters) async {
    Future<dynamic> task() => NewPipeExtractorDart.extractorChannel.invokeMethod(
      "searchYoutubeMusic", { "query": query, "filters": filters }
    );
    var info = await task();
    // Check if we got reCaptcha needed response
    info = await ReCaptchaPage.checkInfo(info, task);
    var parsedList = _parseSearchResults(info);
    return YoutubeMusicSearch(
      query: query,
      searchVideos: parsedList[0],
      searchPlaylists: parsedList[1],
      searchChannels: parsedList[2]
    );
  }

  /// Gets the next page of the current YoutubeMusicSearch Query
  static Future<List<dynamic>> getNextMusicPage() async {
    Future<dynamic> task() => NewPipeExtractorDart.extractorChannel.invokeMethod("getNextMusicPage");
    var info = await task();
    // Check if we got reCaptcha needed response
    info = await ReCaptchaPage.checkInfo(info, task);
    return _parseSearchResults(info);
  }

  static List<dynamic> _parseSearchResults(info) {
    return StreamsParser.parseInfoItemListFromMap(info, singleList: false);
  }

}