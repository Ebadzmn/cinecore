import 'package:cinecore/data/services/hls_playlist_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HlsPlaylistService Tests', () {
    test('extracts only 720p and Auto when only 720p is present in playlist', () {
      const samplePlaylist = '''#EXTM3U
#EXT-X-VERSION:3

#EXT-X-STREAM-INF:BANDWIDTH=2200000,RESOLUTION=1280x720,NAME="720p"
720p/index.m3u8
''';

      const masterUrl = 'https://cdn.example.com/movies/james-bond/hls/master.m3u8';
      final qualities = HlsPlaylistService.parsePlaylistContent(samplePlaylist, masterUrl);

      expect(qualities.length, 2);
      expect(qualities[0].id, 'Auto');
      expect(qualities[0].isAuto, true);
      expect(qualities[0].url, masterUrl);

      expect(qualities[1].id, '720p');
      expect(qualities[1].title, '720p (HD)');
      expect(qualities[1].height, 720);
      expect(qualities[1].url, 'https://cdn.example.com/movies/james-bond/hls/720p/index.m3u8');

      // Unavailable qualities must not exist
      final ids = qualities.map((q) => q.id).toSet();
      expect(ids.contains('1080p'), false);
      expect(ids.contains('480p'), false);
      expect(ids.contains('360p'), false);
    });

    test('extracts both 1080p and 720p when both are present in playlist', () {
      const samplePlaylist = '''#EXTM3U
#EXT-X-VERSION:3

#EXT-X-STREAM-INF:BANDWIDTH=3500000,RESOLUTION=1920x1080,NAME="1080p"
1080p/index.m3u8

#EXT-X-STREAM-INF:BANDWIDTH=2200000,RESOLUTION=1280x720,NAME="720p"
720p/index.m3u8
''';

      const masterUrl = 'https://cdn.example.com/movies/action-hero/hls/master.m3u8';
      final qualities = HlsPlaylistService.parsePlaylistContent(samplePlaylist, masterUrl);

      expect(qualities.length, 3);
      expect(qualities[0].id, 'Auto');
      expect(qualities[1].id, '1080p');
      expect(qualities[1].title, '1080p (Full HD)');
      expect(qualities[1].url, 'https://cdn.example.com/movies/action-hero/hls/1080p/index.m3u8');

      expect(qualities[2].id, '720p');
      expect(qualities[2].title, '720p (HD)');
      expect(qualities[2].url, 'https://cdn.example.com/movies/action-hero/hls/720p/index.m3u8');

      final ids = qualities.map((q) => q.id).toSet();
      expect(ids.contains('480p'), false);
      expect(ids.contains('360p'), false);
    });

    test('handles absolute variant URLs correctly', () {
      const samplePlaylist = '''#EXTM3U
#EXT-X-STREAM-INF:BANDWIDTH=1800000,RESOLUTION=1280x720
https://sub.cdn.com/streams/720p.m3u8
''';

      const masterUrl = 'https://cdn.example.com/master.m3u8';
      final qualities = HlsPlaylistService.parsePlaylistContent(samplePlaylist, masterUrl);

      expect(qualities.length, 2);
      expect(qualities[1].id, '720p');
      expect(qualities[1].url, 'https://sub.cdn.com/streams/720p.m3u8');
    });
  });
}
