import 'dart:async';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../data/models/cast_member_model.dart';
import '../data/models/movie_model.dart';
import '../data/models/video_quality_option.dart';
import '../data/services/hls_playlist_service.dart';
import '../data/services/movie_api_service.dart';

class MovieDetailsController extends GetxController {
  final String movieId;
  final MovieModel? initialMovie;
  final MovieApiService _apiService = MovieApiService();

  MovieDetailsController({
    required this.movieId,
    this.initialMovie,
  });

  final Rx<MovieModel?> movie = Rx<MovieModel?>(null);
  final RxString watchUrl = ''.obs;
  String _baseMasterUrl = '';
  final RxBool isSynopsisExpanded = false.obs;
  final RxBool isLoading = true.obs;

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

  // Dynamic Qualities parsed directly from M3U / HLS Playlist
  final RxList<VideoQualityOption> availableQualities = <VideoQualityOption>[].obs;
  final Rx<VideoQualityOption?> currentQualityOption = Rx<VideoQualityOption?>(null);
  final RxString selectedQuality = 'Auto'.obs;

  Timer? _controlsTimer;

  @override
  void onInit() {
    super.onInit();
    if (initialMovie != null) {
      movie.value = initialMovie;
      if (initialMovie!.watchUrl != null && initialMovie!.watchUrl!.isNotEmpty) {
        watchUrl.value = initialMovie!.watchUrl!;
        _baseMasterUrl = initialMovie!.watchUrl!;
        fetchAvailableQualities(_baseMasterUrl);
      }
      if (initialMovie!.cast != null && initialMovie!.cast!.isNotEmpty) {
        castMembers.assignAll(initialMovie!.cast!);
      }
      if (initialMovie!.screenshots != null && initialMovie!.screenshots!.isNotEmpty) {
        screenshots.assignAll(initialMovie!.screenshots!);
      }
      if (initialMovie!.moreLikeThis != null && initialMovie!.moreLikeThis!.isNotEmpty) {
        moreLikeThisMovies.assignAll(initialMovie!.moreLikeThis!);
      }
    }
    loadMovieDetails();
  }

  void toggleSynopsis() {
    isSynopsisExpanded.value = !isSynopsisExpanded.value;
  }

  Future<void> fetchAvailableQualities(String masterUrl) async {
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

  Future<void> loadMovieDetails() async {
    try {
      isLoading.value = true;
      final fetched = await _apiService.getMovieDetails(movieId);

      if (fetched != null) {
        movie.value = fetched;
        if (fetched.watchUrl != null && fetched.watchUrl!.isNotEmpty) {
          watchUrl.value = fetched.watchUrl!;
          _baseMasterUrl = fetched.watchUrl!;
          fetchAvailableQualities(_baseMasterUrl);
        }
        if (fetched.cast != null && fetched.cast!.isNotEmpty) {
          castMembers.assignAll(fetched.cast!);
        }
        if (fetched.screenshots != null && fetched.screenshots!.isNotEmpty) {
          screenshots.assignAll(fetched.screenshots!);
        }
        if (fetched.moreLikeThis != null && fetched.moreLikeThis!.isNotEmpty) {
          moreLikeThisMovies.assignAll(fetched.moreLikeThis!);
        }
      }

      if (castMembers.isEmpty) {
        final cast = await _apiService.getCastMembers(movieId);
        if (cast.isNotEmpty) {
          castMembers.assignAll(cast);
        }
      }

      if (screenshots.isEmpty) {
        final shots = await _apiService.getScreenshots(movieId);
        if (shots.isNotEmpty) {
          screenshots.assignAll(shots);
        }
      }

      if (moreLikeThisMovies.isEmpty) {
        final currentMovie = movie.value ?? initialMovie;
        final related = await _apiService.getRelatedMovies(
          movieId,
          genre: currentMovie?.genres,
          category: currentMovie?.category,
        );
        if (related.isNotEmpty) {
          moreLikeThisMovies.assignAll(related);
        }
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  // --- Inline Video Player Controls & Dynamic Quality Switching ---

  Future<void> startInlinePlayback({VideoQualityOption? targetQuality}) async {
    final activeUrl = watchUrl.value.isNotEmpty
        ? watchUrl.value
        : (movie.value?.watchUrl ?? initialMovie?.watchUrl ?? '');

    isVideoActive.value = true;
    showVideoControls.value = true;
    videoHasError.value = false;

    if (activeUrl.isNotEmpty) {
      if (availableQualities.isEmpty) {
        await fetchAvailableQualities(activeUrl);
      }

      final chosenOption = targetQuality ??
          currentQualityOption.value ??
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
        totalVideoSeconds.value = dur > 0 ? dur : 100.0;

        videoPlayerController!.addListener(_videoListener);
        if (currentVideoSeconds.value > 0) {
          await videoPlayerController!.seekTo(Duration(seconds: currentVideoSeconds.value.toInt()));
        }
        if (isMuted.value) {
          await videoPlayerController!.setVolume(0.0);
        }
        if (videoSpeed.value != 1.0) {
          await videoPlayerController!.setPlaybackSpeed(videoSpeed.value);
        }

        await videoPlayerController!.play();
        isVideoPlaying.value = true;
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
          await startInlinePlayback(targetQuality: autoOpt);
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
    } else {
      startInlinePlayback();
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

  void stopInlinePlayback() {
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
    if (videoPlayerController != null) {
      videoPlayerController!.removeListener(_videoListener);
      videoPlayerController!.dispose();
      videoPlayerController = null;
    }
    super.onClose();
  }
}
