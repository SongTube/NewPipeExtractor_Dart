import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:newpipeextractor_dart/utils/streamsParser.dart';

/// The YouTube "kiosk" (front-page feed) to pull streams from.
///
/// YouTube removed the classic Trending page on 2025-07-21, so there is no
/// longer a general "trending videos" feed; these category feeds and the live
/// feed are what remain.
enum YoutubeKiosk {
  /// Currently live streams. This is NewPipeExtractor's default kiosk.
  live('live'),

  trendingMusic('trending_music'),
  trendingGaming('trending_gaming'),
  trendingMoviesAndShows('trending_movies_and_shows'),
  trendingPodcasts('trending_podcasts_episodes'),

  /// The classic Trending page.
  ///
  /// Removed by YouTube on 2025-07-21; extraction throws a `PlatformException`
  /// with code `extraction_error`. Kept so existing code still compiles.
  @Deprecated('YouTube removed the Trending page on 2025-07-21. '
      'Use one of the other YoutubeKiosk values.')
  trending('Trending');

  const YoutubeKiosk(this.id);

  /// The kiosk id NewPipeExtractor registers this feed under.
  final String id;
}

class TrendingExtractor {
  /// Returns a kiosk feed as a list of [StreamInfoItem].
  ///
  /// Defaults to [YoutubeKiosk.live], matching NewPipeExtractor's own default.
  /// Note the old implementation called `getDefaultKioskExtractor()` and so had
  /// already been returning live streams rather than trending videos.
  static Future<List<StreamInfoItem>> getTrendingVideos({
    YoutubeKiosk kiosk = YoutubeKiosk.live,
  }) async {
    final info = await ReCaptchaPage.run(
      () => NewPipeExtractorDart.extractorChannel
          .invokeMethod('getTrendingStreams', {'kiosk': kiosk.id}),
    );
    return StreamsParser.parseStreamListFromMap(info);
  }

  /// The kiosk ids the bundled NewPipeExtractor knows about.
  ///
  /// Useful for checking what survived a YouTube change without rebuilding.
  static Future<List<String>> getAvailableKiosks() async {
    final ids = await NewPipeExtractorDart.extractorChannel
        .invokeListMethod<String>('getAvailableKiosks');
    return ids ?? const [];
  }
}
