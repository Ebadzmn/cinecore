import 'package:flutter_test/flutter_test.dart';
import 'package:cinecore/core/utils/version_utils.dart';
import 'package:cinecore/data/models/app_system_status_model.dart';

void main() {
  group('AppVersionUtils Tests', () {
    test('isVersionOlder accurately compares semantic versions', () {
      expect(AppVersionUtils.isVersionOlder('1.0.0', '1.0.1'), isTrue);
      expect(AppVersionUtils.isVersionOlder('1.0.0', '1.1.0'), isTrue);
      expect(AppVersionUtils.isVersionOlder('1.0.0', '2.0.0'), isTrue);
      expect(AppVersionUtils.isVersionOlder('1.0.0', '1.0.0'), isFalse);
      expect(AppVersionUtils.isVersionOlder('1.1.0', '1.0.0'), isFalse);
      expect(AppVersionUtils.isVersionOlder('2.0.0', '1.9.9'), isFalse);
      // Suffixes and build numbers
      expect(AppVersionUtils.isVersionOlder('1.0.0+1', '1.0.1+2'), isTrue);
      expect(AppVersionUtils.isVersionOlder('1.0.0-beta', '1.0.1'), isTrue);
    });

    test('isUpdateAvailable returns true when active', () {
      const updateInactive = AppUpdateModel(
        isUpdateActive: false,
        isForceUpdate: false,
        latestVersion: '2.0.0',
        minVersion: '1.0.0',
        title: 'Title',
        message: 'Msg',
        releaseNotes: [],
        downloadUrl: 'https://cinecore.io/app.apk',
      );
      expect(AppVersionUtils.isUpdateAvailable(updateInactive), isFalse);

      const updateActiveNewer = AppUpdateModel(
        isUpdateActive: true,
        isForceUpdate: false,
        latestVersion: '2.0.0',
        minVersion: '1.0.0',
        title: 'Title',
        message: 'Msg',
        releaseNotes: [],
        downloadUrl: 'https://cinecore.io/app.apk',
      );
      expect(AppVersionUtils.isUpdateAvailable(updateActiveNewer), isTrue);

      const updateActiveSameVersion = AppUpdateModel(
        isUpdateActive: true,
        isForceUpdate: false,
        latestVersion: '1.0.0',
        minVersion: '1.0.0',
        title: 'Announcement Notice',
        message: 'Msg',
        releaseNotes: [],
        downloadUrl: 'https://cinecore.io/app.apk',
      );
      expect(AppVersionUtils.isUpdateAvailable(updateActiveSameVersion), isTrue);
    });

    test('isForceUpdateRequired returns true for required update or when below minVersion', () {
      // Optional update (minVersion <= currentAppVersion and isForceUpdate == false)
      const optionalUpdate = AppUpdateModel(
        isUpdateActive: true,
        isForceUpdate: false,
        latestVersion: '2.0.0',
        minVersion: '1.0.0', // current 1.0.0 >= minVersion
        title: 'Title',
        message: 'Msg',
        releaseNotes: [],
        downloadUrl: 'https://cinecore.io/app.apk',
      );
      expect(AppVersionUtils.isForceUpdateRequired(optionalUpdate), isFalse);

      // Force update by flag
      const forcedUpdate = AppUpdateModel(
        isUpdateActive: true,
        isForceUpdate: true,
        latestVersion: '2.0.0',
        minVersion: '1.0.0',
        title: 'Title',
        message: 'Msg',
        releaseNotes: [],
        downloadUrl: 'https://cinecore.io/app.apk',
      );
      expect(AppVersionUtils.isForceUpdateRequired(forcedUpdate), isTrue);

      // Force update by minVersion > currentVersion
      const minVersionExceededUpdate = AppUpdateModel(
        isUpdateActive: true,
        isForceUpdate: false,
        latestVersion: '2.0.0',
        minVersion: '1.5.0', // current 1.0.0 is below minVersion 1.5.0
        title: 'Title',
        message: 'Msg',
        releaseNotes: [],
        downloadUrl: 'https://cinecore.io/app.apk',
      );
      expect(AppVersionUtils.isForceUpdateRequired(minVersionExceededUpdate), isTrue);
    });
  });

  group('AppUpdateModel & AppSystemStatusModel serialization', () {
    test('serializes and deserializes properly from JSON', () {
      final json = {
        'isMaintenance': false,
        'title': 'Operational',
        'message': 'All systems normal',
        'appUpdate': {
          'isUpdateActive': true,
          'isForceUpdate': true,
          'latestVersion': '1.2.0',
          'minVersion': '1.1.0',
          'title': 'New CineCore Release',
          'message': 'Features 4K streaming and fixes',
          'releaseNotes': ['4K UHD playback', 'Community post edits'],
          'downloadUrl': 'https://cinecore.io/download/app-1.2.0.apk',
        }
      };

      final status = AppSystemStatusModel.fromJson(json);
      expect(status.isMaintenance, isFalse);
      expect(status.appUpdate, isNotNull);
      expect(status.appUpdate!.isUpdateActive, isTrue);
      expect(status.appUpdate!.isForceUpdate, isTrue);
      expect(status.appUpdate!.latestVersion, '1.2.0');
      expect(status.appUpdate!.releaseNotes.length, 2);
      expect(status.appUpdate!.downloadUrl, 'https://cinecore.io/download/app-1.2.0.apk');
    });
  });
}
