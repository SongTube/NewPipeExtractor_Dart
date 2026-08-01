import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:newpipeextractor_dart/utils/parsing.dart';
import 'package:newpipeextractor_dart/utils/stringChecker.dart';

class CommentsExtractor {
  static Future<List<YoutubeComment>> getComments(String videoUrl) async {
    if (StringChecker.hasWhiteSpace(videoUrl)) {
      throw BadUrlException('Url is null or contains white space');
    }
    final info = await ReCaptchaPage.run(
      () => NewPipeExtractorDart.extractorChannel
          .invokeMethod('getComments', {'videoUrl': videoUrl}),
    );

    return Parse.list(
      info,
      (map) => YoutubeComment(
        author: map['author'],
        commentText: map['commentText'],
        uploadDate: map['uploadDate'],
        uploaderAvatars: Parse.imageList(map['uploaderAvatars']),
        uploaderUrl: map['uploaderUrl'],
        commentId: map['commentId'],
        likeCount: Parse.integer(map['likeCount']),
        hearted: Parse.boolean(map['hearted']),
        pinned: Parse.boolean(map['pinned']),
      ),
    );
  }
}
