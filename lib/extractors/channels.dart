import 'package:newpipeextractor_dart/exceptions/badUrlException.dart';
import 'package:newpipeextractor_dart/models/channel.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:newpipeextractor_dart/utils/stringChecker.dart';

class ChannelExtractor {

  /// Retrieve all ChannelInfo and
  /// build it into our own Model
  static Future<YoutubeChannel> channelInfo(String url) async {
    if (url == null || StringChecker.hasWhiteSpace(url))
      throw BadUrlException("Url is null or contains white space");
    var channel = await NewPipeExtractorDart.extractorChannel.invokeMethod('getChannel', {
      "channelUrl": url
    });
    return YoutubeChannel(
      id: channel['id'],
      name: channel['name'],
      url: channel['url'],
      avatarUrl: channel['avatarUrl'],
      bannerUrl: channel['bannerUrl'],
      description: channel['description'],
      feedUrl: channel['feedUrl'],
      subscriberCount: int.parse(channel['subscriberCount'])
    );
  }

  /// Retrieve uploads from a Channel URL
  static Future<List<StreamInfoItem>> getChannelUploads(String url) async {
    if (url == null || StringChecker.hasWhiteSpace(url))
      throw BadUrlException("Url is null or contains white space");
    var info = await NewPipeExtractorDart.extractorChannel.invokeMethod(
      'getChannelUploads', { "channelUrl": url }
    );
    List<StreamInfoItem> streams = [];
    info.forEach((_, map) {
      streams.add(StreamInfoItem(
        map['url'],
        map['name'],
        map['uploaderName'],
        map['uploaderUrl'],
        map['uploadDate'],
        map['thumbnailUrl'],
        int.parse(map['duration']),
        int.parse(map['viewCount'])
      ));
    });
    return streams;
  }

}