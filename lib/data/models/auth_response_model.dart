import 'user_profile_model.dart';

class AuthResponseModel {
  final String token;
  final UserProfileModel user;

  const AuthResponseModel({
    required this.token,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token']?.toString() ?? '',
      user: UserProfileModel.fromJson(
        (json['user'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }
}
