import 'package:newpipeextractor_dart/models/infoItems/video.dart';

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
        int.parse(map['duration']),
        int.parse(map['viewCount'])
      ));
    });
    return streams;
  }

}