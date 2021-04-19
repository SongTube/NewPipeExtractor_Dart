/// Search filters for both the SearchExtractor
class YoutubeSearchFilter {

  // Search filters
  static final String all = "all";
  static final String videos = "videos";
  static final String channels = "channels";
  static final String playlists = "playlists";

  // Music search filters
  static final String musicSongs = "music_songs";
  static final String musicVideos = "music_videos";
  static final String musicAlbums = "music_albums";
  static final String musicPlaylists = "music_playlists";
  static final String musicArtists = "music_artists";

  // Lists
  static final List<String> searchFilters = [
    videos, channels, playlists, musicSongs, musicVideos
  ];

}