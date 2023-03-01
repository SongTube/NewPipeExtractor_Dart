// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:newpipeextractor_dart/extractors/playlist.dart';
import 'package:newpipeextractor_dart/models/infoItems/playlist.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';

class YoutubePlaylist {

  /// Playlist ID
  String? id;

  /// Playlist name
  String? name;

  /// Playlist full URL
  String? url;

  /// Playlist authors name
  String? uploaderName;

  /// Playlist author avatar url
  String? uploaderAvatarUrl;

  /// Playlist channel url
  String? uploaderUrl;

  /// Playlist banner url
  String? bannerUrl;

  /// Playlist thumbnail url
  String? thumbnailUrl;

  /// Playlist videos ammount
  int streamCount;

  /// Playlist streams (Videos)
  List<StreamInfoItem>? streams;

  YoutubePlaylist(
    this.id,
    this.name,
    this.url,
    this.uploaderName,
    this.uploaderAvatarUrl,
    this.uploaderUrl,
    this.bannerUrl,
    this.thumbnailUrl,
    this.streamCount,
    {this.streams}
  );

  /// Transform this object into a PlaylistInfoItem which is smaller and
  /// allows saving or transporting it via Strings
  PlaylistInfoItem toPlaylistInfoItem() {
    return PlaylistInfoItem(
      url,
      name,
      uploaderName,
      thumbnailUrl,
      streamCount
    );
  }

  /// Retrieve this Playlist list of streams (List of StreamInfoItem)
  Future<void> getStreams() async {
    streams = await PlaylistExtractor.getPlaylistStreams(url);
  }


  YoutubePlaylist copyWith({
    String? id,
    String? name,
    String? url,
    String? uploaderName,
    String? uploaderAvatarUrl,
    String? uploaderUrl,
    String? bannerUrl,
    String? thumbnailUrl,
    int? streamCount,
    List<StreamInfoItem>? streams,
  }) {
    return YoutubePlaylist(
      id ?? this.id,
      name ?? this.name,
      url ?? this.url,
      uploaderName ?? this.uploaderName,
      uploaderAvatarUrl ?? this.uploaderAvatarUrl,
      uploaderUrl ?? this.uploaderUrl,
      bannerUrl ?? this.bannerUrl,
      thumbnailUrl ?? this.thumbnailUrl,
      streamCount ?? this.streamCount,
      streams: streams ?? this.streams,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'url': url,
      'uploaderName': uploaderName,
      'uploaderAvatarUrl': uploaderAvatarUrl,
      'uploaderUrl': uploaderUrl,
      'bannerUrl': bannerUrl,
      'thumbnailUrl': thumbnailUrl,
      'streamCount': streamCount,
      'streams': streams == null ? [] : streams!.map((x) => x?.toMap()).toList(),
    };
  }

  factory YoutubePlaylist.fromMap(Map<String, dynamic> map) {
    return YoutubePlaylist(
      map['id'] != null ? map['id'] as String : null,
      map['name'] != null ? map['name'] as String : null,
      map['url'] != null ? map['url'] as String : null,
      map['uploaderName'] != null ? map['uploaderName'] as String : null,
      map['uploaderAvatarUrl'] != null ? map['uploaderAvatarUrl'] as String : null,
      map['uploaderUrl'] != null ? map['uploaderUrl'] as String : null,
      map['bannerUrl'] != null ? map['bannerUrl'] as String : null,
      map['thumbnailUrl'] != null ? map['thumbnailUrl'] as String : null,
      map['streamCount'] as int,
      streams: map['streams'] != null ? List<StreamInfoItem>.from((map['streams']).map<StreamInfoItem?>((x) => StreamInfoItem.fromMap(x as Map<String,dynamic>),),) : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory YoutubePlaylist.fromJson(String source) => YoutubePlaylist.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'YoutubePlaylist(id: $id, name: $name, url: $url, uploaderName: $uploaderName, uploaderAvatarUrl: $uploaderAvatarUrl, uploaderUrl: $uploaderUrl, bannerUrl: $bannerUrl, thumbnailUrl: $thumbnailUrl, streamCount: $streamCount, streams: $streams)';
  }

  @override
  bool operator ==(covariant YoutubePlaylist other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.name == name &&
      other.url == url &&
      other.uploaderName == uploaderName &&
      other.uploaderAvatarUrl == uploaderAvatarUrl &&
      other.uploaderUrl == uploaderUrl &&
      other.bannerUrl == bannerUrl &&
      other.thumbnailUrl == thumbnailUrl &&
      other.streamCount == streamCount &&
      listEquals(other.streams, streams);
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      url.hashCode ^
      uploaderName.hashCode ^
      uploaderAvatarUrl.hashCode ^
      uploaderUrl.hashCode ^
      bannerUrl.hashCode ^
      thumbnailUrl.hashCode ^
      streamCount.hashCode ^
      streams.hashCode;
  }
}
