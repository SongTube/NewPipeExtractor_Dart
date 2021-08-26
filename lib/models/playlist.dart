import 'package:newpipeextractor_dart/extractors/playlist.dart';
import 'package:newpipeextractor_dart/models/infoItems/playlist.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';

class YoutubePlaylist {

  /// Playlist ID
  String? id;

  /// Playlist name
  String? name;

  /// Playlist full URL
  String? url;

  /// Playlist authors name
  String? uploaderName;

  /// Playlist author avatar url
  String? uploaderAvatarUrl;

  /// Playlist channel url
  String? uploaderUrl;

  /// Playlist banner url
  String? bannerUrl;

  /// Playlist thumbnail url
  String? thumbnailUrl;

  /// Playlist videos ammount
  int streamCount;

  /// Playlist streams (Videos)
  List<StreamInfoItem>? streams;

  YoutubePlaylist(
    this.id,
    this.name,
    this.url,
    this.uploaderName,
    this.uploaderAvatarUrl,
    this.uploaderUrl,
    this.bannerUrl,
    this.thumbnailUrl,
    this.streamCount
  );

  /// Transform this object into a PlaylistInfoItem which is smaller and
  /// allows saving or transporting it via Strings
  PlaylistInfoItem toPlaylistInfoItem() {
    return PlaylistInfoItem(
      url,
      name,
      uploaderName,
      thumbnailUrl,
      streamCount
    );
  }

  /// Retrieve this Playlist list of streams (List of StreamInfoItem)
  Future<void> getStreams() async {
    streams = await PlaylistExtractor.getPlaylistStreams(url);
  }

}