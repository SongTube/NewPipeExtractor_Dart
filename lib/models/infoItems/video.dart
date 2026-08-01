import 'dart:convert';

import 'package:newpipeextractor_dart/extractors/channels.dart';
import 'package:newpipeextractor_dart/extractors/videos.dart';
import 'package:newpipeextractor_dart/models/channel.dart';
import 'package:newpipeextractor_dart/models/video.dart';
import 'package:newpipeextractor_dart/utils/parsing.dart';
import 'package:newpipeextractor_dart/utils/thumbnails.dart';

class StreamInfoItem {

  /// Video URL
  final String? url;

  /// Video ID
  final String? id;

  /// Video name
  final String? name;

  /// Video uploader Name
  final String? uploaderName;

  /// Video uploader channel url
  final String? uploaderUrl;

  /// Video uploader avatars
  final List<String>? uploaderAvatars;

  /// Video date
  final String? uploadDate;

  /// Video full date
  final String? date;

  /// Video duration in seconds (s)
  final int? duration;

  /// Video view count
  final int? viewCount;

  StreamInfoItem(
    this.url,
    this.id,
    this.name,
    this.uploaderName,
    this.uploaderUrl,
    this.uploaderAvatars,
    this.uploadDate,
    this.date,
    this.duration,
    this.viewCount
  ) {
    thumbnails = StreamThumbnail(id);
  }

  /// Stream Thumbnails
  StreamThumbnail? thumbnails;

  /// Gets full YoutubeVideo containing more Information and
  /// all necessary streams for Streaming and Downloading
  Future<YoutubeVideo> get getVideo async {
    return await VideoExtractor.getStream(url);
  }

  /// Obtains the full information of the authors Channel
  /// into a YoutubeChannel object
  Future<YoutubeChannel> get getChannel async {
    return await ChannelExtractor.channelInfo(uploaderUrl);
  }

  /// Transform object toMap
  Map<dynamic, dynamic> toMap() {
    return {
      'url': url,
      'id': id,
      'name': name,
      'uploaderName': uploaderName,
      'uploaderUrl': uploaderUrl,
      'uploaderAvatars': uploaderAvatars,
      'uploadDate': uploadDate,
      'date': date,
      'duration': duration.toString(),
      'viewCount': viewCount.toString()
    };
  }

  /// Get StreamInfoItem object fromMap
  ///
  /// Uses tolerant parsing: `int.parse` threw whenever a count was absent, and
  /// `List<String>.from` threw on the `List<dynamic>` that `jsonDecode` returns.
  static StreamInfoItem fromMap(Map<dynamic, dynamic> map) {
    return StreamInfoItem(
      map['url'],
      map['id'],
      map['name'],
      map['uploaderName'],
      map['uploaderUrl'],
      Parse.imageList(map['uploaderAvatars']),
      map['uploadDate'],
      map['date'],
      Parse.integer(map['duration']),
      Parse.integer(map['viewCount']),
    );
  }

  /// Get a list of StreamInfoItem from a simple (valid) json String
  static List<StreamInfoItem> fromJsonString(String jsonString) {
    final Map<String, dynamic> decodedMap = jsonDecode(jsonString);
    final List<dynamic>? list = decodedMap['listStream'];
    if (list == null) return [];
    return [for (final element in list) StreamInfoItem.fromMap(element)];
  }

  /// Transform a list of StreamInfoItem into a simple json String
  static String listToJson(List<StreamInfoItem> list) {
    List<Map<String, dynamic>> x = list
      .map((e) => 
        {
          'url': e.url,
          'id': e.id,
          'name': e.name,
          'uploaderName': e.uploaderName,
          'uploaderUrl': e.uploaderUrl,
          'uploaderAvatars': e.uploaderAvatars,
          'uploadDate': e.uploadDate,
          'date': e.date,
          'duration': e.duration.toString(),
          'viewCount': e.viewCount.toString()
        }
      )
      .toList();
    Map<String, dynamic> map() => {'listStream': x};
    return jsonEncode(map());
  }

}