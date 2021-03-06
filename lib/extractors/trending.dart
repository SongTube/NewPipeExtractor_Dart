import 'package:newpipeextractor_dart/models/infoItems/video.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:newpipeextractor_dart/utils/reCaptcha.dart';
import 'package:newpipeextractor_dart/utils/streamsParser.dart';

class TrendingExtractor {

  /// Returns a list of StreamInfoItem containing Trending Videos
  static Future<List<StreamInfoItem>> getTrendingVideos() async {
    Future<dynamic> task() => NewPipeExtractorDart.extractorChannel.invokeMethod("getTrendingStreams");
    var info = await task();
    // Check if we got reCaptcha needed response
    info = await ReCaptchaPage.checkInfo(info, task);
    return StreamsParser.parseStreamListFromMap(info);
  }

}