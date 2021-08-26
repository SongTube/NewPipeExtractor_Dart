import 'package:newpipeextractor_dart/utils/httpClient.dart';

class AudioOnlyStream {

  String? torrentUrl;
  String? url;
  int averageBitrate;
  String? formatName;
  String? formatSuffix;
  String? formatMimeType;
  int? size;

  AudioOnlyStream(
    this.torrentUrl,
    this.url,
    this.averageBitrate,
    this.formatName,
    this.formatSuffix,
    this.formatMimeType,
  );

  Future<void> getContentSize() async { 
    size = await ExtractorHttpClient.getContentLength(url!);
  }

  double get totalKiloBytes => size! / 1024;

  double get totalMegaBytes => totalKiloBytes / 1024;

  double get totalGigaBytes => totalMegaBytes / 1024;
  
}