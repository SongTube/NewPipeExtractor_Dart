/// Some videos might be segmented, if that is the case this
/// class will define the properties of each segment a stream contains
class StreamSegment {

  final String? url;
  final String? title;
  final String? previewUrl;
  final int startTimeSeconds;

  StreamSegment(
    this.url,
    this.title,
    this.previewUrl,
    this.startTimeSeconds
  );

  

}