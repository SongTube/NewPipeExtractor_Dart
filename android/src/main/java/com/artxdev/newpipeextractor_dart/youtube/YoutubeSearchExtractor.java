package com.artxdev.newpipeextractor_dart.youtube;

import com.artxdev.newpipeextractor_dart.FetchData;

import org.schabi.newpipe.extractor.InfoItem;
import org.schabi.newpipe.extractor.ListExtractor;
import org.schabi.newpipe.extractor.search.SearchExtractor;

import static org.schabi.newpipe.extractor.ServiceList.YouTube;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

public class YoutubeSearchExtractor {

    private SearchExtractor extractor;
    private ListExtractor.InfoItemsPage<InfoItem> itemsPage;

    public Map<String, Map<Integer, Map<String, String>>> searchYoutube(
            final String query, final List<String> filters) throws Exception {
        // Defensive copy: the list arrives straight off the method channel.
        final List<String> contentFilter =
                filters == null ? Collections.emptyList() : new ArrayList<>(filters);
        extractor = YouTube.getSearchExtractor(query, contentFilter, "");
        extractor.fetchPage();
        itemsPage = extractor.getInitialPage();
        return FetchData.fetchInfoItems(itemsPage.getItems());
    }

    public Map<String, Map<Integer, Map<String, String>>> getNextPage() throws Exception {
        if (extractor == null || itemsPage == null) {
            throw new IllegalStateException("searchYoutube must be called before getNextPage");
        }
        if (!itemsPage.hasNextPage()) {
            // Still the full bucket shape, so the Dart parser can index into it safely.
            return FetchData.fetchInfoItems(Collections.emptyList());
        }
        itemsPage = extractor.getPage(itemsPage.getNextPage());
        return FetchData.fetchInfoItems(itemsPage.getItems());
    }
}
