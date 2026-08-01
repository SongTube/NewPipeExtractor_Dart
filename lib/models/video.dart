import 'package:newpipeextractor_dart/exceptions/streamIsNull.dart';
import 'package:newpipeextractor_dart/extractors/videos.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';
import 'package:newpipeextractor_dart/models/streamSegment.dart';
import 'package:newpipeextractor_dart/models/streams/audioOnlyStream.dart';
import 'package:newpipeextractor_dart/models/streams/videoOnlyStream.dart';
import 'package:newpipeextractor_dart/models/streams/videoStream.dart';
import 'package:newpipeextractor_dart/models/videoInfo.dart';

class YoutubeVideo {

  /// Video Information
  VideoInfo videoInfo;

  /// Video Only Streams
  List<VideoOnlyStream>? videoOnlyStreams;

  /// Audio Only Streams
  List<AudioOnlyStream>? audioOnlyStreams;

  /// Video Streams (Muxed, Video + Audio)
  List<VideoStream>? videoStreams;

  // Video Segments
  List<StreamSegment>? segments;

  YoutubeVideo({
    required this.videoInfo,
    this.videoOnlyStreams,
    this.audioOnlyStreams,
    this.videoStreams,
    this.segments
  });

  /// Transform this object into a StreamInfoItem which is smaller and
  /// allows saving or transporting it via Strings
  StreamInfoItem toStreamInfoItem() {
    return StreamInfoItem(
      videoInfo.url,
      videoInfo.id,
      videoInfo.name,
      videoInfo.uploaderName,
      videoInfo.uploaderUrl,
      videoInfo.uploaderAvatars,
      videoInfo.uploadDate,
      videoInfo.uploadDate,
      videoInfo.length,
      videoInfo.viewCount
    );
  }

  /// If an instance of this object has no streams (Information only)
  /// then, this function will retrieve those streams and return a new
  /// [YoutubeVideo] object
  Future<YoutubeVideo> get getStreams async =>
    await VideoExtractor.getStream(videoInfo.url);
  
  /// Vertical pixel count parsed out of a resolution label such as
  /// `1080p60`. Returns -1 when the extractor could not label the stream, so
  /// unlabelled streams sort last instead of throwing -- `resolution` is
  /// nullable and these getters used to force-unwrap it.
  static int _resolutionHeight(String? resolution) {
    if (resolution == null) return -1;
    final digits = RegExp(r'^\d+').firstMatch(resolution)?.group(0);
    return digits == null ? -1 : int.parse(digits);
  }

  static T? _best<T>(List<T>? streams, int Function(T) rank, String onNull) {
    if (streams == null) throw StreamIsNull(onNull);
    T? best;
    for (final stream in streams) {
      if (best == null || rank(best) < rank(stream)) best = stream;
    }
    return best;
  }

  /// Gets the best quality video only stream
  /// (By resolution, fps is not taken in consideration)
  VideoOnlyStream? get videoOnlyWithHighestQuality => _best(
        videoOnlyStreams,
        (s) => _resolutionHeight(s.resolution),
        'Tried to access a null VideoOnly stream',
      );

  /// Gets the best quality video stream
  /// (By resolution, fps is not taken in consideration)
  VideoStream? get videoWithHighestQuality => _best(
        videoStreams,
        (s) => _resolutionHeight(s.resolution),
        'Tried to access a null Video stream',
      );

  /// Gets the best quality audio stream by Bitrate
  AudioOnlyStream? get audioWithHighestQuality => _best(
        audioOnlyStreams,
        (s) => s.averageBitrate,
        'Tried to access a null Audio stream',
      );

  /// Gets the best AAC format audio stream
  AudioOnlyStream? get audioWithBestAacQuality => _bestOfFormat('m4a');

  /// Gets the best OGG format audio stream
  AudioOnlyStream? get audioWithBestOggQuality => _bestOfFormat('webm');

  AudioOnlyStream? _bestOfFormat(String formatName) {
    if (audioOnlyStreams == null) {
      throw StreamIsNull('Tried to access a null Audio stream');
    }
    final matching = audioOnlyStreams!
        .where((element) => element.formatName == formatName)
        .toList();
    if (matching.isEmpty) return audioWithHighestQuality;
    return _best(matching, (s) => s.averageBitrate, '');
  }

  /// Get the best audio stream for the specified video stream
  /// taking in consideration the video stream format
  /// (MP4 supports AAC codec while WEBM supports OGG codec)
  AudioOnlyStream? getAudioStreamWithBestMatchForVideoStream(VideoOnlyStream stream) {
    if (stream.formatSuffix == "mp4") {
      return audioWithBestAacQuality;
    } else if (stream.formatSuffix == "webm") {
      return audioWithBestOggQuality;
    } else {
      return null;
    }
  }

}

