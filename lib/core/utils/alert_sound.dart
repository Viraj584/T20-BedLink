import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

class AlertSoundUtil {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static Timer? _vibrationLoopTimer;
  static bool _isPlaying = false;

  static Future<void> triggerIncomingAlert() async {
    if (_isPlaying) return;
    _isPlaying = true;

    try {
      // 1. Audio looping
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(
        UrlSource('https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3'),
      );

      // 2. Vibration looping
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        // Trigger initial vibration
        Vibration.vibrate(pattern: [500, 1000, 500, 1000]);

        // Repeat vibration pattern every 3 seconds while active
        _vibrationLoopTimer?.cancel();
        _vibrationLoopTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
          if (!_isPlaying) return;
          try {
            Vibration.vibrate(pattern: [500, 1000, 500, 1000]);
          } catch (e) {
            debugPrint('Vibration loop error: $e');
          }
        });
      }
    } catch (e) {
      debugPrint('Error triggering incoming alert loop: $e');
    }
  }

  static Future<void> stopAlert() async {
    _isPlaying = false;
    _vibrationLoopTimer?.cancel();
    _vibrationLoopTimer = null;
    try {
      await _audioPlayer.stop();
      Vibration.cancel();
    } catch (e) {
      debugPrint('Error stopping alert loop: $e');
    }
  }
}
