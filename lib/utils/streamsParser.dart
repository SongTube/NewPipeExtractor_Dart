import 'package:newpipeextractor_dart/models/infoItems/channel.dart';
import 'package:newpipeextractor_dart/models/infoItems/playlist.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';
import 'package:newpipeextractor_dart/models/streamSegment.dart';
import 'package:newpipeextractor_dart/utils/parsing.dart';

/// Turns the raw `Map` payloads coming off the method channel into models.
class StreamsParser {
  /// Splits the `streams` / `playlists` / `channels` buckets into models.
  ///
  /// When [singleList] is false the result always has exactly three entries, in
  /// that order, so callers can index into it safely. It previously returned an
  /// empty list when the native side reported an error, which turned every
  /// failure into a `RangeError` at the call site.
  static List<dynamic> parseInfoItemListFromMap(dynamic info,
      {required bool singleList}) {
    final map = info is Map ? info : const {};

    final listVideos = parseStreamListFromMap(map['streams']);
    final listPlaylists = Parse.list(
      map['playlists'],
      (item) => PlaylistInfoItem(
        item['url'],
        item['name'],
        item['uploaderName'],
        Parse.imageList(item['thumbnails']),
        Parse.integer(item['streamCount']),
      ),
    );
    final listChannels = Parse.list(
      map['channels'],
      (item) => ChannelInfoItem(
        item['url'],
        item['name'],
        item['description'],
        Parse.imageList(item['thumbnails']),
        Parse.integer(item['subscriberCount']),
        Parse.integer(item['streamCount']),
      ),
    );

    if (singleList) {
      return <dynamic>[...listPlaylists, ...listVideos];
    }
    return [listVideos, listPlaylists, listChannels];
  }

  /// Retrieves a list of [StreamInfoItem] from the method channel response map.
  static List<StreamInfoItem> parseStreamListFromMap(dynamic info) {
    return Parse.list(
      info,
      (item) => StreamInfoItem(
        item['url'],
        item['id'],
        item['name'],
        item['uploaderName'],
        item['uploaderUrl'],
        Parse.imageList(item['uploaderAvatars']),
        item['uploadDate'],
        item['date'],
        Parse.integer(item['duration']),
        Parse.integer(item['viewCount']),
      ),
    );
  }

  /// Retrieves a list of [StreamSegment] from the method channel response map.
  static List<StreamSegment> parseStreamSegmentListFromMap(dynamic info) {
    return Parse.list(
      info,
      (item) => StreamSegment(
        item['url'],
        item['title'],
        item['previewUrl'],
        Parse.integer(item['startTimeSeconds']),
      ),
    );
  }
}
