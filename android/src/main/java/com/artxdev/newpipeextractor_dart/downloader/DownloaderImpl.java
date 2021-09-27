package com.artxdev.newpipeextractor_dart.downloader;

import org.schabi.newpipe.extractor.downloader.Downloader;
import org.schabi.newpipe.extractor.downloader.Request;
import org.schabi.newpipe.extractor.downloader.Response;
import org.schabi.newpipe.extractor.exceptions.ReCaptchaException;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import android.util.Log;

import javax.annotation.Nonnull;
import javax.annotation.Nullable;

import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import okhttp3.ResponseBody;

public class DownloaderImpl extends Downloader {
    private static final String USER_AGENT
            = "Mozilla/5.0 (Windows NT 10.0; rv:78.0) Gecko/20100101 Firefox/78.0";
    public static final String YOUTUBE_RESTRICTED_MODE_COOKIE_KEY
            = "youtube_restricted_mode_key";
    public static final String RECAPTCHA_COOKIES_KEY = "recaptcha_cookies";
    public static final String YOUTUBE_DOMAIN = "youtube.com";
    private static DownloaderImpl instance;
    private final Map<String, String> cookies;
    private OkHttpClient client;

    private DownloaderImpl(final OkHttpClient.Builder builder) {
        this.client = builder.readTimeout(30, TimeUnit.SECONDS).build();
        this.cookies = new HashMap<>();
    }

    /**
     * It's recommended to call exactly once in the entire lifetime of the application.
     *
     * @param builder if null, default builder will be used
     * @return a new instance of {@link DownloaderImpl}
     */
    public static DownloaderImpl init(@Nullable final OkHttpClient.Builder builder) {
        instance = new DownloaderImpl(
                builder != null ? builder : new OkHttpClient.Builder());
        return instance;
    }

    public static DownloaderImpl getInstance() {
        if (instance == null) {
            init(null);
        }
        return instance;
    }

    public String getCookies(final String url) {
        final List<String> resultCookies = new ArrayList<>();
        if (url.contains(YOUTUBE_DOMAIN)) {
            final String youtubeCookie = getCookie(YOUTUBE_RESTRICTED_MODE_COOKIE_KEY);
            if (youtubeCookie != null) {
                resultCookies.add(youtubeCookie);
            }
        }
        // Recaptcha cookie is always added TODO: not sure if this is necessary
        final String recaptchaCookie = getCookie(RECAPTCHA_COOKIES_KEY);
        if (recaptchaCookie != null) {
            resultCookies.add(recaptchaCookie);
        }
        return CookieUtils.concatCookies(resultCookies);
    }

    public String getCookie(final String key) {
        return cookies.get(key);
    }

    public void setCookie(final String cookie) {
        cookies.put(RECAPTCHA_COOKIES_KEY, cookie);

    }

    public void removeCookie(final String key) {
        cookies.remove(key);
    }

    @Override
    public Response execute(@Nonnull final Request request)
            throws IOException, ReCaptchaException {
        final String httpMethod = request.httpMethod();
        final String url = request.url();
        final Map<String, List<String>> headers = request.headers();
        final byte[] dataToSend = request.dataToSend();

        RequestBody requestBody = null;
        if (dataToSend != null) {
            requestBody = RequestBody.create(null, dataToSend);
        }

        final okhttp3.Request.Builder requestBuilder = new okhttp3.Request.Builder()
                .method(httpMethod, requestBody).url(url)
                .addHeader("User-Agent", USER_AGENT);

        final String cookies = getCookies(url);
        Log.d("COOKIE", cookies);
        if (!cookies.isEmpty()) {
            requestBuilder.addHeader("Cookie", cookies);
        }

        for (Map.Entry<String, List<String>> pair : headers.entrySet()) {
            final String headerName = pair.getKey();
            final List<String> headerValueList = pair.getValue();

            if (headerValueList.size() > 1) {
                requestBuilder.removeHeader(headerName);
                for (String headerValue : headerValueList) {
                    requestBuilder.addHeader(headerName, headerValue);
                }
            } else if (headerValueList.size() == 1) {
                requestBuilder.header(headerName, headerValueList.get(0));
            }

        }

        final okhttp3.Response response = client.newCall(requestBuilder.build()).execute();

        if (response.code() == 429) {
            response.close();

            throw new ReCaptchaException("reCaptcha Challenge requested: " + url, url);
        }

        final ResponseBody body = response.body();
        String responseBodyToReturn = null;

        if (body != null) {
            responseBodyToReturn = body.string();
        }

        final String latestUrl = response.request().url().toString();
        return new Response(response.code(), response.message(), response.headers().toMultimap(),
                responseBodyToReturn, latestUrl);
    }

    /**
     * Get the size of the content that the url is pointing by firing a HEAD request.
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
