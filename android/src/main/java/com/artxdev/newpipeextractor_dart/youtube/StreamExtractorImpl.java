package com.artxdev.newpipeextractor_dart.youtube;

import com.artxdev.newpipeextractor_dart.FetchData;

import org.schabi.newpipe.extractor.InfoItem;
import org.schabi.newpipe.extractor.InfoItemsCollector;

import static org.schabi.newpipe.extractor.ServiceList.YouTube;

import org.schabi.newpipe.extractor.stream.AudioStream;
import org.schabi.newpipe.extractor.stream.StreamExtractor;
import org.schabi.newpipe.extractor.stream.VideoStream;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

public final class StreamExtractorImpl {

    private StreamExtractorImpl() {
    }

    private static StreamExtractor fetch(final String url) throws Exception {
        final StreamExtractor extractor = YouTube.getStreamExtractor(url);
        extractor.fetchPage();
        return extractor;
    }

    /**
     * Some itags carry no usable content URL (DRM / server-side ads). Dropping them here keeps the
     * Dart models from producing streams with a null {@code url}.
     */
    private static <T extends org.schabi.newpipe.extractor.stream.Stream> List<T> playable(
            final List<T> streams) {
        final List<T> result = new ArrayList<>();
        if (streams == null) {
            return result;
        }
        for (final T stream : streams) {
            if (stream != null && stream.getContent() != null && !stream.getContent().isEmpty()) {
                result.add(stream);
            }
        }
        return result;
    }

    private static List<AudioStream> audioStreams(final StreamExtractor extractor) {
        try {
            return playable(extractor.getAudioStreams());
        } catch (final Exception e) {
            return Collections.emptyList();
        }
    }

    private static List<VideoStream> videoOnlyStreams(final StreamExtractor extractor) {
        try {
            return playable(extractor.getVideoOnlyStreams());
        } catch (final Exception e) {
            return Collections.emptyList();
        }
    }

    private static List<VideoStream> muxedStreams(final StreamExtractor extractor) {
        try {
            return playable(extractor.getVideoStreams());
        } catch (final Exception e) {
            return Collections.emptyList();
        }
    }

    public static Map<String, String> getInfo(final String url) throws Exception {
        return FetchData.fetchVideoInfo(fetch(url));
    }

    /**
     * Video info plus every stream category, in the fixed order the Dart
     * {@code VideoExtractor.getStream} reads positionally:
     * info, audio-only, video-only, muxed, segments.
     */
    public static List<Map> getStream(final String url) throws Exception {
        final StreamExtractor extractor = fetch(url);
        final List<Map> result = new ArrayList<>();
        result.add(FetchData.fetchVideoInfo(extractor));
        result.add(FetchData.indexed(audioStreams(extractor), FetchData::fetchAudioStreamInfo));
        result.add(FetchData.indexed(videoOnlyStreams(extractor), FetchData::fetchVideoStreamInfo));
        result.add(FetchData.indexed(muxedStreams(extractor), FetchData::fetchVideoStreamInfo));
        result.add(FetchData.fetchStreamSegments(streamSegments(extractor)));
        return result;
    }

    /** Same as {@link #getStream} without the leading info map. */
    public static List<Map> getMediaStreams(final String url) throws Exception {
        final StreamExtractor extractor = fetch(url);
        final List<Map> result = new ArrayList<>();
        result.add(FetchData.indexed(audioStreams(extractor), FetchData::fetchAudioStreamInfo));
        result.add(FetchData.indexed(videoOnlyStreams(extractor), FetchData::fetchVideoStreamInfo));
        result.add(FetchData.indexed(muxedStreams(extractor), FetchData::fetchVideoStreamInfo));
        result.add(FetchData.fetchStreamSegments(streamSegments(extractor)));
        return result;
    }

    public static Map<Integer, Map<String, String>> getVideoOnlyStreams(final String url)
            throws Exception {
        return FetchData.indexed(videoOnlyStreams(fetch(url)), FetchData::fetchVideoStreamInfo);
    }

    public static Map<Integer, Map<String, String>> getAudioOnlyStreams(final String url)
            throws Exception {
        return FetchData.indexed(audioStreams(fetch(url)), FetchData::fetchAudioStreamInfo);
    }

    public static Map<Integer, Map<String, String>> getMuxedStreams(final String url)
            throws Exception {
        return FetchData.indexed(muxedStreams(fetch(url)), FetchData::fetchVideoStreamInfo);
    }

    public static Map<String, Map<Integer, Map<String, String>>> getRelatedStreams(final String url)
            throws Exception {
        final InfoItemsCollector<? extends InfoItem, ?> collector = fetch(url).getRelatedItems();
        if (collector == null) {
            return FetchData.fetchInfoItems(Collections.emptyList());
        }
        return FetchData.fetchInfoItems(collector.getItems());
    }

    public static Map<Integer, Map<String, String>> getStreamSegments(final String url)
            throws Exception {
        return FetchData.fetchStreamSegments(streamSegments(fetch(url)));
    }

    private static List<org.schabi.newpipe.extractor.stream.StreamSegment> streamSegments(
            final StreamExtractor extractor) {
        try {
            return extractor.getStreamSegments();
        } catch (final Exception e) {
            return Collections.emptyList();
        }
    }
}
