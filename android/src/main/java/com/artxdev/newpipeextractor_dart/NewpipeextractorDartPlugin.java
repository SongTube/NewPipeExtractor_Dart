package com.artxdev.newpipeextractor_dart;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.Handler;
import android.os.Looper;
import android.os.StrictMode;
import android.preference.PreferenceManager;
import android.webkit.CookieManager;

import androidx.annotation.NonNull;

import com.artxdev.newpipeextractor_dart.downloader.DownloaderImpl;
import com.artxdev.newpipeextractor_dart.youtube.StreamExtractorImpl;
import com.artxdev.newpipeextractor_dart.youtube.YoutubeChannelExtractorImpl;
import com.artxdev.newpipeextractor_dart.youtube.YoutubeCommentsExtractorImpl;
import com.artxdev.newpipeextractor_dart.youtube.YoutubeLinkHandler;
import com.artxdev.newpipeextractor_dart.youtube.YoutubeMusicExtractor;
import com.artxdev.newpipeextractor_dart.youtube.YoutubePlaylistExtractorImpl;
import com.artxdev.newpipeextractor_dart.youtube.YoutubeSearchExtractor;
import com.artxdev.newpipeextractor_dart.youtube.YoutubeTrendingExtractorImpl;

import org.schabi.newpipe.extractor.NewPipe;
import org.schabi.newpipe.extractor.exceptions.ParsingException;
import org.schabi.newpipe.extractor.linkhandler.LinkHandler;
import org.schabi.newpipe.extractor.localization.ContentCountry;
import org.schabi.newpipe.extractor.localization.Localization;
import org.schabi.newpipe.extractor.services.youtube.extractors.YoutubeChannelExtractor;
import org.schabi.newpipe.extractor.services.youtube.linkHandler.YoutubeChannelLinkHandlerFactory;
import org.schabi.newpipe.extractor.stream.StreamExtractor;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** NewpipeextractorDartPlugin */
@SuppressWarnings("unchecked")
@SuppressLint("ApplySharedPref")
public class NewpipeextractorDartPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  private Context context;

  private final YoutubeSearchExtractor searchExtractor
          = new YoutubeSearchExtractor();
  private final YoutubeMusicExtractor musicExtractor
          = new YoutubeMusicExtractor();

  private final YoutubeChannelExtractorImpl channelExtractor
          = new YoutubeChannelExtractorImpl();

  private final String PREFS_COOKIES_KEY = "prefs_cookies_key";

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    context = flutterPluginBinding.getApplicationContext();
    NewPipe.init(DownloaderImpl.getInstance(),
            Localization.fromLocale(Locale.getDefault()),
            new ContentCountry(Locale.getDefault().getCountry()));
    final SharedPreferences preferences = PreferenceManager
            .getDefaultSharedPreferences(context);
    final String cookie = preferences.getString(PREFS_COOKIES_KEY, null);
    if (cookie != "") {
      DownloaderImpl.getInstance().setCookie(cookie);
    }
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
            info[0] = channelExtractor.getChannel(channelUrl);
          } catch (Exception e) {
            e.printStackTrace();
            info[0].put("error", e.getMessage());
          }
        }

        // Get ID from a Stream URL
        if (method.equals("getIdFromStreamUrl")) {
          String streamUrl = call.argument("streamUrl");
          String id = YoutubeLinkHandler.getIdFromStreamUrl(streamUrl);
          info[0].put("id", id);
        }

        // Get ID from a Playlist URL
        if (method.equals("getIdFromPlaylistUrl")) {
          String playlistUrl = call.argument("playlistUrl");
          String id = YoutubeLinkHandler.getIdFromPlaylistUrl(playlistUrl);
          info[0].put("id", id);
        }

        // Get ID from a Channel URL
        if (method.equals("getIdFromChannelUrl")) {
          String channelUrl = call.argument("channelUrl");
          String id = YoutubeLinkHandler.getIdFromChannelUrl(channelUrl);
          info[0].put("id", id);
        }

        // Gets video comments
        if (method.equals("getComments")) {
          String videoUrl = call.argument("videoUrl");
          try {
            info[0] = YoutubeCommentsExtractorImpl.getComments(videoUrl);
          } catch (Exception e) {
            e.printStackTrace();
            info[0].put("error", e.getMessage());
          }
        }

        // Gets all Video Information including Audio, Video and Muxed Streams
        if (method.equals("getVideoInfoAndStreams")) {
          String videoUrl = call.argument("videoUrl");
          try {
            listMaps[0] = StreamExtractorImpl.getStream(videoUrl);
          } catch (Exception e) {
            e.printStackTrace();
            info[0].put("error", e.getMessage());
          }
        }

        // Get all Video information without Streams
        if (method.equals("getVideoInformation")) {
          String videoUrl = call.argument("videoUrl");
          try {
            info[0] = StreamExtractorImpl.getInfo(videoUrl);
          } catch (Exception e) {
            e.printStackTrace();
            info[0].put("error", e.getMessage());
          }
        }

        // Get all Video Streams
        if (method.equals("getAllVideoStreams")) {
          String videoUrl = call.argument("videoUrl");
          try {
            listMaps[0] = StreamExtractorImpl.getMediaStreams(videoUrl);
          } catch (Exception e) {
            e.printStackTrace();
            info[0].put("error", e.getMessage());
          }
        }

        // Get Video Only Streams
        if (method.equals("getVideoOnlyStreams")) {
          String videoUrl = call.argument("videoUrl");
          try {
            info[0] = StreamExtractorImpl.getVideoOnlyStreams(videoUrl);
          } catch (Exception e) {
            e.printStackTrace();
            info[0].put("error", e.getMessage());
          }
        }

        // Get Audio Only Streams
        if (method.equals("getAudioOnlyStreams")) {
          String videoUrl = call.argument("videoUrl");
          try {
            info[0] = StreamExtractorImpl.getAudioOnlyStreams(videoUrl);
          } catch (Exception e) {
            e.printStackTrace();
            info[0].put("error", e.getMessage());
          }
        }

        // Get Video Streams (Muxed)
        if (method.equals("getVideoStreams")) {
          String videoUrl = call.argument("videoUrl");
          try {
            info[0] = StreamExtractorImpl.getMuxedStreams(videoUrl);
          } catch (Exception e) {
            e.printStackTrace();
            info[0].put("error", e.getMessage());
          }
        }

        // Get Video Segments
        if (method.equals("getVideoSegments")) {
          String videoUrl = call.argument("videoUrl");
          try {
            info[0] = StreamExtractorImpl.getStreamSegments(videoUrl);
          } catch (Exception e) {
            e.printStackTrace();
            info[0].put("error", e.getMessage());
          }
        }

        // Search Youtube for Videos/Channels/Playlists
        if (method.equals("searchYoutube")) {
          String query = call.argument("query");
          List<String> filters = call.argument("filters");
          try {
            info[0] = searchExtractor.searchYoutube(query, filters);
          } catch (Exception e) {
            e.printStackTrace();
            info[0].put("error", e.getMessage());
          }
        }

        // Get the next page of a previously made searchYoutube query
        if (method.equals("getNextPage")) {
          try {
            info[0] = searchExtractor.getNextPage();
          } catch (Exception e) {
            e.printStackTrace();
            info[0].put("error", e.getMessage());
          }
        }

        // Search Youtube for Music
        if (method.equals("searchYoutubeMusic")) {
          String query = call.argument("query");
          List<String> filters = call.argument("filters");
          try {
            info[0] = musicExtractor.searchYoutube(query, filters);
          } catch (Exception e) {
            e.printStackTrace();
            info[0].put("error", e.getMessage());
          }
        }

        // Get the next page of a previously made searchYoutubeMusic query
        if (method.equals("getNextMusicPage")) {
          try {
            info[0] = musicExtractor.getNextPage();
          } catch (Exception e) {
            e.printStackTrace();
            info[0].put("error", e.getMessage());
          }
        }

        // Get the Playlist Details
        if (method.equals("getPlaylistDetails")) {
          String playlistUrl = call.argument("playlistUrl");
          try {
            info[0] = YoutubePlaylistExtractorImpl.getPlaylistDetails(playlistUrl);
          } catch (Exception e) {
            e.printStackTrace();
            info[0].put("error", e.getMessage());
          }
        }

        // Get streams from a Playlist
        if (method.equals("getPlaylistStreams")) {
          String playlistUrl = call.argument("playlistUrl");
          try {
            info[0] = YoutubePlaylistExtractorImpl.getPlaylistStreams(playlistUrl);
          } catch (Exception e) {
            e.printStackTrace();
            info[0].put("error", e.getMessage());
          }
        }

        // Get all Streams from a Channel URL
        if (method.equals("getChannelUploads")) {
          String channelUrl = call.argument("channelUrl");
          try {
            info[0] = channelExtractor.getChannelUploads(channelUrl);
          } catch (Exception e) {
            e.printStackTrace();
            info[0].put("error", e.getMessage());
          }
        }

        // Get next page of channel videos
        if (method.equals("getChannelNextPage")) {
          try {
            info[0] = channelExtractor.getChannelNextPage();
          } catch (Exception e) {
            e.printStackTrace();
            info[0].put("error", e.getMessage());
          }
        }

        // Get related streams from video url
        if (method.equals("getRelatedStreams")) {
          String videoUrl = call.argument("videoUrl");
          try {
            info[0] = StreamExtractorImpl.getRelatedStreams(videoUrl);
          } catch (Exception e) {
            e.printStackTrace();
            info[0].put("error", e.getMessage());
          }
        }

        // Get Trending streams
        if (method.equals("getTrendingStreams")) {
          try {
            info[0] = YoutubeTrendingExtractorImpl.getTrendingPage();
          } catch (Exception e) {
            e.printStackTrace();
            info[0].put("error", e.getMessage());
          }
        }

        // Set cookie on our DownloaderImpl
        if (method.equals("setCookie")) {
          String cookie = call.argument("cookie");
          if (cookie != null) {
            DownloaderImpl.getInstance().setCookie(cookie);
            final SharedPreferences preferences = PreferenceManager
                    .getDefaultSharedPreferences(context);
            preferences.edit().putString(PREFS_COOKIES_KEY, cookie).commit();
            info[0].put("status", "success");
          } else {
            info[0].put("status", "failed");
          }
        }

        // Get cookie string from url
        if (method.equals("getCookieByUrl")) {
          String url = call.argument("url");
          try {
            final String cookie = CookieManager.getInstance().getCookie(url);
            info[0].put("cookie", cookie);
          } catch (Exception e) {
            e.printStackTrace();
            info[0].put("error", e.getMessage());
          }
        }

        // Decode Cookie
        if (method.equals("decodeCookie")) {
          String cookie = call.argument("cookie");
          try {
            info[0].put("cookie", URLDecoder.decode(cookie, "UTF-8"));
          } catch (Exception e) {
            e.printStackTrace();
            info[0].put("error", e.getMessage());
          }
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

