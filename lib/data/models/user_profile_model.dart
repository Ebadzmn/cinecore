class UserProfileModel {
  final String id;
  final String email;
  final String displayName;
  final String avatarUrl;
  final bool isGuest;
  final String status;
  final String? blockReason;

  const UserProfileModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.avatarUrl,
    this.isGuest = false,
    this.status = 'ACTIVE',
    this.blockReason,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: json['displayName']?.toString() ??
          json['display_name']?.toString() ??
          json['name']?.toString() ??
          (json['isGuest'] == true ? 'Guest Cinephile' : 'Cinephile'),
      avatarUrl: json['avatarUrl']?.toString() ?? json['avatar_url']?.toString() ?? '',
      isGuest: json['isGuest'] == true || json['is_guest'] == true,
      status: json['status']?.toString() ?? 'ACTIVE',
      blockReason: json['blockReason']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'isGuest': isGuest,
      'status': status,
      if (blockReason != null) 'blockReason': blockReason,
    };
  }
}
