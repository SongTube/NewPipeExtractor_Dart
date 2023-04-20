import 'package:newpipeextractor_dart/models/infoItems/channel.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';

class VideoInfo {
  
  VideoInfo({
    this.id,
    this.url,
    this.name,
    this.uploaderName,
    this.uploaderUrl,
    this.uploaderAvatarUrl,
    this.uploadDate,
    this.description,
    this.length,
    this.viewCount,
    this.likeCount,
    this.dislikeCount,
    this.category,
    this.ageLimit,
    this.tags,
    this.thumbnailUrl
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
  String? uploaderAvatarUrl;

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
  String? thumbnailUrl;

  /// Retrieve a new [VideoInfo] object from Map
  static VideoInfo fromMap(Map<String, dynamic> map) {
    return VideoInfo(
      id: map.containsKey('id') ? map['id'] : null,
      url: map.containsKey('url') ? map['url'] : null,
      name: map.containsKey('name') ? map['name'] : null,
      uploaderName: map.containsKey('uploaderName') ? map['uploaderName'] : null,
      uploaderAvatarUrl: map.containsKey('uploaderAvatarUrl') ? map['uploaderAvatarUrl'] : null,
      uploaderUrl: map.containsKey('uploaderUrl') ? map['uploaderUrl'] : null,
      uploadDate: map.containsKey('uploadDate') ? map['uploadDate'] : null,
      description: map.containsKey('description') ? map['description']: null,
      length: map.containsKey('length') ? int.parse(map['length']) : null,
      viewCount: map.containsKey('viewCount') ? int.parse(map['viewCount']) : null,
      likeCount: map.containsKey('likeCount') ? int.parse(map['likeCount']) : null,
      dislikeCount: map.containsKey('dislikeCount') ? int.parse(map['dislikeCount']) : null,
      category: map.containsKey('category') ? map['category'] : null,
      ageLimit: map.containsKey('ageLimit') ? int.parse(map['ageLimit']) : null,
      thumbnailUrl: map.containsKey('thumbnailUrl') ? map['thumbnailUrl'] : null,
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
      thumbnailUrl: item.thumbnails?.hqdefault
    );
  }

  /// Generate a ChannelInfoItem from this video details
  ChannelInfoItem getChannel() {
    return ChannelInfoItem(uploaderUrl, uploaderName, '', uploaderAvatarUrl, null, -1);
  }

}