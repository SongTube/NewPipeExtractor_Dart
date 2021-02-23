import 'package:newpipeextractor_dart/extractors/playlist.dart';
import 'package:newpipeextractor_dart/models/playlist.dart';

class PlaylistInfoItem {

  /// Playlist URL
  final String url;

  /// Playlist name
  final String name;

  /// Playlist uploader channel name
  final String uploaderName;

  /// Playlist thumbnail url
  final String thumbnailUrl;

  /// Playlist videos count
  final int streamCount;

  PlaylistInfoItem(
    this.url,
    this.name,
    this.uploaderName,
    this.thumbnailUrl,
    this.streamCount
  );

  /// Obtains the full information of the playlist
  /// into a YoutubePlaylist object
  Future<YoutubePlaylist> get getPlaylist async {
    return await PlaylistExtractor.getPlaylistDetails(url);
  }

}