import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:newpipeextractor_dart/utils/httpClient.dart';
import 'package:newpipeextractor_dart/utils/parsing.dart';
import 'package:newpipeextractor_dart/utils/streamsParser.dart';
import 'package:newpipeextractor_dart/utils/stringChecker.dart';

class ChannelExtractor {
  /// Retrieve all channel info and build it into our own model.
  static Future<YoutubeChannel> channelInfo(String? url) async {
    if (url == null || StringChecker.hasWhiteSpace(url)) {
      throw BadUrlException('Url is null or contains white space');
    }
    final channel = await ReCaptchaPage.run(
      () => NewPipeExtractorDart.extractorChannel
          .invokeMethod('getChannel', {'channelUrl': url}),
    ) as Map;

    return YoutubeChannel(
      id: channel['id'],
      name: channel['name'],
      url: channel['url'],
      avatars: Parse.imageList(channel['avatars']),
      banners: Parse.imageList(channel['banners']),
      description: channel['description'],
      feedUrl: channel['feedUrl'],
      subscriberCount: Parse.nullableInteger(channel['subscriberCount']),
    );
  }

  /// Retrieve uploads from a channel URL.
  static Future<List<StreamInfoItem>> getChannelUploads(String url) async {
    if (StringChecker.hasWhiteSpace(url)) {
      throw BadUrlException('Url is null or contains white space');
    }
    final info = await ReCaptchaPage.run(
      () => NewPipeExtractorDart.extractorChannel
          .invokeMethod('getChannelUploads', {'channelUrl': url}),
    );
    return StreamsParser.parseStreamListFromMap(info);
  }

  /// Retrieve the next page of channel uploads.
  ///
  /// Requires a preceding [getChannelUploads] call: the page cursor lives on
  /// the native side.
  static Future<List<StreamInfoItem>> getChannelNextUploads() async {
    final info = await ReCaptchaPage.run(
      () => NewPipeExtractorDart.extractorChannel
          .invokeMethod('getChannelNextPage'),
    );
    return StreamsParser.parseStreamListFromMap(info);
  }

  /// Retrieve a high quality channel avatar URL.
  static Future<String?> getAvatarUrl(String channelId) async {
    final url = 'https://www.youtube.com/channel/$channelId?hl=en';
    final client = http.Client();
    try {
      final response = await client.get(Uri.parse(url),
          headers: ExtractorHttpClient.defaultHeaders);
      return parser
          .parse(response.body)
          .querySelector('meta[property="og:image"]')
          ?.attributes['content'];
    } finally {
      client.close();
    }
  }
}
