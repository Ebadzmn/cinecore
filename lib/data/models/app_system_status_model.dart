class AppUpdateModel {
  final bool isUpdateActive;
  final bool isForceUpdate;
  final String latestVersion;
  final String minVersion;
  final String title;
  final String message;
  final List<String> releaseNotes;
  final String downloadUrl;

  const AppUpdateModel({
    required this.isUpdateActive,
    required this.isForceUpdate,
    required this.latestVersion,
    required this.minVersion,
    required this.title,
    required this.message,
    required this.releaseNotes,
    required this.downloadUrl,
  });

  factory AppUpdateModel.fromJson(Map<String, dynamic> json) {
    final rawNotes = json['releaseNotes'];
    List<String> parsedNotes = [];
    if (rawNotes is List) {
      parsedNotes = rawNotes.map((e) => e.toString()).toList();
    }

    return AppUpdateModel(
      isUpdateActive: json['isUpdateActive'] == true,
      isForceUpdate: json['isForceUpdate'] == true,
      latestVersion: json['latestVersion']?.toString() ?? '1.0.0',
      minVersion: json['minVersion']?.toString() ?? '1.0.0',
      title: json['title']?.toString() ?? 'New Update Available!',
      message: json['message']?.toString() ??
          'A new version of CineCore is available with performance improvements and new features.',
      releaseNotes: parsedNotes,
      downloadUrl: json['downloadUrl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'isUpdateActive': isUpdateActive,
    'isForceUpdate': isForceUpdate,
    'latestVersion': latestVersion,
    'minVersion': minVersion,
    'title': title,
    'message': message,
    'releaseNotes': releaseNotes,
    'downloadUrl': downloadUrl,
  };
}

class AppSystemStatusModel {
  final bool isMaintenance;
  final String title;
  final String message;
  final String? estimatedDowntime;
  final String? supportContact;
  final AppUpdateModel? appUpdate;

  const AppSystemStatusModel({
    required this.isMaintenance,
    required this.title,
    required this.message,
    this.estimatedDowntime,
    this.supportContact,
    this.appUpdate,
  });

  factory AppSystemStatusModel.fromJson(Map<String, dynamic> json) {
    return AppSystemStatusModel(
      isMaintenance: json['isMaintenance'] == true,
      title: json['title']?.toString() ?? 'Under Scheduled Maintenance',
      message:
          json['message']?.toString() ??
          'CineCore is currently undergoing scheduled maintenance to upgrade streaming servers. Please check back shortly.',
      estimatedDowntime: json['estimatedDowntime']?.toString(),
      supportContact:
          json['supportContact']?.toString() ?? 'support@cinecore.io',
      appUpdate: json['appUpdate'] is Map<String, dynamic>
          ? AppUpdateModel.fromJson(json['appUpdate'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'isMaintenance': isMaintenance,
    'title': title,
    'message': message,
    'estimatedDowntime': estimatedDowntime,
    'supportContact': supportContact,
    'appUpdate': appUpdate?.toJson(),
  };
}
