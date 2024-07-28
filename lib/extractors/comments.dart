import 'dart:convert';
import 'package:newpipeextractor_dart/exceptions/badUrlException.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:newpipeextractor_dart/utils/reCaptcha.dart';
import 'package:newpipeextractor_dart/utils/stringChecker.dart';

class CommentsExtractor {

  static Future<List<YoutubeComment>> getComments(String videoUrl) async {
    if (StringChecker.hasWhiteSpace(videoUrl))
      throw BadUrlException("Url is null or contains white space");
    List<YoutubeComment> comments = [];
    Future<dynamic> task() => NewPipeExtractorDart.extractorChannel.invokeMethod('getComments', {
      "videoUrl": videoUrl
    });
    var info = await task();
    // Check if we got reCaptcha needed response
    info = await ReCaptchaPage.checkInfo(info, task);
    info.forEach((key, map) {
      comments.add(YoutubeComment(
        author: map['author'],
        commentText: map['commentText'],
        uploadDate: map['uploadDate'],
        uploaderAvatars: List<String>.from(jsonDecode(map['uploaderAvatars'])),
        uploaderUrl: map['uploaderUrl'],
        commentId: map['commentId'],
        likeCount: int.parse(map['likeCount']),
        hearted: map['hearted'].toLowerCase() == 'true',
        pinned: map['pinned'].toLowerCase() == 'true'
      ));
    });
    return comments;
  }
}