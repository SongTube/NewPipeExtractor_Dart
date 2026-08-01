import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:newpipeextractor_dart/exceptions/fatalFailureException.dart';
import 'package:newpipeextractor_dart/exceptions/requestLimitExceededException.dart';
import 'package:newpipeextractor_dart/exceptions/transistentFailureException.dart';

class ExtractorHttpClient {
  static const Map<String, String> defaultHeaders = {
    'user-agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:128.0) Gecko/20100101 Firefox/128.0'
  };

  /// Size of each ranged request issued by [getStream].
  static const int _chunkSize = 9898989;

  /// Maximum consecutive failures before giving up on a download.
  static const int _maxRetries = 5;

  static Future<int?> getContentLength(String url) async {
    final response = await http.head(Uri.parse(url), headers: defaultHeaders);
    return int.tryParse(response.headers['content-length'] ?? '');
  }

  /// Downloads [stream] (any object exposing `url` and `size`) in ranged chunks.
  static Stream<List<int>> getStream(
    dynamic stream, {
    Map<String, String>? headers,
    bool validate = true,
    int start = 0,
    int errorCount = 0,
  }) async* {
    final String url = stream.url as String;
    final int size = stream.size as int;
    var bytesCount = start;
    final client = http.Client();

    try {
      for (var i = start; i < size; i += _chunkSize) {
        try {
          final request = http.Request('get', Uri.parse(url));
          request.headers['range'] = 'bytes=$i-${i + _chunkSize - 1}';
          headers?.forEach((key, value) => request.headers[key] = value);
          defaultHeaders.forEach((key, value) {
            request.headers[key] ??= value;
          });

          final response = await client.send(request);
          if (validate) {
            _validateResponse(response, response.statusCode);
          }

          // NOTE: this controller used to be named `stream`, shadowing the
          // parameter -- so the retry below handed the controller itself to the
          // recursive call and every retry threw on `stream.url`.
          final chunk = StreamController<List<int>>();
          response.stream.listen(
            (data) {
              bytesCount += data.length;
              chunk.add(data);
            },
            onError: chunk.addError,
            onDone: chunk.close,
            cancelOnError: false,
          );
          errorCount = 0;
          yield* chunk.stream;
        } on Exception {
          if (errorCount == _maxRetries) rethrow;
          await Future.delayed(const Duration(milliseconds: 500));
          yield* getStream(
            stream,
            headers: headers,
            validate: validate,
            start: bytesCount,
            errorCount: errorCount + 1,
          );
          return;
        }
      }
    } finally {
      client.close();
    }
  }

  static void _validateResponse(http.BaseResponse response, int statusCode) {
    final request = response.request!;
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
