import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:newpipeextractor_dart/exceptions/fatalFailureException.dart';
import 'package:newpipeextractor_dart/exceptions/requestLimitExceededException.dart';
import 'package:newpipeextractor_dart/exceptions/transistentFailureException.dart';

class ExtractorHttpClient {

  static const Map<String, String> defaultHeaders = {
    'user-agent':
        'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:68.0) Gecko/20100101 Firefox/68.0'
  };

  static Future<int?> getContentLength(String url) async {
    var response = await http.head(Uri.parse(url), headers: defaultHeaders);
    return int.tryParse(response.headers['content-length'] ?? '');
  }

  static Stream<List<int>> getStream(dynamic stream,
      {Map<String, String>? headers,
      bool validate = true,
      int start = 0,
      int errorCount = 0}) async* {
    String? url = stream.url;
    var bytesCount = start;
    var client = http.Client();
    for (var i = start; i < stream.size; i += 9898989) {
      try {
        final request = http.Request('get', Uri.parse(url!));
        request.headers['range'] = 'bytes=$i-${i + 9898989 - 1}';
        defaultHeaders.forEach((key, value) {
          if (request.headers[key] == null) {
            request.headers[key] = defaultHeaders[key]!;
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

  static void _validateResponse(http.BaseResponse response, int statusCode) {
    var request = response.request!;
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