package com.artxdev.newpipeextractor_dart.youtube;

import com.artxdev.newpipeextractor_dart.downloader.DownloaderImpl;

import org.schabi.newpipe.extractor.ListExtractor;
import org.schabi.newpipe.extractor.NewPipe;
import org.schabi.newpipe.extractor.Page;
import org.schabi.newpipe.extractor.services.youtube.extractors.YoutubeChannelExtractor;
import org.schabi.newpipe.extractor.stream.StreamInfo;
import org.schabi.newpipe.extractor.stream.StreamInfoItem;

import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.schabi.newpipe.extractor.ServiceList.YouTube;

public class YoutubeChannelExtractorImpl {

    private YoutubeChannelExtractor extractor;

    private ListExtractor.InfoItemsPage<StreamInfoItem> currentPage;

    public Map<String, String> getChannel(String url) throws Exception {
        extractor = (YoutubeChannelExtractor) YouTube
                .getChannelExtractor(url);
        extractor.fetchPage();
        Map<String, String> channelMap = new HashMap<String, String>();
        channelMap.put("url", extractor.getUrl());
        channelMap.put("avatarUrl", extractor.getAvatarUrl());
        channelMap.put("bannerUrl", extractor.getBannerUrl());
        channelMap.put("description", extractor.getDescription());
        channelMap.put("feedUrl", extractor.getFeedUrl());
        channelMap.put("id", extractor.getId());
        channelMap.put("name", extractor.getName());
        channelMap.put("subscriberCount", String.valueOf(extractor.getSubscriberCount()));
        return channelMap;
    }

    public Map<Integer, Map<String, String>> getChannelUploads(String url) throws Exception {
        extractor = (YoutubeChannelExtractor) YouTube
                .getChannelExtractor(url);
        extractor.fetchPage();
        currentPage = extractor.getInitialPage();
        List<StreamInfoItem> items = currentPage.getItems();
        return parseData(items);
    }

    public Map<Integer, Map<String, String>> getChannelNextPage() throws Exception {
        if (currentPage.hasNextPage()) {
            currentPage = extractor.getPage(currentPage.getNextPage());
            List<StreamInfoItem> items = currentPage.getItems();
            return parseData(items);
        } else {
            return new HashMap<>();
        }
    }

    public Map<Integer, Map<String, String>> parseData(List<StreamInfoItem> items) {
        Map<Integer, Map<String, String>> itemsMap = new HashMap<>();
        for (int i = 0; i < items.size(); i++) {
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