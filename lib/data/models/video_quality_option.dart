class VideoQualityOption {
  final String id;
  final String title;
  final String subtitle;
  final String badge;
  final String url;
  final int? height;
  final int? width;
  final int? bandwidth;
  final bool isAuto;

  const VideoQualityOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.url,
    this.height,
    this.width,
    this.bandwidth,
    this.isAuto = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoQualityOption &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          url == other.url;

  @override
  int get hashCode => id.hashCode ^ url.hashCode;

  @override
  String toString() => 'VideoQualityOption($id: $title, url: $url)';
}
