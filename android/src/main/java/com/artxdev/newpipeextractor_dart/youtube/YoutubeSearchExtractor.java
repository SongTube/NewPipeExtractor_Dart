package com.artxdev.newpipeextractor_dart.youtube;

import com.artxdev.newpipeextractor_dart.FetchData;
import com.artxdev.newpipeextractor_dart.downloader.DownloaderImpl;

import org.schabi.newpipe.extractor.InfoItem;
import org.schabi.newpipe.extractor.ListExtractor;
import org.schabi.newpipe.extractor.NewPipe;
import org.schabi.newpipe.extractor.channel.ChannelInfoItem;
import org.schabi.newpipe.extractor.playlist.PlaylistInfoItem;
import org.schabi.newpipe.extractor.search.SearchExtractor;
import org.schabi.newpipe.extractor.search.SearchInfo;
import org.schabi.newpipe.extractor.services.youtube.extractors.YoutubeChannelExtractor;
import org.schabi.newpipe.extractor.services.youtube.extractors.YoutubeCommentsExtractor;
import org.schabi.newpipe.extractor.stream.StreamInfo;
import org.schabi.newpipe.extractor.stream.StreamInfoItem;
import org.schabi.newpipe.extractor.stream.StreamInfoItemsCollector;

import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.schabi.newpipe.extractor.ServiceList.YouTube;

public class YoutubeSearchExtractor {

    private SearchExtractor extractor;
    private ListExtractor.InfoItemsPage<InfoItem> itemsPage;

    public Map<String, Map<Integer, Map<String, String>>> searchYoutube(String query, List<String> filters) throws Exception {
        extractor = YouTube.getSearchExtractor(query, filters, "");
        extractor.fetchPage();
        itemsPage = extractor.getInitialPage();
        List<InfoItem> items = itemsPage.getItems();
        return FetchData.fetchInfoItems(items);
    }

    public Map<String, Map<Integer, Map<String, String>>> getNextPage() throws Exception {
        if (itemsPage.hasNextPage()) {
            itemsPage = extractor.getPage(itemsPage.getNextPage());
            List<InfoItem> items = itemsPage.getItems();
            return FetchData.fetchInfoItems(items);
        } else {
            return new HashMap<>();
        }
    }

}
