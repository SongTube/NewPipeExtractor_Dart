package com.artxdev.newpipeextractor_dart;

import com.artxdev.newpipeextractor_dart.downloader.DownloaderImpl;

import org.junit.Assume;
import org.junit.BeforeClass;
import org.junit.Test;
import org.schabi.newpipe.extractor.ListExtractor;
import org.schabi.newpipe.extractor.NewPipe;
import org.schabi.newpipe.extractor.kiosk.KioskExtractor;
import org.schabi.newpipe.extractor.localization.ContentCountry;
import org.schabi.newpipe.extractor.localization.Localization;

import java.util.Locale;

import static org.schabi.newpipe.extractor.ServiceList.YouTube;

/**
 * Diagnostic probe: reports which YouTube kiosks still return items.
 *
 * <p>Not an assertion-bearing test -- it exists so the default kiosk chosen by
 * {@code YoutubeTrendingExtractorImpl} can be re-checked when YouTube changes things again.</p>
 */
public class KioskProbeTest {

    @BeforeClass
    public static void setUp() {
        Assume.assumeTrue("live tests disabled",
                Boolean.parseBoolean(System.getProperty("newpipe.live.tests", "true")));
        NewPipe.init(DownloaderImpl.getInstance(),
                Localization.fromLocale(Locale.US),
                new ContentCountry("US"));
    }

    @Test
    @SuppressWarnings("unchecked")
    public void probeAllKiosks() throws Exception {
        for (final String id : YouTube.getKioskList().getAvailableKiosks()) {
            try {
                final KioskExtractor<?> extractor =
                        YouTube.getKioskList().getExtractorById(id, null);
                extractor.fetchPage();
                final ListExtractor.InfoItemsPage<?> page = extractor.getInitialPage();
                System.out.println("KIOSK " + id + " -> " + page.getItems().size() + " items");
            } catch (final Exception e) {
                System.out.println("KIOSK " + id + " -> FAILED: " + e);
            }
        }
    }
}
