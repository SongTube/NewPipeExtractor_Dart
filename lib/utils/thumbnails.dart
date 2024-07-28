class StreamThumbnail {

  final String? id;
   
  StreamThumbnail(this.id);

  String get hqdefault => "https://img.youtube.com/vi/$id/hqdefault.jpg";

  String get mqdefault => "https://img.youtube.com/vi/$id/mqdefault.jpg";

  String get sddefault => "https://img.youtube.com/vi/$id/sddefault.jpg";

  String get maxresdefault => "https://img.youtube.com/vi/$id/maxresdefault.jpg";

  List<String> toList() {
    return [
      sddefault,
      mqdefault,
      hqdefault,
      maxresdefault
    ];
  }

}