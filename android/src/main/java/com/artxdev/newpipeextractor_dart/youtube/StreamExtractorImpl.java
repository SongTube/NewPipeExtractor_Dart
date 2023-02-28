package com.artxdev.newpipeextractor_dart.youtube;

import com.artxdev.newpipeextractor_dart.FetchData;

import org.schabi.newpipe.extractor.InfoItem;
import org.schabi.newpipe.extractor.InfoItemExtractor;
import org.schabi.newpipe.extractor.InfoItemsCollector;
import org.schabi.newpipe.extractor.channel.ChannelInfoItem;
import org.schabi.newpipe.extractor.playlist.PlaylistInfoItem;
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
        return FetchData.fetchVideoInfo(extractor);
    }

    public static List<Map> getStream(String url) throws Exception {
        StreamExtractor extractor;
        extractor = YouTube.getStreamExtractor(url);
        extractor.fetchPage();
        List<Map> listMaps = new ArrayList<>();

        // Extract all Video Information
        listMaps.add(FetchData.fetchVideoInfo(extractor));

        // Extract all AudioOnlyStreams Information
        Map<Integer, Map<String, String>> audioOnlyStreamsMap = new HashMap<>();
        List<AudioStream> audioStreams = extractor.getAudioStreams();
        for (int i = 0; i < audioStreams.size(); i++) {
            AudioStream audioStream = audioStreams.get(i);
            audioOnlyStreamsMap.put(i, FetchData.fetchAudioStreamInfo(audioStream));
        }
        listMaps.add(audioOnlyStreamsMap);

        // Extract all VideoOnlyStreams Information
        Map<Integer, Map<String, String>> videoOnlyStreamsMap = new HashMap<>();
        List<VideoStream> videoOnlyStreams = extractor.getVideoOnlyStreams();
        for (int i = 0; i < videoOnlyStreams.size(); i++) {
            VideoStream videoOnlyStream = videoOnlyStreams.get(i);
            videoOnlyStreamsMap.put(i, FetchData.fetchVideoStreamInfo(videoOnlyStream));
        }
        listMaps.add(videoOnlyStreamsMap);

        // Extract all VideoStreams Information (Streams which contains Audio)
        Map<Integer, Map<String, String>> videoStreamsMap = new HashMap<>();
        List<VideoStream> videoStreams = extractor.getVideoStreams();
        for (int i = 0; i < videoStreams.size(); i++) {
            VideoStream videoStream = videoStreams.get(i);
            videoStreamsMap.put(i, FetchData.fetchVideoStreamInfo(videoStream));
        }
        listMaps.add(videoStreamsMap);

        // Stream Segments
        listMaps.add(fetchStreamSegments(extractor.getStreamSegments()));

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
            audioOnlyStreamsMap.put(i, FetchData.fetchAudioStreamInfo(audioStream));
        }
        listMaps.add(audioOnlyStreamsMap);

        // Extract all VideoOnlyStreams Information
        Map<Integer, Map<String, String>> videoOnlyStreamsMap = new HashMap<>();
        List<VideoStream> videoOnlyStreams = extractor.getVideoOnlyStreams();
        for (int i = 0; i < videoOnlyStreams.size(); i++) {
            VideoStream videoOnlyStream = videoOnlyStreams.get(i);
            videoOnlyStreamsMap.put(i, FetchData.fetchVideoStreamInfo(videoOnlyStream));
        }
        listMaps.add(videoOnlyStreamsMap);

        // Extract all VideoStreams Information (Streams which contains Audio)
        Map<Integer, Map<String, String>> videoStreamsMap = new HashMap<>();
        List<VideoStream> videoStreams = extractor.getVideoStreams();
        for (int i = 0; i < videoStreams.size(); i++) {
            VideoStream videoStream = videoStreams.get(i);
            videoStreamsMap.put(i, FetchData.fetchVideoStreamInfo(videoStream));
        }
        listMaps.add(videoStreamsMap);

        // Stream Segments
        listMaps.add(fetchStreamSegments(extractor.getStreamSegments()));

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
            videoOnlyStreamsMap.put(i, FetchData.fetchVideoStreamInfo(videoOnlyStream));
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
            audioOnlyStreamsMap.put(i, FetchData.fetchAudioStreamInfo(audioStream));
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
            videoStreamsMap.put(i, FetchData.fetchVideoStreamInfo(videoStream));
        }
        return videoStreamsMap;
    }

    public static Map<String, Map<Integer, Map<String, String>>> getRelatedStreams(String url) throws Exception {
        StreamExtractor extractor = YouTube.getStreamExtractor(url);
        extractor.fetchPage();
        InfoItemsCollector<? extends InfoItem, ? extends InfoItemExtractor> collector = extractor.getRelatedItems();
        List<InfoItem> items = (List<InfoItem>) collector.getItems();
        return FetchData.fetchInfoItems(items);
    }

    public static Map<Integer, Map<String, String>> getStreamSegments(String url) throws Exception {
        StreamExtractor extractor = YouTube.getStreamExtractor(url);
        extractor.fetchPage();
        return fetchStreamSegments(extractor.getStreamSegments());
    }

    public static Map<Integer, Map<String, String>> fetchStreamSegments(List<StreamSegment> segments) {
        Map<Integer, Map<String, String>> itemsMap = new HashMap<>();
        for (int i = 0; i < segments.size(); i++) {
            StreamSegment segment = segments.get(i);
            itemsMap.put(i, FetchData.fetchStreamSegment(segment));
        }
        return itemsMap;
    }

}
