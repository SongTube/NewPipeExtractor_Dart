import 'dart:convert';

import 'package:newpipeextractor_dart/extractors/channels.dart';
import 'package:newpipeextractor_dart/models/channel.dart';
import 'package:newpipeextractor_dart/utils/parsing.dart';

class ChannelInfoItem {

  /// Channel URL
  final String? url;

  /// Channel name
  final String? name;

  /// Channel description
  final String? description;

  /// Channel avatar url
  final List<String>? thumbnails;

  /// Channel subscriber count
  final int? subscriberCount;

  /// Channel number of videos uploaded
  final int streamCount;

  ChannelInfoItem(
    this.url,
    this.name,
    this.description,
    this.thumbnails,
    this.subscriberCount,
    this.streamCount
  );

  /// Obtains the full information of the channel
  /// into a YoutubeChannel object
  Future<YoutubeChannel> get getChannel async {
    return ChannelExtractor.channelInfo(url);
  }

  /// Transform object toMap
  Map<dynamic, dynamic> toMap() {
    return {
      'url': url,
      'name': name,
      'description': description,
      'thumbnails': thumbnails,
      'subscriberCount': subscriberCount.toString(),
      'streamCount': streamCount.toString()
    };
  }

  /// Get ChannelInfoItem object fromMap
  ///
  /// `jsonDecode` hands back `List<dynamic>`, so reading the thumbnails
  /// straight into a `List<String>` used to throw a TypeError on every
  /// round-trip; and a null count made `int.parse` throw on "null".
  static ChannelInfoItem fromMap(Map<dynamic, dynamic> map) {
    return ChannelInfoItem(
      map['url'],
      map['name'],
      map['description'],
      // 'thumbnails' is what toMap has written since 0.1.0; 'thumbnailUrl' is
      // read for data persisted by older versions.
      Parse.imageList(map['thumbnails'] ?? map['thumbnailUrl']),
      Parse.nullableInteger(map['subscriberCount']),
      Parse.integer(map['streamCount']),
    );
  }

  /// Get a list of ChannelInfoItem from a simple (valid) json String
  static List<ChannelInfoItem> fromJsonString(String jsonString) {
    final Map<dynamic, dynamic> decodedMap = jsonDecode(jsonString);
    final List<dynamic>? list = decodedMap['listChannels'];
    if (list == null) return [];
    return [for (final element in list) ChannelInfoItem.fromMap(element)];
  }

  /// Transform a list of ChannelInfoItem to a simple json String
  static String listToJson(List<ChannelInfoItem> list) {
    List<Map<dynamic, dynamic>> x = list
      .map((e) => 
        {
          'url': e.url,
          'name': e.name,
          'description': e.description,
          'thumbnails': e.thumbnails,
          'subscriberCount': e.subscriberCount.toString(),
          'streamCount': e.streamCount.toString()
        }
      )
      .toList();
    Map<String, dynamic> map() => {'listChannels': x};
    return jsonEncode(map());
  }

}