package com.artxdev.newpipeextractor_dart;

public interface BasePlaylistExtractor extends BaseListExtractor {
    void thumbnailUrl() throws Exception;
    void bannerUrl() throws Exception;
    void uploaderName() throws Exception;
    void uploaderAvatarUrl() throws Exception;
    void streamCount() throws Exception;
    void uploaderVerified() throws Exception;
}
