import 'dart:async';
import 'package:get/get.dart';

class MoviePlayerController extends GetxController {
  final RxBool isPlaying = true.obs;
  final RxBool showControls = true.obs;
  final RxDouble currentSeconds = 1420.0.obs; // ~23m 40s
  final double totalSeconds = 8040.0; // 2h 14m (134 min)
  final RxDouble playbackSpeed = 1.0.obs;

  final RxString selectedQuality = '4K Ultra HD'.obs;
  final RxString selectedAudio = 'English (Dolby Atmos)'.obs;
  final RxString selectedSubtitle = 'English [CC]'.obs;

  Timer? _controlsTimer;
  Timer? _playbackTicker;

  @override
  void onInit() {
    super.onInit();
    startControlsTimer();
    startPlaybackSimulation();
  }

  void startPlaybackSimulation() {
    _playbackTicker?.cancel();
    _playbackTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isPlaying.value) {
        if (currentSeconds.value < totalSeconds) {
          currentSeconds.value += playbackSpeed.value;
        } else {
          isPlaying.value = false;
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
    isPlaying.value = !isPlaying.value;
    if (isPlaying.value) {
      startControlsTimer();
    } else {
      _controlsTimer?.cancel();
    }
  }

  void seekBy(double seconds) {
    currentSeconds.value = (currentSeconds.value + seconds).clamp(0.0, totalSeconds);
    startControlsTimer();
  }

  void seekTo(double seconds) {
    currentSeconds.value = seconds.clamp(0.0, totalSeconds);
    startControlsTimer();
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
    _playbackTicker?.cancel();
    super.onClose();
  }
}
