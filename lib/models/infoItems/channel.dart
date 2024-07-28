import 'dart:convert';

import 'package:newpipeextractor_dart/extractors/channels.dart';
import 'package:newpipeextractor_dart/models/channel.dart';

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
      'thumbnailUrl': thumbnails,
      'subscriberCount': subscriberCount.toString(),
      'streamCount': streamCount.toString()
    };
  }

  /// Get ChannelInfoItem object fromMap
  static ChannelInfoItem fromMap(Map<dynamic, dynamic> map) {
    return ChannelInfoItem(
      map['url'],
      map['name'],
      map['description'],
      map['thumbnailUrl'],
      int.parse(map['subscriberCount']),
      int.parse(map['streamCount'])
    );
  }

  /// Get a list of ChannelInfoItem from a simple (valid) json String
  static List<ChannelInfoItem> fromJsonString(String jsonString) {
    Map<dynamic, dynamic> decodedMap = jsonDecode(jsonString);
    List<dynamic>? list = decodedMap['listChannels'];
    List<ChannelInfoItem> channels = [];
    if (list == null) return [];
    list.forEach((element) {
      ChannelInfoItem c = ChannelInfoItem.fromMap(element);
      channels.add(c);
    });
    return channels;
  }

  /// Transform a list of ChannelInfoItem to a simple json String
  static String listToJson(List<ChannelInfoItem> list) {
    List<Map<dynamic, dynamic>> x = list
      .map((e) => 
        {
          'url': e.url,
          'name': e.name,
          'description': e.description,
          'thumbnailUrl': e.thumbnails,
          'subscriberCount': e.subscriberCount.toString(),
          'streamCount': e.streamCount.toString()
        }
      )
      .toList();
    Map<String, dynamic> map() => {'listChannels': x};
    return jsonEncode(map());
  }

}