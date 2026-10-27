import 'package:flutter_test/flutter_test.dart';
import 'package:cinecore/data/models/home_feed_model.dart';
import 'package:cinecore/data/services/movie_api_service.dart';

void main() {
  group('Home CMS Models Tests', () {
    test('HeroBannerModel parses JSON and converts to SpotlightMovieItem', () {
      final bannerJson = {
        '_id': 'banner_123',
        'title': 'Dune: Part Two',
        'subtitle': 'Long Live the Fighters',
        'description': 'Paul Atreides unites with Chani and the Fremen.',
        'mediaType': 'MOVIE',
        'movieId': {
          '_id': 'movie_dune2',
          'title': 'Dune: Part Two',
          'imageUrl': 'https://example.com/poster.jpg',
          'backdropUrl': 'https://example.com/backdrop.jpg',
          'rating': 9.4,
          'genres': 'Sci-Fi, Adventure',
          'duration': '2h 46m',
          'resolution': '4K IMAX',
        },
        'badge': 'IMAX EXCLUSIVE',
        'ctaText': 'PLAY NOW',
        'ctaAction': 'PLAY',
        'order': 1,
        'isActive': true,
      };

      final banner = HeroBannerModel.fromJson(bannerJson);
      expect(banner.id, 'banner_123');
      expect(banner.title, 'Dune: Part Two');
      expect(banner.badge, 'IMAX EXCLUSIVE');
      expect(banner.ctaAction, 'PLAY');
      expect(banner.displayImageUrl, 'https://example.com/backdrop.jpg');

      final spotlight = banner.toSpotlightItem();
      expect(spotlight.fullTitle, 'Dune: Part Two');
      expect(spotlight.badgeText, 'IMAX EXCLUSIVE');
      expect(spotlight.rating, 9.4);
    });

    test('HomeSectionModel parses sections and converts items to TopBlockbusterMovie', () {
      final sectionJson = {
        '_id': 'sec_top10',
        'key': 'top_10_blockbusters',
        'title': 'Top 10 Blockbusters',
        'subtitle': 'Most watched this week',
        'sectionType': 'TOP_10',
        'contentType': 'MOVIE',
        'maxItems': 10,
        'order': 1,
        'isActive': true,
        'isSystem': true,
        'items': [
          {
            'order': 1,
            'customTag': '#1 TRENDING',
            'movie': {
              '_id': 'm_oppenheimer',
              'title': 'Oppenheimer',
              'imageUrl': 'https://example.com/opp.jpg',
              'rating': 9.3,
              'duration': '3h 00m',
              'genres': 'Biography, Drama',
            },
          },
        ],
      };

      final section = HomeSectionModel.fromJson(sectionJson);
      expect(section.key, 'top_10_blockbusters');
      expect(section.sectionType, 'TOP_10');
      expect(section.items.length, 1);
      expect(section.movies.length, 1);
      expect(section.movies.first.title, 'Oppenheimer');

      final rankedMovie = section.items.first.toTopBlockbusterMovie(0);
      expect(rankedMovie.title, 'Oppenheimer');
      expect(rankedMovie.rankTag, '#1 TRENDING');
    });

    test('HomeFeedModel parses multiple banners and sections', () {
      final feedJson = {
        'banners': [
          {
            '_id': 'b1',
            'title': 'Banner 1',
            'subtitle': 'Sub 1',
            'badge': 'PREMIERE',
            'ctaText': 'WATCH',
            'ctaAction': 'PLAY',
            'order': 1,
            'isActive': true,
          }
        ],
        'sections': [
          {
            '_id': 's1',
            'key': 'top_10_blockbusters',
            'title': 'Top 10',
            'sectionType': 'TOP_10',
            'contentType': 'MOVIE',
            'order': 1,
            'isActive': true,
            'items': [],
          },
          {
            '_id': 's2',
            'key': 'top_series',
            'title': 'Top Series',
            'sectionType': 'SERIES_ROW',
            'contentType': 'SERIES',
            'order': 2,
            'isActive': true,
            'items': [],
          }
        ],
      };

      final feed = HomeFeedModel.fromJson(feedJson);
      expect(feed.banners.length, 1);
      expect(feed.sections.length, 2);
      expect(feed.getSection('top_10_blockbusters'), isNotNull);
      expect(feed.getSection('top_series'), isNotNull);
      expect(feed.getSection('non_existent'), isNull);
    });

    test('Live Backend API /feed/home returns valid active CMS content', () async {
      final apiService = MovieApiService();
      final feed = await apiService.getHomeFeed();

      expect(feed, isNotNull);
      expect(feed!.banners, isNotEmpty);
      expect(feed.sections, isNotEmpty);

      // Verify default seeded Top 10 and Top Series are present
      final top10 = feed.getSection('top_10_blockbusters');
      expect(top10, isNotNull);
      expect(top10!.sectionType, 'TOP_10');

      final topSeries = feed.getSection('top_series');
      expect(topSeries, isNotNull);
      expect(topSeries!.sectionType, 'SERIES_ROW');
    });
  });
}
