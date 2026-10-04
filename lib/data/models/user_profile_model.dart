class UserProfileModel {
  final String id;
  final String email;
  final String displayName;
  final String avatarUrl;
  final String subscriptionTier; // 'CINEMAX 4K VIP', 'PREMIUM', 'FREE'
  final bool isVip;

  const UserProfileModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.avatarUrl,
    this.subscriptionTier = 'CINEMAX 4K VIP',
    this.isVip = true,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? json['display_name']?.toString() ?? 'Austin Rivera',
      avatarUrl: json['avatarUrl']?.toString() ?? json['avatar_url']?.toString() ?? '',
      subscriptionTier: json['subscriptionTier']?.toString() ?? 'CINEMAX 4K VIP',
      isVip: json['isVip'] == true || json['subscriptionTier'] == 'CINEMAX 4K VIP',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'subscriptionTier': subscriptionTier,
      'isVip': isVip,
    };
  }
}
