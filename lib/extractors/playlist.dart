import 'package:newpipeextractor_dart/exceptions/badUrlException.dart';
import 'package:newpipeextractor_dart/models/infoItems/playlist.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';
import 'package:newpipeextractor_dart/models/playlist.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:newpipeextractor_dart/utils/streamsParser.dart';
import 'package:newpipeextractor_dart/utils/stringChecker.dart';

class PlaylistExtractor {

  /// Extract all the details of the given Playlist URL into a YoutubePlaylist object
  static Future<YoutubePlaylist> getPlaylistDetails(String playlistUrl) async {
    if (playlistUrl == null || StringChecker.hasWhiteSpace(playlistUrl))
      throw BadUrlException("Url is null or contains white space");
    var info = await NewPipeExtractorDart.extractorChannel.invokeMethod(
      "getPlaylistDetails", { "playlistUrl": playlistUrl }
    );
    return YoutubePlaylist(
      info['id'],
      info['name'],
      info['url'],
      info['uploaderName'],
      info['uploaderAvatarUrl'],
      info['uploaderUrl'],
      info['bannerUrl'],
      info['thumbnailUrl'],
      int.parse(info['streamCount'])
    );
  }

  /// Extract all the Streams from the given Playlist URL
  /// as a list of StreamInfoItem
  static Future<List<StreamInfoItem>> getPlaylistStreams(String playlistUrl) async {
    if (playlistUrl == null || StringChecker.hasWhiteSpace(playlistUrl))
      throw BadUrlException("Url is null or contains white space");
    var info = await NewPipeExtractorDart.extractorChannel.invokeMethod(
      "getPlaylistStreams", { "playlistUrl": playlistUrl }
    );
    return StreamsParser.parseStreamListFromMap(info);
  }

  /// Gets the next page of the current Playlist
  static Future<List<StreamInfoItem>> getNextPage() async {
    var info = await NewPipeExtractorDart.extractorChannel.invokeMethod(
      "getPlaylistNextPage",
    );
    return StreamsParser.parseStreamListFromMap(info);
  }

}