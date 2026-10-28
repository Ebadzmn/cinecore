import 'dart:async';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../data/models/cast_member_model.dart';
import '../data/models/episode_model.dart';
import '../data/models/movie_model.dart';
import '../data/models/video_quality_option.dart';
import '../data/models/watch_history_model.dart';
import '../data/services/hls_playlist_service.dart';
import '../data/services/movie_api_service.dart';
import '../data/services/playback_service.dart';
import 'playback_progress_controller.dart';

class SeriesDetailsController extends GetxController {
  final String seriesId;
  final MovieModel? initialSeries;
  final MovieApiService _apiService = MovieApiService();
  final PlaybackService _playbackService = PlaybackService();

  SeriesDetailsController({
    required this.seriesId,
    this.initialSeries,
  }) {
    if (initialSeries != null) {
      _applySeriesData(initialSeries!);
    }
  }

  final Rx<MovieModel?> series = Rx<MovieModel?>(null);
  final Rx<WatchHistoryModel?> savedProgress = Rx<WatchHistoryModel?>(null);
  Timer? _heartbeatTimer;
  final RxBool isSynopsisExpanded = false.obs;
  final RxBool isLoading = true.obs;

  // Seasons & Episodes
  final RxInt selectedSeasonNumber = 1.obs;
  final RxList<int> availableSeasons = <int>[1].obs;
  final RxList<EpisodeModel> allEpisodes = <EpisodeModel>[].obs;
  final Rx<EpisodeModel?> currentPlayingEpisode = Rx<EpisodeModel?>(null);

  final RxList<CastMemberModel> castMembers = <CastMemberModel>[].obs;
  final RxList<MovieScreenshotModel> screenshots = <MovieScreenshotModel>[].obs;
  final RxList<MovieModel> moreLikeThisMovies = <MovieModel>[].obs;

  // Inline Video Player State
  VideoPlayerController? videoPlayerController;
  final RxBool isVideoActive = false.obs;
  final RxBool isVideoInitialized = false.obs;
  final RxBool isVideoPlaying = false.obs;
  final RxBool isVideoBuffering = false.obs;
  final RxBool showVideoControls = true.obs;
  final RxDouble currentVideoSeconds = 0.0.obs;
  final RxDouble totalVideoSeconds = 100.0.obs;
  final RxDouble videoSpeed = 1.0.obs;
  final RxBool isMuted = false.obs;
  final RxBool videoHasError = false.obs;
  final RxBool isQualityChanging = false.obs;
  final RxBool isQualitiesLoading = false.obs;

  // Dynamic M3U Quality options for current playing episode
  final RxList<VideoQualityOption> availableQualities = <VideoQualityOption>[].obs;
  final Rx<VideoQualityOption?> currentQualityOption = Rx<VideoQualityOption?>(null);
  final RxString selectedQuality = 'Auto'.obs;

  Timer? _controlsTimer;

  List<EpisodeModel> get currentSeasonEpisodes {
    return allEpisodes
        .where((ep) => ep.seasonNumber == selectedSeasonNumber.value)
        .toList()
      ..sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));
  }

  @override
  void onInit() {
    super.onInit();
    if (initialSeries != null) {
      _applySeriesData(initialSeries!);
    }
    loadSeriesDetails();
    loadSavedProgress();
  }

  Future<void> loadSavedProgress() async {
    try {
      final progress = await _playbackService.getProgress(seriesId);
      if (progress != null) {
        savedProgress.value = progress;
        PlaybackProgressController.to.updateProgress(
          movieId: seriesId,
          movieTitle: series.value?.title,
          movieType: 'SERIES',
          positionSeconds: progress.positionSeconds,
          durationSeconds: progress.durationSeconds,
          seasonNumber: progress.seasonNumber,
          episodeNumber: progress.episodeNumber,
          episodeTitle: progress.episodeTitle,
          status: progress.status,
        );
      }
    } catch (_) {}
  }

  void _syncEpisodeProgress({String action = 'HEARTBEAT'}) {
    final ep = currentPlayingEpisode.value;
    if (ep == null || totalVideoSeconds.value <= 0) return;

    PlaybackProgressController.to.updateProgress(
      movieId: seriesId,
      movieTitle: series.value?.title,
      movieType: 'SERIES',
      positionSeconds: currentVideoSeconds.value,
      durationSeconds: totalVideoSeconds.value,
      seasonNumber: ep.seasonNumber,
      episodeNumber: ep.episodeNumber,
      episodeTitle: ep.title,
      status: action == 'COMPLETED' ? 'COMPLETED' : 'IN_PROGRESS',
    );

    _playbackService.recordProgress(
      movieId: seriesId,
      seasonNumber: ep.seasonNumber,
      episodeNumber: ep.episodeNumber,
      episodeId: ep.id,
      episodeTitle: ep.title,
      positionSeconds: currentVideoSeconds.value,
      durationSeconds: totalVideoSeconds.value,
      action: action,
    );
  }

  void _startEpisodeHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (isVideoPlaying.value && currentVideoSeconds.value > 0) {
        _syncEpisodeProgress(action: 'HEARTBEAT');
      }
    });
  }

  void _applySeriesData(MovieModel data) {
    series.value = data;

    if (data.cast != null && data.cast!.isNotEmpty) {
      castMembers.assignAll(data.cast!);
    }
    if (data.screenshots != null && data.screenshots!.isNotEmpty) {
      screenshots.assignAll(data.screenshots!);
    }
    if (data.moreLikeThis != null && data.moreLikeThis!.isNotEmpty) {
      moreLikeThisMovies.assignAll(data.moreLikeThis!);
    }

    if (data.episodes != null && data.episodes!.isNotEmpty) {
      allEpisodes.assignAll(data.episodes!);
    }

    // Discover dynamic season numbers
    _computeAvailableSeasons(data.totalSeasons);

    // Default select first available episode for playback readiness
    if (currentPlayingEpisode.value == null && allEpisodes.isNotEmpty) {
      final firstEp = allEpisodes.firstWhere(
        (e) => e.seasonNumber == selectedSeasonNumber.value,
        orElse: () => allEpisodes.first,
      );
      currentPlayingEpisode.value = firstEp;
    }
  }

  void _computeAvailableSeasons(int totalSeasons) {
    final Set<int> seasonsSet = {};
    if (totalSeasons > 0) {
      for (int i = 1; i <= totalSeasons; i++) {
        seasonsSet.add(i);
      }
    }
    for (final ep in allEpisodes) {
      if (ep.seasonNumber > 0) {
        seasonsSet.add(ep.seasonNumber);
      }
    }
    if (seasonsSet.isEmpty) {
      seasonsSet.add(1);
    }

    final sorted = seasonsSet.toList()..sort();
    availableSeasons.assignAll(sorted);

    if (!seasonsSet.contains(selectedSeasonNumber.value)) {
      selectedSeasonNumber.value = sorted.first;
    }
  }

  void selectSeason(int seasonNumber) {
    if (selectedSeasonNumber.value == seasonNumber) return;
    selectedSeasonNumber.value = seasonNumber;

    // Stage the first episode of the newly selected season (if video is not actively playing)
    if (!isVideoActive.value) {
      final matching = allEpisodes
          .where((e) => e.seasonNumber == seasonNumber)
          .toList()
        ..sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));
      if (matching.isNotEmpty) {
        currentPlayingEpisode.value = matching.first;
      }
    }
  }

  void toggleSynopsis() {
    isSynopsisExpanded.value = !isSynopsisExpanded.value;
  }

  Future<void> loadSeriesDetails() async {
    try {
      isLoading.value = true;
      final fetched = await _apiService.getMovieDetails(seriesId);

      if (fetched != null) {
        _applySeriesData(fetched);
      } else if (series.value == null) {
        final allSeries = await _apiService.getSeriesList(limit: 50);
        for (final s in allSeries) {
          final cleanId = seriesId.toLowerCase().replaceAll('_', ' ').replaceAll('-', ' ');
          final sTitle = s.title.toLowerCase();
          if (s.id == seriesId || sTitle == cleanId || sTitle.contains(cleanId)) {
            _applySeriesData(s);
            break;
          }
        }
      }

      if (castMembers.isEmpty) {
        final cast = await _apiService.getCastMembers(seriesId);
        if (cast.isNotEmpty) castMembers.assignAll(cast);
      }

      if (screenshots.isEmpty) {
        final shots = await _apiService.getScreenshots(seriesId);
        if (shots.isNotEmpty) screenshots.assignAll(shots);
      }

      if (moreLikeThisMovies.isEmpty) {
        final current = series.value ?? initialSeries;
        final related = await _apiService.getRelatedMovies(
          seriesId,
          genre: current?.genres,
          category: current?.category,
        );
        if (related.isNotEmpty) moreLikeThisMovies.assignAll(related);
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  // --- Dynamic M3U Quality Detection & Episode Playback ---

  Future<void> fetchEpisodeQualities(String masterUrl) async {
    final clean = masterUrl.trim();
    if (clean.isEmpty) return;
    try {
      isQualitiesLoading.value = true;
      final parsed = await HlsPlaylistService.parseQualities(clean);
      if (parsed.isNotEmpty) {
        availableQualities.assignAll(parsed);
        if (currentQualityOption.value == null) {
          currentQualityOption.value = parsed.first;
          selectedQuality.value = parsed.first.id;
        }
      }
    } catch (_) {
    } finally {
      isQualitiesLoading.value = false;
    }
  }

  Future<void> playEpisode(EpisodeModel episode, {VideoQualityOption? targetQuality}) async {
    currentPlayingEpisode.value = episode;
    selectedSeasonNumber.value = episode.seasonNumber;

    final activeUrl = episode.watchUrl ?? episode.playbackUrl ?? episode.sourceUrl ?? '';

    isVideoActive.value = true;
    showVideoControls.value = true;
    videoHasError.value = false;

    if (activeUrl.isNotEmpty) {
      await fetchEpisodeQualities(activeUrl);

      final chosenOption = targetQuality ??
          (availableQualities.isNotEmpty ? availableQualities.first : null);

      final streamToLoad = chosenOption?.url ?? activeUrl;

      try {
        if (videoPlayerController != null) {
          videoPlayerController!.removeListener(_videoListener);
          await videoPlayerController!.dispose();
          videoPlayerController = null;
        }

        final uri = Uri.parse(streamToLoad);
        videoPlayerController = VideoPlayerController.networkUrl(uri);
        await videoPlayerController!.initialize();

        isVideoInitialized.value = true;
        final dur = videoPlayerController!.value.duration.inSeconds.toDouble();
        totalVideoSeconds.value = dur > 0
            ? dur
            : (episode.duration != null && episode.duration! > 0
                ? episode.duration!
                : 100.0);

        videoPlayerController!.addListener(_videoListener);
        final resumePos = (savedProgress.value != null &&
                savedProgress.value!.seasonNumber == episode.seasonNumber &&
                savedProgress.value!.episodeNumber == episode.episodeNumber &&
                savedProgress.value!.positionSeconds > 0)
            ? savedProgress.value!.positionSeconds
            : 0.0;
        if (resumePos > 0) {
          await videoPlayerController!.seekTo(Duration(seconds: resumePos.toInt()));
          currentVideoSeconds.value = resumePos;
        } else {
          currentVideoSeconds.value = 0.0;
        }

        if (isMuted.value) {
          await videoPlayerController!.setVolume(0.0);
        }
        if (videoSpeed.value != 1.0) {
          await videoPlayerController!.setPlaybackSpeed(videoSpeed.value);
        }

        await videoPlayerController!.play();
        isVideoPlaying.value = true;
        _startEpisodeHeartbeat();
        _syncEpisodeProgress(action: 'START');

        if (chosenOption != null) {
          currentQualityOption.value = chosenOption;
          selectedQuality.value = chosenOption.id;
        }

        _startControlsTimer();
      } catch (_) {
        if (chosenOption != null && !chosenOption.isAuto && availableQualities.isNotEmpty) {
          final autoOpt = availableQualities.firstWhere(
            (o) => o.isAuto,
            orElse: () => availableQualities.first,
          );
          await playEpisode(episode, targetQuality: autoOpt);
          return;
        }
        videoHasError.value = true;
        isVideoInitialized.value = false;
      }
    } else {
      videoHasError.value = true;
    }
  }

  Future<void> changeQuality(VideoQualityOption option) async {
    if (currentQualityOption.value?.id == option.id && isVideoInitialized.value) return;

    final targetUrl = option.url;
    if (targetUrl.isEmpty) return;

    try {
      isQualityChanging.value = true;
      final currentPos = currentVideoSeconds.value;
      final wasPlaying = isVideoPlaying.value;

      if (videoPlayerController != null) {
        videoPlayerController!.removeListener(_videoListener);
        await videoPlayerController!.pause();
        await videoPlayerController!.dispose();
        videoPlayerController = null;
      }

      final uri = Uri.parse(targetUrl);
      final newController = VideoPlayerController.networkUrl(uri);
      await newController.initialize();

      videoPlayerController = newController;
      isVideoInitialized.value = true;
      videoHasError.value = false;
      currentQualityOption.value = option;
      selectedQuality.value = option.id;

      final dur = newController.value.duration.inSeconds.toDouble();
      if (dur > 0) totalVideoSeconds.value = dur;

      newController.addListener(_videoListener);
      if (currentPos > 0) {
        await newController.seekTo(Duration(seconds: currentPos.toInt()));
      }
      if (isMuted.value) {
        await newController.setVolume(0.0);
      }
      if (videoSpeed.value != 1.0) {
        await newController.setPlaybackSpeed(videoSpeed.value);
      }

      if (wasPlaying) {
        await newController.play();
        isVideoPlaying.value = true;
        _startControlsTimer();
      }
    } catch (_) {
      if (!option.isAuto && availableQualities.isNotEmpty) {
        final autoOpt = availableQualities.firstWhere(
          (o) => o.isAuto,
          orElse: () => availableQualities.first,
        );
        await changeQuality(autoOpt);
      } else {
        videoHasError.value = true;
      }
    } finally {
      isQualityChanging.value = false;
    }
  }

  void playNextEpisode() {
    if (currentPlayingEpisode.value == null || allEpisodes.isEmpty) return;
    final current = currentPlayingEpisode.value!;
    final nextInSeason = allEpisodes.firstWhereOrNull(
      (e) =>
          e.seasonNumber == current.seasonNumber &&
          e.episodeNumber == current.episodeNumber + 1,
    );
    if (nextInSeason != null) {
      playEpisode(nextInSeason);
      return;
    }

    // Try first episode of next season
    final nextSeasonFirst = allEpisodes.firstWhereOrNull(
      (e) => e.seasonNumber == current.seasonNumber + 1 && e.episodeNumber == 1,
    );
    if (nextSeasonFirst != null) {
      playEpisode(nextSeasonFirst);
    }
  }

  void playPreviousEpisode() {
    if (currentPlayingEpisode.value == null || allEpisodes.isEmpty) return;
    final current = currentPlayingEpisode.value!;
    if (current.episodeNumber > 1) {
      final prevInSeason = allEpisodes.firstWhereOrNull(
        (e) =>
            e.seasonNumber == current.seasonNumber &&
            e.episodeNumber == current.episodeNumber - 1,
      );
      if (prevInSeason != null) {
        playEpisode(prevInSeason);
        return;
      }
    }

    // Try last episode of previous season
    if (current.seasonNumber > 1) {
      final prevSeasonEps = allEpisodes
          .where((e) => e.seasonNumber == current.seasonNumber - 1)
          .toList()
        ..sort((a, b) => b.episodeNumber.compareTo(a.episodeNumber));
      if (prevSeasonEps.isNotEmpty) {
        playEpisode(prevSeasonEps.first);
      }
    }
  }

  void _videoListener() {
    if (videoPlayerController == null || !videoPlayerController!.value.isInitialized) return;

    final val = videoPlayerController!.value;
    isVideoPlaying.value = val.isPlaying;
    isVideoBuffering.value = val.isBuffering;

    if (val.duration.inSeconds > 0) {
      totalVideoSeconds.value = val.duration.inSeconds.toDouble();
    }
    currentVideoSeconds.value = val.position.inSeconds.toDouble();
  }

  void togglePlayPause() {
    if (videoPlayerController != null && videoPlayerController!.value.isInitialized) {
      if (videoPlayerController!.value.isPlaying) {
        videoPlayerController!.pause();
        isVideoPlaying.value = false;
        _controlsTimer?.cancel();
      } else {
        videoPlayerController!.play();
        isVideoPlaying.value = true;
        _startControlsTimer();
      }
    } else if (currentPlayingEpisode.value != null) {
      playEpisode(currentPlayingEpisode.value!);
    } else if (currentSeasonEpisodes.isNotEmpty) {
      playEpisode(currentSeasonEpisodes.first);
    }
  }

  void toggleControls() {
    showVideoControls.value = !showVideoControls.value;
    if (showVideoControls.value && isVideoPlaying.value) {
      _startControlsTimer();
    }
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      if (isVideoPlaying.value) {
        showVideoControls.value = false;
      }
    });
  }

  void seekBy(double seconds) {
    final newSec = (currentVideoSeconds.value + seconds).clamp(0.0, totalVideoSeconds.value);
    seekTo(newSec);
  }

  void seekTo(double seconds) {
    currentVideoSeconds.value = seconds.clamp(0.0, totalVideoSeconds.value);
    if (videoPlayerController != null && videoPlayerController!.value.isInitialized) {
      videoPlayerController!.seekTo(Duration(seconds: seconds.toInt()));
    }
    _startControlsTimer();
  }

  void toggleMute() {
    if (videoPlayerController != null && videoPlayerController!.value.isInitialized) {
      isMuted.value = !isMuted.value;
      videoPlayerController!.setVolume(isMuted.value ? 0.0 : 1.0);
    }
  }

  void cycleSpeed() {
    if (videoSpeed.value == 1.0) {
      videoSpeed.value = 1.25;
    } else if (videoSpeed.value == 1.25) {
      videoSpeed.value = 1.5;
    } else if (videoSpeed.value == 1.5) {
      videoSpeed.value = 2.0;
    } else {
      videoSpeed.value = 1.0;
    }

    if (videoPlayerController != null && videoPlayerController!.value.isInitialized) {
      videoPlayerController!.setPlaybackSpeed(videoSpeed.value);
    }
  }

  void stopPlayback() {
    if (videoPlayerController != null) {
      videoPlayerController!.pause();
    }
    isVideoActive.value = false;
    _controlsTimer?.cancel();
  }

  String formatTime(double totalSec) {
    final int hours = totalSec ~/ 3600;
    final int minutes = (totalSec % 3600) ~/ 60;
    final int seconds = (totalSec % 60).toInt();

    final String mStr = minutes.toString().padLeft(2, '0');
    final String sStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      final String hStr = hours.toString().padLeft(2, '0');
      return '$hStr:$mStr:$sStr';
    }
    return '$mStr:$sStr';
  }

  @override
  void onClose() {
    _controlsTimer?.cancel();
    _heartbeatTimer?.cancel();
    if (isVideoPlaying.value || currentVideoSeconds.value > 0) {
      _syncEpisodeProgress(action: 'EXIT');
    }
    if (videoPlayerController != null) {
      videoPlayerController!.removeListener(_videoListener);
      videoPlayerController!.dispose();
      videoPlayerController = null;
    }
    super.onClose();
  }
}
