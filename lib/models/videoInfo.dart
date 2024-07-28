import 'package:newpipeextractor_dart/models/infoItems/channel.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';

class VideoInfo {
  
  VideoInfo({
    this.id,
    this.url,
    this.name,
    this.uploaderName,
    this.uploaderUrl,
    this.uploaderAvatars,
    this.uploadDate,
    this.description,
    this.length,
    this.viewCount,
    this.likeCount,
    this.dislikeCount,
    this.category,
    this.ageLimit,
    this.tags,
    this.thumbnails
  });

  /// Video Id (ex: dQw4w9WgXcQ)
  String? id;

  /// Video full Url (ex: https://www.youtube.com/watch?v=dQw4w9WgXcQ)
  String? url;

  /// Video Title
  String? name;

  /// Video uploader name (Channel name)
  String? uploaderName;

  /// Url to the uploader Channel
  String? uploaderUrl;

  /// Url to the uploader avatar image
  List<String>? uploaderAvatars;

  /// Video upload date
  String? uploadDate;

  /// Video description
  String? description;

  /// Video length (duration in ms)
  int? length;

  /// View Count
  int? viewCount;

  /// Like Count
  int? likeCount;

  /// Dislike Count
  int? dislikeCount;

  /// Video category
  String? category;

  /// Age limit (int)
  int? ageLimit;

  /// Video Tags
  String? tags;

  /// Video Thumbnail Url
  List<String>? thumbnails;

  /// Retrieve a new [VideoInfo] object from Map
  static VideoInfo fromMap(Map<String, dynamic> map) {
    return VideoInfo(
      id: map.containsKey('id') ? map['id'] : null,
      url: map.containsKey('url') ? map['url'] : null,
      name: map.containsKey('name') ? map['name'] : null,
      uploaderName: map.containsKey('uploaderName') ? map['uploaderName'] : null,
      uploaderAvatars: map.containsKey('uploaderAvatars') ? List<String>.from(map['uploaderAvatars']) : null,
      uploaderUrl: map.containsKey('uploaderUrl') ? map['uploaderUrl'] : null,
      uploadDate: map.containsKey('uploadDate') ? map['uploadDate'] : null,
      description: map.containsKey('description') ? map['description']: null,
      length: map.containsKey('length') ? int.parse(map['length']) : null,
      viewCount: map.containsKey('viewCount') ? int.parse(map['viewCount']) : null,
      likeCount: map.containsKey('likeCount') ? int.parse(map['likeCount']) : null,
      dislikeCount: map.containsKey('dislikeCount') ? int.parse(map['dislikeCount']) : null,
      category: map.containsKey('category') ? map['category'] : null,
      ageLimit: map.containsKey('ageLimit') ? int.parse(map['ageLimit']) : null,
      thumbnails: map.containsKey('thumbnails') ? List<String>.from(map['thumbnails']) : null,
    );
  }

  /// Generate a VideoInfo Item from StreamInfoItem
  static VideoInfo fromStreamInfoItem(StreamInfoItem item) {
    return VideoInfo(
      id: item.id,
      url: item.url,
      name: item.name,
      uploadDate: item.uploadDate,
      uploaderUrl: item.uploaderUrl,
      uploaderName: item.uploaderName,
      length: Duration(seconds: item.duration!).inMilliseconds,
      viewCount: item.viewCount,
      thumbnails: [
        item.thumbnails!.sddefault,
        item.thumbnails!.mqdefault,
        item.thumbnails!.hqdefault,
        item.thumbnails!.maxresdefault,
      ]
    );
  }

  /// Generate a ChannelInfoItem from this video details
  ChannelInfoItem getChannel() {
    return ChannelInfoItem(uploaderUrl, uploaderName, '', uploaderAvatars, null, -1);
  }

}