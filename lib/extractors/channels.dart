import 'package:newpipeextractor_dart/exceptions/badUrlException.dart';
import 'package:newpipeextractor_dart/models/channel.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:newpipeextractor_dart/utils/httpClient.dart';
import 'package:newpipeextractor_dart/utils/streamsParser.dart';
import 'package:newpipeextractor_dart/utils/stringChecker.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

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
    return StreamsParser.parseStreamListFromMap(info);
  }
 
  /// Retrieve high quality Channel Avatar URL
  static Future<String> getAvatarUrl(String channelId) async {
    var url = 'https://www.youtube.com/channel/$channelId?hl=en';
    var client = http.Client();
    var response = await client.get(url, headers: ExtractorHttpClient.defaultHeaders);
    var raw = response.body;
    return parser.parse(raw)
      .querySelector('meta[property="og:image"]')
      ?.attributes['content'];
  }

}