import 'dart:convert';

import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';

class StreamsParser {

  /// Retrieves a list of different types of InfoItems from the method channel response map
  static List<dynamic> parseInfoItemListFromMap(info, {required bool singleList}) {
    if ((info as Map).containsKey("error")) {
      print(info["error"]);
      return [];
    }
    List<StreamInfoItem> listVideos = StreamsParser
      .parseStreamListFromMap(info['streams']);
    List<PlaylistInfoItem> listPlaylists = [];
    info['playlists'].forEach((_, map) {
      listPlaylists.add(PlaylistInfoItem(
        map['url'],
        map['name'],
        map['uploaderName'],
        map.containsKey('thumbnails') ? List<String>.from(jsonDecode(map['thumbnails'])) : [],
        int.parse(map['streamCount'])
      ));
    });
    List<ChannelInfoItem> listChannels = [];
    info['channels'].forEach((_, map) {
      listChannels.add(ChannelInfoItem(
        map['url'], 
        map['name'],
        map['description'],
        map.containsKey('thumbnails') ? List<String>.from(jsonDecode(map['thumbnails'])) : [],
        int.parse(map['subscriberCount']),
        int.parse(map['streamCount'])
      ));
    });
    if (singleList) {
      return <dynamic>[...listPlaylists, ...listVideos];
    } else {
      return [
        listVideos,
        listPlaylists,
        listChannels
      ];
    }
  }

  /// Retrieves a list of StreamInfoItem from the method channel response map
  static List<StreamInfoItem> parseStreamListFromMap(info) {
    List<StreamInfoItem> streams = [];
    info.forEach((_, map) {
      streams.add(StreamInfoItem(
        map['url'],
        map['id'],
        map['name'],
        map['uploaderName'],
        map['uploaderUrl'],
        map.containsKey('uploaderAvatars') ? List<String>.from(jsonDecode(map['uploaderAvatars'])) : [],
        map['uploadDate'],
        map['date'],
        int.parse(map['duration']),
        int.parse(map['viewCount'])
      ));
    });
    return streams;
  }

  /// Retrieves a list of StreamSegment from Map
  static List<StreamSegment> parseStreamSegmentListFromMap(info) {
    List<StreamSegment> segments = <StreamSegment>[];
    info.forEach((_, map) {
      segments.add(StreamSegment(
        map['url'],
        map['title'],
        map['previewUrl'],
        int.parse(map['startTimeSeconds'])
      ));
    });
    return segments;
  }

}