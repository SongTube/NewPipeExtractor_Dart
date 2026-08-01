package com.artxdev.newpipeextractor_dart.youtube;

import com.artxdev.newpipeextractor_dart.FetchData;

import org.schabi.newpipe.extractor.InfoItem;
import org.schabi.newpipe.extractor.ListExtractor;
import org.schabi.newpipe.extractor.kiosk.KioskExtractor;
import org.schabi.newpipe.extractor.stream.StreamInfoItem;

import static org.schabi.newpipe.extractor.ServiceList.YouTube;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

public final class YoutubeTrendingExtractorImpl {

    private YoutubeTrendingExtractorImpl() {
    }

    /**
     * Returns the streams of a YouTube kiosk.
     *
     * <p>Two things changed upstream and both silently broke the old implementation:</p>
     *
     * <ul>
     *   <li>YouTube removed the classic Trending page on 2025-07-21, so the {@code Trending}
     *       kiosk now throws {@code Could not get "Now" or "Videos" trending tab}. What remains
     *       are the category kiosks ({@code trending_music}, {@code trending_gaming},
     *       {@code trending_movies_and_shows}, {@code trending_podcasts_episodes}) and
     *       {@code live}.</li>
     *   <li>Since NewPipeExtractor v0.25 the <em>default</em> kiosk is {@code live}, so the old
     *       {@code getDefaultKioskExtractor()} call had already started returning live streams
     *       under the name "trending".</li>
     * </ul>
     *
     * @param kioskId the kiosk to fetch, or null for the service default
     */
    @SuppressWarnings("unchecked")
    public static Map<Integer, Map<String, String>> getTrendingPage(final String kioskId)
            throws Exception {
        final KioskExtractor<? extends InfoItem> extractor =
                (KioskExtractor<? extends InfoItem>) (kioskId == null || kioskId.isEmpty()
                        ? YouTube.getKioskList().getDefaultKioskExtractor()
                        : YouTube.getKioskList().getExtractorById(kioskId, null));
        extractor.fetchPage();

        final ListExtractor.InfoItemsPage<? extends InfoItem> page = extractor.getInitialPage();

        // Some kiosks mix in non-stream items; the Dart API only exposes streams.
        final List<StreamInfoItem> streams = new ArrayList<>();
        for (final InfoItem item : page.getItems()) {
            if (item instanceof StreamInfoItem) {
                streams.add((StreamInfoItem) item);
            }
        }
        return FetchData.fetchStreamInfoItems(streams);
    }

    /** Kiosk ids this build of NewPipeExtractor knows about. */
    public static List<String> getAvailableKiosks() throws Exception {
        final Set<String> kiosks = YouTube.getKioskList().getAvailableKiosks();
        return new ArrayList<>(kiosks);
    }
}
