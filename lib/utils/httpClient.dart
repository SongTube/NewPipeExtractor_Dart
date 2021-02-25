import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:newpipeextractor_dart/exceptions/fatalFailureException.dart';
import 'package:newpipeextractor_dart/exceptions/requestLimitExceededException.dart';
import 'package:newpipeextractor_dart/exceptions/transistentFailureException.dart';

class ExtractorHttpClient {

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
    var response = await http.head(Uri.parse(url), headers: _defaultHeaders);
    return int.tryParse(response.headers['content-length'] ?? '');
  }

  Stream<List<int>> getStream(dynamic stream,
      {Map<String, String> headers,
      bool validate = true,
      int start = 0,
      int errorCount = 0}) async* {
    var url = stream.url;
    var bytesCount = start;
    var client = http.Client();
    for (var i = start; i < stream.size; i += 9898989) {
      try {
        final request = http.Request('get', url);
        request.headers['range'] = 'bytes=$i-${i + 9898989 - 1}';
        _defaultHeaders.forEach((key, value) {
          if (request.headers[key] == null) {
            request.headers[key] = _defaultHeaders[key];
          }
        });
        final response = await client.send(request);
        if (validate) {
          _validateResponse(response, response.statusCode);
        }
        final stream = StreamController<List<int>>();
        response.stream.listen((data) {
          bytesCount += data.length;
          stream.add(data);
        }, onError: (_) => null, onDone: stream.close, cancelOnError: false);
        errorCount = 0;
        yield* stream.stream;
      } on Exception {
        if (errorCount == 5) {
          rethrow;
        }
        await Future.delayed(const Duration(milliseconds: 500));
        yield* getStream(stream,
            headers: headers,
            validate: validate,
            start: bytesCount,
            errorCount: errorCount + 1);
        break;
      }
    }
    client.close();
  }

  void _validateResponse(http.BaseResponse response, int statusCode) {
    var request = response.request;
    if (request.url.host.endsWith('.google.com') &&
        request.url.path.startsWith('/sorry/')) {
      throw RequestLimitExceededException.httpRequest(response);
    }

    if (statusCode >= 500) {
      throw TransientFailureException.httpRequest(response);
    }

    if (statusCode == 429) {
      throw RequestLimitExceededException.httpRequest(response);
    }

    if (statusCode >= 400) {
      throw FatalFailureException.httpRequest(response);
    }
  }

}