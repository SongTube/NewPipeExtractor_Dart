package com.artxdev.newpipeextractor_dart.downloader;

import java.util.Arrays;
import java.util.Collection;
import java.util.LinkedHashSet;
import java.util.Set;

public final class CookieUtils {
    private CookieUtils() {
    }

    public static String concatCookies(final Collection<String> cookieStrings) {
        // LinkedHashSet, not HashSet: cookie order was previously arbitrary and
        // varied between runs. String.join replaces android.text.TextUtils.join
        // so the downloader stays testable off-device.
        final Set<String> cookieSet = new LinkedHashSet<>();
        for (final String cookies : cookieStrings) {
            if (cookies != null && !cookies.isEmpty()) {
                cookieSet.addAll(splitCookies(cookies));
            }
        }
        return String.join("; ", cookieSet).trim();
    }

    public static Set<String> splitCookies(final String cookies) {
        return new LinkedHashSet<>(Arrays.asList(cookies.split("; *")));
    }
}