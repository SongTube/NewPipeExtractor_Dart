package com.artxdev.newpipeextractor_dart;

import android.os.AsyncTask;
import android.os.Handler;
import android.os.Looper;
import android.os.StrictMode;

import androidx.annotation.NonNull;

import com.artxdev.newpipeextractor_dart.downloader.DownloaderImpl;
import com.artxdev.newpipeextractor_dart.youtube.StreamExtractorImpl;
import com.artxdev.newpipeextractor_dart.youtube.YoutubeChannelExtractorImpl;
import com.artxdev.newpipeextractor_dart.youtube.YoutubeCommentsExtractorImpl;
import com.artxdev.newpipeextractor_dart.youtube.YoutubeLinkHandler;
import com.artxdev.newpipeextractor_dart.youtube.YoutubePlaylistExtractorImpl;
import com.artxdev.newpipeextractor_dart.youtube.YoutubeSearchExtractor;

import org.schabi.newpipe.extractor.NewPipe;
import org.schabi.newpipe.extractor.exceptions.ParsingException;
import org.schabi.newpipe.extractor.linkhandler.LinkHandler;
import org.schabi.newpipe.extractor.services.youtube.linkHandler.YoutubeChannelLinkHandlerFactory;
import org.schabi.newpipe.extractor.stream.StreamExtractor;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** NewpipeextractorDartPlugin */
public class NewpipeextractorDartPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  private final YoutubeSearchExtractor searchExtractor
          = new YoutubeSearchExtractor();
  private final YoutubePlaylistExtractorImpl playlistExtractor
          = new YoutubePlaylistExtractorImpl();

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    NewPipe.init(DownloaderImpl.getInstance());
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "newpipeextractor_dart");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull final MethodCall call, @NonNull final Result result) {
    final String method = call.method;
    final Map[] info = new Map[]{new HashMap<>()};
    final ExecutorService executor = Executors.newSingleThreadExecutor();
    final Handler handler = new Handler(Looper.getMainLooper());
    final List<Map>[] listMaps = new List[]{new ArrayList<>()};
    executor.execute(new Runnable() {
      @Override
      public void run() {
        // Background Work, execute all functions needed to be retrieved by
        // NewPipe_Extractor and save them on the [info] map
        //
        // Get Channel Information by Url
        if (method.equals("getChannel")) {
          String channelUrl = call.argument("channelUrl");
          try {
            info[0] = YoutubeChannelExtractorImpl.getChannel(channelUrl);
          } catch (Exception e) { e.printStackTrace(); }
        }

        // Get ID from a Stream URL
        if (method.equals("getIdFromStreamUrl")) {
          String streamUrl = call.argument("streamUrl");
          info[0].put("id", YoutubeLinkHandler.getIdFromStreamUrl(streamUrl));
        }

        // Get ID from a Playlist URL
        if (method.equals("getIdFromPlaylistUrl")) {
          String playlistUrl = call.argument("playlistUrl");
          info[0].put("id", YoutubeLinkHandler.getIdFromPlaylistUrl(playlistUrl));
        }

        // Get ID from a Channel URL
        if (method.equals("getIdFromChannelUrl")) {
          String channelUrl = call.argument("channelUrl");
          info[0].put("id", YoutubeLinkHandler.getIdFromChannelUrl(channelUrl));
        }

        // Gets video comments
        if (method.equals("getComments")) {
          String videoUrl = call.argument("videoUrl");
          try {
            info[0] = YoutubeCommentsExtractorImpl.getCommnets(videoUrl);
          } catch (Exception e) { e.printStackTrace(); }
        }

        // Gets all Video Information including Audio, Video and Muxed Streams
        if (method.equals("getVideoInfoAndStreams")) {
          String videoUrl = call.argument("videoUrl");
          try {
            listMaps[0] = StreamExtractorImpl.getVideoInfoAndStreams(videoUrl);
          } catch (Exception e) { e.printStackTrace(); }
        }

        // Get all Video information without Streams
        if (method.equals("getVideoInformation")) {
          String videoUrl = call.argument("videoUrl");
          try {
            info[0] = StreamExtractorImpl.getVideoInformation(videoUrl);
          } catch (Exception e) { e.printStackTrace(); }
        }

        // Get all Video Streams
        if (method.equals("getAllVideoStreams")) {
          String videoUrl = call.argument("videoUrl");
          try {
            listMaps[0] = StreamExtractorImpl.getAllVideoStreams(videoUrl);
          } catch (Exception e) { e.printStackTrace(); }
        }

        // Get Video Only Streams
        if (method.equals("getVideoOnlyStreams")) {
          String videoUrl = call.argument("videoUrl");
          try {
            info[0] = StreamExtractorImpl.getVideoOnlyStreams(videoUrl);
          } catch (Exception e) { e.printStackTrace(); }
        }

        // Get Audio Only Streams
        if (method.equals("getAudioOnlyStreams")) {
          String videoUrl = call.argument("videoUrl");
          try {
            info[0] = StreamExtractorImpl.getAudioOnlyStreams(videoUrl);
          } catch (Exception e) { e.printStackTrace(); }
        }

        // Get Video Streams (Muxed)
        if (method.equals("getVideoStreams")) {
          String videoUrl = call.argument("videoUrl");
          try {
            info[0] = StreamExtractorImpl.getVideoStreams(videoUrl);
          } catch (Exception e) { e.printStackTrace(); }
        }

        // Search Youtube for Videos/Channels/Playlists
        if (method.equals("searchYoutube")) {
          String query = call.argument("query");
          try {
            info[0] = searchExtractor.searchYoutube(query);
          } catch (Exception e) {
            e.printStackTrace();
            info[0].put("error", e.getMessage());
          }
        }

        // Get the next page of a previously made searchYoutube query
        if (method.equals("getNextPage")) {
          try {
            info[0] = searchExtractor.getNextPage();
          } catch (Exception e) { e.printStackTrace(); }
        }

        // Get the Playlist Details
        if (method.equals("getPlaylistDetails")) {
          String playlistUrl = call.argument("playlistUrl");
          try {
            info[0] = playlistExtractor.getPlaylistDetails(playlistUrl);
          } catch (Exception e) { e.printStackTrace(); }
        }

        // Get streams from a Playlist
        if (method.equals("getPlaylistStreams")) {
          String playlistUrl = call.argument("playlistUrl");
          try {
            info[0] = playlistExtractor.getPlaylistStreams(playlistUrl);
          } catch (Exception e) { e.printStackTrace(); }
        }

        // Get next page from current Playlist
        if (method.equals("getPlaylistNextPage")) {
          try {
            info[0] = playlistExtractor.getNextPage();
          } catch (Exception e) { e.printStackTrace(); }
        }

        // Get all Streams from a Channel URL
        if (method.equals("getChannelUploads")) {
          String channelUrl = call.argument("channelUrl");
          try {
            info[0] = YoutubeChannelExtractorImpl.getChannelUploads(channelUrl);
          } catch (Exception e) { e.printStackTrace(); }
        }

        // Return the NewPipe_Extractor result back to Flutter, if no work
        // was done this will simply return an empty map
        handler.post(new Runnable() {
          @Override
          public void run() {
            if (useList(method)) {
              result.success(listMaps[0]);
            } else {
              result.success(info[0]);
            }
          }
        });
      }
    });
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  public Boolean useList(String methodName) {
    List<String> functions = new ArrayList<>();
    functions.add("getVideoInfoAndStreams");
    functions.add("getAllVideoStreams");
    return functions.contains(methodName);
  }

}

