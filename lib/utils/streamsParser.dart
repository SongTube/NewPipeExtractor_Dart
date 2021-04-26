import 'package:newpipeextractor_dart/models/infoItems/video.dart';
import 'package:newpipeextractor_dart/models/streamSegment.dart';

class StreamsParser {

  /// Retrieves a list of StreamInfoItem from the method channel response map
  static List<StreamInfoItem> parseStreamListFromMap(info) {
    List<StreamInfoItem> streams = [];
    info.forEach((_, map) {
      streams.add(StreamInfoItem(
        map['url'],
        map['id'],
        map['name'],
        map['uploaderName'],
        map['uploaderUrl'],
        map['uploadDate'],
        map['date'],
        int.parse(map['duration']),
        int.parse(map['viewCount'])
      ));
    });
    return streams;
  }

  /// Retrieves a list of StreamSegment from Map
  static List<StreamSegment> parseStreamSegmentListFromMap(info) {
    List<StreamSegment> segments = <StreamSegment>[];
    info.forEach((_, map) {
      segments.add(StreamSegment(
        map['url'],
        map['title'],
        map['previewUrl'],
        int.parse(map['startTimeSeconds'])
      ));
    });
    return segments;
  }

}