class RemoteMedia {
  String url;
  String id;

  RemoteMedia({this.id, this.url});

  factory RemoteMedia.fromJson(Map<String, dynamic> data) {
    return RemoteMedia(
      id: data['id'],
      url: data['url'],
    );
  }
}
