import 'package:newpipeextractor_dart/extractors/search.dart';
import 'package:newpipeextractor_dart/models/infoItems/channel.dart';
import 'package:newpipeextractor_dart/models/infoItems/playlist.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';

class YoutubeSearch {

  /// SearchQuery
  String? query;

  /// Videos from Search
  List<StreamInfoItem>? searchVideos;

  /// Channels from Search
  List<ChannelInfoItem>? searchChannels;

  /// Playlists from Search
  List<PlaylistInfoItem>? searchPlaylists;

  YoutubeSearch({
    this.query,
    this.searchVideos,
    this.searchChannels,
    this.searchPlaylists
  }) {
    dynamicSearchResultsList.addAll(searchChannels!);
    dynamicSearchResultsList.addAll(searchPlaylists!);
    dynamicSearchResultsList.addAll(searchVideos!);
  }

  /// Get next page content and include all results 
  /// in the current object of YoutubeSearch
  Future<void> getNextPage() async {
    var newItems = await SearchExtractor.getNextPage();
    searchVideos!.addAll(newItems[0] as List<StreamInfoItem>);
    searchPlaylists!.addAll(newItems[1] as List<PlaylistInfoItem>);
    searchChannels!.addAll(newItems[2] as List<ChannelInfoItem>);
    dynamicSearchResultsList.addAll(newItems[2]);
    dynamicSearchResultsList.addAll(newItems[1]);
    dynamicSearchResultsList.addAll(newItems[0]);
  }

  /// Gives you a dynamic list with all results in it.
  /// 
  /// This means initial Channels will be at the top of the list, then, initial
  /// Playlists will be added and then, anything else found (Channel, Playlist 
  /// or Videos) will be placed in the order they were found
  List<dynamic> dynamicSearchResultsList = [];
  
}

class YoutubeMusicSearch {

  /// SearchQuery
  String? query;

  /// Videos from Search
  List<StreamInfoItem>? searchVideos;

  /// Channels from Search
  List<ChannelInfoItem>? searchChannels;

  /// Playlists from Search
  List<PlaylistInfoItem>? searchPlaylists;

  YoutubeMusicSearch({
    this.query,
    this.searchVideos,
    this.searchChannels,
    this.searchPlaylists
  }) {
    dynamicSearchResultsList.addAll(searchChannels!);
    dynamicSearchResultsList.addAll(searchPlaylists!);
    dynamicSearchResultsList.addAll(searchVideos!);
  }

  /// Get next page content and include all results 
  /// in the current object of YoutubeSearch
  Future<void> getNextPage() async {
    var newItems = await SearchExtractor.getNextMusicPage();
    searchVideos!.addAll(newItems[0] as List<StreamInfoItem>);
    searchPlaylists!.addAll(newItems[1] as List<PlaylistInfoItem>);
    searchChannels!.addAll(newItems[2] as List<ChannelInfoItem>);
    dynamicSearchResultsList.addAll(newItems[2]);
    dynamicSearchResultsList.addAll(newItems[1]);
    dynamicSearchResultsList.addAll(newItems[0]);
  }

  /// Gives you a dynamic list with all results in it.
  /// 
  /// This means initial Channels will be at the top of the list, then, initial
  /// Playlists will be added and then, anything else found (Channel, Playlist 
  /// or Videos) will be placed in the order they were found
  List<dynamic> dynamicSearchResultsList = [];
  
}