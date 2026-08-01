package com.artxdev.newpipeextractor_dart.youtube;

import com.artxdev.newpipeextractor_dart.FetchData;

import org.schabi.newpipe.extractor.ListExtractor.InfoItemsPage;
import org.schabi.newpipe.extractor.comments.CommentsExtractor;
import org.schabi.newpipe.extractor.comments.CommentsInfoItem;

import static org.schabi.newpipe.extractor.ServiceList.YouTube;

import java.util.Map;

public final class YoutubeCommentsExtractorImpl {

    private YoutubeCommentsExtractorImpl() {
    }

    public static Map<Integer, Map<String, String>> getComments(final String url) throws Exception {
        final CommentsExtractor extractor = YouTube.getCommentsExtractor(url);
        extractor.fetchPage();
        final InfoItemsPage<CommentsInfoItem> page = extractor.getInitialPage();
        return FetchData.indexed(page.getItems(), FetchData::fetchCommentInfoItem);
    }
}
