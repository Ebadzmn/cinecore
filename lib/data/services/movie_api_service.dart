import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../models/cast_member_model.dart';
import '../models/continue_watching_model.dart';
import '../models/movie_model.dart';
import '../models/user_profile_model.dart';

class MovieApiService {
  final ApiClient _apiClient = ApiClient();

  // 1. Fetch Home Feed
  Future<List<MovieModel>> getSpotlightMovies() async {
    try {
      final response = await _apiClient.get(ApiConstants.spotlight);
      if (response.data != null && response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback curated mock data
    }
    return _defaultSpotlightMovies;
  }

  Future<List<MovieModel>> getTopBlockbusters() async {
    try {
      final response = await _apiClient.get('${ApiConstants.leaderboard}?category=top_10');
      if (response.data != null && response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback
    }
    return _defaultTopBlockbusters;
  }

  Future<List<MovieModel>> getPeacockPicks() async {
    try {
      final response = await _apiClient.get('${ApiConstants.movies}?curated=peacock_picks');
      if (response.data != null && response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback
    }
    return _defaultPeacockPicks;
  }

  Future<List<ContinueWatchingModel>> getContinueWatching() async {
    try {
      final response = await _apiClient.get(ApiConstants.continueWatching);
      if (response.data != null && response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((item) => ContinueWatchingModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback
    }
    return _defaultContinueWatching;
  }

  // 2. Fetch Details, Cast, Related & Gallery
  Future<List<CastMemberModel>> getCastMembers(String movieId) async {
    try {
      final response = await _apiClient.get('${ApiConstants.movies}/$movieId/cast-crew');
      if (response.data != null && response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((item) => CastMemberModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback
    }
    return _defaultCastMembers;
  }

  Future<List<MovieScreenshotModel>> getScreenshots(String movieId) async {
    try {
      final response = await _apiClient.get('${ApiConstants.movies}/$movieId/gallery');
      if (response.data != null && response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((item) => MovieScreenshotModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback
    }
    return _defaultScreenshots;
  }

  Future<List<MovieModel>> getRelatedMovies(String movieId) async {
    try {
      final response = await _apiClient.get('${ApiConstants.movies}/$movieId/related');
      if (response.data != null && response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback
    }
    return _defaultRelatedMovies;
  }

  // 3. Search Movies
  Future<List<MovieModel>> searchMovies({
    required String query,
    String? genre,
    String? studio,
    String? sortBy,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.search,
        queryParameters: {
          'q': query,
          if (genre != null && genre != 'All') 'genre': genre,
          if (studio != null && studio != 'All Studios') 'studio': studio,
          if (sortBy != null) 'sort_by': sortBy.toLowerCase(),
        },
      );
      if (response.data != null && response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback local search filtering
    }

    return _allSearchCatalog.where((movie) {
      final matchesQuery = query.isEmpty ||
          movie.title.toLowerCase().contains(query.toLowerCase()) ||
          (movie.subtitle?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
          movie.genres.toLowerCase().contains(query.toLowerCase());
      final matchesGenre = genre == null || genre == 'All' || movie.genres.toLowerCase().contains(genre.toLowerCase());
      final matchesStudio = studio == null || studio == 'All Studios' || (movie.studio?.toLowerCase().contains(studio.toLowerCase()) ?? false);
      return matchesQuery && matchesGenre && matchesStudio;
    }).toList();
  }

  // 4. Watchlist API
  Future<List<MovieModel>> getWatchlist() async {
    try {
      final response = await _apiClient.get(ApiConstants.watchlist);
      if (response.data != null && response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback
    }
    return _defaultWatchlistCatalog;
  }

  Future<void> addToWatchlist(String movieId) async {
    try {
      await _apiClient.post(ApiConstants.watchlist, data: {'movie_id': movieId});
    } catch (_) {}
  }

  Future<void> removeFromWatchlist(String movieId) async {
    try {
      await _apiClient.delete('${ApiConstants.watchlist}/$movieId');
    } catch (_) {}
  }

  // 5. Leaderboard API
  Future<List<MovieModel>> getLeaderboard({
    required String timeframe,
    required String category,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.leaderboard,
        queryParameters: {'timeframe': timeframe, 'category': category},
      );
      if (response.data != null && response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback
    }
    return _defaultLeaderboardCatalog;
  }

  // 6. User Authentication & Profile
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      if (response.data != null && response.data['data'] != null) {
        final data = response.data['data'] as Map<String, dynamic>;
        if (data['token'] != null) {
          _apiClient.setAuthToken(data['token'].toString());
        }
        return data;
      }
    } catch (_) {
      // Fallback
    }
    return {
      'token': 'mock_jwt_token_user_austin',
      'user': {
        'id': 'usr_austin_1',
        'email': email,
        'displayName': email.contains('@') ? email.split('@').first : 'Cinephile User',
        'isGuest': false,
      }
    };
  }

  Future<Map<String, dynamic>?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );
      if (response.data != null && response.data['data'] != null) {
        final data = response.data['data'] as Map<String, dynamic>;
        if (data['token'] != null) {
          _apiClient.setAuthToken(data['token'].toString());
        }
        return data;
      }
    } catch (_) {
      // Fallback
    }
    return {
      'token': 'mock_jwt_token_user_registered',
      'user': {
        'id': 'usr_${DateTime.now().millisecondsSinceEpoch}',
        'email': email,
        'displayName': name.isNotEmpty ? name : 'Cinephile',
        'isGuest': false,
      }
    };
  }

  Future<Map<String, dynamic>?> loginGuest() async {
    try {
      final response = await _apiClient.post(ApiConstants.guestLogin);
      if (response.data != null && response.data['data'] != null) {
        final data = response.data['data'] as Map<String, dynamic>;
        if (data['token'] != null) {
          _apiClient.setAuthToken(data['token'].toString());
        }
        return data;
      }
    } catch (_) {
      // Fallback
    }
    return {
      'token': 'mock_jwt_token_guest',
      'user': {
        'id': 'usr_guest',
        'email': '',
        'displayName': 'Guest Cinephile',
        'isGuest': true,
      }
    };
  }

  Future<UserProfileModel> getUserProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.userProfile);
      if (response.data != null && response.data['data'] is Map) {
        return UserProfileModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
    } catch (_) {}
    return const UserProfileModel(
      id: 'usr_austin_1',
      email: 'austin.rivera@cinecore.io',
      displayName: 'Austin Rivera',
      avatarUrl: '',
      isGuest: false,
    );
  }

  // Curated Fallback Data Assets
  static final List<MovieModel> _defaultSpotlightMovies = [
    const MovieModel(
      id: 'spot_1',
      title: 'SCREAM VII',
      subtitle: 'The Bloodline Returns to Woodsboro',
      imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=1200&auto=format&fit=crop',
      rating: 9.3,
      badge: '#1 IN THEATERS',
      releaseYear: '2025',
      genres: 'Horror, Mystery, Thriller',
      duration: '2h 14m',
      resolution: '4K Ultra HD',
      studio: 'Paramount',
      topMainTag: 'SCREAM VII',
      subDescription: 'A NEW KILLER RISES IN WOODSBORO WITH UNFINISHED BUSINESS.',
    ),
    const MovieModel(
      id: 'spot_2',
      title: 'DUNE: PART TWO',
      subtitle: 'Paul Atreides Unites with the Fremen',
      imageUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?q=80&w=1200&auto=format&fit=crop',
      rating: 9.4,
      badge: 'TOP SCI-FI EPIC',
      releaseYear: '2024',
      genres: 'Sci-Fi, Adventure',
      duration: '2h 46m',
      resolution: 'DOLBY VISION',
      studio: 'Warner Bros.',
      topMainTag: 'ARRAKIS RISING',
      subDescription: 'DESTINY AWAITS IN THE DESERT OF DREAMS',
    ),
    const MovieModel(
      id: 'spot_3',
      title: 'OPPENHEIMER',
      subtitle: 'The World Forever Changes',
      imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=1200&auto=format&fit=crop',
      rating: 9.3,
      badge: 'ACADEMY AWARD WINNER',
      releaseYear: '2023',
      genres: 'Biography, Drama, History',
      duration: '3h 00m',
      resolution: '4K IMAX',
      studio: 'Universal',
      topMainTag: 'THE DAY AFTER TOMORROW',
      subDescription: 'ATOMIC FEAR: SCIENTIFIC DISCOVERY THE ULTIMATE BURDEN',
    ),
  ];

  static final List<MovieModel> _defaultTopBlockbusters = [
    const MovieModel(
      id: 'top_1',
      title: 'OPPENHEIMER',
      topSmallTag: 'Cinematic Screening',
      topMainTag: 'THE DAY AFTER TOMORROW',
      subDescription: 'ATOMIC FEAR: SCIENTIFIC DISCOVERY THE ULTIMATE BURDEN',
      rankTag: '#1 IN ACTION 4K',
      imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=600&auto=format&fit=crop',
      rating: 9.3,
      duration: '3h 00m',
      genres: 'Biography, Drama, History',
      releaseYear: '2023',
      rank: 1,
      trend: '▲ +2',
      boxOfficeOrStreams: '\$957.8M • 4.8M Views',
      studio: 'Universal',
    ),
    const MovieModel(
      id: 'top_2',
      title: 'DEAD RECKONING',
      topSmallTag: 'A THRILLER BY GARETH EDWARDS',
      topMainTag: 'NIGHTFALL RUN',
      subDescription: 'THE CLOCK IS TICKING. THE TRUTH IS BURIED.',
      rankTag: 'IMAX ULTIMATE',
      imageUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?q=80&w=600&auto=format&fit=crop',
      rating: 9.0,
      duration: '2h 43m',
      genres: 'Action, Adventure, Thriller',
      releaseYear: '2024',
      rank: 2,
      trend: '★ #2',
      boxOfficeOrStreams: '\$892.4M • 4.2M Views',
      studio: 'Paramount',
    ),
    const MovieModel(
      id: 'top_3',
      title: 'DUNE: PART TWO',
      topSmallTag: 'DENIS VILLENEUVE MASTERPIECE',
      topMainTag: 'ARRAKIS RISING',
      subDescription: 'DESTINY AWAITS IN THE DESERT OF DREAMS',
      rankTag: '#1 SCI-FI EPIC',
      imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=600&auto=format&fit=crop',
      rating: 9.4,
      duration: '2h 46m',
      genres: 'Sci-Fi, Adventure',
      releaseYear: '2024',
      rank: 3,
      trend: '▲ +1',
      boxOfficeOrStreams: '\$711.8M • 5.1M Views',
      studio: 'Warner Bros.',
    ),
    const MovieModel(
      id: 'top_4',
      title: 'GLADIATOR II',
      topSmallTag: 'RIDLEY SCOTT VISION',
      topMainTag: 'COLOSSEUM OF HONOR',
      subDescription: 'WHAT WE DO IN LIFE ECHOES IN ETERNITY',
      rankTag: 'DOLBY VISION 4K',
      imageUrl: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?q=80&w=600&auto=format&fit=crop',
      rating: 9.1,
      duration: '2h 28m',
      genres: 'Action, Drama',
      releaseYear: '2024',
      rank: 4,
      trend: 'NEW',
      boxOfficeOrStreams: '\$462.1M • 3.7M Views',
      studio: 'Paramount',
    ),
    const MovieModel(
      id: 'top_5',
      title: 'CYBERPUNK 2099',
      topSmallTag: 'WARNER BROS SPECIAL',
      topMainTag: 'NEON MATRIX CITY',
      subDescription: 'REBELLION IN THE SHADOWS OF DYSTOPIA',
      rankTag: 'EXCLUSIVE 4K UHD',
      imageUrl: 'https://images.unsplash.com/photo-1514565131-fce0801e5785?q=80&w=600&auto=format&fit=crop',
      rating: 8.8,
      duration: '2h 15m',
      genres: 'Sci-Fi, Cyberpunk, Action',
      releaseYear: '2025',
      rank: 5,
      trend: '▲ +3',
      boxOfficeOrStreams: '3.4M Streams',
      studio: 'Max',
    ),
  ];

  static final List<MovieModel> _defaultPeacockPicks = [
    const MovieModel(
      id: 'pp_1',
      title: 'WICKED ELDRITCH',
      subtitle: 'The Untethered Witch of Oz',
      imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=600&auto=format&fit=crop',
      rating: 9.2,
      badge: 'TOP 10 TODAY',
      releaseYear: '2024',
      genres: 'Fantasy, Musical',
      duration: '2h 40m',
      resolution: '4K IMAX',
      studio: 'Universal',
    ),
    const MovieModel(
      id: 'pp_2',
      title: 'UNDEAD AVENGERS',
      subtitle: 'The Apocalypse Protocol',
      imageUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?q=80&w=600&auto=format&fit=crop',
      rating: 8.9,
      badge: 'EXCLUSIVE',
      releaseYear: '2025',
      genres: 'Action, Sci-Fi',
      duration: '2h 18m',
      resolution: 'DOLBY VISION',
      studio: 'Max',
    ),
    const MovieModel(
      id: 'pp_3',
      title: 'NEON CYBER CITY',
      subtitle: 'Blade Runners of Sector 4',
      imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=600&auto=format&fit=crop',
      rating: 9.0,
      badge: '4K ULTRA HD',
      releaseYear: '2024',
      genres: 'Cyberpunk, Thriller',
      duration: '2h 05m',
      resolution: '4K HDR',
      studio: 'Netflix',
    ),
  ];

  static final List<ContinueWatchingModel> _defaultContinueWatching = [
    const ContinueWatchingModel(
      id: 'cw_1',
      title: 'SCREAM VII',
      episodeInfo: 'S1 • E4 "Blood Legacy"',
      remainingTime: '23m left',
      qualityInfo: '4K UHD',
      audioInfo: 'Dolby Atmos',
      imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=600&auto=format&fit=crop',
      progress: 0.65,
    ),
    const ContinueWatchingModel(
      id: 'cw_2',
      title: 'DUNE: PART TWO',
      episodeInfo: 'Feature Film',
      remainingTime: '1h 12m left',
      qualityInfo: 'DOLBY VISION',
      audioInfo: 'Spatial Audio',
      imageUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?q=80&w=600&auto=format&fit=crop',
      progress: 0.42,
    ),
    const ContinueWatchingModel(
      id: 'cw_3',
      title: 'OPPENHEIMER',
      episodeInfo: 'Feature Film',
      remainingTime: '45m left',
      qualityInfo: '4K IMAX',
      audioInfo: 'Dolby 7.1',
      imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=600&auto=format&fit=crop',
      progress: 0.85,
    ),
  ];

  static final List<CastMemberModel> _defaultCastMembers = [
    const CastMemberModel(
      name: 'Melissa Barrera',
      character: 'Sam Carpenter',
      imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&auto=format&fit=crop',
    ),
    const CastMemberModel(
      name: 'Jenna Ortega',
      character: 'Tara Carpenter',
      imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=200&auto=format&fit=crop',
    ),
    const CastMemberModel(
      name: 'Courteney Cox',
      character: 'Gale Weathers',
      imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200&auto=format&fit=crop',
    ),
    const CastMemberModel(
      name: 'Hayden Panettiere',
      character: 'Kirby Reed',
      imageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?q=80&w=200&auto=format&fit=crop',
    ),
  ];

  static final List<MovieScreenshotModel> _defaultScreenshots = [
    const MovieScreenshotModel(
      title: 'WOODSBORO ALLEYWAY',
      imageUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?q=80&w=600&auto=format&fit=crop',
      tag: '4K HDR MASTER',
    ),
    const MovieScreenshotModel(
      title: 'GHOSTFACE REVELATION',
      imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=600&auto=format&fit=crop',
      tag: 'DOLBY CINEMA',
    ),
    const MovieScreenshotModel(
      title: 'SHADOW CLIMAX SCENE',
      imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=600&auto=format&fit=crop',
      tag: 'IMAX ENHANCED',
    ),
  ];

  static final List<MovieModel> _defaultRelatedMovies = [
    const MovieModel(
      id: 'rel_1',
      title: 'SCREAM VI',
      genres: 'Horror, Mystery',
      imageUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?q=80&w=400&auto=format&fit=crop',
      rating: 8.8,
      resolution: '4K UHD',
      releaseYear: '2023',
    ),
    const MovieModel(
      id: 'rel_2',
      title: 'HALLOWEEN ENDS',
      genres: 'Horror, Slasher',
      imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=400&auto=format&fit=crop',
      rating: 8.2,
      resolution: 'DOLBY VISION',
      releaseYear: '2022',
    ),
    const MovieModel(
      id: 'rel_3',
      title: 'A QUIET PLACE: DAY ONE',
      genres: 'Sci-Fi, Horror',
      imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=400&auto=format&fit=crop',
      rating: 9.1,
      resolution: '4K IMAX',
      releaseYear: '2024',
    ),
  ];

  static final List<MovieModel> _allSearchCatalog = [
    ..._defaultTopBlockbusters,
    ..._defaultSpotlightMovies,
    ..._defaultPeacockPicks,
    const MovieModel(
      id: 'm_interstellar',
      title: 'INTERSTELLAR',
      subtitle: 'Mankind was born on Earth. It was never meant to die here.',
      imageUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?q=80&w=600&auto=format&fit=crop',
      rating: 9.5,
      releaseYear: '2014',
      duration: '2h 49m',
      resolution: '4K IMAX',
      genres: 'Sci-Fi, Adventure, Drama',
      studio: 'Paramount',
    ),
    const MovieModel(
      id: 'm_batman',
      title: 'THE BATMAN II',
      subtitle: 'Unmask the Truth in Gotham City',
      imageUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?q=80&w=600&auto=format&fit=crop',
      rating: 9.2,
      releaseYear: '2025',
      duration: '2h 55m',
      resolution: 'DOLBY VISION',
      genres: 'Action, Crime, Mystery',
      studio: 'Warner Bros.',
    ),
  ];

  static final List<MovieModel> _defaultWatchlistCatalog = [
    const MovieModel(
      id: 'w1',
      title: 'OPPENHEIMER',
      subtitle: 'The Story of J. Robert Oppenheimer',
      imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=600&auto=format&fit=crop',
      rating: 9.3,
      releaseYear: '2023',
      duration: '3h 00m',
      resolution: '4K IMAX',
      genres: 'Biography, Drama',
      studio: 'Universal',
      watchProgress: 0.65,
      remainingTime: '1h 03m left',
      isDownloaded: true,
    ),
    const MovieModel(
      id: 'w2',
      title: 'DUNE: PART TWO',
      subtitle: 'Paul Atreides Unites with Chani & the Fremen',
      imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=600&auto=format&fit=crop',
      rating: 9.4,
      releaseYear: '2024',
      duration: '2h 46m',
      resolution: 'DOLBY VISION',
      genres: 'Sci-Fi, Adventure',
      studio: 'Warner Bros.',
      watchProgress: 0.3,
      remainingTime: '1h 56m left',
      isDownloaded: true,
    ),
    const MovieModel(
      id: 'w3',
      title: 'DEAD RECKONING',
      subtitle: 'Ethan Hunt and His IMF Team Embark on Dangerous Mission',
      imageUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?q=80&w=600&auto=format&fit=crop',
      rating: 9.0,
      releaseYear: '2024',
      duration: '2h 43m',
      resolution: 'IMAX',
      genres: 'Action, Thriller',
      studio: 'Paramount',
      watchProgress: 0.8,
      remainingTime: '32m left',
      isDownloaded: false,
    ),
  ];

  static final List<MovieModel> _defaultLeaderboardCatalog = [
    ..._defaultTopBlockbusters,
  ];
}
