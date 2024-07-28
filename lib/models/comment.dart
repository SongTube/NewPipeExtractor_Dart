class YoutubeComment {

  /// Comment Author
  String? author;

  /// Full comment text
  String? commentText;

  /// Comment upload date
  String? uploadDate;

  /// Author avatar image Url
  List<String>? uploaderAvatars;

  /// Author channel url
  String? uploaderUrl;

  /// Comment Id
  String? commentId;

  /// Like Count
  int? likeCount;

  /// Is comment hearted by the video Author
  bool? hearted;

  /// Is comment pinned by the video Author
  bool? pinned;

  YoutubeComment({
    this.author,
    this.commentText,
    this.uploadDate,
    this.uploaderAvatars,
    this.uploaderUrl,
    this.commentId,
    this.likeCount,
    this.hearted,
    this.pinned
  });

}