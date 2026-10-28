import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../models/continue_watching_model.dart';
import '../models/watch_history_model.dart';

class PlaybackService {
  static final PlaybackService _instance = PlaybackService._internal();
  factory PlaybackService() => _instance;
  PlaybackService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Record or update playback heartbeat and current position in backend
  Future<WatchHistoryModel?> recordProgress({
    required String movieId,
    required double positionSeconds,
    required double durationSeconds,
    int? seasonNumber,
    int? episodeNumber,
    String? episodeId,
    String? episodeTitle,
    String action = 'HEARTBEAT',
  }) async {
    try {
      final payload = <String, dynamic>{
        'movieId': movieId,
        'positionSeconds': positionSeconds,
        'durationSeconds': durationSeconds,
        'action': action,
      };
      if (seasonNumber != null) payload['seasonNumber'] = seasonNumber;
      if (episodeNumber != null) payload['episodeNumber'] = episodeNumber;
      if (episodeId != null) payload['episodeId'] = episodeId;
      if (episodeTitle != null) payload['episodeTitle'] = episodeTitle;

      final response = await _apiClient.post(
        ApiConstants.playbackProgress,
        data: payload,
      );

      if (response.data != null && response.data['data'] is Map<String, dynamic>) {
        return WatchHistoryModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('⚠️ [PlaybackService] Failed to record progress: $e');
    }
    return null;
  }

  /// Get current saved progress for resuming a movie or episode
  Future<WatchHistoryModel?> getProgress(
    String movieId, {
    int? seasonNumber,
    int? episodeNumber,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (seasonNumber != null) queryParams['seasonNumber'] = seasonNumber;
      if (episodeNumber != null) queryParams['episodeNumber'] = episodeNumber;

      final response = await _apiClient.get(
        '${ApiConstants.playbackProgress}/$movieId',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data != null && response.data['data'] is Map<String, dynamic>) {
        return WatchHistoryModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('⚠️ [PlaybackService] Failed to get playback progress for $movieId: $e');
    }
    return null;
  }

  /// Get active "Continue Watching" list for the user
  Future<List<ContinueWatchingModel>> getContinueWatching() async {
    try {
      final response = await _apiClient.get(ApiConstants.continueWatching);
      if (response.data != null && response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((item) => ContinueWatchingModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('⚠️ [PlaybackService] Failed to get continue watching: $e');
    }
    return [];
  }

  /// Get full Watch History list with pagination and filter
  Future<List<WatchHistoryModel>> getWatchHistory({
    int page = 1,
    int limit = 30,
    String status = 'ALL',
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.watchHistory,
        queryParameters: {
          'page': page,
          'limit': limit,
          'status': status,
        },
      );

      if (response.data != null && response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((item) => WatchHistoryModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('⚠️ [PlaybackService] Failed to get watch history: $e');
    }
    return [];
  }

  /// Delete a single watch history entry
  Future<bool> deleteHistoryItem(String id) async {
    try {
      final response = await _apiClient.delete('${ApiConstants.watchHistory}/$id');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('⚠️ [PlaybackService] Failed to delete history item $id: $e');
      return false;
    }
  }

  /// Clear all watch history for user
  Future<bool> clearAllHistory() async {
    try {
      final response = await _apiClient.delete(ApiConstants.watchHistory);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('⚠️ [PlaybackService] Failed to clear watch history: $e');
      return false;
    }
  }

  /// Get map of playback progress for all watched titles
  Future<Map<String, dynamic>> getPlaybackSummary() async {
    try {
      final response = await _apiClient.get(ApiConstants.playbackSummary);
      if (response.data != null && response.data['data'] is Map) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }
    } catch (e) {
      debugPrint('⚠️ [PlaybackService] Failed to get playback summary: $e');
    }
    return {};
  }
}
