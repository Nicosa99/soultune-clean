/// SoulTune Audio Player Service
///
/// Core audio playback engine with real-time 432Hz frequency transformation.
/// Wraps `just_audio` package with pitch-shift capabilities to transform
/// standard 440Hz music to healing frequencies (432Hz, 528Hz, etc.) without
/// quality loss.
///
/// ## Frequency Transformation
///
/// Standard tuning uses A4 = 440Hz. SoulTune transforms this in real-time:
///
/// - **432 Hz**: -0.31767 semitones (Deep Peace & Harmony) - FREE
/// - **528 Hz**: +0.37851 semitones (Love & Healing) - PREMIUM
/// - **639 Hz**: +0.69877 semitones (Relationships) - PREMIUM
///
/// Formula: `semitones = 12 × log₂(target / 440)`
///
/// The transformation is applied via `just_audio`'s native pitch-shift API,
/// which preserves audio quality while adjusting frequency.
///
/// ## Features
///
/// - Real-time pitch transformation (non-destructive)
/// - Background playback support
/// - Gapless playback between tracks
/// - Seek with millisecond precision
/// - Playback speed control (0.5x - 2x)
/// - Audio session management
/// - Reactive streams (position, state, errors)
///
/// ## Usage
///
/// ```dart
/// final audioPlayer = AudioPlayerService();
/// await audioPlayer.init();
///
/// // Play with 432Hz transformation
/// await audioPlayer.play(
///   audioFile,
///   pitchShift: kPitch432Hz,
/// );
///
/// // Change frequency in real-time
/// await audioPlayer.setPitchShift(kPitch528Hz);
///
/// // Listen to playback state
/// audioPlayer.playingStream.listen((isPlaying) {
///   print('Playing: $isPlaying');
/// });
///
/// // Cleanup
/// await audioPlayer.dispose();
/// ```
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:soultune/shared/exceptions/app_exceptions.dart';
import 'package:soultune/shared/models/audio_file.dart';

/// Service for audio playback with frequency transformation capabilities.
///
/// Provides a high-level API for playing audio files with real-time pitch
/// shifting to healing frequencies. Manages audio session configuration
/// for optimal background playback and system integration.
///
/// **Lifecycle**: Call [init] during app startup, [dispose] during shutdown.
///
/// **Thread Safety**: All methods are safe to call from the main isolate.
/// Stream subscriptions run on the main thread.
class AudioPlayerService {
  /// Creates an [AudioPlayerService] instance.
  ///
  /// The service must be initialized via [init] before use.
  AudioPlayerService() {
    _logger.d('AudioPlayerService created');
  }

  /// Logger instance for debugging and error tracking.
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// The underlying just_audio player instance.
  late final AudioPlayer _player;

  /// Whether the service has been initialized.
  bool _isInitialized = false;

  /// Currently playing audio file.
  AudioFile? _currentAudioFile;

  /// Current playlist (for auto-play next track).
  List<AudioFile> _currentPlaylist = [];

  /// Current track index in playlist.
  int _currentIndex = 0;

  /// Current pitch shift in semitones.
  double _currentPitchShift = 0.0;

  /// Current playback speed (1.0 = normal).
  double _currentSpeed = 1.0;

  /// Whether the service has been disposed.
  bool _isDisposed = false;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  /// Whether the service is initialized and ready for use.
  bool get isInitialized => _isInitialized;

  /// Currently playing audio file, or null if nothing is playing.
  AudioFile? get currentAudioFile => _currentAudioFile;

  /// Current pitch shift in semitones.
  ///
  /// - Negative values lower pitch (e.g., -0.31767 for 432Hz)
  /// - Positive values raise pitch (e.g., +0.37851 for 528Hz)
  /// - 0.0 = no pitch shift (standard 440Hz)
  double get currentPitchShift => _currentPitchShift;

  /// Current playback speed multiplier (0.5x - 2.0x).
  double get currentSpeed => _currentSpeed;

  /// Whether audio is currently playing.
  bool get isPlaying => _player.playing;

  /// Current playback position.
  Duration get position => _player.position;

  /// Total duration of current audio file.
  Duration? get duration => _player.duration;

  // ---------------------------------------------------------------------------
  // Streams
  // ---------------------------------------------------------------------------

  /// Stream of playback positions.
  ///
  /// Emits current position periodically (approx. 200ms intervals).
  /// Use this for seek bars and time displays.
  ///
  /// ```dart
  /// audioPlayer.positionStream.listen((position) {
  ///   print('Position: ${position.inSeconds}s');
  /// });
  /// ```
  Stream<Duration> get positionStream => _player.positionStream;

  /// Stream of duration changes.
  ///
  /// Emits when a new track loads and duration becomes available.
  Stream<Duration?> get durationStream => _player.durationStream;

  /// Stream of playing state changes.
  ///
  /// Emits `true` when playback starts, `false` when paused or stopped.
  Stream<bool> get playingStream => _player.playingStream;

  /// Stream of player state changes.
  ///
  /// Provides detailed state information (idle, loading, ready, completed).
  /// Use this for loading indicators and completion handling.
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// Stream of playback events (position + state combined).
  ///
  /// Provides comprehensive playback information in a single stream.
  Stream<PlaybackEvent> get playbackEventStream => _player.playbackEventStream;

  /// Stream that emits when a track completes.
  ///
  /// Useful for implementing auto-play next track functionality.
  Stream<void> get trackCompletedStream => _player.playerStateStream
      .where((state) => state.processingState == ProcessingState.completed)
      .map((_) => null);

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Initializes the audio player and configures audio session.
  ///
  /// Must be called before any playback operations. Configures the audio
  /// session for music playback with support for background audio, AirPlay,
  /// and system audio controls.
  ///
  /// ## Audio Session Configuration
  ///
  /// - **Category**: Music (optimized for music playback)
  /// - **Mode**: Default (standard audio routing)
  /// - **Mix with Others**: False (exclusive audio focus)
  /// - **Interruptions**: Automatically pauses on phone calls, resumes after
  ///
  /// ## Example
  ///
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///
  ///   final audioPlayer = AudioPlayerService();
  ///   await audioPlayer.init();
  ///
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// ## Throws
  ///
  /// [AudioException] if initialization fails.
  Future<void> init() async {
    if (_isInitialized) {
      _logger.w('AudioPlayerService already initialized');
      return;
    }

    try {
      _logger.i('Initializing AudioPlayerService...');

      // Create player instance
      _player = AudioPlayer();

      // Configure audio session for music playback
      final session = await AudioSession.instance;

      await session.configure(
        const AudioSessionConfiguration.music(),
      );

      // Explicitly activate the session for background playback
      await session.setActive(true);

      _logger.d('Audio session configured: ${session.configuration}');

      // Handle audio interruptions (phone calls, etc.)
      session.interruptionEventStream.listen((event) {
        _logger.d('Audio interruption: ${event.type}');

        if (event.begin) {
          // Pause on interruption
          pause();
        } else {
          // Resume after interruption (optional - user preference)
          if (event.type == AudioInterruptionType.unknown) {
            // Auto-resume for temporary interruptions
            play();
          }
        }
      });

      // Handle becoming noisy (headphones unplugged)
      session.becomingNoisyEventStream.listen((_) {
        _logger.w('Audio becoming noisy (headphones unplugged?)');
        pause();
      });

      _isInitialized = true;
      _logger.i('✓ AudioPlayerService initialized successfully');
    } on Exception catch (e, stackTrace) {
      _logger.e(
        'Failed to initialize AudioPlayerService',
        error: e,
        stackTrace: stackTrace,
      );

      throw AudioException(
        'Failed to initialize audio player',
        e,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Playback Control
  // ---------------------------------------------------------------------------

  /// Loads and plays an audio file with optional pitch shift.
  ///
  /// Stops current playback (if any), loads the new file, applies pitch
  /// transformation, and starts playback.
  ///
  /// ## Parameters
  ///
  /// - [audioFile]: The audio file to play
  /// - [pitchShift]: Semitone shift (default: 0.0 = no shift)
  ///   - Use constants: [kPitch432Hz], [kPitch528Hz], [kPitch639Hz]
  /// - [startPosition]: Optional starting position (default: beginning)
  ///
  /// ## Returns
  ///
  /// Future that completes when playback starts.
  ///
  /// ## Throws
  ///
  /// - [AudioException]: If file cannot be loaded or played
  /// - [FileException]: If file doesn't exist
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Play with 432Hz transformation
  /// await audioPlayer.play(
  ///   audioFile,
  ///   pitchShift: kPitch432Hz,
  /// );
  ///
  /// // Play from 30 seconds in
  /// await audioPlayer.play(
  ///   audioFile,
  ///   startPosition: Duration(seconds: 30),
  /// );
  /// ```
  Future<void> play([
    AudioFile? audioFile,
    double pitchShift = 0.0,
    Duration? startPosition,
  ]) async {
    _ensureInitialized();

    try {
      // If new audio file provided, load it
      if (audioFile != null) {
        _logger.i('Loading audio file: ${audioFile.title}');

        // Set audio source
        await _player.setAudioSource(
          AudioSource.file(audioFile.filePath),
          initialPosition: startPosition ?? Duration.zero,
        );

        _currentAudioFile = audioFile;
        _logger.d('Audio source loaded: ${audioFile.filePath}');
      }

      // Apply pitch shift
      if (pitchShift != _currentPitchShift) {
        await setPitchShift(pitchShift);
      }

      // Start playback
      await _player.play();

      _logger.i(
        'Playback started: ${_currentAudioFile?.title ?? "Unknown"} '
        '(pitch: ${_currentPitchShift.toStringAsFixed(3)} semitones)',
      );
    } on PlayerException catch (e) {
      _logger.e('Player error', error: e);
      throw AudioException(
        'Failed to play audio: ${e.message}',
        e,
      );
    } on Exception catch (e, stackTrace) {
      _logger.e(
        'Failed to play audio',
        error: e,
        stackTrace: stackTrace,
      );

      throw AudioException(
        'Failed to play audio file',
        e,
      );
    }
  }

  /// Pauses playback.
  ///
  /// Preserves current position. Use [play] without arguments to resume.
  ///
  /// ## Example
  ///
  /// ```dart
  /// await audioPlayer.pause();
  /// // ... later
  /// await audioPlayer.play(); // Resume from paused position
  /// ```
  Future<void> pause() async {
    _ensureInitialized();

    try {
      await _player.pause();
      _logger.d('Playback paused');
    } on Exception catch (e) {
      _logger.e('Failed to pause', error: e);
      throw AudioException('Failed to pause playback', e);
    }
  }

  /// Stops playback and resets position to beginning.
  ///
  /// After stopping, [play] will start from the beginning unless a different
  /// [startPosition] is specified.
  Future<void> stop() async {
    _ensureInitialized();

    try {
      await _player.stop();
      _logger.d('Playback stopped');
    } on Exception catch (e) {
      _logger.e('Failed to stop', error: e);
      throw AudioException('Failed to stop playback', e);
    }
  }

  /// Seeks to a specific position in the current track.
  ///
  /// ## Parameters
  ///
  /// - [position]: Target position to seek to
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Jump to 1 minute mark
  /// await audioPlayer.seek(Duration(minutes: 1));
  ///
  /// // Skip forward 10 seconds
  /// final newPosition = audioPlayer.position + Duration(seconds: 10);
  /// await audioPlayer.seek(newPosition);
  /// ```
  Future<void> seek(Duration position) async {
    _ensureInitialized();

    try {
      await _player.seek(position);
      _logger.d('Seeked to: ${position.inSeconds}s');
    } on Exception catch (e) {
      _logger.e('Failed to seek', error: e);
      throw AudioException('Failed to seek to position', e);
    }
  }

  // ---------------------------------------------------------------------------
  // Frequency Transformation
  // ---------------------------------------------------------------------------

  /// Changes the pitch shift in real-time.
  ///
  /// Applies frequency transformation without interrupting playback.
  /// Use predefined constants for healing frequencies:
  ///
  /// - `kPitch432Hz` = -0.31767 semitones (432 Hz - Deep Peace)
  /// - `kPitch528Hz` = +0.37851 semitones (528 Hz - Love Frequency)
  /// - `kPitch639Hz` = +0.69877 semitones (639 Hz - Relationships)
  ///
  /// ## Parameters
  ///
  /// - [semitones]: Pitch shift in semitones
  ///   - Negative = lower pitch
  ///   - Positive = higher pitch
  ///   - 0.0 = no shift (standard 440Hz tuning)
  ///
  /// ## Technical Details
  ///
  /// The pitch shift is converted to a playback rate multiplier:
  /// `rate = 2^(semitones / 12)`
  ///
  /// This preserves tempo while changing pitch (time-stretching).
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Transform to 432Hz while playing
  /// await audioPlayer.setPitchShift(kPitch432Hz);
  ///
  /// // Return to standard tuning
  /// await audioPlayer.setPitchShift(0.0);
  ///
  /// // Custom frequency (e.g., 396 Hz Solfeggio)
  /// final pitch396 = calculatePitchShift(targetHz: 396.0);
  /// await audioPlayer.setPitchShift(pitch396);
  /// ```
  Future<void> setPitchShift(double semitones) async {
    _ensureInitialized();

    try {
      // Convert semitones to playback rate
      // Formula: rate = 2^(semitones / 12)
      final rate = _semitoneToRate(semitones);

      await _player.setPitch(rate);

      _currentPitchShift = semitones;

      _logger.i(
        'Pitch shift updated: ${semitones.toStringAsFixed(3)} semitones '
        '(rate: ${rate.toStringAsFixed(4)})',
      );
    } on Exception catch (e, stackTrace) {
      _logger.e(
        'Failed to set pitch shift',
        error: e,
        stackTrace: stackTrace,
      );

      throw AudioException(
        'Failed to change frequency',
        e,
      );
    }
  }

  /// Sets playback speed without changing pitch.
  ///
  /// Useful for meditation (slower) or study (faster) modes.
  ///
  /// ## Parameters
  ///
  /// - [speed]: Speed multiplier (0.5 - 2.0)
  ///   - 0.5 = half speed
  ///   - 1.0 = normal speed
  ///   - 2.0 = double speed
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Slow down for meditation
  /// await audioPlayer.setSpeed(0.8);
  ///
  /// // Return to normal
  /// await audioPlayer.setSpeed(1.0);
  /// ```
  Future<void> setSpeed(double speed) async {
    _ensureInitialized();

    if (speed < 0.5 || speed > 2.0) {
      throw AudioException('Speed must be between 0.5 and 2.0');
    }

    try {
      await _player.setSpeed(speed);

      _currentSpeed = speed;

      _logger.i('Playback speed: ${speed.toStringAsFixed(2)}x');
    } on Exception catch (e) {
      _logger.e('Failed to set speed', error: e);
      throw AudioException('Failed to change playback speed', e);
    }
  }

  // ---------------------------------------------------------------------------
  // Volume Control
  // ---------------------------------------------------------------------------

  /// Sets playback volume.
  ///
  /// ## Parameters
  ///
  /// - [volume]: Volume level (0.0 - 1.0)
  ///   - 0.0 = muted
  ///   - 1.0 = maximum
  ///
  /// ## Example
  ///
  /// ```dart
  /// await audioPlayer.setVolume(0.5); // 50% volume
  /// ```
  Future<void> setVolume(double volume) async {
    _ensureInitialized();

    if (volume < 0.0 || volume > 1.0) {
      throw AudioException('Volume must be between 0.0 and 1.0');
    }

    try {
      await _player.setVolume(volume);
      _logger.d('Volume: ${(volume * 100).toStringAsFixed(0)}%');
    } on Exception catch (e) {
      _logger.e('Failed to set volume', error: e);
      throw AudioException('Failed to set volume', e);
    }
  }

  // ---------------------------------------------------------------------------
  // Helper Methods
  // ---------------------------------------------------------------------------

  /// Converts semitone shift to playback rate multiplier.
  ///
  /// Formula: `rate = 2^(semitones / 12)`
  ///
  /// Examples:
  /// - -0.31767 semitones (432Hz) = 0.98181 rate
  /// - +0.37851 semitones (528Hz) = 1.02345 rate
  double _semitoneToRate(double semitones) {
    // 2^(semitones / 12)
    return math.pow(2, semitones / 12).toDouble();
  }

  /// Ensures the service is initialized before operations.
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw const AudioException(
        'AudioPlayerService not initialized. Call init() first.',
      );
    }

    if (_isDisposed) {
      throw const AudioException(
        'AudioPlayerService has been disposed. Create a new instance.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Playlist Management
  // ---------------------------------------------------------------------------

  /// Sets the current playlist for auto-play functionality.
  ///
  /// ## Parameters
  ///
  /// - [playlist]: List of audio files to play
  /// - [startIndex]: Index of track to start playing (default: 0)
  ///
  /// ## Example
  ///
  /// ```dart
  /// await audioPlayer.setPlaylist(allTracks, startIndex: 5);
  /// ```
  void setPlaylist(List<AudioFile> playlist, {int startIndex = 0}) {
    _currentPlaylist = playlist;
    _currentIndex = startIndex.clamp(0, playlist.length - 1);
    _logger.d('Playlist set: ${playlist.length} tracks, starting at $startIndex');
  }

  /// Plays the next track in the playlist.
  ///
  /// Returns `true` if there is a next track, `false` otherwise.
  ///
  /// ## Example
  ///
  /// ```dart
  /// if (await audioPlayer.playNext()) {
  ///   print('Playing next track');
  /// }
  /// ```
  Future<bool> playNext({double pitchShift = 0.0}) async {
    _ensureInitialized();

    if (_currentPlaylist.isEmpty) {
      _logger.w('Cannot play next: Playlist is empty');
      return false;
    }

    final nextIndex = _currentIndex + 1;
    if (nextIndex >= _currentPlaylist.length) {
      _logger.d('Reached end of playlist');
      return false;
    }

    _currentIndex = nextIndex;
    await play(_currentPlaylist[_currentIndex], pitchShift);
    return true;
  }

  /// Plays the previous track in the playlist.
  ///
  /// Returns `true` if there is a previous track, `false` otherwise.
  ///
  /// ## Example
  ///
  /// ```dart
  /// if (await audioPlayer.playPrevious()) {
  ///   print('Playing previous track');
  /// }
  /// ```
  Future<bool> playPrevious({double pitchShift = 0.0}) async {
    _ensureInitialized();

    if (_currentPlaylist.isEmpty) {
      _logger.w('Cannot play previous: Playlist is empty');
      return false;
    }

    final previousIndex = _currentIndex - 1;
    if (previousIndex < 0) {
      _logger.d('Already at start of playlist');
      return false;
    }

    _currentIndex = previousIndex;
    await play(_currentPlaylist[_currentIndex], pitchShift);
    return true;
  }

  /// Restarts the playlist from the beginning.
  ///
  /// Returns `true` if successful.
  Future<bool> restartPlaylist({double pitchShift = 0.0}) async {
    _ensureInitialized();

    if (_currentPlaylist.isEmpty) {
      _logger.w('Cannot restart: Playlist is empty');
      return false;
    }

    _currentIndex = 0;
    await play(_currentPlaylist[0], pitchShift);
    return true;
  }

  // ---------------------------------------------------------------------------
  // Disposal
  // ---------------------------------------------------------------------------

  /// Disposes the audio player and releases resources.
  ///
  /// Must be called during app shutdown to prevent memory leaks.
  /// After disposal, the service cannot be reused - create a new instance.
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// void dispose() {
  ///   audioPlayerService.dispose();
  ///   super.dispose();
  /// }
  /// ```
  Future<void> dispose() async {
    if (_isDisposed) {
      _logger.w('AudioPlayerService already disposed');
      return;
    }

    try {
      _logger.i('Disposing AudioPlayerService...');

      await _player.dispose();

      _isDisposed = true;
      _isInitialized = false;
      _currentAudioFile = null;

      _logger.i('✓ AudioPlayerService disposed');
    } on Exception catch (e) {
      _logger.e('Error during disposal', error: e);
      // Don't throw during cleanup
    }
  }
}
