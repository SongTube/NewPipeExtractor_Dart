package com.artxdev.newpipeextractor_dart;

public interface BaseSearchExtractor extends BaseListExtractor {
    void searchString() throws Exception;
    void searchSuggestion() throws Exception;
    void searchCorrected() throws Exception;
}
