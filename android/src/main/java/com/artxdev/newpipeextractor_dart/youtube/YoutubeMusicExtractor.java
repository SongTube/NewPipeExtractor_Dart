package com.artxdev.newpipeextractor_dart.youtube;

import com.artxdev.newpipeextractor_dart.FetchData;

import org.schabi.newpipe.extractor.InfoItem;
import org.schabi.newpipe.extractor.ListExtractor;
import org.schabi.newpipe.extractor.search.SearchExtractor;
import org.schabi.newpipe.extractor.services.youtube.linkHandler.YoutubeSearchQueryHandlerFactory;

import static org.schabi.newpipe.extractor.ServiceList.YouTube;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

public class YoutubeMusicExtractor {

    private SearchExtractor extractor;
    private ListExtractor.InfoItemsPage<InfoItem> itemsPage;

    public Map<String, Map<Integer, Map<String, String>>> searchYoutube(
            final String query, final List<String> filters) throws Exception {
        final List<String> contentFilter = new ArrayList<>();
        if (filters == null || filters.isEmpty()) {
            contentFilter.add(YoutubeSearchQueryHandlerFactory.MUSIC_SONGS);
        } else {
            // The caller's filters win. Previously this started from
            // Collections.singletonList(MUSIC_SONGS) and then called addAll on it, which threw
            // UnsupportedOperationException for any non-empty filter list.
            contentFilter.addAll(filters);
        }
        extractor = YouTube.getSearchExtractor(query, contentFilter, "");
        extractor.fetchPage();
        itemsPage = extractor.getInitialPage();
        return FetchData.fetchInfoItems(itemsPage.getItems());
    }

    public Map<String, Map<Integer, Map<String, String>>> getNextPage() throws Exception {
        if (extractor == null || itemsPage == null) {
            throw new IllegalStateException("searchYoutubeMusic must be called before getNextPage");
        }
        if (!itemsPage.hasNextPage()) {
            return FetchData.fetchInfoItems(Collections.emptyList());
        }
        itemsPage = extractor.getPage(itemsPage.getNextPage());
        return FetchData.fetchInfoItems(itemsPage.getItems());
    }
}
