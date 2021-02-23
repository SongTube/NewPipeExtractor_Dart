import 'package:newpipeextractor_dart/utils/contentLength.dart';

class VideoStream {

  String torrentUrl;
  String url;
  String resolution;
  String formatName;
  String formatSuffix;
  String formatMimeType;
  int size;

  VideoStream(
    this.torrentUrl,
    this.url,
    this.resolution,
    this.formatName,
    this.formatSuffix,
    this.formatMimeType,
  );

  Future<void> get getStreamSize async {
    size = await ContentLength.getContentLength(url);
  }

}