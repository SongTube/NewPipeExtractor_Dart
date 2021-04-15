import 'package:flutter/services.dart';

// Models
export 'models/channel.dart';
export 'models/comment.dart';
export 'models/filters.dart';
export 'models/playlist.dart';
export 'models/search.dart';
export 'models/video.dart';
export 'models/streamSegment.dart';

// InfoItems
export 'models/infoItems/channel.dart';
export 'models/infoItems/playlist.dart';
export 'models/infoItems/video.dart';

// Streams
export 'models/streams/audioOnlyStream.dart';
export 'models/streams/videoOnlyStream.dart';
export 'models/streams/videoStream.dart';

class NewPipeExtractorDart {
  static const MethodChannel extractorChannel =
      const MethodChannel('newpipeextractor_dart');
}
