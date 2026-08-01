package com.artxdev.newpipeextractor_dart;

import com.artxdev.newpipeextractor_dart.youtube.YoutubeLinkHandler;
import com.google.gson.Gson;

import org.schabi.newpipe.extractor.Image;
import org.schabi.newpipe.extractor.InfoItem;
import org.schabi.newpipe.extractor.MediaFormat;
import org.schabi.newpipe.extractor.channel.ChannelInfoItem;
import org.schabi.newpipe.extractor.comments.CommentsInfoItem;
import org.schabi.newpipe.extractor.localization.DateWrapper;
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

/**
 * Converts NewPipeExtractor model objects into the plain {@code Map<String, String>} shape the
 * Dart side parses.
 *
 * <p>Every stream / playlist / channel item is serialized through the helpers here so the key
 * names stay consistent across extractors. They used to be copy-pasted per extractor, which is
 * how {@code thumbnails} ended up spelled {@code thumbnailUrl} on the channel-uploads path.</p>
 */
public final class FetchData {

    private static final Gson GSON = new Gson();

    private FetchData() {
    }

    /**
     * Serializes a list of {@link Image} to a JSON array of URLs. Never returns null, so the Dart
     * side can always {@code jsonDecode} the value.
     */
    public static String imagesToJson(final List<Image> images) {
        final List<String> urls = new ArrayList<>();
        if (images != null) {
            for (final Image image : images) {
                if (image != null && image.getUrl() != null) {
                    urls.add(image.getUrl());
                }
            }
        }
        return GSON.toJson(urls);
    }

    private static String formatDate(final DateWrapper date) {
        if (date == null) {
            return null;
        }
        try {
            return date.offsetDateTime().format(DateTimeFormatter.ISO_OFFSET_DATE_TIME);
        } catch (final Exception ignored) {
            return null;
        }
    }

    /**
     * {@link MediaFormat} is null for streams whose itag the extractor doesn't recognise. The old
     * code dereferenced it unconditionally, which aborted the whole extraction.
     */
    private static void putFormat(final Map<String, String> map, final MediaFormat format) {
        map.put("formatName", format == null ? null : format.getName());
        map.put("formatSuffix", format == null ? null : format.getSuffix());
        map.put("formatMimeType", format == null ? null : format.getMimeType());
    }

    public static Map<String, String> fetchVideoInfo(final StreamExtractor extractor) {
        final Map<String, String> map = new HashMap<>();
        try {
            map.put("id", extractor.getId());
        } catch (final Exception ignored) {
        }
        try {
            map.put("url", extractor.getUrl());
        } catch (final Exception ignored) {
        }
        try {
            map.put("name", extractor.getName());
        } catch (final Exception ignored) {
        }
        try {
            map.put("uploaderName", extractor.getUploaderName());
        } catch (final Exception ignored) {
        }
        try {
            map.put("uploaderUrl", extractor.getUploaderUrl());
        } catch (final Exception ignored) {
        }
        try {
            map.put("uploaderAvatars", imagesToJson(extractor.getUploaderAvatars()));
        } catch (final Exception ignored) {
        }
        try {
            map.put("uploadDate", extractor.getTextualUploadDate());
        } catch (final Exception ignored) {
        }
        try {
            map.put("date", formatDate(extractor.getUploadDate()));
        } catch (final Exception ignored) {
        }
        try {
            map.put("description", extractor.getDescription().getContent());
        } catch (final Exception ignored) {
        }
        try {
            map.put("length", String.valueOf(extractor.getLength()));
        } catch (final Exception ignored) {
        }
        try {
            map.put("viewCount", String.valueOf(extractor.getViewCount()));
        } catch (final Exception ignored) {
        }
        try {
            map.put("likeCount", String.valueOf(extractor.getLikeCount()));
        } catch (final Exception ignored) {
        }
        try {
            map.put("dislikeCount", String.valueOf(extractor.getDislikeCount()));
        } catch (final Exception ignored) {
        }
        try {
            map.put("category", extractor.getCategory());
        } catch (final Exception ignored) {
        }
        try {
            map.put("ageLimit", String.valueOf(extractor.getAgeLimit()));
        } catch (final Exception ignored) {
        }
        try {
            map.put("tags", GSON.toJson(extractor.getTags()));
        } catch (final Exception ignored) {
        }
        try {
            map.put("thumbnails", imagesToJson(extractor.getThumbnails()));
        } catch (final Exception ignored) {
        }
        return map;
    }

    public static Map<String, String> fetchAudioStreamInfo(final AudioStream stream) {
        final Map<String, String> map = new HashMap<>();
        map.put("torrentUrl", stream.getContent());
        map.put("url", stream.getContent());
        map.put("averageBitrate", String.valueOf(stream.getAverageBitrate()));
        map.put("bitrate", String.valueOf(stream.getBitrate()));
        map.put("audioTrackName", stream.getAudioTrackName());
        putFormat(map, stream.getFormat());
        return map;
    }

    public static Map<String, String> fetchVideoStreamInfo(final VideoStream stream) {
        final Map<String, String> map = new HashMap<>();
        map.put("torrentUrl", stream.getContent());
        map.put("url", stream.getContent());
        map.put("resolution", stream.getResolution());
        putFormat(map, stream.getFormat());
        return map;
    }

    public static Map<String, String> fetchPlaylistInfoItem(final PlaylistInfoItem item) {
        final Map<String, String> map = new HashMap<>();
        map.put("name", item.getName());
        map.put("uploaderName", item.getUploaderName());
        map.put("url", item.getUrl());
        map.put("id", YoutubeLinkHandler.getIdFromPlaylistUrl(item.getUrl()));
        map.put("thumbnails", imagesToJson(item.getThumbnails()));
        map.put("streamCount", String.valueOf(item.getStreamCount()));
        return map;
    }

    public static Map<String, String> fetchChannelInfoItem(final ChannelInfoItem item) {
        final Map<String, String> map = new HashMap<>();
        map.put("name", item.getName());
        map.put("thumbnails", imagesToJson(item.getThumbnails()));
        map.put("url", item.getUrl());
        map.put("id", YoutubeLinkHandler.getIdFromChannelUrl(item.getUrl()));
        map.put("description", item.getDescription());
        map.put("streamCount", String.valueOf(item.getStreamCount()));
        map.put("subscriberCount", String.valueOf(item.getSubscriberCount()));
        return map;
    }

    public static Map<String, String> fetchStreamInfoItem(final StreamInfoItem item) {
        final Map<String, String> map = new HashMap<>();
        map.put("name", item.getName());
        map.put("uploaderName", item.getUploaderName());
        map.put("uploaderUrl", item.getUploaderUrl());
        map.put("uploadDate", item.getTextualUploadDate());
        map.put("date", formatDate(item.getUploadDate()));
        map.put("thumbnails", imagesToJson(item.getThumbnails()));
        map.put("uploaderAvatars", imagesToJson(item.getUploaderAvatars()));
        map.put("duration", String.valueOf(item.getDuration()));
        map.put("viewCount", String.valueOf(item.getViewCount()));
        map.put("url", item.getUrl());
        map.put("id", YoutubeLinkHandler.getIdFromStreamUrl(item.getUrl()));
        return map;
    }

    public static Map<String, String> fetchCommentInfoItem(final CommentsInfoItem comment) {
        final Map<String, String> map = new HashMap<>();
        map.put("commentId", comment.getCommentId());
        map.put("author", comment.getUploaderName());
        map.put("commentText",
                comment.getCommentText() == null ? null : comment.getCommentText().getContent());
        map.put("uploaderAvatars", imagesToJson(comment.getUploaderAvatars()));
        map.put("uploadDate", comment.getTextualUploadDate());
        map.put("uploaderUrl", comment.getUploaderUrl());
        map.put("likeCount", String.valueOf(comment.getLikeCount()));
        map.put("replyCount", String.valueOf(comment.getReplyCount()));
        map.put("pinned", String.valueOf(comment.isPinned()));
        map.put("hearted", String.valueOf(comment.isHeartedByUploader()));
        return map;
    }

    public static Map<String, String> fetchStreamSegment(final StreamSegment segment) {
        final Map<String, String> map = new HashMap<>();
        map.put("url", segment.getUrl());
        map.put("title", segment.getTitle());
        map.put("previewUrl", segment.getPreviewUrl());
        map.put("startTimeSeconds", String.valueOf(segment.getStartTimeSeconds()));
        return map;
    }

    public interface Serializer<T> {
        Map<String, String> serialize(T item);
    }

    /** Indexes already-serialized items by position, which is the shape Dart expects. */
    public static <T> Map<Integer, Map<String, String>> indexed(
            final List<T> items, final Serializer<T> serializer) {
        final Map<Integer, Map<String, String>> map = new HashMap<>();
        if (items == null) {
            return map;
        }
        for (int i = 0; i < items.size(); i++) {
            map.put(i, serializer.serialize(items.get(i)));
        }
        return map;
    }

    public static Map<Integer, Map<String, String>> fetchStreamInfoItems(
            final List<StreamInfoItem> items) {
        return indexed(items, FetchData::fetchStreamInfoItem);
    }

    public static Map<Integer, Map<String, String>> fetchStreamSegments(
            final List<StreamSegment> segments) {
        return indexed(segments, FetchData::fetchStreamSegment);
    }

    /**
     * Splits a mixed list of info items into the {@code streams} / {@code channels} /
     * {@code playlists} buckets the Dart {@code StreamsParser} reads.
     */
    public static Map<String, Map<Integer, Map<String, String>>> fetchInfoItems(
            final List<? extends InfoItem> items) {
        final List<StreamInfoItem> streams = new ArrayList<>();
        final List<PlaylistInfoItem> playlists = new ArrayList<>();
        final List<ChannelInfoItem> channels = new ArrayList<>();

        if (items != null) {
            for (final InfoItem item : items) {
                if (item instanceof StreamInfoItem) {
                    streams.add((StreamInfoItem) item);
                } else if (item instanceof ChannelInfoItem) {
                    channels.add((ChannelInfoItem) item);
                } else if (item instanceof PlaylistInfoItem) {
                    playlists.add((PlaylistInfoItem) item);
                }
            }
        }

        final Map<String, Map<Integer, Map<String, String>>> results = new HashMap<>();
        results.put("streams", indexed(streams, FetchData::fetchStreamInfoItem));
        results.put("channels", indexed(channels, FetchData::fetchChannelInfoItem));
        results.put("playlists", indexed(playlists, FetchData::fetchPlaylistInfoItem));
        return results;
    }
}
