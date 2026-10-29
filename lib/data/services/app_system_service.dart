import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../models/app_system_status_model.dart';

class AppSystemService {
  final ApiClient _apiClient = ApiClient();

  /// Fetches real-time server maintenance & operational status
  Future<AppSystemStatusModel> checkAppStatus() async {
    try {
      final response = await _apiClient.get(ApiConstants.systemStatus);
      final responseData = response.data as Map<String, dynamic>;
      final rawData = (responseData['data'] as Map<String, dynamic>?) ?? {};
      return AppSystemStatusModel.fromJson(rawData);
    } catch (e) {
      debugPrint('⚠️ [AppSystemService] Error checking app system status: $e');
    }

    // Default safe fallback if network or connection fails
    return const AppSystemStatusModel(
      isMaintenance: false,
      title: 'Under Scheduled Maintenance',
      message:
          'CineCore is currently undergoing scheduled maintenance to upgrade streaming servers. Please check back shortly.',
    );
  }
}
