/// SoulTune Audio Service Integration
///
/// Synchronizes AudioPlayerService (app-internal playback) with
/// NotificationService (system media controls). Ensures both services
/// stay in sync during playback.
///
/// ## Architecture
///
/// ```
/// PlayerRepository
///     ↓
/// AudioServiceIntegration ← You are here
///     ↓              ↓
/// AudioPlayerService  NotificationService
/// (Internal Player)   (System Controls)
/// ```
///
/// ## Usage
///
/// ```dart
/// // In PlayerRepository
/// await AudioServiceIntegration.playAudioFile(
///   audioFile,
///   audioPlayerService,
///   pitchShift: kPitch432Hz,
/// );
/// ```
library;

import 'package:logger/logger.dart';
import 'package:soultune/shared/models/audio_file.dart';
import 'package:soultune/shared/services/audio/audio_player_service.dart';
import 'package:soultune/shared/services/audio/notification_service.dart';

/// Integration layer between internal player and notification service.
///
/// Provides static methods to synchronize playback state between
/// AudioPlayerService and NotificationService.
class AudioServiceIntegration {
  /// Private constructor (utility class).
  AudioServiceIntegration._();

  /// Logger instance.
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Plays an audio file with both services synchronized.
  ///
  /// Updates both the internal player and notification.
  ///
  /// ## Parameters
  ///
  /// - [audioFile]: The audio file to play
  /// - [audioPlayerService]: The internal player service
  /// - [pitchShift]: Frequency transformation (default: 0.0)
  ///
  /// ## Example
  ///
  /// ```dart
  /// await AudioServiceIntegration.playAudioFile(
  ///   audioFile,
  ///   _audioPlayerService,
  ///   pitchShift: kPitch432Hz,
  /// );
  /// ```
  static Future<void> playAudioFile(
    AudioFile audioFile,
    AudioPlayerService audioPlayerService, {
    double pitchShift = 0.0,
  }) async {
    _logger.d('playAudioFile: ${audioFile.title} (pitch: $pitchShift)');

    try {
      // Play on internal service
      await audioPlayerService.play(audioFile, pitchShift: pitchShift);

      // Update notification if initialized
      if (NotificationService.isInitialized) {
        try {
          await NotificationService.audioHandler.playAudioFile(
            audioFile,
            pitchShift: pitchShift,
          );
        } catch (e) {
          _logger.w('Failed to update notification: $e');
          // Continue anyway - app still works without notifications
        }
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to play audio file',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Sets the playlist for both services.
  ///
  /// ## Parameters
  ///
  /// - [playlist]: List of audio files
  /// - [audioPlayerService]: The internal player service
  /// - [startIndex]: Starting track index (default: 0)
  ///
  /// ## Example
  ///
  /// ```dart
  /// AudioServiceIntegration.setPlaylist(
  ///   playlistTracks,
  ///   _audioPlayerService,
  ///   startIndex: 2,
  /// );
  /// ```
  static void setPlaylist(
    List<AudioFile> playlist,
    AudioPlayerService audioPlayerService, {
    int startIndex = 0,
  }) {
    _logger.d('setPlaylist: ${playlist.length} tracks (start: $startIndex)');

    // Set on internal service
    audioPlayerService.setPlaylist(playlist, startIndex: startIndex);

    // Update notification if initialized
    if (NotificationService.isInitialized) {
      try {
        NotificationService.audioHandler.setPlaylist(playlist);
      } catch (e) {
        _logger.w('Failed to update notification playlist: $e');
      }
    }
  }

  /// Updates pitch shift on both services.
  ///
  /// ## Parameters
  ///
  /// - [semitones]: Pitch shift in semitones
  /// - [audioPlayerService]: The internal player service
  ///
  /// ## Example
  ///
  /// ```dart
  /// await AudioServiceIntegration.updatePitchShift(
  ///   kPitch432Hz,
  ///   _audioPlayerService,
  /// );
  /// ```
  static Future<void> updatePitchShift(
    double semitones,
    AudioPlayerService audioPlayerService,
  ) async {
    _logger.d('updatePitchShift: $semitones');

    try {
      // Update on internal service
      await audioPlayerService.setPitchShift(semitones);

      // Update notification if initialized
      if (NotificationService.isInitialized) {
        try {
          await NotificationService.audioHandler.updatePitchShift(semitones);
        } catch (e) {
          _logger.w('Failed to update notification pitch: $e');
        }
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to update pitch shift',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Pauses playback on both services.
  ///
  /// ## Parameters
  ///
  /// - [audioPlayerService]: The internal player service
  ///
  /// ## Example
  ///
  /// ```dart
  /// await AudioServiceIntegration.pause(_audioPlayerService);
  /// ```
  static Future<void> pause(AudioPlayerService audioPlayerService) async {
    _logger.d('pause()');

    try {
      // Pause internal service
      await audioPlayerService.pause();

      // Pause notification if initialized
      if (NotificationService.isInitialized) {
        try {
          await NotificationService.audioHandler.pause();
        } catch (e) {
          _logger.w('Failed to pause notification: $e');
        }
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to pause', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Resumes playback on both services.
  ///
  /// ## Parameters
  ///
  /// - [audioPlayerService]: The internal player service
  ///
  /// ## Example
  ///
  /// ```dart
  /// await AudioServiceIntegration.resume(_audioPlayerService);
  /// ```
  static Future<void> resume(AudioPlayerService audioPlayerService) async {
    _logger.d('resume()');

    try {
      // Resume internal service
      await audioPlayerService.resume();

      // Resume notification if initialized
      if (NotificationService.isInitialized) {
        try {
          await NotificationService.audioHandler.play();
        } catch (e) {
          _logger.w('Failed to resume notification: $e');
        }
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to resume', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Stops playback on both services.
  ///
  /// ## Parameters
  ///
  /// - [audioPlayerService]: The internal player service
  ///
  /// ## Example
  ///
  /// ```dart
  /// await AudioServiceIntegration.stop(_audioPlayerService);
  /// ```
  static Future<void> stop(AudioPlayerService audioPlayerService) async {
    _logger.d('stop()');

    try {
      // Stop internal service
      await audioPlayerService.stop();

      // Stop notification if initialized
      if (NotificationService.isInitialized) {
        try {
          await NotificationService.audioHandler.stop();
        } catch (e) {
          _logger.w('Failed to stop notification: $e');
        }
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to stop', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
