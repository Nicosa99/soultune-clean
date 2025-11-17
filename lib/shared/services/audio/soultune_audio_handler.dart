/// SoulTune Audio Handler
///
/// Implements audio_service's AudioHandler interface to provide system-level
/// media controls and notifications. Integrates with just_audio for playback.
///
/// ## Features
///
/// - System notification with media controls
/// - Lock screen controls (Play/Pause/Skip)
/// - Bluetooth/headset button support
/// - Android Auto/CarPlay ready
/// - Background playback management
/// - Metadata and artwork display
/// - Frequency indicator in notification
///
/// ## Usage
///
/// ```dart
/// final audioHandler = await AudioService.init(
///   builder: () => SoulTuneAudioHandler(),
///   config: AudioServiceConfig(...),
/// );
/// ```
library;

import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:soultune/shared/models/audio_file.dart';

/// Custom audio handler for SoulTune.
///
/// Manages system media session, notification, and playback controls.
/// Coordinates between audio_service (system integration) and just_audio
/// (playback engine).
class SoulTuneAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  /// Creates a [SoulTuneAudioHandler].
  SoulTuneAudioHandler() {
    _logger.d('SoulTuneAudioHandler created');
    _init();
  }

  /// Logger instance.
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

  /// The underlying just_audio player.
  final AudioPlayer _player = AudioPlayer();

  /// Current playlist.
  List<MediaItem> _queue = [];

  /// Current track index.
  int _currentIndex = 0;

  /// Current pitch shift (for display in notification).
  double _currentPitchShift = 0.0;

  /// Stream subscriptions.
  final List<StreamSubscription> _subscriptions = [];

  /// Initializes the audio handler.
  Future<void> _init() async {
    _logger.i('Initializing SoulTuneAudioHandler...');

    // Listen to player state changes and update system
    _subscriptions.add(_player.playbackEventStream.listen(_broadcastState));

    // Listen to player completion
    _subscriptions.add(
      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _handleTrackCompletion();
        }
      }),
    );

    _logger.i('✓ SoulTuneAudioHandler initialized');
  }

  // ---------------------------------------------------------------------------
  // Playback Control Methods (called from system)
  // ---------------------------------------------------------------------------

  @override
  Future<void> play() async {
    _logger.d('play() called from system');
    await _player.play();
  }

  @override
  Future<void> pause() async {
    _logger.d('pause() called from system');
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    _logger.d('stop() called from system');
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    _logger.d('seek($position) called from system');
    await _player.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    _logger.d('skipToNext() called from system');
    if (_currentIndex < _queue.length - 1) {
      await skipToQueueItem(_currentIndex + 1);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    _logger.d('skipToPrevious() called from system');
    if (_currentIndex > 0) {
      await skipToQueueItem(_currentIndex - 1);
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    _logger.d('skipToQueueItem($index) called');
    if (index < 0 || index >= _queue.length) {
      _logger.w('Invalid queue index: $index');
      return;
    }

    _currentIndex = index;
    final mediaItem = _queue[index];

    // Update current media item
    this.mediaItem.add(mediaItem);

    // Load and play the track
    await _player.setFilePath(mediaItem.extras!['filePath'] as String);
    await _player.play();
  }

  // ---------------------------------------------------------------------------
  // Custom Methods (called from app)
  // ---------------------------------------------------------------------------

  /// Plays an audio file with optional pitch shift.
  Future<void> playAudioFile(
    AudioFile audioFile, {
    double pitchShift = 0.0,
  }) async {
    _logger.i('playAudioFile: ${audioFile.title} (pitch: $pitchShift)');

    _currentPitchShift = pitchShift;

    // Create media item from audio file
    final mediaItem = _createMediaItem(audioFile, pitchShift);

    // Update current media item
    this.mediaItem.add(mediaItem);

    // Load audio source
    await _player.setFilePath(audioFile.filePath);

    // Apply pitch shift
    final pitchValue = 1.0 + (pitchShift / 12.0);
    await _player.setPitch(pitchValue);

    // Start playback
    await _player.play();
  }

  /// Sets the current playlist.
  void setPlaylist(List<AudioFile> audioFiles) {
    _logger.i('setPlaylist: ${audioFiles.length} tracks');

    _queue = audioFiles.map((file) => _createMediaItem(file, _currentPitchShift)).toList();
    queue.add(_queue);
  }

  /// Updates pitch shift for current track.
  Future<void> updatePitchShift(double semitones) async {
    _logger.i('updatePitchShift: $semitones');

    _currentPitchShift = semitones;

    // Apply pitch shift
    final pitchValue = 1.0 + (semitones / 12.0);
    await _player.setPitch(pitchValue);

    // Update notification with new frequency
    if (mediaItem.value != null) {
      final updatedItem = mediaItem.value!.copyWith(
        extras: {
          ...mediaItem.value!.extras!,
          'pitchShift': semitones,
          'frequency': _getFrequencyLabel(semitones),
        },
      );
      mediaItem.add(updatedItem);
    }
  }

  // ---------------------------------------------------------------------------
  // Helper Methods
  // ---------------------------------------------------------------------------

  /// Creates a MediaItem from AudioFile.
  MediaItem _createMediaItem(AudioFile audioFile, double pitchShift) {
    return MediaItem(
      id: audioFile.id,
      title: audioFile.title,
      artist: audioFile.artist ?? 'Unknown Artist',
      album: audioFile.album,
      duration: audioFile.duration,
      artUri: audioFile.albumArt != null ? Uri.file(audioFile.albumArt!) : null,
      extras: {
        'filePath': audioFile.filePath,
        'pitchShift': pitchShift,
        'frequency': _getFrequencyLabel(pitchShift),
      },
    );
  }

  /// Broadcasts current player state to system.
  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    final processingState = _getProcessingState();

    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: processingState,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _currentIndex,
      ),
    );
  }

  /// Gets audio_service processing state from just_audio state.
  AudioProcessingState _getProcessingState() {
    switch (_player.processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  /// Handles track completion (auto-play next).
  Future<void> _handleTrackCompletion() async {
    _logger.d('Track completed');

    // Auto-play next track if available
    if (_currentIndex < _queue.length - 1) {
      await skipToNext();
    }
  }

  /// Gets frequency label from pitch shift value.
  String _getFrequencyLabel(double pitchShift) {
    if ((pitchShift - (-0.31767)).abs() < 0.01) {
      return '432Hz';
    } else if ((pitchShift - 0.37851).abs() < 0.01) {
      return '528Hz';
    } else if ((pitchShift - 0.69877).abs() < 0.01) {
      return '639Hz';
    }
    return '440Hz';
  }

  // ---------------------------------------------------------------------------
  // Disposal
  // ---------------------------------------------------------------------------

  /// Disposes resources.
  Future<void> dispose() async {
    _logger.d('Disposing SoulTuneAudioHandler...');

    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }

    await _player.dispose();
  }
}
