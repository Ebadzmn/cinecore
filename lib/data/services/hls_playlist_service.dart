import 'package:dio/dio.dart';
import '../models/video_quality_option.dart';

class HlsPlaylistService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      headers: {
        'Accept': '*/*',
        'User-Agent': 'Cinecore/1.0',
      },
    ),
  );

  /// Fetches and parses an M3U8 master playlist, extracting all valid stream renditions.
  /// If the playlist cannot be parsed or contains no variants, returns a default 'Auto' option.
  static Future<List<VideoQualityOption>> parseQualities(String masterUrl) async {
    final cleanUrl = masterUrl.trim();
    if (cleanUrl.isEmpty) return const [];

    try {
      final response = await _dio.get<String>(
        cleanUrl,
        options: Options(responseType: ResponseType.plain),
      );

      final content = response.data;
      if (content == null || content.isEmpty) {
        return [_createAutoOption(cleanUrl)];
      }

      return parsePlaylistContent(content, cleanUrl);
    } catch (_) {
      // In case of network or parsing error, fallback safely to Auto
      return [_createAutoOption(cleanUrl)];
    }
  }

  /// Parses the raw string content of an M3U8 playlist
  static List<VideoQualityOption> parsePlaylistContent(String content, String baseUrl) {
    final lines = content.split(RegExp(r'\r?\n'));
    final List<VideoQualityOption> variants = [];
    final baseUri = Uri.parse(baseUrl);

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.startsWith('#EXT-X-STREAM-INF:')) {
        final attributesStr = line.substring('#EXT-X-STREAM-INF:'.length);

        // 1. Resolution (e.g. RESOLUTION=1920x1080)
        int? width;
        int? height;
        final resMatch = RegExp(r'RESOLUTION=(\d+)x(\d+)', caseSensitive: false).firstMatch(attributesStr);
        if (resMatch != null) {
          width = int.tryParse(resMatch.group(1) ?? '');
          height = int.tryParse(resMatch.group(2) ?? '');
        }

        // 2. Bandwidth (e.g. BANDWIDTH=3500000)
        int? bandwidth;
        final bwMatch = RegExp(r'BANDWIDTH=(\d+)', caseSensitive: false).firstMatch(attributesStr);
        if (bwMatch != null) {
          bandwidth = int.tryParse(bwMatch.group(1) ?? '');
        }

        // 3. Name (optional, e.g. NAME="1080p")
        String? name;
        final nameMatch = RegExp(r'NAME="?([^",]+)"?', caseSensitive: false).firstMatch(attributesStr);
        if (nameMatch != null) {
          name = nameMatch.group(1)?.trim();
        }

        // The next non-empty, non-comment line is the rendition URI
        String? streamUri;
        for (int j = i + 1; j < lines.length; j++) {
          final nextLine = lines[j].trim();
          if (nextLine.isNotEmpty && !nextLine.startsWith('#')) {
            streamUri = nextLine;
            i = j; // Advance outer loop
            break;
          }
        }

        if (streamUri != null && streamUri.isNotEmpty) {
          // Resolve relative or absolute URL against master playlist base URI
          final resolvedUrl = baseUri.resolve(streamUri).toString();

          final opt = _buildVariantOption(
            height: height,
            width: width,
            bandwidth: bandwidth,
            customName: name,
            url: resolvedUrl,
          );
          variants.add(opt);
        }
      }
    }

    if (variants.isEmpty) {
      return [_createAutoOption(baseUrl)];
    }

    // Sort descending by height (e.g. 1080p, 720p, 480p) or bandwidth
    variants.sort((a, b) {
      final hA = a.height ?? 0;
      final hB = b.height ?? 0;
      if (hA != hB) return hB.compareTo(hA);
      return (b.bandwidth ?? 0).compareTo(a.bandwidth ?? 0);
    });

    // Remove duplicates if multiple audio/sub variants share the same resolution
    final Set<String> seenIds = {};
    final List<VideoQualityOption> uniqueVariants = [];
    for (final v in variants) {
      if (!seenIds.contains(v.id)) {
        seenIds.add(v.id);
        uniqueVariants.add(v);
      }
    }

    // Auto is always at index 0 for adaptive streaming
    return [
      _createAutoOption(baseUrl),
      ...uniqueVariants,
    ];
  }

  static VideoQualityOption _createAutoOption(String url) {
    return VideoQualityOption(
      id: 'Auto',
      title: 'Auto',
      subtitle: 'Adaptive bitrate (Recommended)',
      badge: 'AUTO',
      url: url,
      isAuto: true,
    );
  }

  static VideoQualityOption _buildVariantOption({
    int? height,
    int? width,
    int? bandwidth,
    String? customName,
    required String url,
  }) {
    String id;
    String title;
    String badge;

    if (height != null) {
      id = '${height}p';
      if (height >= 2160) {
        title = '2160p (4K Ultra HD)';
        badge = '4K';
      } else if (height >= 1440) {
        title = '1440p (2K QHD)';
        badge = '2K';
      } else if (height >= 1080) {
        title = '1080p (Full HD)';
        badge = 'FHD';
      } else if (height >= 720) {
        title = '720p (HD)';
        badge = 'HD';
      } else if (height >= 480) {
        title = '480p (SD)';
        badge = 'SD';
      } else if (height >= 360) {
        title = '360p (Data Saver)';
        badge = 'ECO';
      } else {
        title = '${height}p';
        badge = '${height}p';
      }
    } else if (customName != null && customName.isNotEmpty) {
      id = customName.toLowerCase();
      title = customName;
      badge = customName.toUpperCase();
    } else if (bandwidth != null) {
      final mbps = (bandwidth / 1000000).toStringAsFixed(1);
      id = '${mbps}mbps';
      title = '$mbps Mbps';
      badge = 'NET';
    } else {
      id = 'stream';
      title = 'Standard';
      badge = 'STD';
    }

    // Subtitle formatting
    String subtitle;
    if (width != null && height != null && bandwidth != null) {
      final mbps = (bandwidth / 1000000).toStringAsFixed(1);
      subtitle = '$width×$height • $mbps Mbps';
    } else if (width != null && height != null) {
      subtitle = '$width×$height resolution';
    } else if (bandwidth != null) {
      final mbps = (bandwidth / 1000000).toStringAsFixed(1);
      subtitle = '$mbps Mbps bitrate';
    } else {
      subtitle = 'Direct stream rendition';
    }

    return VideoQualityOption(
      id: id,
      title: title,
      subtitle: subtitle,
      badge: badge,
      url: url,
      height: height,
      width: width,
      bandwidth: bandwidth,
      isAuto: false,
    );
  }
}
