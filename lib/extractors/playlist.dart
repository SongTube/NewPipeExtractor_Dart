import 'dart:convert';

import 'package:newpipeextractor_dart/exceptions/badUrlException.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';
import 'package:newpipeextractor_dart/models/playlist.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:newpipeextractor_dart/utils/reCaptcha.dart';
import 'package:newpipeextractor_dart/utils/streamsParser.dart';
import 'package:newpipeextractor_dart/utils/stringChecker.dart';

class PlaylistExtractor {

  /// Extract all the details of the given Playlist URL into a YoutubePlaylist object
  static Future<YoutubePlaylist> getPlaylistDetails(String? playlistUrl) async {
    if (playlistUrl == null || StringChecker.hasWhiteSpace(playlistUrl))
      throw BadUrlException("Url is null or contains white space");
    Future<dynamic> task() => NewPipeExtractorDart.extractorChannel.invokeMethod(
      "getPlaylistDetails", { "playlistUrl": playlistUrl }
    );
    var info = await task();
    // Check if we got reCaptcha needed response
    info = await ReCaptchaPage.checkInfo(info, task);
    return YoutubePlaylist(
      info['id'],
      info['name'],
      info['url'],
      info['uploaderName'],
      List<String>.from(jsonDecode(info['uploaderAvatars'])),
      info['uploaderUrl'],
      List<String>.from(jsonDecode(info['banners'])),
      List<String>.from(jsonDecode(info['thumbnails'])),
      int.parse(info['streamCount'])
    );
  }

  /// Extract all the Streams from the given Playlist URL
  /// as a list of StreamInfoItem
  static Future<List<StreamInfoItem>> getPlaylistStreams(String? playlistUrl) async {
    if (playlistUrl == null || StringChecker.hasWhiteSpace(playlistUrl))
      throw BadUrlException("Url is null or contains white space");
    Future<dynamic> task() => NewPipeExtractorDart.extractorChannel.invokeMethod(
      "getPlaylistStreams", { "playlistUrl": playlistUrl }
    );
    var info = await task();
    // Check if we got reCaptcha needed response
    info = await ReCaptchaPage.checkInfo(info, task);
    return StreamsParser.parseStreamListFromMap(info);
  }
}