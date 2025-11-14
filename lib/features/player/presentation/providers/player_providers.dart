/// SoulTune Player Providers
///
/// Riverpod state management for the player feature. Exposes reactive state
/// for UI components using code generation (@riverpod annotations).
///
/// ## Architecture
///
/// ```
/// UI Widgets
///    ↓ (watch/read)
/// Providers (State Management) ← You are here
///    ↓
/// PlayerRepository (Business Logic)
///    ↓
/// Services & Data Sources
/// ```
///
/// ## Available Providers
///
/// **Core**
/// - [playerRepository]: Singleton repository instance
///
/// **Playback State**
/// - [currentAudioFile]: Currently playing track
/// - [isPlaying]: Play/pause state
/// - [playbackPosition]: Current position stream
/// - [playbackDuration]: Track duration
/// - [currentPitchShift]: Active frequency transformation
///
/// **Library**
/// - [audioLibrary]: All audio files
/// - [favoritesLibrary]: Favorite tracks
/// - [recentlyAdded]: Recently added tracks
/// - [mostPlayed]: Most played tracks
/// - [searchResults]: Search query results
///
/// **User Actions**
/// - [playAudio]: Play a track with optional pitch shift
/// - [togglePlayPause]: Play/pause control
/// - [seekTo]: Seek to position
/// - [changePitchShift]: Change frequency transformation
/// - [toggleFavoriteAction]: Toggle favorite status
///
/// ## Usage
///
/// ```dart
/// // In a ConsumerWidget
/// @override
/// Widget build(BuildContext context, WidgetRef ref) {
///   // Watch current track
///   final currentTrack = ref.watch(currentAudioFileProvider);
///
///   // Watch playing state
///   final isPlaying = ref.watch(isPlayingProvider);
///
///   // Watch library
///   final library = ref.watch(audioLibraryProvider);
///
///   return library.when(
///     data: (files) => ListView.builder(...),
///     loading: () => CircularProgressIndicator(),
///     error: (err, stack) => Text('Error: $err'),
///   );
/// }
///
/// // Execute actions
/// ref.read(playAudioProvider)(audioFile, pitchShift: kPitch432Hz);
/// ref.read(togglePlayPauseProvider)();
/// ref.read(toggleFavoriteActionProvider)(audioFile.id);
/// ```
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soultune/features/player/data/repositories/player_repository.dart';
import 'package:soultune/shared/models/audio_file.dart';

part 'player_providers.g.dart';

// =============================================================================
// Core Repository
// =============================================================================

/// Provides the singleton [PlayerRepository] instance.
///
/// Automatically initializes on first access. Use this to access repository
/// methods directly when needed.
///
/// ## Example
///
/// ```dart
/// final repository = ref.read(playerRepositoryProvider);
/// await repository.scanAndImportLibrary();
/// ```
@Riverpod(keepAlive: true)
Future<PlayerRepository> playerRepository(PlayerRepositoryRef ref) async {
  final repository = PlayerRepository();
  await repository.init();

  // Cleanup on provider disposal
  ref.onDispose(() async {
    await repository.dispose();
  });

  return repository;
}

// =============================================================================
// Playback State Providers
// =============================================================================

/// Provides the currently playing audio file.
///
/// Returns `null` if no track is playing.
///
/// Watches the player state stream to reactively update when playback changes.
///
/// ## Example
///
/// ```dart
/// final currentTrack = ref.watch(currentAudioFileProvider);
///
/// if (currentTrack != null) {
///   Text('Now Playing: ${currentTrack.title}');
/// }
/// ```
@riverpod
Stream<AudioFile?> currentAudioFile(CurrentAudioFileRef ref) async* {
  final repository = await ref.watch(playerRepositoryProvider.future);

  // Emit current file immediately
  yield repository.currentAudioFile;

  // Watch player state stream and emit current file on each change
  await for (final _ in repository.playingStream) {
    yield repository.currentAudioFile;
  }
}

/// Provides the current playing state.
///
/// Returns `true` if audio is playing, `false` if paused or stopped.
///
/// ## Example
///
/// ```dart
/// final isPlaying = ref.watch(isPlayingProvider);
///
/// IconButton(
///   icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
///   onPressed: () => ref.read(togglePlayPauseProvider)(),
/// );
/// ```
@riverpod
bool isPlaying(IsPlayingRef ref) {
  final repository = ref.watch(playerRepositoryProvider).value;
  return repository?.isPlaying ?? false;
}

/// Provides a stream of playback positions.
///
/// Emits current position periodically (approx. 200ms intervals).
/// Use for seek bars and time displays.
///
/// ## Example
///
/// ```dart
/// final positionAsync = ref.watch(playbackPositionProvider);
///
/// positionAsync.when(
///   data: (position) => Text('${position.inSeconds}s'),
///   loading: () => Text('--:--'),
///   error: (_, __) => Text('--:--'),
/// );
/// ```
@riverpod
Stream<Duration> playbackPosition(PlaybackPositionRef ref) async* {
  final repository = await ref.watch(playerRepositoryProvider.future);
  yield* repository.positionStream;
}

/// Provides the current track duration.
///
/// Returns `null` if no track is loaded.
///
/// ## Example
///
/// ```dart
/// final duration = ref.watch(playbackDurationProvider);
///
/// if (duration != null) {
///   Text('Duration: ${duration.inMinutes}:${duration.inSeconds % 60}');
/// }
/// ```
@riverpod
Duration? playbackDuration(PlaybackDurationRef ref) {
  final repository = ref.watch(playerRepositoryProvider).value;
  return repository?.duration;
}

/// Provides the current pitch shift in semitones.
///
/// Returns the active frequency transformation:
/// - -0.31767 for 432Hz
/// - 0.0 for standard 440Hz
/// - +0.37851 for 528Hz
///
/// ## Example
///
/// ```dart
/// final pitchShift = ref.watch(currentPitchShiftProvider);
///
/// Text('Frequency: ${pitchShift == kPitch432Hz ? "432 Hz" : "440 Hz"}');
/// ```
@riverpod
double currentPitchShift(CurrentPitchShiftRef ref) {
  final repository = ref.watch(playerRepositoryProvider).value;
  return repository?.currentPitchShift ?? 0.0;
}

/// Provides the current playback speed.
///
/// Returns the speed multiplier (1.0 = normal speed).
///
/// ## Example
///
/// ```dart
/// final speed = ref.watch(currentSpeedProvider);
/// Text('Speed: ${speed}x');
/// ```
@riverpod
double currentSpeed(CurrentSpeedRef ref) {
  final repository = ref.watch(playerRepositoryProvider).value;
  return repository?.currentSpeed ?? 1.0;
}

// =============================================================================
// Library Data Providers
// =============================================================================

/// Provides all audio files in the library.
///
/// Automatically refreshes when library changes (via stream subscription).
///
/// ## Example
///
/// ```dart
/// final libraryAsync = ref.watch(audioLibraryProvider);
///
/// libraryAsync.when(
///   data: (files) => ListView.builder(
///     itemCount: files.length,
///     itemBuilder: (context, index) => AudioTile(files[index]),
///   ),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
@riverpod
Stream<List<AudioFile>> audioLibrary(AudioLibraryRef ref) async* {
  final repository = await ref.watch(playerRepositoryProvider.future);

  // Emit initial library
  yield await repository.getAllAudioFiles();

  // Listen to changes
  yield* repository.libraryStream;
}

/// Provides favorite audio files.
///
/// Returns only files marked as favorites.
///
/// ## Example
///
/// ```dart
/// final favoritesAsync = ref.watch(favoritesLibraryProvider);
///
/// favoritesAsync.when(
///   data: (favorites) => Text('${favorites.length} favorites'),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error'),
/// );
/// ```
@riverpod
Future<List<AudioFile>> favoritesLibrary(FavoritesLibraryRef ref) async {
  final repository = await ref.watch(playerRepositoryProvider.future);
  return repository.getFavorites();
}

/// Provides recently added audio files.
///
/// Returns up to 20 most recently added tracks by default.
///
/// ## Example
///
/// ```dart
/// final recentAsync = ref.watch(recentlyAddedProvider);
/// ```
@riverpod
Future<List<AudioFile>> recentlyAdded(RecentlyAddedRef ref) async {
  final repository = await ref.watch(playerRepositoryProvider.future);
  return repository.getRecentlyAdded(limit: 20);
}

/// Provides most played audio files.
///
/// Returns up to 20 most played tracks by default.
///
/// ## Example
///
/// ```dart
/// final popularAsync = ref.watch(mostPlayedProvider);
/// ```
@riverpod
Future<List<AudioFile>> mostPlayed(MostPlayedRef ref) async {
  final repository = await ref.watch(playerRepositoryProvider.future);
  return repository.getMostPlayed(limit: 20);
}

/// Provides search results for a query.
///
/// Searches both title and artist fields.
///
/// ## Example
///
/// ```dart
/// // Create a search query provider
/// final searchQueryProvider = StateProvider<String>((ref) => '');
///
/// // In widget
/// final query = ref.watch(searchQueryProvider);
/// final resultsAsync = ref.watch(searchResultsProvider(query));
/// ```
@riverpod
Future<List<AudioFile>> searchResults(
  SearchResultsRef ref,
  String query,
) async {
  final repository = await ref.watch(playerRepositoryProvider.future);

  if (query.trim().isEmpty) {
    return [];
  }

  return repository.searchAudioFiles(query);
}

// =============================================================================
// Action Providers (User Interactions)
// =============================================================================

/// Action: Play an audio file with optional frequency transformation.
///
/// ## Parameters
///
/// - [audioFile]: The audio file to play
/// - [pitchShift]: Semitone shift (default: 0.0)
///   - Use constants: kPitch432Hz, kPitch528Hz, kPitch639Hz
/// - [startPosition]: Optional starting position
///
/// ## Example
///
/// ```dart
/// // In button onPressed
/// onPressed: () async {
///   await ref.read(playAudioProvider.notifier).play(
///     audioFile,
///     pitchShift: kPitch432Hz,
///   );
/// }
/// ```
@riverpod
class PlayAudio extends _$PlayAudio {
  @override
  FutureOr<void> build() {
    // No-op build
  }

  Future<void> play(
    AudioFile audioFile, {
    double pitchShift = 0.0,
    Duration? startPosition,
  }) async {
    final repository = await ref.read(playerRepositoryProvider.future);

    await repository.playAudioFile(
      audioFile,
      pitchShift: pitchShift,
      startPosition: startPosition,
    );

    // Force state refresh without disposing repository
    // Note: We invalidate the state providers, not the repository itself
    ref.invalidate(currentAudioFileProvider);
    ref.invalidate(isPlayingProvider);
  }
}

/// Action: Toggle play/pause.
///
/// If playing, pauses. If paused, resumes.
///
/// ## Example
///
/// ```dart
/// IconButton(
///   icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
///   onPressed: () => ref.read(togglePlayPauseProvider)(),
/// );
/// ```
@riverpod
Future<void> Function() togglePlayPause(TogglePlayPauseRef ref) {
  return () async {
    final repository = await ref.read(playerRepositoryProvider.future);

    if (repository.isPlaying) {
      await repository.pause();
    } else {
      await repository.resume();
    }

    // Refresh playing state
    ref.invalidate(isPlayingProvider);
  };
}

/// Action: Pause playback.
///
/// ## Example
///
/// ```dart
/// onPressed: () => ref.read(pausePlaybackProvider)(),
/// ```
@riverpod
Future<void> Function() pausePlayback(PausePlaybackRef ref) {
  return () async {
    final repository = await ref.read(playerRepositoryProvider.future);
    await repository.pause();
    ref.invalidate(isPlayingProvider);
  };
}

/// Action: Resume playback.
///
/// ## Example
///
/// ```dart
/// onPressed: () => ref.read(resumePlaybackProvider)(),
/// ```
@riverpod
Future<void> Function() resumePlayback(ResumePlaybackRef ref) {
  return () async {
    final repository = await ref.read(playerRepositoryProvider.future);
    await repository.resume();
    ref.invalidate(isPlayingProvider);
  };
}

/// Action: Stop playback.
///
/// ## Example
///
/// ```dart
/// onPressed: () => ref.read(stopPlaybackProvider)(),
/// ```
@riverpod
Future<void> Function() stopPlayback(StopPlaybackRef ref) {
  return () async {
    final repository = await ref.read(playerRepositoryProvider.future);
    await repository.stop();
    ref.invalidate(isPlayingProvider);
    ref.invalidate(currentAudioFileProvider);
  };
}

/// Action: Seek to a specific position.
///
/// ## Parameters
///
/// - [position]: Target position
///
/// ## Example
///
/// ```dart
/// onChanged: (value) {
///   ref.read(seekToProvider)(Duration(seconds: value.toInt()));
/// }
/// ```
@riverpod
Future<void> Function(Duration position) seekTo(SeekToRef ref) {
  return (Duration position) async {
    final repository = await ref.read(playerRepositoryProvider.future);
    await repository.seek(position);
  };
}

/// Action: Change pitch shift (frequency transformation).
///
/// Applies frequency transformation in real-time without interrupting playback.
///
/// ## Parameters
///
/// - [semitones]: Pitch shift in semitones
///   - Use constants: kPitch432Hz, kPitch528Hz, kPitch639Hz
///
/// ## Example
///
/// ```dart
/// // Toggle 432Hz on/off
/// onPressed: () {
///   final currentPitch = ref.read(currentPitchShiftProvider);
///   final newPitch = currentPitch == 0.0 ? kPitch432Hz : 0.0;
///   ref.read(changePitchShiftProvider)(newPitch);
/// }
/// ```
@riverpod
Future<void> Function(double semitones) changePitchShift(
  ChangePitchShiftRef ref,
) {
  return (double semitones) async {
    final repository = await ref.read(playerRepositoryProvider.future);
    await repository.setPitchShift(semitones);
    ref.invalidate(currentPitchShiftProvider);
  };
}

/// Action: Change playback speed.
///
/// ## Parameters
///
/// - [speed]: Speed multiplier (0.5 - 2.0)
///
/// ## Example
///
/// ```dart
/// onPressed: () => ref.read(changeSpeedProvider)(0.8),
/// ```
@riverpod
Future<void> Function(double speed) changeSpeed(ChangeSpeedRef ref) {
  return (double speed) async {
    final repository = await ref.read(playerRepositoryProvider.future);
    await repository.setSpeed(speed);
    ref.invalidate(currentSpeedProvider);
  };
}

/// Action: Change volume.
///
/// ## Parameters
///
/// - [volume]: Volume level (0.0 - 1.0)
///
/// ## Example
///
/// ```dart
/// Slider(
///   value: volume,
///   onChanged: (value) => ref.read(changeVolumeProvider)(value),
/// );
/// ```
@riverpod
Future<void> Function(double volume) changeVolume(ChangeVolumeRef ref) {
  return (double volume) async {
    final repository = await ref.read(playerRepositoryProvider.future);
    await repository.setVolume(volume);
  };
}

/// Action: Toggle favorite status.
///
/// ## Parameters
///
/// - [id]: Audio file ID
///
/// ## Example
///
/// ```dart
/// IconButton(
///   icon: Icon(
///     audioFile.isFavorite ? Icons.favorite : Icons.favorite_border,
///   ),
///   onPressed: () => ref.read(toggleFavoriteActionProvider)(audioFile.id),
/// );
/// ```
@riverpod
Future<void> Function(String id) toggleFavoriteAction(
  ToggleFavoriteActionRef ref,
) {
  return (String id) async {
    final repository = await ref.read(playerRepositoryProvider.future);
    await repository.toggleFavorite(id);

    // Refresh library providers
    ref.invalidate(audioLibraryProvider);
    ref.invalidate(favoritesLibraryProvider);
  };
}

/// Action: Record a play event.
///
/// Increments play count and updates last played timestamp.
///
/// ## Parameters
///
/// - [id]: Audio file ID
///
/// ## Example
///
/// ```dart
/// // Call when track finishes or user plays >50%
/// ref.read(recordPlayActionProvider)(audioFile.id);
/// ```
@riverpod
Future<void> Function(String id) recordPlayAction(RecordPlayActionRef ref) {
  return (String id) async {
    final repository = await ref.read(playerRepositoryProvider.future);
    await repository.recordPlay(id);

    // Refresh library providers
    ref.invalidate(audioLibraryProvider);
    ref.invalidate(mostPlayedProvider);
  };
}

/// Action: Scan and import music library.
///
/// Scans device storage for music files and imports new ones.
///
/// ## Parameters
///
/// - [onProgress]: Optional progress callback `(current, total)`
/// - [extractAlbumArt]: Whether to extract album art (default: true)
///
/// ## Example
///
/// ```dart
/// ElevatedButton(
///   onPressed: () async {
///     await ref.read(scanLibraryActionProvider)(
///       onProgress: (current, total) {
///         print('Scanning: $current / $total');
///       },
///     );
///
///     // Refresh library
///     ref.invalidate(audioLibraryProvider);
///   },
///   child: Text('Scan Library'),
/// );
/// ```
@riverpod
Future<int> Function({
  void Function(int current, int total)? onProgress,
  bool extractAlbumArt,
}) scanLibraryAction(ScanLibraryActionRef ref) {
  return ({
    void Function(int current, int total)? onProgress,
    bool extractAlbumArt = true,
  }) async {
    final repository = await ref.read(playerRepositoryProvider.future);

    final newFilesCount = await repository.scanAndImportLibrary(
      onProgress: onProgress,
      extractAlbumArt: extractAlbumArt,
    );

    // Refresh all library providers
    ref.invalidate(audioLibraryProvider);
    ref.invalidate(recentlyAddedProvider);

    return newFilesCount;
  };
}

/// Action: Import files manually via file picker.
///
/// ## Parameters
///
/// - [allowMultiple]: Allow multiple file selection (default: true)
/// - [extractAlbumArt]: Extract album artwork (default: true)
///
/// ## Example
///
/// ```dart
/// ElevatedButton(
///   onPressed: () async {
///     final count = await ref.read(importFilesActionProvider)();
///     print('Imported $count files');
///   },
///   child: Text('Import Files'),
/// );
/// ```
@riverpod
Future<int> Function({
  bool allowMultiple,
  bool extractAlbumArt,
}) importFilesAction(ImportFilesActionRef ref) {
  return ({
    bool allowMultiple = true,
    bool extractAlbumArt = true,
  }) async {
    final repository = await ref.read(playerRepositoryProvider.future);

    final count = await repository.importFiles(
      allowMultiple: allowMultiple,
      extractAlbumArt: extractAlbumArt,
    );

    // Refresh library
    ref.invalidate(audioLibraryProvider);
    ref.invalidate(recentlyAddedProvider);

    return count;
  };
}

/// Action: Remove audio file from library.
///
/// ## Parameters
///
/// - [id]: Audio file ID
///
/// ## Example
///
/// ```dart
/// onPressed: () {
///   ref.read(removeFromLibraryActionProvider)(audioFile.id);
/// }
/// ```
@riverpod
Future<void> Function(String id) removeFromLibraryAction(
  RemoveFromLibraryActionRef ref,
) {
  return (String id) async {
    final repository = await ref.read(playerRepositoryProvider.future);
    await repository.removeFromLibrary(id);

    // Refresh library
    ref.invalidate(audioLibraryProvider);
  };
}
