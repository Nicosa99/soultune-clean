# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development Commands

```bash
# Get dependencies
flutter pub get

# Generate code (freezed, riverpod, json_serializable) - REQUIRED after model changes
dart run build_runner build --delete-conflicting-outputs

# Watch mode for continuous code generation
dart run build_runner watch --delete-conflicting-outputs

# Analyze code (strict mode enabled - will fail CI if issues found)
flutter analyze

# Format code (enforced: 80 char lines, trailing commas, single quotes)
dart format .

# Run app
flutter run

# Build release
flutter build apk --release
flutter build ios --release
```

## Architecture Overview

Feature-first clean architecture with Riverpod state management:

```
lib/
├── main.dart                           # Entry: Hive init, NotificationService init
├── app/constants/frequencies.dart      # Frequency preset definitions (kPitch432Hz, etc.)
├── features/
│   ├── player/
│   │   ├── data/repositories/player_repository.dart  # Business logic layer
│   │   └── presentation/
│   │       ├── providers/player_providers.dart       # Riverpod state (@riverpod)
│   │       ├── screens/now_playing_screen.dart
│   │       └── widgets/                              # player_controls, seek_bar, frequency_selector
│   ├── library/presentation/screens/library_screen.dart
│   └── playlist/                                     # Playlist management feature
└── shared/
    ├── models/                         # Freezed data models + Hive adapters
    │   ├── audio_file.dart             # Core audio file model
    │   └── hive_adapters.dart          # Hive type adapters
    ├── services/
    │   ├── audio/
    │   │   ├── audio_player_service.dart    # just_audio wrapper with pitch shift
    │   │   ├── notification_service.dart    # System media controls (audio_service)
    │   │   └── metadata_service.dart        # ID3 tag extraction
    │   ├── storage/hive_service.dart        # Local database
    │   └── file/                            # File system & permissions
    ├── theme/                          # Material 3 dark theme
    └── exceptions/app_exceptions.dart  # AudioException, FileException, etc.
```

### Data Flow

```
UI Widgets (ConsumerWidget)
    ↓ watch/read
Providers (player_providers.dart - @riverpod generated)
    ↓
PlayerRepository (business logic)
    ↓
Services (AudioPlayerService, HiveService, etc.)
```

## Critical: Frequency Transformation

Core feature is real-time pitch shifting from 440Hz to healing frequencies:

```dart
// Mathematical formula: semitones = 12 × log₂(target / 440)
const double kPitch432Hz = -0.31767;  // 432 Hz - Deep Peace (FREE)
const double kPitch528Hz = 0.37851;   // 528 Hz - Love Frequency (PREMIUM)
const double kPitch639Hz = 0.69877;   // 639 Hz - Relationships (PREMIUM)

// Implementation in AudioPlayerService (lib/shared/services/audio/audio_player_service.dart:601)
// Convert semitones to playback rate: rate = 2^(semitones / 12)
double _semitoneToRate(double semitones) {
  return math.pow(2, semitones / 12).toDouble();
}

// Applied via just_audio's native pitch API
await _player.setPitch(_semitoneToRate(semitones));
```

## Code Patterns

### Riverpod with Code Generation

All providers use `@riverpod` annotation and require code generation:

```dart
// Stream provider (lib/features/player/presentation/providers/player_providers.dart)
@riverpod
Stream<bool> isPlaying(IsPlayingRef ref) async* {
  final repository = await ref.watch(playerRepositoryProvider.future);
  yield repository.isPlaying;
  yield* repository.playingStream;
}

// Action provider pattern - returns a function
@riverpod
Future<void> Function() togglePlayPause(TogglePlayPauseRef ref) {
  return () async {
    final repository = await ref.read(playerRepositoryProvider.future);
    if (repository.isPlaying) {
      await repository.pause();
    } else {
      await repository.resume();
    }
  };
}
```

After modifying any `@riverpod`, `@freezed`, or `@JsonSerializable` annotations, run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Freezed Data Models with Hive

Models require both Freezed generation AND Hive type adapters:

```dart
// Model definition (lib/shared/models/audio_file.dart)
@freezed
class AudioFile with _$AudioFile {
  @HiveType(typeId: 0)
  const factory AudioFile({
    @HiveField(0) required String id,
    @HiveField(1) required String filePath,
    // ...
  }) = _AudioFile;

  factory AudioFile.fromJson(Map<String, dynamic> json) => _$AudioFileFromJson(json);
}

// Hive adapter registration (lib/shared/models/hive_adapters.dart)
static void registerAdapters() {
  Hive.registerAdapter(AudioFileImplAdapter());
}
```

### Error Handling

Use custom exceptions from `lib/shared/exceptions/app_exceptions.dart`:

```dart
try {
  await audioPlayer.play(filePath);
} on PlayerException catch (e) {
  throw AudioException('Failed to play audio: ${e.message}', e);
} catch (e) {
  throw AudioException('Unexpected playback error', e);
}
```

## Important Constraints

### Strict Analysis Rules

The project enforces strict linting (`analysis_options.yaml`):
- `strict-casts: true`, `strict-inference: true`, `strict-raw-types: true`
- `lines_longer_than_80_chars` - Max 80 characters per line
- `public_member_api_docs` - All public APIs need doc comments
- `require_trailing_commas` - Required for multi-line
- `prefer_single_quotes` - Use single quotes for strings
- `avoid_print` - Use Logger package instead

### Don'ts

- **Never use setState** - Use Riverpod providers exclusively
- **Never use print()** - Use Logger package (`_logger.i()`, `_logger.e()`, etc.)
- **Never ignore disposal** - Dispose StreamSubscriptions, AudioPlayer in `dispose()`
- **Never block UI** - Use Isolates for metadata parsing, heavy file operations

### Platform Configuration

- **Android**: MainActivity must extend `FlutterFragmentActivity` (see `NOTIFICATION_SETUP.md`)
- **Permissions**: `READ_EXTERNAL_STORAGE`, `FOREGROUND_SERVICE`, `WAKE_LOCK`
- **iOS**: Background audio mode enabled, deployment target 12.0

## Key Files for Context

- `NOTIFICATION_SETUP.md` - Android media notification configuration
- `PERMISSIONS_SETUP.md` - Storage permission setup
- `PLAN.md` - Feature roadmap and implementation phases
- `lib/app/constants/frequencies.dart` - Frequency constants and presets
- `lib/features/player/presentation/providers/player_providers.dart` - All state management

## Git Commit Convention

Use conventional commits:
```
feat: add sleep timer functionality
fix: resolve audio interruption on incoming calls
refactor: simplify frequency selector state management
docs: update permission setup guide
```
