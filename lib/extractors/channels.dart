import 'package:newpipeextractor_dart/exceptions/badUrlException.dart';
import 'package:newpipeextractor_dart/models/channel.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:newpipeextractor_dart/utils/stringChecker.dart';

class ChannelExtractor {

  // Retrieve all ChannelInfo and
  // build it into our own Model
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

}