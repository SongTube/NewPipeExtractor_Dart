import 'package:newpipeextractor_dart/extractors/playlist.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';

class YoutubePlaylist {

  String id;
  String name;
  String url;
  String uploaderName;
  String uploaderAvatarUrl;
  String uploaderUrl;
  String bannerUrl;
  String thumbnailUrl;
  int streamCount;

  List<StreamInfoItem> streams;

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

  Future<void> getStreams() async {
    streams = await PlaylistExtractor.getPlaylistStreams(url);
  }

  Future<void> getMoreStreams() async {
    streams.addAll(await PlaylistExtractor.getNextPage());
  }

}