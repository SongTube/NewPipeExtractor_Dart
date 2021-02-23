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

  double get totalKiloBytes => size / 1024;

  double get totalMegaBytes => totalKiloBytes / 1024;

  double get totalGigaBytes => totalMegaBytes / 1024;

}