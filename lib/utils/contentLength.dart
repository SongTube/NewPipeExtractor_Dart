import 'dart:io';

import 'package:http/http.dart';

class ContentLength {

  static const Map<String, String> _defaultHeaders = {
    'user-agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36',
    'accept-language': 'en-US,en;q=1.0',
    'x-youtube-client-name': '1',
    'x-youtube-client-version': '2.20200609.04.02',
    'x-spf-previous': 'https://www.youtube.com/',
    'x-spf-referer': 'https://www.youtube.com/',
    'x-youtube-device':
        'cbr=Chrome&cbrver=81.0.4044.138&ceng=WebKit&cengver=537.36'
            '&cos=Windows&cosver=10.0',
    'x-youtube-page-label': 'youtube.ytfe.desktop_20200617_1_RC1'
  };

  static Future<int> getContentLength(String url) async {
    var response = await head(Uri.parse(url), headers: _defaultHeaders);
    return int.tryParse(response.headers['content-length'] ?? '');
  }

}