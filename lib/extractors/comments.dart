import 'package:newpipeextractor_dart/exceptions/badUrlException.dart';
import 'package:newpipeextractor_dart/models/comment.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:newpipeextractor_dart/utils/stringChecker.dart';

class CommentsExtractor {

  static Future<List<YoutubeComment>> getComments(String videoUrl) async {
    if (videoUrl == null || StringChecker.hasWhiteSpace(videoUrl))
      throw BadUrlException("Url is null or contains white space");
    List<YoutubeComment> comments = [];
    Map<dynamic, dynamic> commentsMap = await NewPipeExtractorDart.extractorChannel.invokeMethod('getComments', {
      "videoUrl": videoUrl
    });
    commentsMap.forEach((key, map) {
      comments.add(YoutubeComment(
        author: map['author'],
        commentText: map['commentText'],
        uploadDate: map['uploadDate'],
        uploaderAvatarUrl: map['uploaderAvatarUrl'],
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