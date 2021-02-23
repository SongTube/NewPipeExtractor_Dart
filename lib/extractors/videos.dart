import 'package:newpipeextractor_dart/exceptions/badUrlException.dart';
import 'package:newpipeextractor_dart/models/streams/audioOnlyStream.dart';
import 'package:newpipeextractor_dart/models/video.dart';
import 'package:newpipeextractor_dart/models/streams/videoOnlyStream.dart';
import 'package:newpipeextractor_dart/models/streams/videoStream.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:newpipeextractor_dart/utils/stringChecker.dart';

class VideoExtractor {

  /// This functions retrieves a full [YoutubeVideo] object which
  /// has all the information from that video including all Video,
  /// Audio and Muxed Streams (Muxed = Video + Audio)
  static Future<YoutubeVideo> getVideoInfoAndStreams(String videoUrl) async {
    if (videoUrl == null || StringChecker.hasWhiteSpace(videoUrl))
      throw BadUrlException("Url is null or contains white space");
    var info = await NewPipeExtractorDart.extractorChannel.invokeMethod(
      "getVideoInfoAndStreams", { "videoUrl": videoUrl }
    );
    var informationMap = info[0];
    List<AudioOnlyStream> audioOnlyStreams = [];
    info[1].forEach((key, map) {
      audioOnlyStreams.add(
        AudioOnlyStream(
          map['torrentUrl'],
          map['url'],
          int.parse(map['averageBitrate']),
          map['formatName'],
          map['formatSuffix'],
          map['formatMimeType']
      ));
    });
    List<VideoOnlyStream> videoOnlyStreams = [];
    info[2].forEach((key, map) {
      videoOnlyStreams.add(
        VideoOnlyStream(
          map['torrentUrl'],
          map['url'],
          map['resolution'],
          map['formatName'],
          map['formatSuffix'],
          map['formatMimeType']
      ));
    });
    List<VideoStream> videoStreams = [];
    info[3].forEach((key, map) {
      videoStreams.add(
        VideoStream(
          map['torrentUrl'],
          map['url'],
          map['resolution'],
          map['formatName'],
          map['formatSuffix'],
          map['formatMimeType']
      ));
    });
    return YoutubeVideo(
      id: informationMap['id'],
      url: informationMap['url'],
      name: informationMap['name'],
      uploaderName: informationMap['uploaderName'],
      uploaderAvatarUrl: informationMap['uploaderAvatarUrl'],
      uploaderUrl: informationMap['uploaderUrl'],
      uploadDate: informationMap['uploadDate'],
      description: informationMap['description'],
      length: int.parse(informationMap['length']),
      viewCount: int.parse(informationMap['viewCount']),
      likeCount: int.parse(informationMap['likeCount']),
      dislikeCount: int.parse(informationMap['dislikeCount']),
      category: informationMap['category'],
      ageLimit: int.parse(informationMap['ageLimit']),
      thumbnailUrl: informationMap['thumbnailUrl'],
      videoOnlyStreams: videoOnlyStreams,
      audioOnlyStreams: audioOnlyStreams,
      videoStreams: videoStreams
    );
  }

  /// Retrieve only the Video Information
  static Future<YoutubeVideo> getVideoInformation(String videoUrl) async {
    if (videoUrl == null || StringChecker.hasWhiteSpace(videoUrl))
      throw BadUrlException("Url is null or contains white space");
    var informationMap = await NewPipeExtractorDart.extractorChannel.invokeMethod(
      "getVideoInformation", { "videoUrl": videoUrl }
    );
    return YoutubeVideo(
      id: informationMap['id'],
      url: informationMap['url'],
      name: informationMap['name'],
      uploaderName: informationMap['uploaderName'],
      uploaderAvatarUrl: informationMap['uploaderAvatarUrl'],
      uploaderUrl: informationMap['uploaderUrl'],
      uploadDate: informationMap['uploadDate'],
      description: informationMap['description'],
      length: int.parse(informationMap['length']),
      viewCount: int.parse(informationMap['viewCount']),
      likeCount: int.parse(informationMap['likeCount']),
      dislikeCount: int.parse(informationMap['dislikeCount']),
      category: informationMap['category'],
      ageLimit: int.parse(informationMap['ageLimit']),
      thumbnailUrl: informationMap['thumbnailUrl']
    );
  }

  /// Retrieve all Streams into a dynamic List with the following order:
  /// 
  /// [0] VideoOnlyStreams
  /// [1] AudioOnlyStreams
  /// [2] VideoStreams
  /// 
  static Future<List<dynamic>> getAllVideoStreams(String videoUrl) async {
    if (videoUrl == null || StringChecker.hasWhiteSpace(videoUrl))
      throw BadUrlException("Url is null or contains white space");
    var info = await NewPipeExtractorDart.extractorChannel.invokeMethod(
      "getAllVideoStreams", { "videoUrl": videoUrl }
    );
    return info;
  }
  
  /// Retrieve Video Only Streams
  static Future<List<VideoOnlyStream>> getVideoOnlyStreams(String videoUrl) async {
    if (videoUrl == null || StringChecker.hasWhiteSpace(videoUrl))
      throw BadUrlException("Url is null or contains white space");
    var info = await NewPipeExtractorDart.extractorChannel.invokeMethod(
      "getVideoOnlyStreams", { "videoUrl": videoUrl }
    );
    List<VideoOnlyStream> videoOnlyStreams = [];
    info.forEach((key, map) {
      videoOnlyStreams.add(
        VideoOnlyStream(
          map['torrentUrl'],
          map['url'],
          map['resolution'],
          map['formatName'],
          map['formatSuffix'],
          map['formatMimeType']
      ));
    });
    return videoOnlyStreams;
  }

  /// Retrieve Audio Only Streams
  static Future<List<AudioOnlyStream>> getAudioOnlyStreams(String videoUrl) async {
    if (videoUrl == null || StringChecker.hasWhiteSpace(videoUrl))
      throw BadUrlException("Url is null or contains white space");
    var info = await NewPipeExtractorDart.extractorChannel.invokeMethod(
      "getAudioOnlyStreams", { "videoUrl": videoUrl }
    );
    List<AudioOnlyStream> audioOnlyStreams = [];
    info.forEach((key, map) {
      audioOnlyStreams.add(
        AudioOnlyStream(
          map['torrentUrl'],
          map['url'],
          int.parse(map['averageBitrate']),
          map['formatName'],
          map['formatSuffix'],
          map['formatMimeType']
      ));
    });
    return audioOnlyStreams;
  }

  /// Retrieve Video Streams (Muxed = Video + Audio)
  static Future<List<VideoStream>> getVideoStreams(String videoUrl) async {
    if (videoUrl == null || StringChecker.hasWhiteSpace(videoUrl))
      throw BadUrlException("Url is null or contains white space");
    var info = await NewPipeExtractorDart.extractorChannel.invokeMethod(
      "getVideoStreams", { "videoUrl": videoUrl }
    );
    List<VideoStream> videoStreams = [];
    info.forEach((key, map) {
      videoStreams.add(
        VideoStream(
          map['torrentUrl'],
          map['url'],
          map['resolution'],
          map['formatName'],
          map['formatSuffix'],
          map['formatMimeType']
      ));
    });
    return videoStreams;
  }

}