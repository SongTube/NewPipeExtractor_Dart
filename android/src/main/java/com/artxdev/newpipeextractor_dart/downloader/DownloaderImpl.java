package com.artxdev.newpipeextractor_dart.downloader;

import org.schabi.newpipe.extractor.downloader.Downloader;
import org.schabi.newpipe.extractor.downloader.Request;
import org.schabi.newpipe.extractor.downloader.Response;
import org.schabi.newpipe.extractor.exceptions.ReCaptchaException;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import okhttp3.ResponseBody;

public class DownloaderImpl extends Downloader {

    private static final String USER_AGENT =
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:128.0) Gecko/20100101 Firefox/128.0";

    public static final String YOUTUBE_RESTRICTED_MODE_COOKIE_KEY = "youtube_restricted_mode_key";
    public static final String RECAPTCHA_COOKIES_KEY = "recaptcha_cookies";
    public static final String YOUTUBE_DOMAIN = "youtube.com";

    private static volatile DownloaderImpl instance;

    /** Read on the extractor thread, written from the method-channel handler. */
    private final Map<String, String> cookies = new ConcurrentHashMap<>();
    private final OkHttpClient client;

    private DownloaderImpl(final OkHttpClient.Builder builder) {
        this.client = builder
                .connectTimeout(30, TimeUnit.SECONDS)
                .readTimeout(30, TimeUnit.SECONDS)
                .build();
    }

    /**
     * It's recommended to call this exactly once in the entire lifetime of the application.
     *
     * @param builder if null, a default builder is used
     * @return a new instance of {@link DownloaderImpl}
     */
    public static DownloaderImpl init(@Nullable final OkHttpClient.Builder builder) {
        synchronized (DownloaderImpl.class) {
            instance = new DownloaderImpl(
                    builder != null ? builder : new OkHttpClient.Builder());
            return instance;
        }
    }

    public static DownloaderImpl getInstance() {
        DownloaderImpl local = instance;
        if (local == null) {
            synchronized (DownloaderImpl.class) {
                local = instance;
                if (local == null) {
                    local = init(null);
                }
            }
        }
        return local;
    }

    public String getCookies(final String url) {
        final List<String> resultCookies = new ArrayList<>();
        if (url != null && url.contains(YOUTUBE_DOMAIN)) {
            final String youtubeCookie = getCookie(YOUTUBE_RESTRICTED_MODE_COOKIE_KEY);
            if (youtubeCookie != null) {
                resultCookies.add(youtubeCookie);
            }
        }
        final String recaptchaCookie = getCookie(RECAPTCHA_COOKIES_KEY);
        if (recaptchaCookie != null) {
            resultCookies.add(recaptchaCookie);
        }
        return CookieUtils.concatCookies(resultCookies);
    }

    public String getCookie(final String key) {
        return cookies.get(key);
    }

    /**
     * Stores the cookie obtained from solving a reCaptcha. A null or blank value clears it --
     * the previous version stored the null and left a dead entry behind.
     */
    public void setCookie(@Nullable final String cookie) {
        if (cookie == null || cookie.trim().isEmpty()) {
            cookies.remove(RECAPTCHA_COOKIES_KEY);
        } else {
            cookies.put(RECAPTCHA_COOKIES_KEY, cookie);
        }
    }

    public void removeCookie(final String key) {
        cookies.remove(key);
    }

    @Override
    public Response execute(@NonNull final Request request)
            throws IOException, ReCaptchaException {
        final String httpMethod = request.httpMethod();
        final String url = request.url();
        final Map<String, List<String>> headers = request.headers();
        final byte[] dataToSend = request.dataToSend();

        RequestBody requestBody = null;
        if (dataToSend != null) {
            requestBody = RequestBody.create(dataToSend, null);
        }

        final okhttp3.Request.Builder requestBuilder = new okhttp3.Request.Builder()
                .method(httpMethod, requestBody)
                .url(url)
                .addHeader("User-Agent", USER_AGENT);

        final String cookieHeader = getCookies(url);
        if (!cookieHeader.isEmpty()) {
            requestBuilder.addHeader("Cookie", cookieHeader);
        }

        for (final Map.Entry<String, List<String>> pair : headers.entrySet()) {
            final String headerName = pair.getKey();
            final List<String> headerValueList = pair.getValue();

            if (headerValueList.size() > 1) {
                requestBuilder.removeHeader(headerName);
                for (final String headerValue : headerValueList) {
                    requestBuilder.addHeader(headerName, headerValue);
                }
            } else if (headerValueList.size() == 1) {
                requestBuilder.header(headerName, headerValueList.get(0));
            }
        }

        try (okhttp3.Response response = client.newCall(requestBuilder.build()).execute()) {
            if (response.code() == 429) {
                throw new ReCaptchaException("reCaptcha Challenge requested: " + url, url);
            }

            final ResponseBody body = response.body();
            final String responseBodyToReturn = body != null ? body.string() : null;
            final String latestUrl = response.request().url().toString();

            return new Response(response.code(), response.message(),
                    response.headers().toMultimap(), responseBodyToReturn, latestUrl);
        }
    }

    /**
     * Get the size of the content the url points to, by firing a HEAD request.
     *
     * @param url an url pointing to the content
     * @return the size of the content, in bytes
     */
    public long getContentLength(final String url) throws IOException {
        try {
            final Response response = head(url);
            return Long.parseLong(response.getHeader("Content-Length"));
        } catch (final NumberFormatException e) {
            throw new IOException("Invalid content length", e);
        } catch (final ReCaptchaException e) {
            throw new IOException(e);
        }
    }
}
