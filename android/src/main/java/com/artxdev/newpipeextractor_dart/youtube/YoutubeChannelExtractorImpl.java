package com.artxdev.newpipeextractor_dart.youtube;

import com.artxdev.newpipeextractor_dart.downloader.DownloaderImpl;

import org.schabi.newpipe.extractor.ListExtractor;
import org.schabi.newpipe.extractor.NewPipe;
import org.schabi.newpipe.extractor.Page;
import org.schabi.newpipe.extractor.feed.FeedExtractor;
import org.schabi.newpipe.extractor.services.youtube.extractors.YoutubeChannelExtractor;
import org.schabi.newpipe.extractor.services.youtube.extractors.YoutubeFeedExtractor;
import org.schabi.newpipe.extractor.stream.StreamInfo;
import org.schabi.newpipe.extractor.stream.StreamInfoItem;

import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import static org.schabi.newpipe.extractor.ServiceList.YouTube;

import android.os.Build;

public class YoutubeChannelExtractorImpl {

    private YoutubeChannelExtractor extractor;
    private FeedExtractor feedExtractor;

    private ListExtractor.InfoItemsPage<StreamInfoItem> currentPage;

    public Map<String, String> getChannel(String url) throws Exception {
        extractor = (YoutubeChannelExtractor) YouTube
                .getChannelExtractor(url);
        extractor.fetchPage();
        Map<String, String> channelMap = new HashMap<String, String>();
        channelMap.put("url", extractor.getUrl());
        channelMap.put("avatarUrl", extractor.getAvatars().get(0).getUrl());
        channelMap.put("bannerUrl", extractor.getBanners().get(0).getUrl());
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
        feedExtractor = YouTube.getFeedExtractor(extractor.getFeedUrl());
        currentPage = feedExtractor.getInitialPage();
        List<StreamInfoItem> items = currentPage.getItems();
        return parseData(items);
    }

    public Map<Integer, Map<String, String>> getChannelNextPage() throws Exception {
        if (currentPage.hasNextPage()) {
            currentPage = feedExtractor.getPage(currentPage.getNextPage());
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
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                itemMap.put("date", Objects.requireNonNull(item.getUploadDate()).offsetDateTime().format(DateTimeFormatter.ISO_DATE_TIME));
            } else {
                itemMap.put("date", null);
            }
            itemMap.put("thumbnailUrl", item.getThumbnails().get(0).getUrl());
            itemMap.put("duration", String.valueOf(item.getDuration()));
            itemMap.put("viewCount", String.valueOf(item.getViewCount()));
            itemMap.put("url", item.getUrl());
            itemMap.put("id", YoutubeLinkHandler.getIdFromStreamUrl(item.getUrl()));
            itemsMap.put(i, itemMap);
        }
        return itemsMap;
    }
}