class ContinueWatchingModel {
  final String id;
  final String title;
  final String episodeInfo;
  final String remainingTime;
  final String qualityInfo;
  final String audioInfo;
  final String imageUrl;
  final double progress; // 0.0 to 1.0

  const ContinueWatchingModel({
    required this.id,
    required this.title,
    required this.episodeInfo,
    required this.remainingTime,
    required this.qualityInfo,
    required this.audioInfo,
    required this.imageUrl,
    required this.progress,
  });

  factory ContinueWatchingModel.fromJson(Map<String, dynamic> json) {
    return ContinueWatchingModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      episodeInfo: json['episodeInfo']?.toString() ?? '',
      remainingTime: json['remainingTime']?.toString() ?? '',
      qualityInfo: json['qualityInfo']?.toString() ?? '4K UHD',
      audioInfo: json['audioInfo']?.toString() ?? 'Dolby Atmos',
      imageUrl: json['imageUrl']?.toString() ?? '',
      progress: (json['progress'] is num) ? (json['progress'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'episodeInfo': episodeInfo,
      'remainingTime': remainingTime,
      'qualityInfo': qualityInfo,
      'audioInfo': audioInfo,
      'imageUrl': imageUrl,
      'progress': progress,
    };
  }
}
