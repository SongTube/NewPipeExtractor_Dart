import 'package:newpipeextractor_dart/models/infoItems/channel.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';
import 'package:newpipeextractor_dart/utils/parsing.dart';

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

  /// Video tags, as a JSON array string (e.g. `["music","live"]`).
  ///
  /// The native side used to send Java's `List.toString()` here, which was not
  /// machine-readable; it is now proper JSON.
  String? tags;

  /// Video Thumbnail Url
  List<String>? thumbnails;

  /// Retrieve a new [VideoInfo] object from Map.
  ///
  /// The image fields arrive as JSON array *strings*; this used to call
  /// `List<String>.from` on them directly, so every call threw. The numeric
  /// fields used `int.parse`, which threw whenever the extractor could not
  /// determine a value and sent null.
  static VideoInfo fromMap(Map<String, dynamic> map) {
    return VideoInfo(
      id: map['id'],
      url: map['url'],
      name: map['name'],
      uploaderName: map['uploaderName'],
      uploaderAvatars: Parse.imageList(map['uploaderAvatars']),
      uploaderUrl: map['uploaderUrl'],
      uploadDate: map['uploadDate'],
      description: map['description'],
      length: Parse.nullableInteger(map['length']),
      viewCount: Parse.nullableInteger(map['viewCount']),
      likeCount: Parse.nullableInteger(map['likeCount']),
      dislikeCount: Parse.nullableInteger(map['dislikeCount']),
      category: map['category'],
      ageLimit: Parse.nullableInteger(map['ageLimit']),
      tags: map['tags'],
      thumbnails: Parse.imageList(map['thumbnails']),
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