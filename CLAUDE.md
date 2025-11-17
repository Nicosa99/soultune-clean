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
├── main.dart                           # Entry: Hive init, NotificationService init, HomeScreen launch
├── app/constants/frequencies.dart      # Frequency preset definitions (kPitch432Hz, etc.)
├── features/
│   ├── home/                           # Main screen with bottom navigation
│   │   └── presentation/screens/home_screen.dart   # Entry point (Library, Playlists, Now Playing, Generator tabs)
│   ├── player/
│   │   ├── data/
│   │   │   ├── datasources/hive_audio_datasource.dart   # Hive CRUD for audio files
│   │   │   └── repositories/player_repository.dart      # Business logic layer
│   │   └── presentation/
│   │       ├── providers/player_providers.dart          # Riverpod state (@riverpod)
│   │       ├── screens/now_playing_screen.dart
│   │       └── widgets/                                 # player_controls, seek_bar, frequency_selector
│   ├── library/presentation/screens/library_screen.dart # Songs & Playlists tabs
│   ├── playlist/                                        # Playlist management feature
│   │   ├── data/datasources/hive_playlist_datasource.dart
│   │   └── presentation/                                # playlist screens, providers, widgets
│   ├── generator/                                       # ⭐ Frequency Generator (NEW)
│   │   ├── data/
│   │   │   ├── models/                                  # binaural_config, frequency_preset, waveform
│   │   │   │   ├── frequency_constants.dart             # Solfeggio (174-963Hz) & brainwave frequencies
│   │   │   │   ├── predefined_presets.dart              # CIA Gateway, OBE, meditation presets
│   │   │   │   └── preset_category.dart                 # Focus, Relaxation, Sleep, Astral, etc.
│   │   │   └── services/frequency_generator_service.dart # SoLoud-based real-time synthesis
│   │   ├── domain/panning_engine.dart                   # Adaptive L→R→L panning with brainwave sync
│   │   └── presentation/
│   │       ├── providers/generator_providers.dart       # Generator state management
│   │       ├── screens/generator_screen.dart            # Preset browser & player
│   │       ├── screens/custom_generator_screen.dart     # Custom frequency editor
│   │       ├── screens/binaural_editor_screen.dart      # Advanced binaural beat editor
│   │       └── widgets/                                 # waveform_visualizer, panning_indicator, preset_detail
│   ├── equalizer/                                       # Audio equalizer feature (future)
│   └── settings/                                        # App settings feature (future)
└── shared/
    ├── models/                         # Freezed data models + Hive adapters
    │   ├── audio_file.dart             # Core audio file model
    │   ├── playlist.dart               # Playlist model
    │   ├── frequency_setting.dart      # Frequency configuration
    │   ├── loop_mode.dart              # Playback loop mode enum
    │   ├── json_converters.dart        # Custom JSON converters for Freezed
    │   └── hive_adapters.dart          # Hive type adapters registration
    ├── services/
    │   ├── audio/
    │   │   ├── audio_player_service.dart        # just_audio wrapper with pitch shift
    │   │   ├── notification_service.dart        # System media controls (audio_service)
    │   │   ├── metadata_service.dart            # ID3 tag extraction
    │   │   ├── soultune_audio_handler.dart      # audio_service handler implementation
    │   │   └── audio_service_integration.dart   # Integrates audio_service with player
    │   ├── storage/hive_service.dart            # Local database initialization
    │   └── file/                                # File system & permissions
    ├── widgets/                        # Shared UI components (mini_player, etc.)
    ├── utils/                          # Formatters and utilities
    ├── theme/                          # Material 3 dark theme
    └── exceptions/app_exceptions.dart  # AudioException, FileException, etc.
```

### Data Flow

```
UI Widgets (ConsumerWidget)
    ↓ watch/read
Providers (player_providers.dart, playlist_providers.dart, generator_providers.dart - @riverpod generated)
    ↓
Repositories (business logic & domain rules)
    ↓
Datasources (HiveAudioDataSource, HivePlaylistDataSource - data access)
    ↓
Services (AudioPlayerService, FrequencyGeneratorService, HiveService, FileSystemService, etc.)
```

**Note**: Not all features have the full data/domain/presentation split yet. The player, playlist, and generator features follow clean architecture; other features may have simplified structures.

## Critical: Frequency Transformation

### 1. Audio File Pitch Shifting (Player Feature)

Real-time pitch shifting from 440Hz to healing frequencies:

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

### 2. Frequency Generator (NEW - Real-time Synthesis)

Direct frequency synthesis using SoLoud engine:

```dart
// Solfeggio Frequencies (lib/features/generator/data/models/frequency_constants.dart)
const double kSolfeggio174Hz = 174.0;  // Pain Relief & Grounding
const double kSolfeggio285Hz = 285.0;  // Cellular Healing
const double kSolfeggio396Hz = 396.0;  // Liberating Guilt & Fear (Root Chakra)
const double kSolfeggio417Hz = 417.0;  // Facilitating Change (Sacral Chakra)
const double kSolfeggio528Hz = 528.0;  // DNA Repair (Solar Plexus) - MIRACLE FREQUENCY
const double kSolfeggio639Hz = 639.0;  // Relationships (Heart Chakra)
const double kSolfeggio741Hz = 741.0;  // Awakening Intuition (Throat Chakra)
const double kSolfeggio852Hz = 852.0;  // Spiritual Awareness (Third Eye Chakra)
const double kSolfeggio963Hz = 963.0;  // Enlightenment (Crown Chakra)

// Brainwave Frequencies
// Delta (0.5-4 Hz): Deep Sleep, Physical Healing
// Theta (4-8 Hz): Meditation, Deep Relaxation, Creativity
// Alpha (8-14 Hz): Relaxed Focus, Learning
// Beta (14-30 Hz): Active Thinking, Concentration
// Gamma (30-100 Hz): Peak Performance, Transcendence

// Binaural Beats: Different frequency in each ear creates perceived beat
// Example: Left 200Hz + Right 207Hz = 7Hz Theta binaural beat
```

**Frequency Generator Features:**
- **Real-time synthesis**: SoLoud engine generates pure tones (sine/square/triangle/sawtooth)
- **Binaural beats**: Different frequencies per channel for brainwave entrainment
- **Adaptive panning**: L→R→L modulation synchronized with brainwave frequencies
- **Predefined presets**: CIA Gateway, OBE (Out-of-Body Experience), Focus, Sleep, Meditation
- **Custom editor**: Create and save custom frequency combinations
- **Waveform visualization**: Real-time audio waveform display

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

### Custom JSON Converters (for Freezed with complex types)

When Freezed models have non-primitive types, use custom converters:

```dart
// lib/shared/models/json_converters.dart
class WaveformConverter implements JsonConverter<Waveform, String> {
  const WaveformConverter();

  @override
  Waveform fromJson(String json) => Waveform.values.byName(json);

  @override
  String toJson(Waveform object) => object.name;
}

// Usage in model
@freezed
class FrequencyLayer with _$FrequencyLayer {
  const factory FrequencyLayer({
    required double frequency,
    @WaveformConverter() required Waveform waveform,
  }) = _FrequencyLayer;
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

## Testing

Testing infrastructure is configured but tests are not yet implemented:

- **Unit tests**: Use `flutter test` (mockito configured in pubspec.yaml)
- **Integration tests**: Use `flutter test integration_test/` (integration_test package available)
- **Test location**: Create test files as `test/**/*_test.dart` or `integration_test/**/*_test.dart`
- **Mocking**: Use mockito for mocking services and repositories

When writing tests:
- Mock external dependencies (file system, audio player, Hive, SoLoud)
- Test Riverpod providers using ProviderContainer
- Use `flutter test --coverage` to generate coverage reports

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
- **Never ignore disposal** - Dispose StreamSubscriptions, AudioPlayer, SoLoud in `dispose()`
- **Never block UI** - Use Isolates for metadata parsing, heavy file operations

### Platform Configuration

- **Android**: MainActivity must extend `FlutterFragmentActivity` (see `NOTIFICATION_SETUP.md`)
- **Permissions**: `READ_EXTERNAL_STORAGE`, `FOREGROUND_SERVICE`, `WAKE_LOCK`
- **iOS**: Background audio mode enabled, deployment target 12.0

## Key Files for Context

- `NOTIFICATION_SETUP.md` - Android media notification configuration
- `PERMISSIONS_SETUP.md` - Storage permission setup
- `PLAN.md` - Feature roadmap and implementation phases
- `ANDROID_V2_FIX.md` - Android v2 embedding migration fixes
- `lib/app/constants/frequencies.dart` - Frequency constants for pitch shifting
- `lib/features/player/presentation/providers/player_providers.dart` - Player state management
- `lib/features/playlist/presentation/providers/playlist_providers.dart` - Playlist state management
- `lib/features/generator/presentation/providers/generator_providers.dart` - Generator state management
- `lib/features/generator/data/models/frequency_constants.dart` - Solfeggio & brainwave frequencies
- `lib/features/generator/data/models/predefined_presets.dart` - All preset definitions
- `lib/features/generator/data/services/frequency_generator_service.dart` - SoLoud synthesis engine
- `lib/features/generator/domain/panning_engine.dart` - Adaptive panning algorithm
- `lib/features/home/presentation/screens/home_screen.dart` - Main app entry with bottom navigation
- `lib/shared/widgets/mini_player.dart` - Persistent mini player UI (shown on Library/Playlists tabs)

## Git Commit Convention

Use conventional commits:
```
feat: add sleep timer functionality
fix: resolve audio interruption on incoming calls
refactor: simplify frequency selector state management
docs: update permission setup guide
```
