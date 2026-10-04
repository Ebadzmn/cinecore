class ApiConstants {
  static const String baseUrl = 'https://api.cinecore.io/api/v1';
  static const int connectTimeout = 10000; // 10 seconds
  static const int receiveTimeout = 10000; // 10 seconds

  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh-token';
  static const String userProfile = '/users/me';
  
  static const String homeFeed = '/feed/home';
  static const String spotlight = '/feed/spotlight';
  static const String categories = '/feed/categories';
  static const String studios = '/studios';
  
  static const String movies = '/movies';
  static const String search = '/search';
  static const String trendingKeywords = '/search/trending-keywords';
  static const String watchlist = '/watchlist';
  static const String continueWatching = '/playback/continue-watching';
  static const String playbackHeartbeat = '/playback/heartbeat';
  static const String leaderboard = '/leaderboard';
}
