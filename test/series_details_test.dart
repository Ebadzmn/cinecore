import 'package:flutter_test/flutter_test.dart';
import 'package:cinecore/data/models/episode_model.dart';
import 'package:cinecore/data/models/movie_model.dart';
import 'package:cinecore/controllers/series_details_controller.dart';

void main() {
  group('Series & Episode Models Tests', () {
    test('EpisodeModel parses JSON properly and computes getters', () {
      final json = {
        'id': 'ep1',
        'episodeNumber': 1,
        'seasonNumber': 1,
        'name': 'Pilot',
        'duration': 3480, // 58 minutes
        'watchUrl': 'https://example.com/s01e01/master.m3u8',
        'stillPath': 'https://example.com/thumb.jpg',
        'overview': 'A high school chemistry teacher diagnosed with lung cancer.',
      };

      final ep = EpisodeModel.fromJson(json);

      expect(ep.id, 'ep1');
      expect(ep.episodeNumber, 1);
      expect(ep.seasonNumber, 1);
      expect(ep.title, 'Pilot');
      expect(ep.episodeCode, 'S01E01');
      expect(ep.formattedDuration, '58m');
      expect(ep.watchUrl, 'https://example.com/s01e01/master.m3u8');
    });

    test('MovieModel identifies series correctly', () {
      final seriesMovie = MovieModel(
        id: 'series-1',
        title: 'Breaking Bad',
        imageUrl: 'https://example.com/poster.jpg',
        rating: 9.5,
        type: 'SERIES',
        totalSeasons: 5,
        episodes: [
          const EpisodeModel(
            id: 'ep1',
            episodeNumber: 1,
            seasonNumber: 1,
            title: 'Pilot',
          ),
          const EpisodeModel(
            id: 'ep2',
            episodeNumber: 1,
            seasonNumber: 2,
            title: 'Seven Thirty-Seven',
          ),
        ],
      );

      expect(seriesMovie.isSeries, isTrue);
      expect(seriesMovie.totalSeasons, 5);
      expect(seriesMovie.episodes?.length, 2);

      final regularMovie = MovieModel(
        id: 'movie-1',
        title: 'Inception',
        imageUrl: 'https://example.com/poster.jpg',
        rating: 8.8,
        type: 'MOVIE',
        totalSeasons: 0,
      );

      expect(regularMovie.isSeries, isFalse);
    });
  });

  group('SeriesDetailsController Logic Tests', () {
    test('SeriesDetailsController computes dynamic seasons and filters episodes', () {
      final seriesMovie = MovieModel(
        id: 'series-1',
        title: 'Breaking Bad',
        imageUrl: 'https://example.com/poster.jpg',
        rating: 9.5,
        type: 'SERIES',
        totalSeasons: 3,
        episodes: [
          const EpisodeModel(
            id: 'ep1_1',
            episodeNumber: 1,
            seasonNumber: 1,
            title: 'S1E1',
          ),
          const EpisodeModel(
            id: 'ep1_2',
            episodeNumber: 2,
            seasonNumber: 1,
            title: 'S1E2',
          ),
          const EpisodeModel(
            id: 'ep2_1',
            episodeNumber: 1,
            seasonNumber: 2,
            title: 'S2E1',
          ),
        ],
      );

      final controller = SeriesDetailsController(
        seriesId: 'series-1',
        initialSeries: seriesMovie,
      );

      // Verify computed seasons
      expect(controller.availableSeasons, containsAll([1, 2, 3]));

      // Verify season 1 episodes
      controller.selectSeason(1);
      expect(controller.currentSeasonEpisodes.length, 2);
      expect(controller.currentSeasonEpisodes.first.title, 'S1E1');

      // Verify season 2 episodes
      controller.selectSeason(2);
      expect(controller.currentSeasonEpisodes.length, 1);
      expect(controller.currentSeasonEpisodes.first.title, 'S2E1');

      // Verify season 3 episodes (empty list handled gracefully)
      controller.selectSeason(3);
      expect(controller.currentSeasonEpisodes.isEmpty, isTrue);
    });

    test('SeriesDetailsController next/previous episode navigation', () {
      final episodes = [
        const EpisodeModel(id: '1', episodeNumber: 1, seasonNumber: 1, title: 'Ep 1'),
        const EpisodeModel(id: '2', episodeNumber: 2, seasonNumber: 1, title: 'Ep 2'),
        const EpisodeModel(id: '3', episodeNumber: 1, seasonNumber: 2, title: 'Ep 3'),
      ];

      final seriesMovie = MovieModel(
        id: 'series-test',
        title: 'Test Series',
        imageUrl: 'https://example.com/poster.jpg',
        rating: 8.9,
        type: 'SERIES',
        totalSeasons: 2,
        episodes: episodes,
      );

      final controller = SeriesDetailsController(
        seriesId: 'series-test',
        initialSeries: seriesMovie,
      );

      expect(controller.currentPlayingEpisode.value?.id, '1');

      // Play next episode
      controller.playNextEpisode();
      expect(controller.currentPlayingEpisode.value?.id, '2');

      // Play next across season boundary
      controller.playNextEpisode();
      expect(controller.currentPlayingEpisode.value?.id, '3');
      expect(controller.selectedSeasonNumber.value, 2);

      // Play previous
      controller.playPreviousEpisode();
      expect(controller.currentPlayingEpisode.value?.id, '2');
      expect(controller.selectedSeasonNumber.value, 1);
    });
  });
}
