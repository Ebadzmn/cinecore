class CastMemberModel {
  final String name;
  final String character;
  final String imageUrl;

  const CastMemberModel({
    required this.name,
    required this.character,
    required this.imageUrl,
  });

  factory CastMemberModel.fromJson(Map<String, dynamic> json) {
    return CastMemberModel(
      name: json['name']?.toString() ?? '',
      character: json['character']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ??
          json['image']?.toString() ??
          json['profile_path']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'character': character,
      'imageUrl': imageUrl,
    };
  }
}

class MovieScreenshotModel {
  final String title;
  final String imageUrl;
  final String tag;

  const MovieScreenshotModel({
    required this.title,
    required this.imageUrl,
    required this.tag,
  });

  factory MovieScreenshotModel.fromJson(Map<String, dynamic> json) {
    return MovieScreenshotModel(
      title: json['title']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      tag: json['tag']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'tag': tag,
    };
  }
}
