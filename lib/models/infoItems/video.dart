import 'dart:convert';

import 'package:newpipeextractor_dart/extractors/channels.dart';
import 'package:newpipeextractor_dart/extractors/videos.dart';
import 'package:newpipeextractor_dart/models/channel.dart';
import 'package:newpipeextractor_dart/models/video.dart';

class StreamInfoItem {

  /// Video URL
  final String url;

  /// Video name
  final String name;

  /// Video uploader Name
  final String uploaderName;

  /// Video uploader channel url
  final String uploaderUrl;

  /// Video date
  final String uploadDate;

  /// Video thumbnail url
  final String thumbnailUrl;

  /// Video duration in seconds (s)
  final int duration;

  /// Video view count
  final int viewCount;

  StreamInfoItem(
    this.url,
    this.name,
    this.uploaderName,
    this.uploaderUrl,
    this.uploadDate,
    this.thumbnailUrl,
    this.duration,
    this.viewCount
  );

  /// Gets full YoutubeVideo containing more Information and
  /// all necessary streams for Streaming and Downloading
  Future<YoutubeVideo> get getVideo async {
    return await VideoExtractor.getVideoInfoAndStreams(url);
  }

  /// Obtains the full information of the authors Channel
  /// into a YoutubeChannel object
  Future<YoutubeChannel> get getChannel async {
    return await ChannelExtractor.channelInfo(uploaderUrl);
  }

  /// Transform object toMap
  Map<dynamic, dynamic> toMap(StreamInfoItem infoItem) {
    return {
      'url': url,
      'name': name,
      'uploaderName': uploaderName,
      'uploaderUrl': uploaderUrl,
      'uploadDate': uploadDate,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration.toString(),
      'viewCount': viewCount.toString()
    };
  }

  /// Get StreamInfoItem object fromMap
  static StreamInfoItem fromMap(Map<dynamic, dynamic> map) {
    return StreamInfoItem(
      map['url'],
      map['name'],
      map['uploaderName'],
      map['uploaderUrl'],
      map['uploadDate'],
      map['thumbnailUrl'],
      int.parse(map['duration']),
      int.parse(map['viewCount'])
    );
  }

  /// Get a list of StreamInfoItem from a simple (valid) json String
  static List<StreamInfoItem> fromJsonString(String jsonString) {
    Map<String, dynamic> decodedMap = jsonDecode(jsonString);
    List<dynamic> list = decodedMap['listStream'];
    List<StreamInfoItem> streams = [];
    if (list == null) return [];
    list.forEach((element) {
      StreamInfoItem s = StreamInfoItem.fromMap(element);
      streams.add(s);
    });
    return streams;
  }

  /// Transform a list of StreamInfoItem into a simple json String
  static String listToJson(List<StreamInfoItem> list) {
    List<Map<String, String>> x = list
      .map((e) => 
        {
          'url': e.url,
          'name': e.name,
          'uploaderName': e.uploaderName,
          'uploaderUrl': e.uploaderUrl,
          'uploadDate': e.uploadDate,
          'thumbnailUrl': e.thumbnailUrl,
          'duration': e.duration.toString(),
          'viewCount': e.viewCount.toString()
        }
      )
      .toList();
    Map<String, dynamic> map() => {'listStream': x};
    return jsonEncode(map());
  }

}