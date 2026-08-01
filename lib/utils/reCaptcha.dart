import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:newpipeextractor_dart/utils/httpClient.dart';

/// Error code the Android side reports when YouTube demands a reCaptcha.
///
/// Must stay in sync with `NewpipeextractorDartPlugin.ERROR_RECAPTCHA`.
const String kReCaptchaErrorCode = 'recaptcha';

/// A page that lets the user solve a YouTube reCaptcha challenge, plus the
/// [run] helper every extractor funnels its method-channel calls through.
///
/// To enable the solving flow, the host app must:
///
/// ```dart
/// MaterialApp(
///   navigatorKey: NavigationService.instance.navigationKey,
///   routes: {ReCaptchaPage.routeName: (_) => const ReCaptchaPage()},
/// )
/// ```
///
/// Without that wiring the challenge simply surfaces as a [PlatformException].
class ReCaptchaPage extends StatefulWidget {
  const ReCaptchaPage({super.key});

  /// Route name the host app must register for this page.
  static const String routeName = 'reCaptcha';

  static bool _solving = false;

  /// Runs [task]; if the native side reports a reCaptcha challenge, shows the
  /// solving page and then retries [task] exactly once.
  ///
  /// Anything else -- including a challenge that cannot be solved because the
  /// host app didn't wire up [NavigationService] -- is rethrown. The previous
  /// implementation returned null on every non-captcha error, which turned each
  /// extraction failure into a null-dereference further up the stack.
  static Future<T> run<T>(Future<T> Function() task) async {
    try {
      return await task();
    } on PlatformException catch (e) {
      final url = _challengeUrl(e);
      if (e.code != kReCaptchaErrorCode ||
          url == null ||
          _solving ||
          !NavigationService.instance.hasNavigator) {
        rethrow;
      }
      _solving = true;
      try {
        await NavigationService.instance.navigateTo(routeName, url);
      } finally {
        _solving = false;
      }
      return task();
    }
  }

  /// The native side passes the challenge URL as the exception's `details`.
  static String? _challengeUrl(PlatformException e) {
    final details = e.details;
    if (details is String && details.startsWith('http')) return details;
    // Fall back to digging it out of the message for older native builds.
    final match = RegExp(r'https?://\S+').firstMatch(e.message ?? '');
    return match?.group(0);
  }

  @override
  State<ReCaptchaPage> createState() => _ReCaptchaPageState();
}

class _ReCaptchaPageState extends State<ReCaptchaPage> {
  InAppWebViewController? controller;
  String foundCookies = '';

  @override
  Widget build(BuildContext context) {
    final url = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.redAccent,
        title: ListTile(
          title: const Text('reCaptcha', style: TextStyle(color: Colors.white)),
          subtitle: Text(
            'Solve the reCaptcha and confirm',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            color: Colors.white,
            onPressed: () => _confirm(url),
          ),
        ],
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(url),
          headers: ExtractorHttpClient.defaultHeaders,
        ),
        onLoadStop: (cont, _) => controller = cont,
      ),
    );
  }

  Future<void> _confirm(String fallbackUrl) async {
    final currentUrl = (await controller?.getUrl())?.toString() ?? fallbackUrl;

    final info = await NewPipeExtractorDart.extractorChannel
        .invokeMapMethod<String, String>('getCookieByUrl', {'url': currentUrl});
    handleCookies(info?['cookie']);

    // Sometimes the cookie is embedded in the url itself.
    final abuseStart = currentUrl.indexOf('google_abuse=');
    if (abuseStart != -1) {
      final abuseEnd = currentUrl.indexOf('+path');
      if (abuseEnd > abuseStart) {
        try {
          final raw = currentUrl.substring(abuseStart + 13, abuseEnd);
          // invokeMethod returns the {'cookie': ...} map, not a bare string;
          // the old code cast the map to String and always threw here.
          final decoded = await NewPipeExtractorDart.extractorChannel
              .invokeMapMethod<String, String>('decodeCookie', {'cookie': raw});
          handleCookies(decoded?['cookie']);
        } catch (_) {
          // A malformed abuse cookie shouldn't block the ones we already have.
        }
      }
    }

    await NewPipeExtractorDart.extractorChannel
        .invokeMethod('setCookie', {'cookie': foundCookies});

    if (!mounted) return;
    Navigator.pop(context);
  }

  void handleCookies(String? cookies) {
    if (cookies == null) return;
    if (!cookies.contains('s_gl=') &&
        !cookies.contains('goojf=') &&
        !cookies.contains('VISITOR_INFO1_LIVE=') &&
        !cookies.contains('GOOGLE_ABUSE_EXEMPTION=')) {
      return;
    }
    if (foundCookies.contains(cookies)) return;

    if (foundCookies.isEmpty || foundCookies.endsWith('; ')) {
      foundCookies += cookies;
    } else if (foundCookies.endsWith(';')) {
      foundCookies += ' $cookies';
    } else {
      foundCookies += '; $cookies';
    }
  }
}
