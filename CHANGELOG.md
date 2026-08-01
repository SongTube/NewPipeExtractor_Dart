# Changelog

## 0.1.0

Modernization pass: the plugin builds and runs again on current Flutter and
Android toolchains.

### Toolchain

* NewPipeExtractor `v0.24.2` → `v0.26.4`.
* Android Gradle Plugin `4.1.0` → `8.11.1`; added the `namespace` AGP 8 requires
  and dropped the removed `package` attribute from `AndroidManifest.xml`.
* `compileSdk` 34 → 36, `minSdk` 22 → 24, Java 8 → 17.
* okhttp `3.12.13` → `4.12.0`, gson `2.8.6` → `2.11.0`,
  `desugar_jdk_libs` `1.1.1` → `2.1.5`.
* Removed the manual `jsoup` / `rhino` pins — they were years behind what the
  extractor is built against — plus the unused `junit`, `autolink` and
  `spotbugs-annotations` dependencies.
* Dart SDK `>=2.17.5 <3.0.0` → `>=3.5.0 <4.0.0`;
  `flutter_inappwebview` 5 → 6, `http` → 1.x.
* Added an `example/` app with a button per extractor, `analysis_options.yaml`,
  36 Dart unit tests, and JVM tests that exercise the native bridge against the
  live YouTube service.
* Added `consumer-rules.pro` so release builds with R8 work without the app
  needing its own Rhino/protobuf keep rules.

Apps using this plugin must now enable core library desugaring — see the README.

### Fixed (native)

* Trending returned **live streams, not trending videos**: since extractor v0.25
  the default kiosk is `live`, and the code asked for the default kiosk. The
  kiosk is now explicit and selectable — see the breaking-change note below.
* Every method channel call created a single-thread `ExecutorService` and never
  shut it down, leaking a thread per call. There is now one executor for the
  plugin, shut down when the engine detaches.
* `searchYoutubeMusic` threw `UnsupportedOperationException` for any non-empty
  filter list: it called `addAll` on a `Collections.singletonList`.
* Channel uploads came from the RSS feed extractor, which caps at ~15 items and
  has no next page, so `getChannelNextUploads()` could never return anything.
  Uploads now come from the channel's Videos tab, which pages properly.
* A null `MediaFormat` — returned for any itag the extractor doesn't recognise —
  aborted the whole stream extraction with an NPE.
* Cookie loading compared strings with `!=`, so a null cookie was stored on
  every startup.
* `getPlaylistDetails` reset global extractor state and seeded the shared RNG
  with a constant on each call, affecting every other extractor.
* Streams with no content URL are dropped instead of surfacing as models with a
  null `url`.
* Removed the per-request `Log.d` that printed the user's cookies to logcat.
* Unknown method names now return `notImplemented()` instead of an empty map.
* Replaced deprecated `android.preference.PreferenceManager` with the AndroidX
  one, and dropped the unused `AsyncTask` / `StrictMode` imports.
* All info-item serialization goes through shared helpers, so key names are
  consistent — channel uploads previously sent `thumbnailUrl` where every other
  path sent `thumbnails`.
* Item ordering: results are keyed by index and read back in index order rather
  than relying on `HashMap` iteration order.

### Fixed (Dart)

* **Errors were swallowed.** `ReCaptchaPage.checkInfo` returned `null` for any
  error that wasn't a reCaptcha, turning every extraction failure into a null
  dereference further up the stack. Failures now throw a `PlatformException`
  (`extraction_error` / `recaptcha`).
* `VideoExtractor.getInfo` threw on every call: `VideoInfo.fromMap` called
  `List<String>.from` on the JSON *string* the native side sends, and `int.parse`
  on counts that may be null.
* `ChannelInfoItem` / `PlaylistInfoItem` / `StreamInfoItem` `fromJsonString`
  threw a `TypeError` on every round-trip for the same reason
  (`jsonDecode` yields `List<dynamic>`).
* `StreamsParser.parseInfoItemListFromMap` returned `[]` on error while callers
  indexed `[0]`, `[1]`, `[2]` — a `RangeError`. It now always returns three
  buckets.
* `ExtractorHttpClient.getStream` shadowed its `stream` parameter with a local
  `StreamController`, so every retry passed the controller to itself and threw.
  The client is now also closed on the error path.
* The reCaptcha page was broken end to end under `flutter_inappwebview` 6:
  `URLRequest` needs a `WebUri`, `getUrl()` returns a `Uri` (was cast to
  `String`), and `decodeCookie` returns a map (was cast to `String`). The abuse
  cookie substring was also off by one, keeping a leading `=`.
* `YoutubeVideo.videoOnlyWithHighestQuality` / `videoWithHighestQuality`
  force-unwrapped the nullable `resolution` and `int.parse`d it; unlabelled
  streams now sort last instead of throwing.
* `NavigationService.navigateToReplacement` dropped its `argument`, and the
  navigation helpers threw when the host app hadn't wired up the navigator key.
* `VideoExtractor.getMediaStreams` returned the raw method-channel payload
  rather than the documented models, and the documented order was wrong. It now
  returns `[audioOnly, videoOnly, muxed, segments]` as models.

### Changed

* **YouTube removed the Trending page on 2025-07-21.** There is no general
  "trending videos" feed any more; `TrendingExtractor.getTrendingVideos()` now
  takes a `YoutubeKiosk` and defaults to `YoutubeKiosk.live`. The category
  kiosks (`trendingMusic`, `trendingGaming`, `trendingMoviesAndShows`,
  `trendingPodcasts`) all work; `YoutubeKiosk.trending` is deprecated and
  throws. Added `TrendingExtractor.getAvailableKiosks()`.

* `VideoInfo.tags` is now a JSON array string; it used to be Java's
  `List.toString()` output, which was not machine-readable (and was never
  populated by `fromMap`).
* The barrel file now exports the extractors, exceptions and reCaptcha helpers,
  so `import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';` is
  enough.
* `AudioOnlyStream` payloads additionally carry `bitrate` and `audioTrackName`;
  comments carry `replyCount`.

## 0.0.1

* Initial Release
