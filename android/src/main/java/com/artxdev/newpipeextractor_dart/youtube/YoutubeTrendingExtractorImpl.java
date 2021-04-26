package com.artxdev.newpipeextractor_dart.youtube;

import org.schabi.newpipe.extractor.ListExtractor;
import org.schabi.newpipe.extractor.services.youtube.extractors.YoutubeTrendingExtractor;
import org.schabi.newpipe.extractor.stream.StreamInfoItem;

import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.schabi.newpipe.extractor.ServiceList.YouTube;

public class YoutubeTrendingExtractorImpl {

    private static YoutubeTrendingExtractor extractor;
    private static ListExtractor.InfoItemsPage<StreamInfoItem> itemsPage;

    public static Map<Integer, Map<String, String>> getTrendingPage() throws Exception {
        extractor = (YoutubeTrendingExtractor) YouTube.getKioskList().getDefaultKioskExtractor();
        extractor.fetchPage();
        itemsPage = extractor.getInitialPage();
        List<StreamInfoItem> items = itemsPage.getItems();
        Map<Integer, Map<String, String>> itemsMap = new HashMap<>();
        for(int i = 0; i < items.size(); i++) {
            StreamInfoItem item = items.get(i);
            Map<String, String> itemMap = new HashMap<>();
            itemMap.put("name", item.getName());
            itemMap.put("uploaderName", item.getUploaderName());
            itemMap.put("uploaderUrl", item.getUploaderUrl());
            itemMap.put("uploadDate", item.getTextualUploadDate());
            try {
                itemMap.put("date", item.getUploadDate().offsetDateTime().format(DateTimeFormatter.ISO_DATE_TIME));
            } catch (NullPointerException ignore) {
                itemMap.put("date", null);
            }
            itemMap.put("thumbnailUrl", item.getThumbnailUrl());
            itemMap.put("duration", String.valueOf(item.getDuration()));
            itemMap.put("viewCount", String.valueOf(item.getViewCount()));
            itemMap.put("url", item.getUrl());
            itemMap.put("id", YoutubeLinkHandler.getIdFromStreamUrl(item.getUrl()));
            itemsMap.put(i, itemMap);
        }
        return itemsMap;
    }
}
