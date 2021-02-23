import 'package:newpipeextractor_dart/extractors/channels.dart';
import 'package:newpipeextractor_dart/extractors/videos.dart';
import 'package:newpipeextractor_dart/models/channel.dart';
import 'package:newpipeextractor_dart/models/video.dart';

class StreamInfoItem {

  /// Video URL
  final String url;

  /// Video name
  final String name;

  /// Video uploader Name
  final String uploaderName;

  /// Video uploader channel url
  final String uploaderUrl;

  /// Video date
  final String uploadDate;

  /// Video thumbnail url
  final String thumbnailUrl;

  /// Video duration in seconds (s)
  final int duration;

  /// Video view count
  final int viewCount;

  StreamInfoItem(
    this.url,
    this.name,
    this.uploaderName,
    this.uploaderUrl,
    this.uploadDate,
    this.thumbnailUrl,
    this.duration,
    this.viewCount
  );

  /// Gets full YoutubeVideo containing more Information and
  /// all necessary streams for Streaming and Downloading
  Future<YoutubeVideo> get getVideo async {
    return VideoExtractor.getVideoInfoAndStreams(url);
  }

  /// Obtains the full information of the authors Channel
  /// into a YoutubeChannel object
  Future<YoutubeChannel> get getChannel async {
    return ChannelExtractor.channelInfo(uploaderUrl);
  }

}