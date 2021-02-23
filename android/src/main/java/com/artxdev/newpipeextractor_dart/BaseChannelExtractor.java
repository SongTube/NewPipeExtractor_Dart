package com.artxdev.newpipeextractor_dart;

public interface BaseChannelExtractor extends BaseListExtractor {
    void description() throws Exception;
    void avatarUrl() throws Exception;
    void bannerUrl() throws Exception;
    void feedUrl() throws Exception;
    void subscriberCount() throws Exception;
    void verified() throws Exception;
}
