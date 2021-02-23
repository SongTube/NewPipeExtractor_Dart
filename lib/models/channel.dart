class YoutubeChannel {

  /// Channel Id
  String id;

  /// Channel name
  String name;

  /// Channel Url
  String url;

  /// Channel avatar image Url
  String avatarUrl;

  /// Channel banner image Url
  String bannerUrl;

  /// Channel description
  String description;

  /// Channel feed Url
  String feedUrl;

  /// Channel subscriber Count
  int subscriberCount;

  YoutubeChannel({
    this.id,
    this.name,
    this.url,
    this.avatarUrl,
    this.bannerUrl,
    this.description,
    this.feedUrl,
    this.subscriberCount
  });

}