import 'dart:convert';

import 'package:newpipeextractor_dart/exceptions/badUrlException.dart';
import 'package:newpipeextractor_dart/models/videoInfo.dart';
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
    final infoMap = Map<String, dynamic>.from(informationMap);
    return YoutubeVideo(
      videoInfo: VideoInfo(
        id: infoMap.containsKey('id') ? infoMap['id'] : null,
        url: infoMap.containsKey('url') ? infoMap['url'] : null,
        name: infoMap.containsKey('name') ? infoMap['name'] : null,
        uploaderName: infoMap.containsKey('uploaderName') ? infoMap['uploaderName'] : null,
        uploaderAvatars: infoMap.containsKey('uploaderAvatars') ? List<String>.from(jsonDecode(infoMap['uploaderAvatars'])) : null,
        uploaderUrl: infoMap.containsKey('uploaderUrl') ? infoMap['uploaderUrl'] : null,
        uploadDate: infoMap.containsKey('uploadDate') ? infoMap['uploadDate'] : null,
        description: infoMap.containsKey('description') ? infoMap['description']: null,
        length: infoMap.containsKey('length') ? int.parse(infoMap['length']) : null,
        viewCount: infoMap.containsKey('viewCount') ? int.parse(infoMap['viewCount']) : null,
        likeCount: infoMap.containsKey('likeCount') ? int.parse(infoMap['likeCount']) : null,
        dislikeCount: infoMap.containsKey('dislikeCount') ? int.parse(infoMap['dislikeCount']) : null,
        category: infoMap.containsKey('category') ? infoMap['category'] : null,
        ageLimit: infoMap.containsKey('ageLimit') ? int.parse(infoMap['ageLimit']) : null,
        thumbnails: infoMap.containsKey('thumbnails') ? List<String>.from(jsonDecode(infoMap['thumbnails'])) : null,
      ),
      videoOnlyStreams: videoOnlyStreams,
      audioOnlyStreams: audioOnlyStreams,
      videoStreams: videoStreams,
      segments: StreamsParser.parseStreamSegmentListFromMap(info[4])
    );
  }

  /// Retrieve only the Video Information
  static Future<YoutubeVideo> getInfo(String videoUrl) async {
    if (StringChecker.hasWhiteSpace(videoUrl))
      throw BadUrlException("Url is null or contains white space");
    Future<dynamic> task() => NewPipeExtractorDart.extractorChannel.invokeMethod(
      "getVideoInformation", { "videoUrl": videoUrl }
    );
    var informationMap = await task();
    // Check if we got reCaptcha needed response
    informationMap = await ReCaptchaPage.checkInfo(informationMap, task);
    return YoutubeVideo(
      videoInfo: VideoInfo.fromMap(Map<String, dynamic>.from(informationMap)),
    );
  }

  /// Retrieve all Streams into a dynamic List with the following order:
  /// 
  /// [0] VideoOnlyStreams
  /// [1] AudioOnlyStreams
  /// [2] VideoStreams
  /// 
  static Future<List<dynamic>?> getMediaStreams(String videoUrl) async {
    if (StringChecker.hasWhiteSpace(videoUrl))
      throw BadUrlException("Url is null or contains white space");
    Future<dynamic> task() => NewPipeExtractorDart.extractorChannel.invokeMethod(
      "getAllVideoStreams", { "videoUrl": videoUrl }
    );
    var info = await task();
    return info;
  }
  
  /// Retrieve Video Only Streams
  static Future<List<VideoOnlyStream>> getVideoOnlyStreams(String videoUrl) async {
    if (StringChecker.hasWhiteSpace(videoUrl))
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
    if (StringChecker.hasWhiteSpace(videoUrl))
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
    if (StringChecker.hasWhiteSpace(videoUrl))
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
  static Future<List<dynamic>> getRelatedStreams(String videoUrl) async {
    if (StringChecker.hasWhiteSpace(videoUrl))
      throw BadUrlException("Url is null or contains white space");
    Future<dynamic> task() => NewPipeExtractorDart.extractorChannel.invokeMethod(
      "getRelatedStreams", { "videoUrl": videoUrl }
    );
    var info = await task();
    // Check if we got reCaptcha needed response
    info = await ReCaptchaPage.checkInfo(info, task);
    return StreamsParser.parseInfoItemListFromMap(info, singleList: true);
  }

  /// Retrieves all stream segments from video URL
  static Future<List<StreamSegment>> getStreamSegments(String videoUrl) async {
    if (StringChecker.hasWhiteSpace(videoUrl))
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