package com.artxdev.newpipeextractor_dart;

import com.artxdev.newpipeextractor_dart.youtube.YoutubeLinkHandler;

import org.schabi.newpipe.extractor.exceptions.ParsingException;
import org.schabi.newpipe.extractor.stream.AudioStream;
import org.schabi.newpipe.extractor.stream.StreamExtractor;
import org.schabi.newpipe.extractor.stream.StreamInfoItem;
import org.schabi.newpipe.extractor.stream.StreamSegment;
import org.schabi.newpipe.extractor.stream.VideoStream;

import java.util.HashMap;
import java.util.Map;

public class FetchData {

    static public Map<String, String> fetchVideoInfo(StreamExtractor extractor) {
        Map<String, String> videoInformationMap = new HashMap<>();
        try {
            videoInformationMap.put("id", extractor.getId());
        } catch(ParsingException ignored) {
        }
        try {
            videoInformationMap.put("url", extractor.getUrl());
        } catch (ParsingException ignored) {
        }
        try {
            videoInformationMap.put("name", extractor.getName());
        } catch (ParsingException ignored) {
        }
        try {
            videoInformationMap.put("uploaderName", extractor.getUploaderName());
        } catch (ParsingException ignored) {
        }
        try {
            videoInformationMap.put("uploaderUrl", extractor.getUploaderUrl());
        } catch (ParsingException ignored) {
        }
        try {
            videoInformationMap.put("uploaderAvatarUrl", extractor.getUploaderAvatarUrl());
        } catch (ParsingException ignored) {
        }
        try {
            videoInformationMap.put("uploadDate", extractor.getTextualUploadDate());
        } catch (ParsingException ignored) {
        }
        try {
            videoInformationMap.put("description", extractor.getDescription().getContent());
        } catch (ParsingException ignored) {
        }
        try {
            videoInformationMap.put("length", String.valueOf(extractor.getLength()));
        } catch (ParsingException ignored) {
        }
        try {
            videoInformationMap.put("viewCount", String.valueOf(extractor.getViewCount()));
        } catch (ParsingException ignored) {
        }
        try {
            videoInformationMap.put("likeCount", String.valueOf(extractor.getLikeCount()));
        } catch (ParsingException ignored) {
        }
        try {
            videoInformationMap.put("dislikeCount", String.valueOf(extractor.getDislikeCount()));
        } catch (ParsingException ignored) {
        }
        try {
            videoInformationMap.put("category", extractor.getCategory());
        } catch (ParsingException ignored) {
        }
        try {
            videoInformationMap.put("ageLimit", String.valueOf(extractor.getAgeLimit()));
        } catch (ParsingException ignored) {
        }
        try {
            videoInformationMap.put("tags", extractor.getTags().toString());
        } catch (ParsingException ignored) {
        }
        try {
            videoInformationMap.put("thumbnailUrl", extractor.getThumbnailUrl());
        } catch (ParsingException ignored) {
        }
        return videoInformationMap;
    }

    static public Map<String, String> fetchAudioStreamInfo(AudioStream stream) {
        Map<String, String> streamMap = new HashMap<>();
        streamMap.put("torrentUrl", stream.getUrl());
        streamMap.put("url", stream.getUrl());
        streamMap.put("averageBitrate", String.valueOf(stream.getAverageBitrate()));
        streamMap.put("formatName", stream.getFormat().name);
        streamMap.put("formatSuffix", stream.getFormat().suffix);
        streamMap.put("formatMimeType", stream.getFormat().mimeType);
        return streamMap;
    }

    static public Map<String, String> fetchVideoStreamInfo(VideoStream stream) {
        Map<String, String> streamMap = new HashMap<>();
        streamMap.put("torrentUrl", stream.getUrl());
        streamMap.put("url", stream.getUrl());
        streamMap.put("resolution", stream.getResolution());
        streamMap.put("formatName", stream.getFormat().name);
        streamMap.put("formatSuffix", stream.getFormat().suffix);
        streamMap.put("formatMimeType", stream.getFormat().mimeType);
        return streamMap;
    }

    static public Map<String, String> fetchRelatedStream(StreamInfoItem item) {
        Map<String, String> itemMap = new HashMap<>();
        itemMap.put("name", item.getName());
        itemMap.put("uploaderName", item.getUploaderName());
        itemMap.put("uploaderUrl", item.getUploaderUrl());
        itemMap.put("uploadDate", item.getTextualUploadDate());
        itemMap.put("thumbnailUrl", item.getThumbnailUrl());
        itemMap.put("duration", String.valueOf(item.getDuration()));
        itemMap.put("viewCount", String.valueOf(item.getViewCount()));
        itemMap.put("url", item.getUrl());
        itemMap.put("id", YoutubeLinkHandler.getIdFromStreamUrl(item.getUrl()));
        return itemMap;
    }

    static public Map<String, String> fetchStreamSegment(StreamSegment segment) {
        Map<String, String> itemMap = new HashMap<>();
        itemMap.put("url", segment.getUrl());
        itemMap.put("title", segment.getTitle());
        itemMap.put("previewUrl", segment.getPreviewUrl());
        itemMap.put("startTimeSeconds", String.valueOf(segment.getStartTimeSeconds()));
        return itemMap;
    }

}
