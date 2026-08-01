import 'dart:convert';

import 'package:newpipeextractor_dart/extractors/playlist.dart';
import 'package:newpipeextractor_dart/models/playlist.dart';
import 'package:newpipeextractor_dart/utils/parsing.dart';

class PlaylistInfoItem {

  /// Playlist URL
  final String? url;

  /// Playlist name
  final String? name;

  /// Playlist uploader channel name
  final String? uploaderName;

  /// Playlist thumbnail url
  final List<String>? thumbnails;

  /// Playlist videos count
  final int streamCount;

  PlaylistInfoItem(
    this.url,
    this.name,
    this.uploaderName,
    this.thumbnails,
    this.streamCount
  );

  /// Obtains the full information of the playlist
  /// into a YoutubePlaylist object
  Future<YoutubePlaylist> get getPlaylist async {
    return await PlaylistExtractor.getPlaylistDetails(url);
  }

  /// Transform this object toMap
  Map<dynamic, dynamic> toMap() {
    return {
      'url': url,
      'name': name,
      'uploaderName': uploaderName,
      'thumbnails': thumbnails,
      'streamCount': streamCount.toString()
    };
  }

  /// Get an object of PlaylistInfoItem from map
  ///
  /// `jsonDecode` hands back `List<dynamic>`, so reading the thumbnails
  /// straight into a `List<String>` used to throw a TypeError on every
  /// round-trip.
  static PlaylistInfoItem fromMap(Map<dynamic, dynamic> map) {
    return PlaylistInfoItem(
      map['url'],
      map['name'],
      map['uploaderName'],
      Parse.imageList(map['thumbnails']),
      Parse.integer(map['streamCount']),
    );
  }

  /// Get a list of PlaylistInfoItem from a simple (valid) json String
  static List<PlaylistInfoItem> fromJsonString(String jsonString) {
    final Map<String, dynamic> decodedMap = jsonDecode(jsonString);
    final List<dynamic>? list = decodedMap['listPlaylist'];
    if (list == null) return [];
    return [for (final element in list) PlaylistInfoItem.fromMap(element)];
  }

  /// Transform a list of PlaylistInfoItem into a simple json String
  static String listToJson(List<PlaylistInfoItem> list) {
    List<Map<dynamic, dynamic>> x = list
      .map((e) => 
        {
          'url': e.url,
          'name': e.name,
          'uploaderName': e.uploaderName,
          'thumbnails': e.thumbnails,
          'streamCount': e.streamCount.toString()
        }
      )
      .toList();
    Map<String, dynamic> map() => {'listPlaylist' : x};
    return jsonEncode(map());
  }

}