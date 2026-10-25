class UserProfileModel {
  final String id;
  final String email;
  final String displayName;
  final String avatarUrl;
  final bool isGuest;

  const UserProfileModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.avatarUrl,
    this.isGuest = false,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: json['displayName']?.toString() ??
          json['display_name']?.toString() ??
          json['name']?.toString() ??
          'Cinephile',
      avatarUrl: json['avatarUrl']?.toString() ?? json['avatar_url']?.toString() ?? '',
      isGuest: json['isGuest'] == true || json['is_guest'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'isGuest': isGuest,
    };
  }
}
