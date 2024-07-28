import 'dart:convert';

import 'package:newpipeextractor_dart/exceptions/badUrlException.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:newpipeextractor_dart/utils/httpClient.dart';
import 'package:newpipeextractor_dart/utils/reCaptcha.dart';
import 'package:newpipeextractor_dart/utils/streamsParser.dart';
import 'package:newpipeextractor_dart/utils/stringChecker.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

class ChannelExtractor {

  /// Retrieve all ChannelInfo and
  /// build it into our own Model
  static Future<YoutubeChannel> channelInfo(String? url) async {
    if (url == null || StringChecker.hasWhiteSpace(url))
      throw BadUrlException("Url is null or contains white space");
    Future<dynamic> task() => NewPipeExtractorDart.extractorChannel.invokeMethod('getChannel', {
      "channelUrl": url
    });
    var channel = await task();
    // Check if we got reCaptcha needed response
    channel = await ReCaptchaPage.checkInfo(channel, task);
    return YoutubeChannel(
      id: channel['id'],
      name: channel['name'],
      url: channel['url'],
      avatars: List<String>.from(jsonDecode(channel['avatars'])),
      banners: List<String>.from(jsonDecode(channel['banners'])),
      description: channel['description'],
      feedUrl: channel['feedUrl'],
      subscriberCount: int.parse(channel['subscriberCount'])
    );
  }

  /// Retrieve uploads from a Channel URL
  static Future<List<StreamInfoItem>> getChannelUploads(String url) async {
    if (StringChecker.hasWhiteSpace(url))
      throw BadUrlException("Url is null or contains white space");
    Future<dynamic> task() => NewPipeExtractorDart.extractorChannel.invokeMethod(
      'getChannelUploads', { "channelUrl": url }
    );
    var info = await task();
    // Check if we got reCaptcha needed response
    info = await ReCaptchaPage.checkInfo(info, task);
    return StreamsParser.parseStreamListFromMap(info);
  }
 
  /// Retrieve next page from channel uploads
  static Future<List<StreamInfoItem>> getChannelNextUploads() async {
    Future<dynamic> task() => NewPipeExtractorDart.extractorChannel.invokeMethod('getChannelNextPage');
    var info = await task();
    // Check if we got reCaptcha needed response
    info = await ReCaptchaPage.checkInfo(info, task);
    return StreamsParser.parseStreamListFromMap(info);
  } 

  /// Retrieve high quality Channel Avatar URL
  static Future<String?> getAvatarUrl(String channelId) async {
    var url = 'https://www.youtube.com/channel/$channelId?hl=en';
    var client = http.Client();
    var response = await client.get(Uri.parse(url), headers: ExtractorHttpClient.defaultHeaders);
    var raw = response.body;
    return parser.parse(raw)
      .querySelector('meta[property="og:image"]')
      ?.attributes['content'];
  }

}