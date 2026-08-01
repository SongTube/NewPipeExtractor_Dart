# newpipeextractor_dart

Flutter bindings for [NewPipeExtractor](https://github.com/TeamNewPipe/NewPipeExtractor),
exposing YouTube video, playlist, channel, search, comment and trending
extraction to Dart. Android only.

Currently bridges **NewPipeExtractor v0.26.4**.

## Setup

Add the plugin as a dependency, then make two changes to your Android app.

### 1. JitPack repository

NewPipeExtractor is published on JitPack. The plugin registers that repository
for you, so nothing is needed unless your app locks repositories down with
`RepositoriesMode.FAIL_ON_PROJECT_REPOS` — in that case add it yourself in
`android/settings.gradle.kts`:

```kotlin
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
    }
}
```

### 2. Core library desugaring

NewPipeExtractor uses `java.time`, `java.util.stream` and `List.of` — natively
API 26, 24 and 30 respectively. Your app must enable core library desugaring in
`android/app/build.gradle.kts`:

```kotlin
android {
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
```

The plugin requires `minSdk 24` and is built against `compileSdk 36` with
AGP 8.11.1.

## Usage

```dart
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';

// Kiosk feeds — see the note below about Trending
final live = await TrendingExtractor.getTrendingVideos();
final music = await TrendingExtractor.getTrendingVideos(
  kiosk: YoutubeKiosk.trendingMusic,
);

// Search (see YoutubeSearchFilter for filter constants)
final search = await SearchExtractor.searchYoutube('lofi', []);
await search.getNextPage();

// A single video, with every stream
final video = await VideoExtractor.getStream('https://youtu.be/dQw4w9WgXcQ');
final bestAudio = video.audioWithHighestQuality;
final bestVideo = video.videoOnlyWithHighestQuality;

// Info only, no stream extraction
final info = (await VideoExtractor.getInfo(url)).videoInfo;

// Channels, playlists, comments
final channel = await ChannelExtractor.channelInfo(channelUrl);
final uploads = await ChannelExtractor.getChannelUploads(channelUrl);
final more = await ChannelExtractor.getChannelNextUploads();
final playlist = await PlaylistExtractor.getPlaylistDetails(playlistUrl);
final comments = await CommentsExtractor.getComments(videoUrl);
```

Paging state (`getNextPage`, `getNextMusicPage`, `getChannelNextUploads`) lives
on the native side, so each of those continues the most recent corresponding
query.

### The Trending page is gone

YouTube removed the general Trending page on **2025-07-21**. There is no
replacement for "trending videos"; what remains are category kiosks and the live
feed, selectable via `YoutubeKiosk`:

| `YoutubeKiosk` | id | works |
| --- | --- | --- |
| `live` (default) | `live` | yes |
| `trendingMusic` | `trending_music` | yes |
| `trendingGaming` | `trending_gaming` | yes |
| `trendingMoviesAndShows` | `trending_movies_and_shows` | yes |
| `trendingPodcasts` | `trending_podcasts_episodes` | yes |
| `trending` (deprecated) | `Trending` | **no** — throws `extraction_error` |

`TrendingExtractor.getAvailableKiosks()` reports what the bundled extractor
knows about. Note the previous version called NewPipeExtractor's
`getDefaultKioskExtractor()`, which since v0.25 means `live` — so
`getTrendingVideos()` had already been returning live streams, just without
saying so.

### Error handling

Extraction failures throw a `PlatformException`:

| code | meaning |
| --- | --- |
| `extraction_error` | the extractor failed; `details` holds the native stack trace |
| `recaptcha` | YouTube demanded a reCaptcha; `details` holds the URL to solve |

### Solving reCaptcha challenges

To let users solve challenges in-app, wire the plugin's navigator key and route
into your `MaterialApp`:

```dart
MaterialApp(
  navigatorKey: NavigationService.instance.navigationKey,
  routes: {ReCaptchaPage.routeName: (_) => const ReCaptchaPage()},
  home: const HomePage(),
)
```

Every extractor call then transparently shows the solving page and retries once.
Without this wiring the challenge simply surfaces as a `PlatformException` with
code `recaptcha`.

## Verifying the bridge

`example/` is a runnable app with a button per extractor:

```
cd example && flutter run
```

Dart-side parsing is covered by unit tests:

```
flutter test
```

The native bridge is covered by JVM tests that hit the **live** YouTube service —
the only way to catch NewPipeExtractor API drift that compiles but fails at
runtime:

```
cd example/android && ./gradlew :newpipeextractor_dart:testDebugUnitTest
```

Add `-Dnewpipe.live.tests=false` to skip them offline. `KioskProbeTest` prints
which kiosks still return items.

## Keeping up with NewPipeExtractor

YouTube changes break extraction regularly; the fix is almost always to bump the
version in `android/build.gradle` and re-run the example app. Do not pin
`jsoup` / `rhino` / `nanojson` separately — they come in transitively at the
versions the extractor was built against, and stale pins break extraction at
runtime in ways that are hard to diagnose.
