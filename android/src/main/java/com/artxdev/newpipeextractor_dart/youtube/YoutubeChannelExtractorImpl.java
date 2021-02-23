package com.artxdev.newpipeextractor_dart.youtube;

import com.artxdev.newpipeextractor_dart.downloader.DownloaderImpl;

import org.schabi.newpipe.extractor.NewPipe;
import org.schabi.newpipe.extractor.services.youtube.extractors.YoutubeChannelExtractor;

import java.util.HashMap;
import java.util.Map;

import static org.schabi.newpipe.extractor.ServiceList.YouTube;

public class YoutubeChannelExtractorImpl {

    private static YoutubeChannelExtractor extractor;

    public static Map<String, String> getChannel(String url) throws Exception {
        NewPipe.init(DownloaderImpl.getInstance());
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

}