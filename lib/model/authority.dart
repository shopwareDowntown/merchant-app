class Authority {
  String id;
  String name;
  String domain;
  String accessKey;

  Authority({
    this.id,
    this.name,
    this.domain,
    this.accessKey,
  });

  factory Authority.fromJson(Map<String, dynamic> data) {
    return Authority(
      id: data['id'],
      name: data['name'],
      domain: data['domain'],
      accessKey: data['accessKey'],
    );
  }
}
