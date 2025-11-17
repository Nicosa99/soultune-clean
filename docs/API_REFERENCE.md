# SoulTune API Reference

## Core Services

### AudioPlayerService

**Location:** `lib/shared/services/audio/audio_player_service.dart`

Core audio playback engine with 432Hz frequency transformation.

```dart
class AudioPlayerService {
  // Initialization
  Future<void> init();
  Future<void> dispose();

  // Playback Control
  Future<void> play([AudioFile? audioFile, double pitchShift = 0.0, Duration? startPosition]);
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);

  // Frequency Transformation
  Future<void> setPitchShift(double semitones);
  // Constants: kPitch432Hz, kPitch528Hz, kPitch639Hz

  // Speed Control
  Future<void> setSpeed(double speed); // 0.5 - 2.0
  Future<void> setVolume(double volume); // 0.0 - 1.0

  // Playlist Management
  void setPlaylist(List<AudioFile> playlist, {int startIndex = 0});
  Future<bool> playNext({double pitchShift = 0.0});
  Future<bool> playPrevious({double pitchShift = 0.0});
  Future<void> restartPlaylist({double pitchShift = 0.0});

  // Getters
  bool get isPlaying;
  bool get isInitialized;
  Duration get position;
  Duration? get duration;
  AudioFile? get currentAudioFile;
  double get currentPitchShift;
  double get currentSpeed;

  // Streams
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;
  Stream<bool> get playingStream;
  Stream<PlayerState> get playerStateStream;
  Stream<void> get trackCompletedStream;
}
```

**Example:**
```dart
final player = AudioPlayerService();
await player.init();

// Play with 432Hz transformation
await player.play(audioFile, kPitch432Hz);

// Listen to position updates
player.positionStream.listen((position) {
  print('Position: ${position.inSeconds}s');
});
```

---

### PlayerRepository

**Location:** `lib/features/player/data/repositories/player_repository.dart`

Business logic coordinator for player feature.

```dart
class PlayerRepository {
  // Initialization
  Future<void> init();
  Future<void> dispose();

  // Library Management
  Future<int> scanAndImportLibrary({
    void Function(int current, int total)? onProgress,
    bool extractAlbumArt = true,
  });
  Future<int> importFiles({bool allowMultiple = true});
  Future<void> removeFromLibrary(String id);
  Future<void> clearLibrary();

  // Library Queries
  Future<List<AudioFile>> getAllAudioFiles();
  Future<AudioFile?> getAudioFile(String id);
  Future<List<AudioFile>> getFavorites();
  Future<List<AudioFile>> getRecentlyAdded({int limit = 20});
  Future<List<AudioFile>> getMostPlayed({int limit = 20});
  Future<List<AudioFile>> searchAudioFiles(String query);

  // Playback Control (with notification sync)
  Future<void> playAudioFile(AudioFile audioFile, {
    double pitchShift = 0.0,
    Duration? startPosition,
  });
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> seek(Duration position);

  // Frequency & Speed
  Future<void> setPitchShift(double semitones);
  Future<void> setSpeed(double speed);
  Future<void> setVolume(double volume);

  // User Actions
  Future<AudioFile> toggleFavorite(String id);
  Future<AudioFile> recordPlay(String id);

  // Playlist & Loop
  void setPlaylist(List<AudioFile> playlist, {int startIndex = 0});
  void setLoopMode(LoopMode mode);
  Future<bool> playNext();
  Future<bool> playPrevious();

  // Getters
  bool get isPlaying;
  Duration get position;
  Duration? get duration;
  AudioFile? get currentAudioFile;
  double get currentPitchShift;
  double get currentSpeed;
  LoopMode get loopMode;

  // Streams
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;
  Stream<bool> get playingStream;
  Stream<List<AudioFile>> get libraryStream;
}
```

**Example:**
```dart
final repo = PlayerRepository();
await repo.init();

// Scan library
final newFiles = await repo.scanAndImportLibrary(
  onProgress: (current, total) {
    print('Scanning: $current/$total');
  },
);
print('Added $newFiles new tracks');

// Play with 432Hz
final files = await repo.getAllAudioFiles();
await repo.playAudioFile(files.first, pitchShift: kPitch432Hz);

// Toggle favorite
await repo.toggleFavorite(files.first.id);
```

---

### HiveAudioDataSource

**Location:** `lib/features/player/data/datasources/hive_audio_datasource.dart`

Local storage CRUD operations.

```dart
class HiveAudioDataSource {
  Future<void> init();
  Future<void> dispose();

  // CRUD
  Future<void> saveAudioFile(AudioFile file);
  Future<void> saveAudioFiles(List<AudioFile> files);
  Future<AudioFile?> getAudioFile(String id);
  Future<List<AudioFile>> getAllAudioFiles();
  Future<void> deleteAudioFile(String id);
  Future<void> clearLibrary();

  // Queries
  Future<List<AudioFile>> getFavorites();
  Future<List<AudioFile>> getRecentlyAdded({int limit = 20});
  Future<List<AudioFile>> getMostPlayed({int limit = 20});
  Future<List<AudioFile>> searchAudioFiles(String query);
  Future<int> getAudioFileCount();

  // User Actions
  Future<AudioFile> toggleFavorite(String id);
  Future<AudioFile> incrementPlayCount(String id);

  // Reactive
  Stream<List<AudioFile>> watchLibrary();
}
```

---

### FileSystemService

**Location:** `lib/shared/services/file/file_system_service.dart`

Music file scanner with metadata extraction.

```dart
class FileSystemService {
  Future<void> init();
  Future<void> dispose();

  Future<List<AudioFile>> scanMusicLibrary({
    void Function(int current, int total)? onProgress,
    bool extractAlbumArt = true,
  });

  Future<List<AudioFile>> pickAudioFiles({
    bool allowMultiple = true,
    bool extractAlbumArt = true,
  });
}
```

---

## Riverpod Providers

**Location:** `lib/features/player/presentation/providers/player_providers.dart`

### Core Providers

```dart
// Repository instance (singleton)
final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  final repo = PlayerRepository();
  ref.onDispose(() => repo.dispose());
  return repo;
});

// Current audio file
final currentAudioFileProvider = Provider<AudioFile?>((ref) {
  return ref.watch(playerRepositoryProvider).currentAudioFile;
});

// Playing state
final isPlayingProvider = StreamProvider<bool>((ref) {
  return ref.watch(playerRepositoryProvider).playingStream;
});

// Position stream
final positionStreamProvider = StreamProvider<Duration>((ref) {
  return ref.watch(playerRepositoryProvider).positionStream;
});

// Duration stream
final durationStreamProvider = StreamProvider<Duration?>((ref) {
  return ref.watch(playerRepositoryProvider).durationStream;
});

// Current pitch shift
final currentPitchShiftProvider = Provider<double>((ref) {
  return ref.watch(playerRepositoryProvider).currentPitchShift;
});

// Loop mode
final loopModeProvider = Provider<LoopMode>((ref) {
  return ref.watch(playerRepositoryProvider).loopMode;
});

// Library stream
final libraryStreamProvider = StreamProvider<List<AudioFile>>((ref) {
  return ref.watch(playerRepositoryProvider).libraryStream;
});
```

### Action Providers

```dart
// Play action
final playActionProvider = Provider<Future<void> Function(AudioFile, {double pitchShift})>((ref) {
  return (audioFile, {double pitchShift = 0.0}) async {
    await ref.read(playerRepositoryProvider).playAudioFile(
      audioFile,
      pitchShift: pitchShift,
    );
  };
});

// Pause action
final pauseActionProvider = Provider<Future<void> Function()>((ref) {
  return () => ref.read(playerRepositoryProvider).pause();
});

// Resume action
final resumeActionProvider = Provider<Future<void> Function()>((ref) {
  return () => ref.read(playerRepositoryProvider).resume();
});

// Toggle favorite action
final toggleFavoriteActionProvider = Provider<Future<AudioFile> Function(String)>((ref) {
  return (id) => ref.read(playerRepositoryProvider).toggleFavorite(id);
});

// Set pitch shift action
final setPitchShiftActionProvider = Provider<Future<void> Function(double)>((ref) {
  return (semitones) => ref.read(playerRepositoryProvider).setPitchShift(semitones);
});

// Scan library action
final scanLibraryActionProvider = Provider<Future<int> Function({void Function(int, int)?})>((ref) {
  return ({onProgress}) => ref.read(playerRepositoryProvider).scanAndImportLibrary(
    onProgress: onProgress,
  );
});
```

---

## Data Models

### AudioFile

**Location:** `lib/shared/models/audio_file.dart`

```dart
class AudioFile {
  final String id;
  final String filePath;
  final String title;
  final String? artist;
  final String? album;
  final String? albumArt;  // File path to extracted album art
  final Duration duration;
  final DateTime dateAdded;
  final DateTime? lastPlayed;
  final int playCount;
  final bool isFavorite;

  // Constructor
  AudioFile({
    required this.id,
    required this.filePath,
    required this.title,
    this.artist,
    this.album,
    this.albumArt,
    required this.duration,
    required this.dateAdded,
    this.lastPlayed,
    this.playCount = 0,
    this.isFavorite = false,
  });

  // CopyWith
  AudioFile copyWith({...});

  // JSON serialization
  factory AudioFile.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

### Playlist

**Location:** `lib/shared/models/playlist.dart`

```dart
class Playlist {
  final String id;
  final String name;
  final String? description;
  final List<String> audioFileIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Playlist({...});
  Playlist copyWith({...});
  factory Playlist.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

### FrequencySetting

**Location:** `lib/shared/models/frequency_setting.dart`

```dart
class FrequencySetting {
  final String id;
  final double targetHz;
  final String displayName;
  final String description;
  final double pitchShift;
  final bool isPremium;
  final Color color;

  const FrequencySetting({...});
}

// Predefined settings
const frequencySettings = [
  FrequencySetting(
    id: '440',
    targetHz: 440.0,
    displayName: '440 Hz - Standard',
    pitchShift: 0.0,
    isPremium: false,
  ),
  FrequencySetting(
    id: '432',
    targetHz: 432.0,
    displayName: '432 Hz - Deep Peace',
    pitchShift: -0.31767,
    isPremium: false,
  ),
  // ... 528Hz, 639Hz (premium)
];
```

### LoopMode

**Location:** `lib/shared/models/loop_mode.dart`

```dart
enum LoopMode {
  off,   // Play through playlist once
  one,   // Repeat current track
  all,   // Repeat entire playlist
}

extension LoopModeExtension on LoopMode {
  String get displayName;
  IconData get icon;
  LoopMode get next;
}
```

---

## Constants

### Frequency Constants

**Location:** `lib/app/constants/frequencies.dart`

```dart
/// Standard tuning (A4 = 440 Hz)
const double kPitchStandard = 0.0;

/// 432 Hz - Deep Peace & Harmony (FREE)
const double kPitch432Hz = -0.31767;

/// 528 Hz - Love & Healing (PREMIUM)
const double kPitch528Hz = 0.37851;

/// 639 Hz - Relationships (PREMIUM)
const double kPitch639Hz = 0.69877;

/// Calculate pitch shift for any frequency
double calculatePitchShift({required double targetHz, double standardHz = 440.0}) {
  return 12 * (log(targetHz / standardHz) / log(2));
}
```

---

## Exception Types

**Location:** `lib/shared/exceptions/app_exceptions.dart`

```dart
abstract class AppException implements Exception {
  final String message;
  final dynamic cause;
}

class AudioException extends AppException {...}
class FileException extends AppException {...}
class StorageException extends AppException {...}
class PermissionException extends AppException {...}
class NetworkException extends AppException {...}
```

---

## Widget Usage Examples

### MiniPlayer

```dart
MiniPlayer(
  onTap: () {
    // Show Now Playing modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const NowPlayingScreen(),
    );
  },
)
```

### FrequencySelector

```dart
FrequencySelector(
  currentPitchShift: kPitch432Hz,
  onFrequencyChanged: (newPitch) async {
    await ref.read(setPitchShiftActionProvider)(newPitch);
  },
)
```

### SeekBar

```dart
SeekBar(
  position: position,
  duration: duration,
  onSeek: (newPosition) async {
    await ref.read(playerRepositoryProvider).seek(newPosition);
  },
)
```

### PlayerControls

```dart
PlayerControls(
  isPlaying: true,
  onPrevious: () => ref.read(playerRepositoryProvider).playPrevious(),
  onPlayPause: () => ref.read(pauseActionProvider)(),
  onNext: () => ref.read(playerRepositoryProvider).playNext(),
  onLoopModeChanged: (mode) => ref.read(playerRepositoryProvider).setLoopMode(mode),
)
```

---

## Notification Service (EXPERIMENTAL)

**Location:** `lib/shared/services/audio/notification_service.dart`

```dart
class NotificationService {
  static bool get isInitialized;
  static SoulTuneAudioHandler get audioHandler;

  static Future<void> init();
}
```

**Location:** `lib/shared/services/audio/audio_service_integration.dart`

```dart
class AudioServiceIntegration {
  static Future<void> playAudioFile(
    AudioFile audioFile,
    AudioPlayerService audioPlayerService, {
    double pitchShift = 0.0,
  });

  static void setPlaylist(
    List<AudioFile> playlist,
    AudioPlayerService audioPlayerService, {
    int startIndex = 0,
  });

  static Future<void> pause(AudioPlayerService audioPlayerService);
  static Future<void> resume(AudioPlayerService audioPlayerService);
  static Future<void> stop(AudioPlayerService audioPlayerService);
  static Future<void> updatePitchShift(double semitones, AudioPlayerService audioPlayerService);
}
```

**Note:** NotificationService is currently blocked by Android configuration issues. The integration layer is ready but disabled.

---

*Last updated: 2025-11-17*
