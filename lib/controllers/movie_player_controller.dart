import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../data/models/video_quality_option.dart';
import '../data/services/hls_playlist_service.dart';
import '../data/services/playback_service.dart';
import 'playback_progress_controller.dart';

class MoviePlayerController extends GetxController {
  final String? streamUrl;
  final String? movieId;
  final String movieType; // 'MOVIE' | 'SERIES'
  final int? seasonNumber;
  final int? episodeNumber;
  final String? episodeTitle;
  final double initialPositionSeconds;

  MoviePlayerController({
    this.streamUrl,
    this.movieId,
    this.movieType = 'MOVIE',
    this.seasonNumber,
    this.episodeNumber,
    this.episodeTitle,
    this.initialPositionSeconds = 0.0,
  });

  final PlaybackService _playbackService = PlaybackService();

  VideoPlayerController? videoPlayerController;
  final RxBool isInitialized = false.obs;
  final RxBool isPlaying = false.obs;
  final RxBool isBuffering = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool showControls = true.obs;

  final RxDouble currentSeconds = 0.0.obs;
  final RxDouble totalSeconds = 7200.0.obs;
  final RxDouble playbackSpeed = 1.0.obs;

  final RxBool isQualityChanging = false.obs;
  final RxBool isQualitiesLoading = false.obs;
  final RxList<VideoQualityOption> availableQualities = <VideoQualityOption>[].obs;
  final Rx<VideoQualityOption?> currentQualityOption = Rx<VideoQualityOption?>(null);
  final RxString selectedQuality = 'Auto'.obs;
  final RxString selectedAudio = 'English (Dolby Atmos)'.obs;
  final RxString selectedSubtitle = 'English [CC]'.obs;

  Timer? _controlsTimer;
  Timer? _fallbackTicker;
  Timer? _heartbeatTimer;
  bool _hasCompleted = false;

  @override
  void onInit() {
    super.onInit();
    if (initialPositionSeconds > 0) {
      currentSeconds.value = initialPositionSeconds;
    }
    _initializePlayer();
    startControlsTimer();
    _startHeartbeat();
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (isPlaying.value && currentSeconds.value > 0) {
        _syncProgress(action: 'HEARTBEAT');
      }
    });
  }

  Future<void> _syncProgress({String action = 'HEARTBEAT'}) async {
    final effectiveMovieId = movieId;
    if (effectiveMovieId == null || effectiveMovieId.isEmpty) return;

    final pos = currentSeconds.value;
    final dur = totalSeconds.value > 0
        ? totalSeconds.value
        : (movieType == 'SERIES' ? 2700.0 : 7200.0);

    // Real-time local reactive store update for all cards across app
    PlaybackProgressController.to.updateProgress(
      movieId: effectiveMovieId,
      movieType: movieType,
      positionSeconds: pos,
      durationSeconds: dur,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      episodeTitle: episodeTitle,
      status: action == 'COMPLETED' ? 'COMPLETED' : 'IN_PROGRESS',
    );

    try {
      await _playbackService.recordProgress(
        movieId: effectiveMovieId,
        positionSeconds: pos,
        durationSeconds: dur,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
        episodeTitle: episodeTitle,
        action: action,
      );
    } catch (e) {
      debugPrint('⚠️ [MoviePlayerController] Progress sync error: $e');
    }
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

  Future<void> _initializePlayer({VideoQualityOption? targetQuality}) async {
    final activeUrl = streamUrl ?? '';

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

        isInitialized.value = true;
        hasError.value = false;
        final dur = videoPlayerController!.value.duration.inSeconds.toDouble();
        totalSeconds.value = dur > 0 ? dur : (movieType == 'SERIES' ? 2700.0 : 7200.0);

        videoPlayerController!.addListener(_videoListener);

        // Resume playback from initial position if available
        final seekPos = initialPositionSeconds > 0
            ? initialPositionSeconds
            : currentSeconds.value;

        if (seekPos > 0) {
          await videoPlayerController!.seekTo(Duration(seconds: seekPos.toInt()));
          currentSeconds.value = seekPos;
        }
        if (playbackSpeed.value != 1.0) {
          await videoPlayerController!.setPlaybackSpeed(playbackSpeed.value);
        }

        await videoPlayerController!.play();
        isPlaying.value = true;
        _syncProgress(action: 'START');

        if (chosenOption != null) {
          currentQualityOption.value = chosenOption;
          selectedQuality.value = chosenOption.id;
        }
      } catch (e) {
        if (chosenOption != null && !chosenOption.isAuto && availableQualities.isNotEmpty) {
          final autoOpt = availableQualities.firstWhere(
            (o) => o.isAuto,
            orElse: () => availableQualities.first,
          );
          await _initializePlayer(targetQuality: autoOpt);
          return;
        }
        hasError.value = true;
        errorMessage.value = e.toString();
        _startFallbackSimulation();
      }
    } else {
      _startFallbackSimulation();
    }
  }

  Future<void> changeQuality(VideoQualityOption option) async {
    if (currentQualityOption.value?.id == option.id && isInitialized.value) return;

    final targetUrl = option.url;
    if (targetUrl.isEmpty) return;

    try {
      isQualityChanging.value = true;
      final currentPos = currentSeconds.value;
      final wasPlaying = isPlaying.value;

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
      isInitialized.value = true;
      hasError.value = false;
      currentQualityOption.value = option;
      selectedQuality.value = option.id;

      final dur = newController.value.duration.inSeconds.toDouble();
      if (dur > 0) totalSeconds.value = dur;

      newController.addListener(_videoListener);
      if (currentPos > 0) {
        await newController.seekTo(Duration(seconds: currentPos.toInt()));
      }
      if (playbackSpeed.value != 1.0) {
        await newController.setPlaybackSpeed(playbackSpeed.value);
      }

      if (wasPlaying) {
        await newController.play();
        isPlaying.value = true;
        startControlsTimer();
      }
    } catch (_) {
      if (!option.isAuto && availableQualities.isNotEmpty) {
        final autoOpt = availableQualities.firstWhere(
          (o) => o.isAuto,
          orElse: () => availableQualities.first,
        );
        await changeQuality(autoOpt);
      } else {
        hasError.value = true;
      }
    } finally {
      isQualityChanging.value = false;
    }
  }

  void _videoListener() {
    if (videoPlayerController == null || !videoPlayerController!.value.isInitialized) return;

    final val = videoPlayerController!.value;
    isPlaying.value = val.isPlaying;
    isBuffering.value = val.isBuffering;

    if (val.duration.inSeconds > 0) {
      totalSeconds.value = val.duration.inSeconds.toDouble();
    }
    currentSeconds.value = val.position.inSeconds.toDouble();

    // Check completion (90% threshold or within 5s of end)
    if (!_hasCompleted && totalSeconds.value > 10) {
      final pos = currentSeconds.value;
      final dur = totalSeconds.value;
      if (pos >= dur - 5 || (pos / dur) >= 0.90) {
        _hasCompleted = true;
        _syncProgress(action: 'COMPLETED');
      }
    }
  }

  void _startFallbackSimulation() {
    isPlaying.value = true;
    _fallbackTicker?.cancel();
    _fallbackTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isPlaying.value) {
        if (currentSeconds.value < totalSeconds.value) {
          currentSeconds.value += playbackSpeed.value;
        } else {
          isPlaying.value = false;
          if (!_hasCompleted) {
            _hasCompleted = true;
            _syncProgress(action: 'COMPLETED');
          }
        }
      }
    });
  }

  void startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      if (isPlaying.value) {
        showControls.value = false;
      }
    });
  }

  void toggleControls() {
    showControls.value = !showControls.value;
    if (showControls.value && isPlaying.value) {
      startControlsTimer();
    }
  }

  void togglePlayPause() {
    if (videoPlayerController != null && videoPlayerController!.value.isInitialized) {
      if (videoPlayerController!.value.isPlaying) {
        videoPlayerController!.pause();
        isPlaying.value = false;
        _controlsTimer?.cancel();
        _syncProgress(action: 'PAUSE');
      } else {
        videoPlayerController!.play();
        isPlaying.value = true;
        startControlsTimer();
        _syncProgress(action: 'START');
      }
    } else {
      isPlaying.value = !isPlaying.value;
      if (isPlaying.value) {
        startControlsTimer();
        _syncProgress(action: 'START');
      } else {
        _controlsTimer?.cancel();
        _syncProgress(action: 'PAUSE');
      }
    }
  }

  void seekBy(double seconds) {
    final newSec = (currentSeconds.value + seconds).clamp(0.0, totalSeconds.value);
    seekTo(newSec);
  }

  void seekTo(double seconds) {
    currentSeconds.value = seconds.clamp(0.0, totalSeconds.value);
    if (videoPlayerController != null && videoPlayerController!.value.isInitialized) {
      videoPlayerController!.seekTo(Duration(seconds: seconds.toInt()));
    }
    startControlsTimer();
    _syncProgress(action: 'HEARTBEAT');
  }

  void cycleSpeed() {
    if (playbackSpeed.value == 1.0) {
      playbackSpeed.value = 1.25;
    } else if (playbackSpeed.value == 1.25) {
      playbackSpeed.value = 1.5;
    } else if (playbackSpeed.value == 1.5) {
      playbackSpeed.value = 2.0;
    } else {
      playbackSpeed.value = 1.0;
    }

    if (videoPlayerController != null && videoPlayerController!.value.isInitialized) {
      videoPlayerController!.setPlaybackSpeed(playbackSpeed.value);
    }
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
    _fallbackTicker?.cancel();
    _heartbeatTimer?.cancel();

    // Flush exit progress before disposal
    _syncProgress(action: 'EXIT');

    if (videoPlayerController != null) {
      videoPlayerController!.removeListener(_videoListener);
      videoPlayerController!.dispose();
    }
    super.onClose();
  }
}
