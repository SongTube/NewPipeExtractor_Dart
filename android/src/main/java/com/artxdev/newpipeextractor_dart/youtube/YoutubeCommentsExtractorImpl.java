package com.artxdev.newpipeextractor_dart.youtube;

import com.artxdev.newpipeextractor_dart.downloader.DownloaderImpl;

import org.schabi.newpipe.extractor.ListExtractor;
import org.schabi.newpipe.extractor.ListExtractor.InfoItemsPage;
import org.schabi.newpipe.extractor.NewPipe;
import org.schabi.newpipe.extractor.comments.CommentsInfoItem;
import org.schabi.newpipe.extractor.services.youtube.extractors.YoutubeCommentsExtractor;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.schabi.newpipe.extractor.ServiceList.YouTube;

public class YoutubeCommentsExtractorImpl {

    public static Map<Integer, Map<String, String>> getComments(String url) throws Exception {
        YoutubeCommentsExtractor extractor;
        extractor = (YoutubeCommentsExtractor) YouTube
                .getCommentsExtractor(url);
        extractor.fetchPage();
        Map<Integer, Map<String, String>> commentsMap = new HashMap<>();
        InfoItemsPage<CommentsInfoItem> commentsInfo = extractor.getInitialPage();
        List<CommentsInfoItem> comments = commentsInfo.getItems();
        for (int i = 0; i < comments.size(); i++) {
            CommentsInfoItem comment = comments.get(i);
            Map<String, String> commentMap = new HashMap<>();
            commentMap.put("commentId", comment.getCommentId());
            commentMap.put("author", comment.getUploaderName());
            commentMap.put("commentText", comment.getCommentText());
            commentMap.put("uploaderAvatarUrl", comment.getUploaderAvatarUrl());
            commentMap.put("uploadDate", comment.getTextualUploadDate());
            commentMap.put("uploaderUrl", comment.getUploaderUrl());
            commentMap.put("likeCount", String.valueOf(comment.getLikeCount()));
            commentMap.put("pinned", String.valueOf(comment.isPinned()));
            commentMap.put("hearted", String.valueOf(comment.isHeartedByUploader()));
            commentsMap.put(i, commentMap);
        }
        return commentsMap;
    }

}
