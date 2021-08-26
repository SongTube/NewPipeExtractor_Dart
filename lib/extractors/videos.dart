import 'package:newpipeextractor_dart/exceptions/badUrlException.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';
import 'package:newpipeextractor_dart/models/streamSegment.dart';
import 'package:newpipeextractor_dart/models/streams/audioOnlyStream.dart';
import 'package:newpipeextractor_dart/models/video.dart';
import 'package:newpipeextractor_dart/models/streams/videoOnlyStream.dart';
import 'package:newpipeextractor_dart/models/streams/videoStream.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:newpipeextractor_dart/utils/reCaptcha.dart';
import 'package:newpipeextractor_dart/utils/streamsParser.dart';
import 'package:newpipeextractor_dart/utils/stringChecker.dart';

class VideoExtractor {

  /// This functions retrieves a full [YoutubeVideo] object which
  /// has all the information from that video including all Video,
  /// Audio and Muxed Streams (Muxed = Video + Audio)
  static Future<YoutubeVideo> getStream(String? videoUrl) async {
    if (videoUrl == null || StringChecker.hasWhiteSpace(videoUrl))
      throw BadUrlException("Url is null or contains white space");
    Future<dynamic> task() => NewPipeExtractorDart.extractorChannel.invokeMethod(
      "getVideoInfoAndStreams", { "videoUrl": videoUrl }
    );
    var info = await task();
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
          map['formatMimeType'],
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
          map['formatMimeType'],
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
          map['formatMimeType'],
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
      videoStreams: videoStreams,
      segments: StreamsParser.parseStreamSegmentListFromMap(info[4])
    );
  }

  /// Retrieve only the Video Information
  static Future<YoutubeVideo> getInfo(String videoUrl) async {
    if (videoUrl == null || StringChecker.hasWhiteSpace(videoUrl))
      throw BadUrlException("Url is null or contains white space");
    Future<dynamic> task() => NewPipeExtractorDart.extractorChannel.invokeMethod(
      "getVideoInformation", { "videoUrl": videoUrl }
    );
    var informationMap = await task();
    // Check if we got reCaptcha needed response
    informationMap = await ReCaptchaPage.checkInfo(informationMap, task);
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
  static Future<List<dynamic>?> getMediaStreams(String videoUrl) async {
    if (videoUrl == null || StringChecker.hasWhiteSpace(videoUrl))
      throw BadUrlException("Url is null or contains white space");
    Future<dynamic> task() => NewPipeExtractorDart.extractorChannel.invokeMethod(
      "getAllVideoStreams", { "videoUrl": videoUrl }
    );
    var info = await task();
    return info;
  }
  
  /// Retrieve Video Only Streams
  static Future<List<VideoOnlyStream>> getVideoOnlyStreams(String videoUrl) async {
    if (videoUrl == null || StringChecker.hasWhiteSpace(videoUrl))
      throw BadUrlException("Url is null or contains white space");
    Future<dynamic> task() => NewPipeExtractorDart.extractorChannel.invokeMethod(
      "getVideoOnlyStreams", { "videoUrl": videoUrl }
    );
    var info = await task();
    // Check if we got reCaptcha needed response
    info = await ReCaptchaPage.checkInfo(info, task);
    List<VideoOnlyStream> videoOnlyStreams = [];
    info.forEach((key, map) {
      videoOnlyStreams.add(
        VideoOnlyStream(
          map['torrentUrl'],
          map['url'],
          map['resolution'],
          map['formatName'],
          map['formatSuffix'],
          map['formatMimeType'],
      ));
    });
    return videoOnlyStreams;
  }

  /// Retrieve Audio Only Streams
  static Future<List<AudioOnlyStream>> getAudioOnlyStreams(String videoUrl) async {
    if (videoUrl == null || StringChecker.hasWhiteSpace(videoUrl))
      throw BadUrlException("Url is null or contains white space");
    Future<dynamic> task() => NewPipeExtractorDart.extractorChannel.invokeMethod(
      "getAudioOnlyStreams", { "videoUrl": videoUrl }
    );
    var info = await task();
    // Check if we got reCaptcha needed response
    info = await ReCaptchaPage.checkInfo(info, task);
    List<AudioOnlyStream> audioOnlyStreams = [];
    info.forEach((key, map) {
      audioOnlyStreams.add(
        AudioOnlyStream(
          map['torrentUrl'],
          map['url'],
          int.parse(map['averageBitrate']),
          map['formatName'],
          map['formatSuffix'],
          map['formatMimeType'],
      ));
    });
    return audioOnlyStreams;
  }

  /// Retrieve Video Streams (Muxed = Video + Audio)
  static Future<List<VideoStream>> getVideoStreams(String videoUrl) async {
    if (videoUrl == null || StringChecker.hasWhiteSpace(videoUrl))
      throw BadUrlException("Url is null or contains white space");
    Future<dynamic> task() => NewPipeExtractorDart.extractorChannel.invokeMethod(
      "getVideoStreams", { "videoUrl": videoUrl }
    );
    var info = await task();
    // Check if we got reCaptcha needed response
    info = await ReCaptchaPage.checkInfo(info, task);
    List<VideoStream> videoStreams = [];
    info.forEach((key, map) {
      videoStreams.add(
        VideoStream(
          map['torrentUrl'],
          map['url'],
          map['resolution'],
          map['formatName'],
          map['formatSuffix'],
          map['formatMimeType'],
      ));
    });
    return videoStreams;
  }

  /// Retrieve related videos by URL
  static Future<List<StreamInfoItem>> getRelatedStreams(String videoUrl) async {
    if (videoUrl == null || StringChecker.hasWhiteSpace(videoUrl))
      throw BadUrlException("Url is null or contains white space");
    Future<dynamic> task() => NewPipeExtractorDart.extractorChannel.invokeMethod(
      "getRelatedStreams", { "videoUrl": videoUrl }
    );
    var info = await task();
    // Check if we got reCaptcha needed response
    info = await ReCaptchaPage.checkInfo(info, task);
    return StreamsParser.parseStreamListFromMap(info);
  }

  /// Retrieves all stream segments from video URL
  static Future<List<StreamSegment>> getStreamSegments(String videoUrl) async {
    if (videoUrl == null || StringChecker.hasWhiteSpace(videoUrl))
      throw BadUrlException("Url is null or contains white space");
    Future<dynamic> task() => NewPipeExtractorDart.extractorChannel.invokeMethod(
      "getVideoSegments", { "videoUrl": videoUrl }
    );
    var info = await task();
    // Check if we got reCaptcha needed response
    info = await ReCaptchaPage.checkInfo(info, task);
    return StreamsParser.parseStreamSegmentListFromMap(info);
  }

}