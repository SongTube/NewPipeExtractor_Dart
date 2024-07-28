package com.artxdev.newpipeextractor_dart;

import android.os.Build;

import com.artxdev.newpipeextractor_dart.youtube.YoutubeLinkHandler;
import com.google.gson.Gson;

import org.schabi.newpipe.extractor.Image;
import org.schabi.newpipe.extractor.InfoItem;
import org.schabi.newpipe.extractor.channel.ChannelInfoItem;
import org.schabi.newpipe.extractor.exceptions.ParsingException;
import org.schabi.newpipe.extractor.playlist.PlaylistInfo;
import org.schabi.newpipe.extractor.playlist.PlaylistInfoItem;
import org.schabi.newpipe.extractor.stream.AudioStream;
import org.schabi.newpipe.extractor.stream.StreamExtractor;
import org.schabi.newpipe.extractor.stream.StreamInfoItem;
import org.schabi.newpipe.extractor.stream.StreamSegment;
import org.schabi.newpipe.extractor.stream.VideoStream;

import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

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
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                videoInformationMap.put("uploaderAvatars", new Gson().toJson(extractor.getUploaderAvatars().stream().map(Image::getUrl).collect(Collectors.toList())));
            }
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
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                videoInformationMap.put("thumbnails", new Gson().toJson(extractor.getThumbnails().stream().map(Image::getUrl).collect(Collectors.toList())));
            }
        } catch (ParsingException ignored) {
        }
        return videoInformationMap;
    }

    static public Map<String, String> fetchAudioStreamInfo(AudioStream stream) {
        Map<String, String> streamMap = new HashMap<>();
        streamMap.put("torrentUrl", stream.getContent());
        streamMap.put("url", stream.getContent());
        streamMap.put("averageBitrate", String.valueOf(stream.getAverageBitrate()));
        streamMap.put("formatName", Objects.requireNonNull(stream.getFormat()).name);
        streamMap.put("formatSuffix", stream.getFormat().suffix);
        streamMap.put("formatMimeType", stream.getFormat().mimeType);
        return streamMap;
    }

    static public Map<String, String> fetchVideoStreamInfo(VideoStream stream) {
        Map<String, String> streamMap = new HashMap<>();
        streamMap.put("torrentUrl", stream.getContent());
        streamMap.put("url", stream.getContent());
        streamMap.put("resolution", stream.getResolution());
        streamMap.put("formatName", Objects.requireNonNull(stream.getFormat()).name);
        streamMap.put("formatSuffix", stream.getFormat().suffix);
        streamMap.put("formatMimeType", stream.getFormat().mimeType);
        return streamMap;
    }

    static public Map<String, String> fetchPlaylistInfoItem(PlaylistInfoItem item) {
        Map<String, String> itemMap = new HashMap<>();
        itemMap.put("name", item.getName());
        itemMap.put("uploaderName", item.getUploaderName());
        itemMap.put("url", item.getUrl());
        itemMap.put("id", YoutubeLinkHandler.getIdFromPlaylistUrl(item.getUrl()));
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            itemMap.put("thumbnails", new Gson().toJson(item.getThumbnails().stream().map(Image::getUrl).collect(Collectors.toList())));
        }
        itemMap.put("streamCount", String.valueOf(item.getStreamCount()));
        return itemMap;
    }

    static public Map<String, String> fetchStreamInfoItem(StreamInfoItem item) {
        Map<String, String> itemMap = new HashMap<>();
        itemMap.put("name", item.getName());
        itemMap.put("uploaderName", item.getUploaderName());
        itemMap.put("uploaderUrl", item.getUploaderUrl());
        itemMap.put("uploadDate", item.getTextualUploadDate());
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                itemMap.put("date", Objects.requireNonNull(item.getUploadDate()).offsetDateTime().format(DateTimeFormatter.ISO_DATE_TIME));
            } else {
                itemMap.put("date", null);
            }
        } catch (NullPointerException ignore) {
            itemMap.put("date", null);
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            itemMap.put("thumbnails", new Gson().toJson(item.getThumbnails().stream().map(Image::getUrl).collect(Collectors.toList())));
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            itemMap.put("uploaderAvatars", new Gson().toJson(item.getUploaderAvatars().stream().map(Image::getUrl).collect(Collectors.toList())));
        }
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

    static public Map<String, Map<Integer, Map<String, String>>> fetchInfoItems(List<InfoItem> items) {
        List<StreamInfoItem> streamsList = new ArrayList<>();
        List<PlaylistInfoItem> playlistsList = new ArrayList<>();
        List<ChannelInfoItem> channelsList = new ArrayList<>();
        Map<String, Map<Integer, Map<String, String>>> resultsList = new HashMap<>();
        for (int i = 0; i < items.size(); i++) {
            switch (items.get(i).getInfoType()) {
                case STREAM:
                    StreamInfoItem streamInfo = (StreamInfoItem) items.get(i);
                    streamsList.add(streamInfo);
                    break;
                case CHANNEL:
                    ChannelInfoItem channelInfo = (ChannelInfoItem) items.get(i);
                    channelsList.add(channelInfo);
                    break;
                case PLAYLIST:
                    PlaylistInfoItem playlistInfo = (PlaylistInfoItem) items.get(i);
                    playlistsList.add(playlistInfo);
                    break;
                default:
                    break;
            }
        }

        // Extract into a map Stream Results
        Map<Integer, Map<String, String>> streamResultsMap = new HashMap<>();
        if (!streamsList.isEmpty()) {
            for (int i = 0; i < streamsList.size(); i++) {
                StreamInfoItem item = streamsList.get(i);
                streamResultsMap.put(i, fetchStreamInfoItem(item));
            }
        }
        resultsList.put("streams", streamResultsMap);

        // Extract into a map Channel Results
        Map<Integer, Map<String, String>> channelResultsMap = new HashMap<>();
        if (!channelsList.isEmpty()) {
            for (int i = 0; i < channelsList.size(); i++) {
                Map<String, String> itemMap = new HashMap<>();
                ChannelInfoItem item = channelsList.get(i);
                itemMap.put("name", item.getName());
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    itemMap.put("thumbnails", new Gson().toJson(item.getThumbnails().stream().map(Image::getUrl).collect(Collectors.toList())));
                }
                itemMap.put("url", item.getUrl());
                itemMap.put("id", YoutubeLinkHandler.getIdFromChannelUrl(item.getUrl()));
                itemMap.put("description", item.getDescription());
                itemMap.put("streamCount", String.valueOf(item.getStreamCount()));
                itemMap.put("subscriberCount", String.valueOf(item.getSubscriberCount()));
                channelResultsMap.put(i, itemMap);
            }
        }
        resultsList.put("channels", channelResultsMap);

        // Extract into a map Playlist Results
        Map<Integer, Map<String, String>> playlistResultsMap = new HashMap<>();
        if (!playlistsList.isEmpty()) {
            for (int i = 0; i < playlistsList.size(); i++) {
                PlaylistInfoItem item = playlistsList.get(i);
                playlistResultsMap.put(i, fetchPlaylistInfoItem(item));
            }
        }
        resultsList.put("playlists", playlistResultsMap);
        return resultsList;
    }

}
