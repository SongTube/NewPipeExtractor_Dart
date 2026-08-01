package com.artxdev.newpipeextractor_dart;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Handler;
import android.os.Looper;
import android.webkit.CookieManager;

import androidx.annotation.NonNull;
import androidx.preference.PreferenceManager;

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
import org.schabi.newpipe.extractor.exceptions.ReCaptchaException;
import org.schabi.newpipe.extractor.localization.ContentCountry;
import org.schabi.newpipe.extractor.localization.Localization;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.RejectedExecutionException;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** NewpipeextractorDartPlugin */
public class NewpipeextractorDartPlugin implements FlutterPlugin, MethodCallHandler {

    /** Error code the Dart side matches on to open the reCaptcha solving page. */
    public static final String ERROR_RECAPTCHA = "recaptcha";
    /** Error code for any other extraction failure. */
    public static final String ERROR_EXTRACTION = "extraction_error";

    private static final String PREFS_COOKIES_KEY = "prefs_cookies_key";

    private MethodChannel channel;
    private Context context;

    /**
     * One executor for the whole plugin. The previous version created a new single-thread
     * executor on every method call and never shut any of them down, leaking a thread per call.
     * A single thread also serializes access to the paging state the extractors below hold.
     */
    private ExecutorService executor;
    private final Handler mainThread = new Handler(Looper.getMainLooper());

    private final YoutubeSearchExtractor searchExtractor = new YoutubeSearchExtractor();
    private final YoutubeMusicExtractor musicExtractor = new YoutubeMusicExtractor();
    private final YoutubeChannelExtractorImpl channelExtractor = new YoutubeChannelExtractorImpl();

    @Override
    public void onAttachedToEngine(@NonNull final FlutterPluginBinding flutterPluginBinding) {
        context = flutterPluginBinding.getApplicationContext();

        NewPipe.init(DownloaderImpl.getInstance(),
                Localization.fromLocale(Locale.getDefault()),
                new ContentCountry(Locale.getDefault().getCountry()));

        final SharedPreferences preferences =
                PreferenceManager.getDefaultSharedPreferences(context);
        // Was `cookie != ""`, a reference comparison that was always true, so a null cookie got
        // stored on every startup.
        final String cookie = preferences.getString(PREFS_COOKIES_KEY, null);
        if (cookie != null && !cookie.isEmpty()) {
            DownloaderImpl.getInstance().setCookie(cookie);
        }

        executor = Executors.newSingleThreadExecutor();
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(),
                "newpipeextractor_dart");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull final FlutterPluginBinding binding) {
        if (channel != null) {
            channel.setMethodCallHandler(null);
            channel = null;
        }
        if (executor != null) {
            executor.shutdown();
            executor = null;
        }
        context = null;
    }

    /** Produces the value to hand back to Dart, or throws. */
    private interface Task {
        Object run() throws Exception;
    }

    @Override
    public void onMethodCall(@NonNull final MethodCall call, @NonNull final Result result) {
        final Task task = taskFor(call);
        if (task == null) {
            result.notImplemented();
            return;
        }

        final ExecutorService currentExecutor = executor;
        if (currentExecutor == null) {
            result.error(ERROR_EXTRACTION, "Plugin is detached from the engine", null);
            return;
        }

        try {
            currentExecutor.execute(() -> {
                try {
                    final Object value = task.run();
                    mainThread.post(() -> result.success(value));
                } catch (final Exception e) {
                    final ReCaptchaException captcha = findReCaptcha(e);
                    if (captcha != null) {
                        // details carries the URL the user has to solve.
                        mainThread.post(() -> result.error(
                                ERROR_RECAPTCHA, captcha.getMessage(), captcha.getUrl()));
                    } else {
                        final String message = e.getMessage() != null
                                ? e.getMessage() : e.getClass().getName();
                        mainThread.post(() -> result.error(
                                ERROR_EXTRACTION, message, android.util.Log.getStackTraceString(e)));
                    }
                }
            });
        } catch (final RejectedExecutionException e) {
            result.error(ERROR_EXTRACTION, "Plugin is shutting down", null);
        }
    }

    /**
     * The extractor wraps the reCaptcha signal in other exception types, so walk the cause chain
     * rather than only checking the top-level type.
     */
    private static ReCaptchaException findReCaptcha(final Throwable throwable) {
        Throwable current = throwable;
        while (current != null) {
            if (current instanceof ReCaptchaException) {
                return (ReCaptchaException) current;
            }
            if (current.getCause() == current) {
                break;
            }
            current = current.getCause();
        }
        return null;
    }

    @SuppressWarnings("unchecked")
    private Task taskFor(final MethodCall call) {
        switch (call.method) {
            case "getChannel": {
                final String url = call.argument("channelUrl");
                return () -> channelExtractor.getChannel(url);
            }
            case "getChannelUploads": {
                final String url = call.argument("channelUrl");
                return () -> channelExtractor.getChannelUploads(url);
            }
            case "getChannelNextPage":
                return channelExtractor::getChannelNextPage;

            case "getIdFromStreamUrl": {
                final String url = call.argument("streamUrl");
                return () -> singleton("id", YoutubeLinkHandler.getIdFromStreamUrl(url));
            }
            case "getIdFromPlaylistUrl": {
                final String url = call.argument("playlistUrl");
                return () -> singleton("id", YoutubeLinkHandler.getIdFromPlaylistUrl(url));
            }
            case "getIdFromChannelUrl": {
                final String url = call.argument("channelUrl");
                return () -> singleton("id", YoutubeLinkHandler.getIdFromChannelUrl(url));
            }

            case "getComments": {
                final String url = call.argument("videoUrl");
                return () -> YoutubeCommentsExtractorImpl.getComments(url);
            }

            case "getVideoInfoAndStreams": {
                final String url = call.argument("videoUrl");
                return () -> StreamExtractorImpl.getStream(url);
            }
            case "getVideoInformation": {
                final String url = call.argument("videoUrl");
                return () -> StreamExtractorImpl.getInfo(url);
            }
            case "getAllVideoStreams": {
                final String url = call.argument("videoUrl");
                return () -> StreamExtractorImpl.getMediaStreams(url);
            }
            case "getVideoOnlyStreams": {
                final String url = call.argument("videoUrl");
                return () -> StreamExtractorImpl.getVideoOnlyStreams(url);
            }
            case "getAudioOnlyStreams": {
                final String url = call.argument("videoUrl");
                return () -> StreamExtractorImpl.getAudioOnlyStreams(url);
            }
            case "getVideoStreams": {
                final String url = call.argument("videoUrl");
                return () -> StreamExtractorImpl.getMuxedStreams(url);
            }
            case "getVideoSegments": {
                final String url = call.argument("videoUrl");
                return () -> StreamExtractorImpl.getStreamSegments(url);
            }
            case "getRelatedStreams": {
                final String url = call.argument("videoUrl");
                return () -> StreamExtractorImpl.getRelatedStreams(url);
            }

            case "searchYoutube": {
                final String query = call.argument("query");
                final List<String> filters = call.argument("filters");
                return () -> searchExtractor.searchYoutube(query, filters);
            }
            case "getNextPage":
                return searchExtractor::getNextPage;

            case "searchYoutubeMusic": {
                final String query = call.argument("query");
                final List<String> filters = call.argument("filters");
                return () -> musicExtractor.searchYoutube(query, filters);
            }
            case "getNextMusicPage":
                return musicExtractor::getNextPage;

            case "getPlaylistDetails": {
                final String url = call.argument("playlistUrl");
                return () -> YoutubePlaylistExtractorImpl.getPlaylistDetails(url);
            }
            case "getPlaylistStreams": {
                final String url = call.argument("playlistUrl");
                return () -> YoutubePlaylistExtractorImpl.getPlaylistStreams(url);
            }

            case "getTrendingStreams": {
                final String kiosk = call.argument("kiosk");
                return () -> YoutubeTrendingExtractorImpl.getTrendingPage(kiosk);
            }
            case "getAvailableKiosks":
                return YoutubeTrendingExtractorImpl::getAvailableKiosks;

            case "setCookie": {
                final String cookie = call.argument("cookie");
                return () -> {
                    DownloaderImpl.getInstance().setCookie(cookie);
                    persistCookie(cookie);
                    return singleton("status", "success");
                };
            }
            case "getCookieByUrl": {
                final String url = call.argument("url");
                return () -> singleton("cookie", CookieManager.getInstance().getCookie(url));
            }
            case "decodeCookie": {
                final String cookie = call.argument("cookie");
                return () -> {
                    if (cookie == null) {
                        return singleton("cookie", null);
                    }
                    try {
                        return singleton("cookie", URLDecoder.decode(cookie, "UTF-8"));
                    } catch (final UnsupportedEncodingException e) {
                        return singleton("cookie", cookie);
                    }
                };
            }

            default:
                return null;
        }
    }

    private void persistCookie(final String cookie) {
        final Context currentContext = context;
        if (currentContext == null) {
            return;
        }
        PreferenceManager.getDefaultSharedPreferences(currentContext)
                .edit()
                .putString(PREFS_COOKIES_KEY, cookie)
                .apply();
    }

    private static Map<String, String> singleton(final String key, final String value) {
        // Not Collections.singletonMap: the method-channel codec is fine with it, but callers
        // downstream have historically mutated these maps.
        final Map<String, String> map = new HashMap<>(1);
        map.put(key, value);
        return map;
    }
}
