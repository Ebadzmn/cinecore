import '../../data/models/app_system_status_model.dart';

class AppVersionUtils {
  /// Current build version of CineCore
  static const String currentAppVersion = '1.0.0';

  /// Compare two semantic version strings (e.g. "1.0.0" and "1.1.0")
  /// Returns `true` if [current] is strictly older than [target].
  static bool isVersionOlder(String current, String target) {
    try {
      final currentParts = _cleanVersion(current);
      final targetParts = _cleanVersion(target);

      final maxLength = currentParts.length > targetParts.length
          ? currentParts.length
          : targetParts.length;

      for (int i = 0; i < maxLength; i++) {
        final currentVal = i < currentParts.length ? currentParts[i] : 0;
        final targetVal = i < targetParts.length ? targetParts[i] : 0;

        if (currentVal < targetVal) return true;
        if (currentVal > targetVal) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static List<int> _cleanVersion(String v) {
    final clean = v.split('+').first.split('-').first.trim();
    return clean
        .split('.')
        .map((part) => int.tryParse(RegExp(r'\d+').stringMatch(part) ?? '0') ?? 0)
        .toList();
  }

  /// Check whether an update or announcement broadcast is active for this client
  static bool isUpdateAvailable(AppUpdateModel? update) {
    if (update == null || !update.isUpdateActive) return false;

    // 1. If admin activated force update, always show
    if (update.isForceUpdate) return true;

    // 2. If target version is newer than current, update is available
    if (isVersionOlder(currentAppVersion, update.latestVersion)) return true;

    // 3. If admin explicitly turned isUpdateActive ON, treat as active announcement/update broadcast
    return true;
  }

  /// Check whether the update is mandatory (blocks app usage completely)
  static bool isForceUpdateRequired(AppUpdateModel? update) {
    if (update == null || !update.isUpdateActive) return false;
    if (update.isForceUpdate) return true;
    // Also force if current version is below minimum supported version
    return isVersionOlder(currentAppVersion, update.minVersion);
  }
}
