import 'package:newpipeextractor_dart/extractors/channels.dart';
import 'package:newpipeextractor_dart/models/channel.dart';

class ChannelInfoItem {

  /// Channel URL
  final String url;

  /// Channel name
  final String name;

  /// Channel description
  final String description;

  /// Channel avatar url
  final String thumbnailUrl;

  /// Channel subscriber count
  final int subscriberCount;

  /// Channel number of videos uploaded
  final int streamCount;

  ChannelInfoItem(
    this.url,
    this.name,
    this.description,
    this.thumbnailUrl,
    this.subscriberCount,
    this.streamCount
  );

  /// Obtains the full information of the channel
  /// into a YoutubeChannel object
  Future<YoutubeChannel> get getChannel async {
    return ChannelExtractor.channelInfo(url);
  }

}