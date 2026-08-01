package com.artxdev.newpipeextractor_dart.youtube;

import com.artxdev.newpipeextractor_dart.FetchData;

import org.schabi.newpipe.extractor.InfoItem;
import org.schabi.newpipe.extractor.ListExtractor;
import org.schabi.newpipe.extractor.channel.ChannelExtractor;
import org.schabi.newpipe.extractor.channel.tabs.ChannelTabExtractor;
import org.schabi.newpipe.extractor.channel.tabs.ChannelTabs;
import org.schabi.newpipe.extractor.linkhandler.ListLinkHandler;
import org.schabi.newpipe.extractor.stream.StreamInfoItem;

import static org.schabi.newpipe.extractor.ServiceList.YouTube;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

public class YoutubeChannelExtractorImpl {

    private ChannelTabExtractor uploadsExtractor;
    private ListExtractor.InfoItemsPage<InfoItem> currentPage;

    public Map<String, String> getChannel(final String url) throws Exception {
        // No cast to YoutubeChannelExtractor: every field read below is on the base class, and
        // the concrete type varies (age-gated channels use a different implementation).
        final ChannelExtractor extractor = YouTube.getChannelExtractor(url);
        extractor.fetchPage();

        final Map<String, String> channelMap = new java.util.HashMap<>();
        channelMap.put("url", extractor.getUrl());
        channelMap.put("id", extractor.getId());
        channelMap.put("name", extractor.getName());
        channelMap.put("avatars", FetchData.imagesToJson(extractor.getAvatars()));
        channelMap.put("banners", FetchData.imagesToJson(extractor.getBanners()));
        channelMap.put("description", extractor.getDescription());
        channelMap.put("subscriberCount", String.valueOf(extractor.getSubscriberCount()));
        channelMap.put("verified", String.valueOf(extractor.isVerified()));
        try {
            channelMap.put("feedUrl", extractor.getFeedUrl());
        } catch (final Exception ignored) {
            channelMap.put("feedUrl", null);
        }
        return channelMap;
    }

    /**
     * Uploads come from the channel's "Videos" tab.
     *
     * <p>This used to go through the RSS {@code FeedExtractor}, which caps out at ~15 items and
     * exposes no next page -- so {@link #getChannelNextPage()} could never return anything. The
     * tab extractor pages properly.</p>
     */
    public Map<Integer, Map<String, String>> getChannelUploads(final String url) throws Exception {
        final ChannelExtractor channel = YouTube.getChannelExtractor(url);
        channel.fetchPage();

        final ListLinkHandler videosTab = findTab(channel.getTabs(), ChannelTabs.VIDEOS);
        if (videosTab == null) {
            throw new IllegalStateException("Channel has no videos tab: " + url);
        }

        uploadsExtractor = YouTube.getChannelTabExtractor(videosTab);
        uploadsExtractor.fetchPage();
        currentPage = uploadsExtractor.getInitialPage();
        return streamItems(currentPage.getItems());
    }

    public Map<Integer, Map<String, String>> getChannelNextPage() throws Exception {
        if (uploadsExtractor == null || currentPage == null) {
            throw new IllegalStateException(
                    "getChannelUploads must be called before getChannelNextPage");
        }
        if (!currentPage.hasNextPage()) {
            return Collections.emptyMap();
        }
        currentPage = uploadsExtractor.getPage(currentPage.getNextPage());
        return streamItems(currentPage.getItems());
    }

    private static ListLinkHandler findTab(final List<ListLinkHandler> tabs, final String name) {
        if (tabs == null) {
            return null;
        }
        for (final ListLinkHandler tab : tabs) {
            if (tab.getContentFilters().contains(name)) {
                return tab;
            }
        }
        return null;
    }

    /** A channel tab yields mixed {@link InfoItem}s; the uploads API only exposes streams. */
    private static Map<Integer, Map<String, String>> streamItems(final List<InfoItem> items) {
        final List<StreamInfoItem> streams = new ArrayList<>();
        if (items != null) {
            for (final InfoItem item : items) {
                if (item instanceof StreamInfoItem) {
                    streams.add((StreamInfoItem) item);
                }
            }
        }
        return FetchData.fetchStreamInfoItems(streams);
    }
}
