import 'package:flutter/material.dart';
import 'package:newpipeextractor_dart/extractors/playlist.dart';
import 'package:newpipeextractor_dart/extractors/search.dart';
import 'package:newpipeextractor_dart/extractors/videos.dart';
import 'package:newpipeextractor_dart/models/playlist.dart';
import 'package:newpipeextractor_dart/models/search.dart';

import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  YoutubeSearch search;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: ListView(
          children: [
            ListTile(
              title: Text("Get Channel"),
              onTap: () async {
                String url = "https://www.youtube.com/playlist?list=PLSmhG8yDCXaFj04Rag9btia4G3nN3hFRn";
                Stopwatch stopwatch = new Stopwatch()..start();
                YoutubePlaylist info = await PlaylistExtractor.getPlaylistDetails(url);
                await info.getStreams();
                print('VideoExtraction executed in ${stopwatch.elapsed}');
                print("Done");
              },
            ),
            Center(child: CircularProgressIndicator())
          ],
        ),
      ),
    );
  }
}
