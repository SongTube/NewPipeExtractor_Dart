package com.artxdev.newpipeextractor_dart.youtube;

import com.artxdev.newpipeextractor_dart.downloader.DownloaderImpl;

import org.schabi.newpipe.extractor.NewPipe;
import org.schabi.newpipe.extractor.stream.AudioStream;
import org.schabi.newpipe.extractor.stream.StreamExtractor;
import org.schabi.newpipe.extractor.stream.StreamInfoItem;
import org.schabi.newpipe.extractor.stream.StreamSegment;
import org.schabi.newpipe.extractor.stream.VideoStream;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.schabi.newpipe.extractor.ServiceList.YouTube;

public class StreamExtractorImpl {

    public static Map<String, String> getInfo(String url) throws Exception {
        StreamExtractor extractor;
        extractor = YouTube.getStreamExtractor(url);
        extractor.fetchPage();
        // Extract all Video Information
        Map<String, String> videoInformationMap = new HashMap<String, String>();
        videoInformationMap.put("id", extractor.getId());
        videoInformationMap.put("url", extractor.getUrl());
        videoInformationMap.put("name", extractor.getName());
        videoInformationMap.put("uploaderName", extractor.getUploaderName());
        videoInformationMap.put("uploaderUrl", extractor.getUploaderUrl());
        videoInformationMap.put("uploaderAvatarUrl", extractor.getUploaderAvatarUrl());
        videoInformationMap.put("uploadDate", extractor.getTextualUploadDate());
        videoInformationMap.put("description", extractor.getDescription().getContent());
        videoInformationMap.put("length", String.valueOf(extractor.getLength()));
        videoInformationMap.put("viewCount", String.valueOf(extractor.getViewCount()));
        videoInformationMap.put("likeCount", String.valueOf(extractor.getLikeCount()));
        videoInformationMap.put("dislikeCount", String.valueOf(extractor.getDislikeCount()));
        videoInformationMap.put("category", extractor.getCategory());
        videoInformationMap.put("ageLimit", String.valueOf(extractor.getAgeLimit()));
        videoInformationMap.put("tags", extractor.getTags().toString());
        videoInformationMap.put("thumbnailUrl", extractor.getThumbnailUrl());
        return videoInformationMap;
    }

    public static List<Map> getStream(String url) throws Exception {
        StreamExtractor extractor;
        extractor = YouTube.getStreamExtractor(url);
        extractor.fetchPage();
        List<Map> listMaps = new ArrayList<>();

        // Extract all Video Information
        Map<String, String> videoInformationMap = new HashMap<>();
        videoInformationMap.put("id", extractor.getId());
        videoInformationMap.put("url", extractor.getUrl());
        videoInformationMap.put("name", extractor.getName());
        videoInformationMap.put("uploaderName", extractor.getUploaderName());
        videoInformationMap.put("uploaderUrl", extractor.getUploaderUrl());
        videoInformationMap.put("uploaderAvatarUrl", extractor.getUploaderAvatarUrl());
        videoInformationMap.put("uploadDate", extractor.getTextualUploadDate());
        videoInformationMap.put("description", extractor.getDescription().getContent());
        videoInformationMap.put("length", String.valueOf(extractor.getLength()));
        videoInformationMap.put("viewCount", String.valueOf(extractor.getViewCount()));
        videoInformationMap.put("likeCount", String.valueOf(extractor.getLikeCount()));
        videoInformationMap.put("dislikeCount", String.valueOf(extractor.getDislikeCount()));
        videoInformationMap.put("category", extractor.getCategory());
        videoInformationMap.put("ageLimit", String.valueOf(extractor.getAgeLimit()));
        videoInformationMap.put("tags", extractor.getTags().toString());
        videoInformationMap.put("thumbnailUrl", extractor.getThumbnailUrl());
        listMaps.add(videoInformationMap);

        // Extract all AudioOnlyStreams Information
        Map<Integer, Map<String, String>> audioOnlyStreamsMap = new HashMap<>();
        List<AudioStream> audioStreams = extractor.getAudioStreams();
        for (int i = 0; i < audioStreams.size(); i++) {
            AudioStream audioStream = audioStreams.get(i);
            Map<String, String> audioStreamMap = new HashMap<>();
            audioStreamMap.put("torrentUrl", audioStream.getTorrentUrl());
            audioStreamMap.put("url", audioStream.getUrl());
            audioStreamMap.put("averageBitrate", String.valueOf(audioStream.getAverageBitrate()));
            audioStreamMap.put("formatName", audioStream.getFormat().name);
            audioStreamMap.put("formatSuffix", audioStream.getFormat().suffix);
            audioStreamMap.put("formatMimeType", audioStream.getFormat().mimeType);
            audioOnlyStreamsMap.put(i, audioStreamMap);
        }
        listMaps.add(audioOnlyStreamsMap);

        // Extract all VideoOnlyStreams Information
        Map<Integer, Map<String, String>> videoOnlyStreamsMap = new HashMap<>();
        List<VideoStream> videoOnlyStreams = extractor.getVideoOnlyStreams();
        for (int i = 0; i < videoOnlyStreams.size(); i++) {
            VideoStream videoOnlyStream = videoOnlyStreams.get(i);
            Map<String, String> videoOnlyStreamMap = new HashMap<>();
            videoOnlyStreamMap.put("torrentUrl", videoOnlyStream.getTorrentUrl());
            videoOnlyStreamMap.put("url", videoOnlyStream.getUrl());
            videoOnlyStreamMap.put("resolution", videoOnlyStream.getResolution());
            videoOnlyStreamMap.put("formatName", videoOnlyStream.getFormat().name);
            videoOnlyStreamMap.put("formatSuffix", videoOnlyStream.getFormat().suffix);
            videoOnlyStreamMap.put("formatMimeType", videoOnlyStream.getFormat().mimeType);
            videoOnlyStreamsMap.put(i, videoOnlyStreamMap);
        }
        listMaps.add(videoOnlyStreamsMap);

        // Extract all VideoStreams Information (Streams which contains Audio)
        Map<Integer, Map<String, String>> videoStreamsMap = new HashMap<>();
        List<VideoStream> videoStreams = extractor.getVideoStreams();
        for (int i = 0; i < videoStreams.size(); i++) {
            VideoStream videoStream = videoStreams.get(i);
            Map<String, String> videoStreamMap = new HashMap<>();
            videoStreamMap.put("torrentUrl", videoStream.getTorrentUrl());
            videoStreamMap.put("url", videoStream.getUrl());
            videoStreamMap.put("resolution", videoStream.getResolution());
            videoStreamMap.put("formatName", videoStream.getFormat().name);
            videoStreamMap.put("formatSuffix", videoStream.getFormat().suffix);
            videoStreamMap.put("formatMimeType", videoStream.getFormat().mimeType);
            videoStreamsMap.put(i, videoStreamMap);
        }
        listMaps.add(videoStreamsMap);

        // Stream Segments
        listMaps.add(_fetchStreamSegments(extractor.getStreamSegments()));

        return listMaps;
    }

    public static List<Map> getMediaStreams(String url) throws Exception {
        StreamExtractor extractor;
        extractor = YouTube.getStreamExtractor(url);
        extractor.fetchPage();
        List<Map> listMaps = new ArrayList<>();

        // Extract all AudioOnlyStreams Information
        Map<Integer, Map<String, String>> audioOnlyStreamsMap = new HashMap<>();
        List<AudioStream> audioStreams = extractor.getAudioStreams();
        for (int i = 0; i < audioStreams.size(); i++) {
            AudioStream audioStream = audioStreams.get(i);
            Map<String, String> audioStreamMap = new HashMap<>();
            audioStreamMap.put("torrentUrl", audioStream.getTorrentUrl());
            audioStreamMap.put("url", audioStream.getUrl());
            audioStreamMap.put("averageBitrate", String.valueOf(audioStream.getAverageBitrate()));
            audioStreamMap.put("formatName", audioStream.getFormat().name);
            audioStreamMap.put("formatSuffix", audioStream.getFormat().suffix);
            audioStreamMap.put("formatMimeType", audioStream.getFormat().mimeType);
            audioOnlyStreamsMap.put(i, audioStreamMap);
        }
        listMaps.add(audioOnlyStreamsMap);

        // Extract all VideoOnlyStreams Information
        Map<Integer, Map<String, String>> videoOnlyStreamsMap = new HashMap<>();
        List<VideoStream> videoOnlyStreams = extractor.getVideoOnlyStreams();
        for (int i = 0; i < videoOnlyStreams.size(); i++) {
            VideoStream videoOnlyStream = videoOnlyStreams.get(i);
            Map<String, String> videoOnlyStreamMap = new HashMap<>();
            videoOnlyStreamMap.put("torrentUrl", videoOnlyStream.getTorrentUrl());
            videoOnlyStreamMap.put("url", videoOnlyStream.getUrl());
            videoOnlyStreamMap.put("resolution", videoOnlyStream.getResolution());
            videoOnlyStreamMap.put("formatName", videoOnlyStream.getFormat().name);
            videoOnlyStreamMap.put("formatSuffix", videoOnlyStream.getFormat().suffix);
            videoOnlyStreamMap.put("formatMimeType", videoOnlyStream.getFormat().mimeType);
            videoOnlyStreamsMap.put(i, videoOnlyStreamMap);
        }
        listMaps.add(videoOnlyStreamsMap);

        // Extract all VideoStreams Information (Streams which contains Audio)
        Map<Integer, Map<String, String>> videoStreamsMap = new HashMap<>();
        List<VideoStream> videoStreams = extractor.getVideoStreams();
        for (int i = 0; i < videoStreams.size(); i++) {
            VideoStream videoStream = videoStreams.get(i);
            Map<String, String> videoStreamMap = new HashMap<>();
            videoStreamMap.put("torrentUrl", videoStream.getTorrentUrl());
            videoStreamMap.put("url", videoStream.getUrl());
            videoStreamMap.put("resolution", videoStream.getResolution());
            videoStreamMap.put("formatName", videoStream.getFormat().name);
            videoStreamMap.put("formatSuffix", videoStream.getFormat().suffix);
            videoStreamMap.put("formatMimeType", videoStream.getFormat().mimeType);
            videoStreamsMap.put(i, videoStreamMap);
        }
        listMaps.add(videoStreamsMap);

        // Stream Segments
        listMaps.add(_fetchStreamSegments(extractor.getStreamSegments()));

        return listMaps;
    }

    public static Map<Integer, Map<String, String>> getVideoOnlyStreams(String url) throws Exception {
        StreamExtractor extractor;
        extractor = YouTube.getStreamExtractor(url);
        extractor.fetchPage();
        // Extract all VideoOnlyStreams Information
        Map<Integer, Map<String, String>> videoOnlyStreamsMap = new HashMap<>();
        List<VideoStream> videoOnlyStreams = extractor.getVideoOnlyStreams();
        for (int i = 0; i < videoOnlyStreams.size(); i++) {
            VideoStream videoOnlyStream = videoOnlyStreams.get(i);
            Map<String, String> videoOnlyStreamMap = new HashMap<>();
            videoOnlyStreamMap.put("torrentUrl", videoOnlyStream.getTorrentUrl());
            videoOnlyStreamMap.put("url", videoOnlyStream.getUrl());
            videoOnlyStreamMap.put("resolution", videoOnlyStream.getResolution());
            videoOnlyStreamMap.put("formatName", videoOnlyStream.getFormat().name);
            videoOnlyStreamMap.put("formatSuffix", videoOnlyStream.getFormat().suffix);
            videoOnlyStreamMap.put("formatMimeType", videoOnlyStream.getFormat().mimeType);
            videoOnlyStreamsMap.put(i, videoOnlyStreamMap);
        }
        return videoOnlyStreamsMap;
    }

    public static Map<Integer, Map<String, String>> getAudioOnlyStreams(String url) throws Exception {
        StreamExtractor extractor;
        extractor = YouTube.getStreamExtractor(url);
        extractor.fetchPage();
        // Extract all AudioOnlyStreams Information
        Map<Integer, Map<String, String>> audioOnlyStreamsMap = new HashMap<>();
        List<AudioStream> audioStreams = extractor.getAudioStreams();
        for (int i = 0; i < audioStreams.size(); i++) {
            AudioStream audioStream = audioStreams.get(i);
            Map<String, String> audioStreamMap = new HashMap<>();
            audioStreamMap.put("torrentUrl", audioStream.getTorrentUrl());
            audioStreamMap.put("url", audioStream.getUrl());
            audioStreamMap.put("averageBitrate", String.valueOf(audioStream.getAverageBitrate()));
            audioStreamMap.put("formatName", audioStream.getFormat().name);
            audioStreamMap.put("formatSuffix", audioStream.getFormat().suffix);
            audioStreamMap.put("formatMimeType", audioStream.getFormat().mimeType);
            audioOnlyStreamsMap.put(i, audioStreamMap);
        }
        return audioOnlyStreamsMap;
    }

    public static Map<Integer, Map<String, String>> getMuxedStreams(String url) throws Exception {
        StreamExtractor extractor;
        extractor = YouTube.getStreamExtractor(url);
        extractor.fetchPage();
        // Extract all VideoStreams Information (Streams which contains Audio)
        Map<Integer, Map<String, String>> videoStreamsMap = new HashMap<>();
        List<VideoStream> videoStreams = extractor.getVideoStreams();
        for (int i = 0; i < videoStreams.size(); i++) {
            VideoStream videoStream = videoStreams.get(i);
            Map<String, String> videoStreamMap = new HashMap<>();
            videoStreamMap.put("torrentUrl", videoStream.getTorrentUrl());
            videoStreamMap.put("url", videoStream.getUrl());
            videoStreamMap.put("resolution", videoStream.getResolution());
            videoStreamMap.put("formatName", videoStream.getFormat().name);
            videoStreamMap.put("formatSuffix", videoStream.getFormat().suffix);
            videoStreamMap.put("formatMimeType", videoStream.getFormat().mimeType);
            videoStreamsMap.put(i, videoStreamMap);
        }
        return videoStreamsMap;
    }

    public static Map<Integer, Map<String, String>> getRelatedStreams(String url) throws Exception {
        StreamExtractor extractor = YouTube.getStreamExtractor(url);
        extractor.fetchPage();
        List<StreamInfoItem> items = extractor.getRelatedStreams().getStreamInfoItemList();
        Map<Integer, Map<String, String>> itemsMap = new HashMap<>();
        for (int i = 0; i < items.size(); i++) {
            StreamInfoItem item = items.get(i);
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
            itemsMap.put(i, itemMap);
        }
        return itemsMap;
    }

    public static Map<Integer, Map<String, String>> getStreamSegments(String url) throws Exception {
        StreamExtractor extractor = YouTube.getStreamExtractor(url);
        extractor.fetchPage();
        List<StreamInfoItem> items = extractor.getRelatedStreams().getStreamInfoItemList();
        return _fetchStreamSegments(extractor.getStreamSegments());
    }

    public static Map<Integer, Map<String, String>> _fetchStreamSegments(List<StreamSegment> segments) {
        Map<Integer, Map<String, String>> itemsMap = new HashMap<>();
        for (int i = 0; i < segments.size(); i++) {
            StreamSegment segment = segments.get(i);
            Map<String, String> itemMap = new HashMap<>();
            itemMap.put("url", segment.getUrl());
            itemMap.put("title", segment.getTitle());
            itemMap.put("previewUrl", segment.getPreviewUrl());
            itemMap.put("startTimeSeconds", String.valueOf(segment.getStartTimeSeconds()));
            itemsMap.put(i, itemMap);
        }
        return itemsMap;
    }

}
