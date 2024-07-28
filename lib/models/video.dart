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
  
  /// Gets the best quality video only stream
  /// (By resolution, fps is not taken in consideration)
  VideoOnlyStream? get videoOnlyWithHighestQuality {
    if (videoOnlyStreams == null)
      throw StreamIsNull("Tried to access a null VideoOnly stream");
    VideoOnlyStream? video;
    for (var i = 0; i < videoOnlyStreams!.length; i++) {
      if (video == null) {
        video = videoOnlyStreams![i];
      } else {
        int curRes = int.parse(video.resolution!.split("p").first);
        int newRes = int.parse(videoOnlyStreams![i].resolution!.split("p").first);
        if (curRes < newRes) {
          video = videoOnlyStreams![i];
        }
      }
    }
    return video;
  }

  /// Gets the best quality video stream
  /// (By resolution, fps is not taken in consideration)
  VideoStream? get videoWithHighestQuality {
    if (videoStreams == null)
      throw StreamIsNull("Tried to access a null Video stream");
    VideoStream? video;
    for (var i = 0; i < videoStreams!.length; i++) {
      if (video == null) {
        video = videoStreams![i];
      } else {
        int curRes = int.parse(video.resolution!.split("p").first);
        int newRes = int.parse(videoStreams![i].resolution!.split("p").first);
        if (curRes < newRes) {
          video = videoStreams![i];
        }
      }
    }
    return video;
  }

  /// Gets the best quality audio stream by Bitrate
  AudioOnlyStream? get audioWithHighestQuality {
    if (audioOnlyStreams == null)
      throw StreamIsNull("Tried to access a null Audio stream");
    AudioOnlyStream? audio;
    for (var i = 0; i < audioOnlyStreams!.length; i++) {
      if (audio == null) {
        audio = audioOnlyStreams![i];
      } else {
        int curBitrate = audio.averageBitrate;
        int newBitrate = audioOnlyStreams![i].averageBitrate;
        if (curBitrate < newBitrate) {
          audio = audioOnlyStreams![i];
        }
      }
    }
    return audio;
  }

  /// Gets the best AAC format audio stream
  AudioOnlyStream? get audioWithBestAacQuality {
    if (audioOnlyStreams == null)
      throw StreamIsNull("Tried to access a null Audio stream");
    List<AudioOnlyStream> newList = [];
    audioOnlyStreams!.forEach((element) {
      if (element.formatName == "m4a") {
        newList.add(element);
      }
    });
    if (newList.isEmpty)
      return audioWithHighestQuality;
    AudioOnlyStream? audio;
    for (var i = 0; i < newList.length; i++) {
      if (audio == null) {
        audio = newList[i];
      } else {
        int curBitrate = audio.averageBitrate;
        int newBitrate = newList[i].averageBitrate;
        if (curBitrate < newBitrate) {
          audio = newList[i];
        }
      }
    }
    return audio;
  }

  /// Gets the best OGG format audio stream
  AudioOnlyStream? get audioWithBestOggQuality {
    if (audioOnlyStreams == null)
      throw StreamIsNull("Tried to access a null Audio stream");
    List<AudioOnlyStream> newList = [];
    audioOnlyStreams!.forEach((element) {
      if (element.formatName == "webm") {
        newList.add(element);
      }
    });
    if (newList.isEmpty)
      return audioWithHighestQuality;
    AudioOnlyStream? audio;
    for (var i = 0; i < newList.length; i++) {
      if (audio == null) {
        audio = newList[i];
      } else {
        int curBitrate = audio.averageBitrate;
        int newBitrate = newList[i].averageBitrate;
        if (curBitrate < newBitrate) {
          audio = newList[i];
        }
      }
    }
    return audio;
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

