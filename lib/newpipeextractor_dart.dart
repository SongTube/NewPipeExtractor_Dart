import 'package:flutter/services.dart';

// Models
export 'models/channel.dart';
export 'models/comment.dart';
export 'models/filters.dart';
export 'models/playlist.dart';
export 'models/search.dart';
export 'models/streamSegment.dart';
export 'models/video.dart';
export 'models/videoInfo.dart';

// InfoItems
export 'models/infoItems/channel.dart';
export 'models/infoItems/playlist.dart';
export 'models/infoItems/video.dart';

// Streams
export 'models/streams/audioOnlyStream.dart';
export 'models/streams/videoOnlyStream.dart';
export 'models/streams/videoStream.dart';

// Extractors
export 'extractors/channels.dart';
export 'extractors/comments.dart';
export 'extractors/playlist.dart';
export 'extractors/search.dart';
export 'extractors/trending.dart';
export 'extractors/videos.dart';

// Exceptions
export 'exceptions/badUrlException.dart';
export 'exceptions/fatalFailureException.dart';
export 'exceptions/requestLimitExceededException.dart';
export 'exceptions/streamIsNull.dart';
export 'exceptions/transistentFailureException.dart';

// reCaptcha support -- see ReCaptchaPage for the wiring the host app must do.
export 'utils/navigationService.dart';
export 'utils/reCaptcha.dart' show ReCaptchaPage, kReCaptchaErrorCode;
export 'utils/url.dart';

class NewPipeExtractorDart {
  static const MethodChannel extractorChannel =
      MethodChannel('newpipeextractor_dart');
}
