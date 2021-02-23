import 'package:newpipeextractor_dart/utils/contentLength.dart';

class AudioOnlyStream {

  String torrentUrl;
  String url;
  int averageBitrate;
  String formatName;
  String formatSuffix;
  String formatMimeType;
  int size;

  AudioOnlyStream(
    this.torrentUrl,
    this.url,
    this.averageBitrate,
    this.formatName,
    this.formatSuffix,
    this.formatMimeType,
  );

  Future<void> get getStreamSize async {
    size = await ContentLength.getContentLength(url);
  }

}