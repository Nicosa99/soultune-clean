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

import 'package:audio_service/audio_service.dart';
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

  /// Current playlist.
  List<MediaItem> _queue = [];

  /// Current track index.
  int _currentIndex = 0;

  /// Current pitch shift (for display in notification).
  double _currentPitchShift = 0.0;

  /// Callback for play action from system.
  void Function()? onPlay;

  /// Callback for pause action from system.
  void Function()? onPause;

  /// Callback for skip to next action from system.
  void Function()? onSkipToNext;

  /// Callback for skip to previous action from system.
  void Function()? onSkipToPrevious;

  /// Callback for seek action from system.
  void Function(Duration position)? onSeek;

  /// Callback for stop action from system.
  void Function()? onStop;

  /// Initializes the audio handler.
  Future<void> _init() async {
    _logger.i('Initializing SoulTuneAudioHandler...');

    // Initialize with default playback state
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );

    _logger.i('✓ SoulTuneAudioHandler initialized');
  }

  // ---------------------------------------------------------------------------
  // Playback Control Methods (called from system)
  // ---------------------------------------------------------------------------

  @override
  Future<void> play() async {
    _logger.d('play() called from system');
    // Call the actual player via callback
    onPlay?.call();
    _broadcastPlayingState(true);
  }

  @override
  Future<void> pause() async {
    _logger.d('pause() called from system');
    // Call the actual player via callback
    onPause?.call();
    _broadcastPlayingState(false);
  }

  @override
  Future<void> stop() async {
    _logger.d('stop() called from system');
    // Call the actual player via callback
    onStop?.call();
    _broadcastPlayingState(false);
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    _logger.d('seek($position) called from system');
    // Call the actual player via callback
    onSeek?.call(position);
    playbackState.add(
      playbackState.value.copyWith(
        updatePosition: position,
      ),
    );
  }

  @override
  Future<void> skipToNext() async {
    _logger.d('skipToNext() called from system');
    // Call the actual player via callback
    onSkipToNext?.call();
  }

  @override
  Future<void> skipToPrevious() async {
    _logger.d('skipToPrevious() called from system');
    // Call the actual player via callback
    onSkipToPrevious?.call();
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

    // Update current media item (notification only)
    this.mediaItem.add(mediaItem);

    // Update playback state
    _broadcastPlayingState(true);
  }

  // ---------------------------------------------------------------------------
  // Custom Methods (called from app)
  // ---------------------------------------------------------------------------

  /// Plays an audio file with optional pitch shift.
  ///
  /// Note: This method only updates the notification metadata.
  /// Actual playback is handled by AudioPlayerService.
  Future<void> playAudioFile(
    AudioFile audioFile, {
    double pitchShift = 0.0,
  }) async {
    _logger.i('playAudioFile: ${audioFile.title} (pitch: $pitchShift)');

    _currentPitchShift = pitchShift;

    // Create media item from audio file
    final mediaItem = _createMediaItem(audioFile, pitchShift);

    // Update current media item (updates notification)
    this.mediaItem.add(mediaItem);

    // Update playback state to show as playing
    _broadcastPlayingState(true);
  }

  /// Updates playback state in notification.
  void _broadcastPlayingState(bool playing) {
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
        processingState: AudioProcessingState.ready,
        playing: playing,
        queueIndex: _currentIndex,
      ),
    );
  }

  /// Sets the current playlist.
  void setPlaylist(List<AudioFile> audioFiles) {
    _logger.i('setPlaylist: ${audioFiles.length} tracks');

    _queue = audioFiles.map((file) => _createMediaItem(file, _currentPitchShift)).toList();
    queue.add(_queue);
  }

  /// Updates pitch shift for current track.
  ///
  /// Note: This only updates the notification metadata.
  /// Actual pitch is set via AudioPlayerService.
  Future<void> updatePitchShift(double semitones) async {
    _logger.i('updatePitchShift: $semitones');

    _currentPitchShift = semitones;

    // Update notification with new frequency label
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
    // No internal player to dispose - actual playback handled by AudioPlayerService
  }
}
