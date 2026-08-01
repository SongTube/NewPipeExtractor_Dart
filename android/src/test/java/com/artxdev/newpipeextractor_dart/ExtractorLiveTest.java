package com.artxdev.newpipeextractor_dart;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import com.artxdev.newpipeextractor_dart.downloader.DownloaderImpl;
import com.artxdev.newpipeextractor_dart.youtube.StreamExtractorImpl;
import com.artxdev.newpipeextractor_dart.youtube.YoutubeChannelExtractorImpl;
import com.artxdev.newpipeextractor_dart.youtube.YoutubeCommentsExtractorImpl;
import com.artxdev.newpipeextractor_dart.youtube.YoutubeLinkHandler;
import com.artxdev.newpipeextractor_dart.youtube.YoutubeMusicExtractor;
import com.artxdev.newpipeextractor_dart.youtube.YoutubePlaylistExtractorImpl;
import com.artxdev.newpipeextractor_dart.youtube.YoutubeSearchExtractor;
import com.artxdev.newpipeextractor_dart.youtube.YoutubeTrendingExtractorImpl;

import org.junit.Assume;
import org.junit.BeforeClass;
import org.junit.Test;
import org.schabi.newpipe.extractor.NewPipe;
import org.schabi.newpipe.extractor.localization.ContentCountry;
import org.schabi.newpipe.extractor.localization.Localization;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * Exercises the bridge against the live YouTube service on the JVM.
 *
 * <p>None of the classes under test touch the Android framework, so this runs as a plain unit
 * test. It is the only way to catch NewPipeExtractor API drift that compiles but fails at
 * runtime -- which is how the trending kiosk silently started returning live streams.</p>
 *
 * <p>Requires network access. Run with:</p>
 *
 * <pre>cd example/android &amp;&amp; ./gradlew :newpipeextractor_dart:testDebugUnitTest</pre>
 *
 * <p>Skip it (e.g. on an offline CI runner) with {@code -Dnewpipe.live.tests=false}.</p>
 */
public class ExtractorLiveTest {

    private static final String VIDEO_URL = "https://www.youtube.com/watch?v=dQw4w9WgXcQ";
    private static final String CHANNEL_URL =
            "https://www.youtube.com/channel/UCuAXFkgsw1L7xaCfnd5JJOw";
    private static final String PLAYLIST_URL =
            "https://www.youtube.com/playlist?list=PLirAqAtl_h2r5g8xGajEwdXd3x1sZh8hC";

    @BeforeClass
    public static void setUp() {
        Assume.assumeTrue("live tests disabled",
                Boolean.parseBoolean(System.getProperty("newpipe.live.tests", "true")));
        NewPipe.init(DownloaderImpl.getInstance(),
                Localization.fromLocale(Locale.US),
                new ContentCountry("US"));
    }

    private static void assertNotBlank(final String label, final String value) {
        assertNotNull(label + " was null", value);
        assertFalse(label + " was blank", value.trim().isEmpty());
    }

    /** The Dart side jsonDecodes these, so they must always be a JSON array. */
    private static void assertJsonArray(final String label, final String value) {
        assertNotNull(label + " was null", value);
        assertTrue(label + " was not a JSON array: " + value, value.startsWith("["));
    }

    @Test
    public void linkHandlersExtractIds() {
        assertNotBlank("stream id", YoutubeLinkHandler.getIdFromStreamUrl(VIDEO_URL));
        assertNotBlank("playlist id", YoutubeLinkHandler.getIdFromPlaylistUrl(PLAYLIST_URL));
        assertNotBlank("channel id", YoutubeLinkHandler.getIdFromChannelUrl(CHANNEL_URL));
    }

    @Test
    public void videoInfoIsPopulated() throws Exception {
        final Map<String, String> info = StreamExtractorImpl.getInfo(VIDEO_URL);

        assertNotBlank("name", info.get("name"));
        assertNotBlank("uploaderName", info.get("uploaderName"));
        assertNotBlank("length", info.get("length"));
        assertNotBlank("viewCount", info.get("viewCount"));
        assertJsonArray("thumbnails", info.get("thumbnails"));
        assertJsonArray("uploaderAvatars", info.get("uploaderAvatars"));
        assertJsonArray("tags", info.get("tags"));
    }

    @Test
    @SuppressWarnings("unchecked")
    public void streamsAreExtractedAndPlayable() throws Exception {
        final List<Map> payload = StreamExtractorImpl.getStream(VIDEO_URL);

        // Order is positional and the Dart side depends on it.
        assertTrue("expected 5 entries, got " + payload.size(), payload.size() == 5);

        final Map<Integer, Map<String, String>> audio = payload.get(1);
        final Map<Integer, Map<String, String>> videoOnly = payload.get(2);
        assertFalse("no audio streams", audio.isEmpty());
        assertFalse("no video-only streams", videoOnly.isEmpty());

        final Map<String, String> firstAudio = audio.get(0);
        assertNotBlank("audio url", firstAudio.get("url"));
        assertTrue("audio url is not http", firstAudio.get("url").startsWith("http"));
        assertNotBlank("audio bitrate", firstAudio.get("averageBitrate"));

        assertNotBlank("video resolution", videoOnly.get(0).get("resolution"));
    }

    @Test
    public void defaultKioskReturnsStreams() throws Exception {
        final Map<Integer, Map<String, String>> streams =
                YoutubeTrendingExtractorImpl.getTrendingPage(null);

        assertFalse("default kiosk was empty", streams.isEmpty());
        final Map<String, String> first = streams.get(0);
        assertNotBlank("kiosk item name", first.get("name"));
        assertNotBlank("kiosk item url", first.get("url"));
        assertJsonArray("kiosk item thumbnails", first.get("thumbnails"));
    }

    @Test
    public void namedKiosksReturnStreams() throws Exception {
        // The classic "Trending" kiosk is deliberately absent: YouTube removed
        // that page on 2025-07-21 and the extractor now fails on it.
        for (final String kiosk : Arrays.asList(
                "live", "trending_music", "trending_gaming",
                "trending_movies_and_shows", "trending_podcasts_episodes")) {
            final Map<Integer, Map<String, String>> streams =
                    YoutubeTrendingExtractorImpl.getTrendingPage(kiosk);
            assertFalse("kiosk " + kiosk + " was empty", streams.isEmpty());
            assertNotBlank("name in kiosk " + kiosk, streams.get(0).get("name"));
        }
    }

    @Test
    public void availableKiosksAreReported() throws Exception {
        final List<String> kiosks = YoutubeTrendingExtractorImpl.getAvailableKiosks();
        assertTrue("live kiosk missing: " + kiosks, kiosks.contains("live"));
    }

    @Test
    public void searchReturnsAllBucketsAndPages() throws Exception {
        final YoutubeSearchExtractor extractor = new YoutubeSearchExtractor();
        final Map<String, Map<Integer, Map<String, String>>> first =
                extractor.searchYoutube("lofi hip hop", Collections.emptyList());

        assertNotNull("streams bucket missing", first.get("streams"));
        assertNotNull("channels bucket missing", first.get("channels"));
        assertNotNull("playlists bucket missing", first.get("playlists"));
        assertFalse("no search results", first.get("streams").isEmpty());

        final Map<String, Map<Integer, Map<String, String>>> second = extractor.getNextPage();
        assertNotNull("next page returned null", second.get("streams"));
    }

    @Test
    public void musicSearchAcceptsExplicitFilters() throws Exception {
        // Regression: this threw UnsupportedOperationException for any non-empty
        // filter list, because it called addAll on a singletonList.
        final Map<String, Map<Integer, Map<String, String>>> results =
                new YoutubeMusicExtractor()
                        .searchYoutube("daft punk", Arrays.asList("music_songs"));

        assertNotNull("streams bucket missing", results.get("streams"));
    }

    @Test
    public void channelInfoAndUploadsPage() throws Exception {
        final YoutubeChannelExtractorImpl extractor = new YoutubeChannelExtractorImpl();

        final Map<String, String> channel = extractor.getChannel(CHANNEL_URL);
        assertNotBlank("channel name", channel.get("name"));
        assertJsonArray("channel avatars", channel.get("avatars"));
        assertJsonArray("channel banners", channel.get("banners"));

        final Map<Integer, Map<String, String>> first = extractor.getChannelUploads(CHANNEL_URL);
        assertFalse("no uploads", first.isEmpty());
        assertNotBlank("upload name", first.get(0).get("name"));

        // Was impossible via the old RSS feed path, which had no next page.
        final Map<Integer, Map<String, String>> second = extractor.getChannelNextPage();
        assertFalse("no second page of uploads", second.isEmpty());
    }

    @Test
    public void playlistDetailsAndStreams() throws Exception {
        final Map<String, String> details =
                YoutubePlaylistExtractorImpl.getPlaylistDetails(PLAYLIST_URL);
        assertNotBlank("playlist name", details.get("name"));
        assertJsonArray("playlist thumbnails", details.get("thumbnails"));

        final Map<Integer, Map<String, String>> streams =
                YoutubePlaylistExtractorImpl.getPlaylistStreams(PLAYLIST_URL);
        assertFalse("no playlist streams", streams.isEmpty());
        assertNotBlank("playlist stream name", streams.get(0).get("name"));
    }

    @Test
    public void relatedStreams() throws Exception {
        final Map<String, Map<Integer, Map<String, String>>> related =
                StreamExtractorImpl.getRelatedStreams(VIDEO_URL);

        assertNotNull("streams bucket missing", related.get("streams"));
        assertNotNull("channels bucket missing", related.get("channels"));
        assertNotNull("playlists bucket missing", related.get("playlists"));
    }

    @Test
    public void comments() throws Exception {
        final Map<Integer, Map<String, String>> comments =
                YoutubeCommentsExtractorImpl.getComments(VIDEO_URL);

        // Comments may legitimately be disabled; only assert on the shape.
        if (!comments.isEmpty()) {
            final Map<String, String> first = comments.get(0);
            assertNotBlank("comment author", first.get("author"));
            assertJsonArray("comment avatars", first.get("uploaderAvatars"));
            assertNotBlank("comment likeCount", first.get("likeCount"));
        }
    }
}
