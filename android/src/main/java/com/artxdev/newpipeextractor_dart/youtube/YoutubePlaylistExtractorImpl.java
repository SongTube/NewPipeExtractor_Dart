package com.artxdev.newpipeextractor_dart.youtube;

import com.artxdev.newpipeextractor_dart.FetchData;

import org.schabi.newpipe.extractor.playlist.PlaylistExtractor;

import static org.schabi.newpipe.extractor.ServiceList.YouTube;

import java.util.HashMap;
import java.util.Map;

public final class YoutubePlaylistExtractorImpl {

    private YoutubePlaylistExtractorImpl() {
    }

    public static Map<String, String> getPlaylistDetails(final String url) throws Exception {
        // The old implementation reset the cached client version and seeded
        // YoutubeParsingHelper's RNG with a constant here. Both are global mutable state that
        // affected every other extractor, and the fixed seed made requests fingerprintable.
        final PlaylistExtractor extractor = YouTube.getPlaylistExtractor(url);
        extractor.fetchPage();

        final Map<String, String> details = new HashMap<>();
        details.put("id", extractor.getId());
        details.put("url", extractor.getUrl());
        details.put("name", extractor.getName());
        details.put("thumbnails", FetchData.imagesToJson(extractor.getThumbnails()));
        details.put("banners", FetchData.imagesToJson(extractor.getBanners()));
        details.put("streamCount", String.valueOf(extractor.getStreamCount()));

        // Mix playlists and auto-generated lists have no real uploader.
        try {
            details.put("uploaderName", extractor.getUploaderName());
        } catch (final Exception ignored) {
            details.put("uploaderName", null);
        }
        try {
            details.put("uploaderUrl", extractor.getUploaderUrl());
        } catch (final Exception ignored) {
            details.put("uploaderUrl", null);
        }
        try {
            details.put("uploaderAvatars",
                    FetchData.imagesToJson(extractor.getUploaderAvatars()));
        } catch (final Exception ignored) {
            details.put("uploaderAvatars", "[]");
        }
        try {
            details.put("description", extractor.getDescription().getContent());
        } catch (final Exception ignored) {
            details.put("description", null);
        }
        return details;
    }

    public static Map<Integer, Map<String, String>> getPlaylistStreams(final String url)
            throws Exception {
        final PlaylistExtractor extractor = YouTube.getPlaylistExtractor(url);
        extractor.fetchPage();
        return FetchData.fetchStreamInfoItems(extractor.getInitialPage().getItems());
    }
}
