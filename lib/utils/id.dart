import 'package:newpipeextractor_dart/exceptions/badUrlException.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:newpipeextractor_dart/utils/stringChecker.dart';

class YoutubeId {

  static Future<String> getIdFromUrl(String url) async {
    if (url == null || StringChecker.hasWhiteSpace(url))
      throw BadUrlException("Url is null or contains white space");
    var id = await NewPipeExtractorDart.extractorChannel.invokeMethod('getIdFromUrl',
      {"url": url});
    return id['id'];
  }

}