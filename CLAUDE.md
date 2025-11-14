# SoulTune - 432Hz Music Player 🎵✨

## Project Overview
SoulTune transforms your music library to healing frequencies (432Hz, 528Hz) in real-time. Built with Flutter for Android and iOS, targeting wellness, meditation, and spiritual music communities. The app reads local audio files and applies pitch-shift transformation without quality loss.

**Market Position**: Premium alternative to basic 432 Hz players with modern UX, advanced features, and freemium monetization.

## Tech Stack
- **Framework**: Flutter 3.24+ / Dart 3.5+
- **Audio Engine**: just_audio ^0.9.36 (MIT License)
- **State Management**: Riverpod 2.5+ with code generation
- **Database**: Hive 2.2+ (Apache 2.0 - NoSQL for local storage)
- **Metadata**: metadata_god ^0.3.0
- **Audio Processing**: Native pitch-shift via just_audio (no external DSP)
- **File Management**: file_picker, path_provider, permission_handler

## Core Feature: Real-Time Frequency Transformation

### Mathematical Foundation
// Standard tuning: 440 Hz (A4)
// Target: 432 Hz (8 Hz lower, the "healing frequency")

// Formula: Pitch shift in semitones = 12 * log2(target/standard)
// 432/440 = 0.98181818... = -0.31767 semitones

const double PITCH_432_HZ = -0.31767; // Deep Peace & Harmony
const double PITCH_528_HZ = 0.37851; // Love & Healing (premium)
const double PITCH_639_HZ = 0.69877; // Relationships (premium)


### Implementation Strategy
- Use `just_audio`'s native pitch-shift (no quality loss)
- Apply transformation in real-time during playback
- Support all audio formats: MP3, FLAC, WAV, AAC, OGG
- Zero latency toggle between frequencies
- Preserve original files (non-destructive)

## Architecture: Feature-First Clean Architecture

lib/
├── main.dart # Entry point
├── app/
│ ├── config/
│ │ ├── app_config.dart # Constants, API keys
│ │ └── themes.dart # Material 3 themes
│ ├── constants/
│ │ ├── frequencies.dart # Frequency presets
│ │ └── audio_formats.dart # Supported formats
│ └── routes/
│ └── app_router.dart # go_router navigation
│
├── features/
│ ├── player/ # Audio playback & controls
│ │ ├── data/
│ │ │ ├── models/
│ │ │ │ └── audio_file_model.dart
│ │ │ ├── datasources/
│ │ │ │ └── hive_audio_source.dart
│ │ │ └── repositories/
│ │ │ └── player_repository.dart
│ │ ├── domain/
│ │ │ └── entities/
│ │ ├── presentation/
│ │ │ ├── screens/
│ │ │ │ └── now_playing_screen.dart
│ │ │ ├── widgets/
│ │ │ │ ├── player_controls.dart
│ │ │ │ ├── frequency_selector.dart
│ │ │ │ ├── visualizer.dart
│ │ │ │ └── seek_bar.dart
│ │ │ └── providers/
│ │ │ └── player_providers.dart
│ │ └── player_feature.dart
│ │
│ ├── library/ # Music library & playlists
│ │ ├── data/
│ │ ├── domain/
│ │ ├── presentation/
│ │ │ ├── screens/
│ │ │ │ └── library_screen.dart
│ │ │ └── widgets/
│ │ └── library_feature.dart
│ │
│ ├── equalizer/ # 10-band EQ (premium)
│ │ ├── data/
│ │ ├── domain/
│ │ ├── presentation/
│ │ └── equalizer_feature.dart
│ │
│ └── settings/ # App settings
│ ├── data/
│ ├── domain/
│ ├── presentation/
│ └── settings_feature.dart
│
├── shared/
│ ├── models/
│ │ ├── audio_file.dart # freezed
│ │ ├── playlist.dart # freezed
│ │ ├── frequency_setting.dart # freezed
│ │ └── equalizer_preset.dart # freezed
│ │
│ ├── services/
│ │ ├── audio/
│ │ │ ├── audio_player_service.dart # just_audio wrapper
│ │ │ ├── metadata_service.dart # ID3 tags
│ │ │ └── visualizer_service.dart # FFT analysis
│ │ ├── file/
│ │ │ ├── file_system_service.dart
│ │ │ └── permission_service.dart
│ │ └── storage/
│ │ └── hive_service.dart
│ │
│ ├── utils/
│ │ ├── extensions/
│ │ │ ├── duration_ext.dart
│ │ │ └── string_ext.dart
│ │ └── formatters/
│ │
│ ├── theme/
│ │ ├── app_colors.dart
│ │ ├── app_text_styles.dart
│ │ └── app_theme.dart
│ │
│ ├── widgets/
│ │ └── common_widgets.dart
│ │
│ └── exceptions/
│ └── app_exceptions.dart
│
└── l10n/
├── app_en.arb # English
├── app_de.arb # German
└── app_fr.arb # French

text

## Coding Standards

### Dart Style
- Use `dart format` for all files
- Enable ALL lints from `analysis_options.yaml`
- Prefer `const` constructors wherever possible
- Use trailing commas for better formatting
- Max line length: 80 characters

### Naming Conventions
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/Functions: `camelCase`
- Private: `_leadingUnderscore`
- Constants: `kConstantName` or `SCREAMING_SNAKE_CASE`

### State Management with Riverpod
// Use @riverpod annotation with code generation
@riverpod
class PlayerState extends _$PlayerState {
@override
FutureOr<AudioFile?> build() async {
return null;
}
}

// Always use AutoDispose unless explicitly needed
@riverpod
Stream<Duration> audioPosition(AudioPositionRef ref) {
final player = ref.watch(audioPlayerProvider);
return player.positionStream;
}

// Name providers clearly: [feature][Purpose]Provider
final currentFrequencyProvider = StateProvider<FrequencySetting>(...);
final playlistsProvider = FutureProvider<List<Playlist>>(...);

text

### Data Models with Freezed
@freezed
class AudioFile with _$AudioFile {
const factory AudioFile({
required String id,
required String filePath,
required String title,
String? artist,
String? album,
String? albumArt,
required Duration duration,
required DateTime dateAdded,
@Default(0) int playCount,
}) = _AudioFile;

factory AudioFile.fromJson(Map<String, dynamic> json) =>
_$AudioFileFromJson(json);
}

text

### Error Handling
// Always wrap async calls in try-catch
try {
await audioPlayer.play(filePath);
} on AudioException catch (e) {
logger.e('Audio playback failed: ${e.message}');
throw PlayerException('Failed to play audio: ${e.message}');
} catch (e) {
logger.e('Unexpected error: $e');
throw UnknownException('An unexpected error occurred');
}

// Use custom exceptions (see shared/exceptions/)
class PlayerException implements Exception {
final String message;
PlayerException(this.message);
}

text

### Performance Best Practices
- Use `const` constructors aggressively
- `ListView.builder` for long lists (never `ListView`)
- Cache album art with `cached_network_image`
- Dispose audio players properly in `dispose()`
- Use Isolates for heavy operations (metadata parsing)
- Debounce search queries (300ms)

### Testing Requirements
- Unit tests for all services
- Widget tests for critical UI components
- Mock audio player with Mockito
- Test coverage goal: 70%+

## Current Phase: MVP (Week 1-2)

**Goal**: Functional music player with 432Hz transformation

### MVP Features
- [ ] Local music file scanning (MP3, FLAC, WAV)
- [ ] Basic Now Playing screen
- [ ] Play/Pause/Skip controls
- [ ] Seek bar with time display
- [ ] **432Hz pitch-shift toggle**
- [ ] Simple playlist (recently added)
- [ ] Favorites marking
- [ ] Background playback
- [ ] Hive database for persistence

### Out of Scope (MVP)
- ❌ Equalizer (Phase 2)
- ❌ Multiple frequencies (Phase 2)
- ❌ Visualizer (Phase 2)
- ❌ Cloud sync (Phase 3)
- ❌ Streaming services (Future)

## Key Implementation Details

### 432Hz Pitch Shift Service
class AudioPlayerService {
final AudioPlayer _player = AudioPlayer();
double _currentPitchShift = 0.0;

Future<void> play(String filePath, {double pitchShift = 0.0}) async {
await _player.setAudioSource(AudioSource.file(filePath));
await _player.setPitch(1.0 + (pitchShift / 12.0));
await _player.play();
}

Future<void> setPitchShift(double semitones) async {
_currentPitchShift = semitones;
await _player.setPitch(1.0 + (semitones / 12.0));
}
}

text

### Frequency Presets
const frequencySettings = [
FrequencySetting(
id: '432',
targetHz: 432.0,
displayName: '432 Hz - Deep Peace',
description: 'Natural tuning for harmony and healing',
pitchShift: -0.31767,
isPremium: false,
color: Color(0xFF6366F1),
),
FrequencySetting(
id: '528',
targetHz: 528.0,
displayName: '528 Hz - Love Frequency',
description: 'Transformation and miracles',
pitchShift: 0.37851,
isPremium: true,
color: Color(0xFF06B6D4),
),
];

text

## Monetization Strategy

### Free Tier
- 432 Hz (standard frequency)
- Basic player controls
- Up to 3 playlists
- Ads (banner, respectful placement)

### Premium ($2.99 one-time)
- ✓ Ad-free experience
- ✓ 528 Hz + 639 Hz + more frequencies
- ✓ 10-band equalizer
- ✓ Unlimited playlists
- ✓ Custom EQ presets
- ✓ Sleep timer
- ✓ Audio visualizer
- ✓ Cloud backup (future)

## Don't Do ❌

- ❌ **Never use `setState`** - Always use Riverpod
- ❌ **Never hardcode strings** - Use localization (l10n)
- ❌ **Never ignore null safety** - Enable sound null safety
- ❌ **Never use `print()`** - Use `logger` package
- ❌ **Never commit secrets** - Use `.env` files
- ❌ **Never ignore disposal** - Always dispose players/streams
- ❌ **Never block UI thread** - Use Isolates for heavy work
- ❌ **Never skip error handling** - Try-catch all async operations

## Do ✅

- ✅ **Always use `const`** where possible
- ✅ **Always add trailing commas** for better formatting
- ✅ **Always write tests** for critical features
- ✅ **Always validate input** before processing
- ✅ **Always provide user feedback** (loading, errors, success)
- ✅ **Always think mobile-first** (battery, memory, network)
- ✅ **Always consider accessibility** (labels, contrast, font sizes)

## Platform-Specific Notes

### Android
- minSdkVersion: 24 (Android 7.0)
- targetSdkVersion: 34
- Permissions: READ_EXTERNAL_STORAGE, FOREGROUND_SERVICE
- Background playback via MediaSessionService

### iOS
- Deployment target: 12.0
- Info.plist: NSAppleMusicUsageDescription
- Background modes: Audio, AirPlay, Picture in Picture
- AVAudioSession configuration

## Key Files & References

- `docs/432Hz_MusicPlayer_ProjectDocs.pdf` - Complete specifications
- `lib/app/config/app_config.dart` - App-wide configuration
- `lib/shared/services/audio/audio_player_service.dart` - Audio engine
- `lib/features/player/presentation/providers/player_providers.dart` - State
- `pubspec.yaml` - Dependencies
- `analysis_options.yaml` - Linting rules

## Development Workflow

1. **Read @docs/432Hz_MusicPlayer_ProjectDocs.pdf** for full context
2. **Create tasks** in small, reviewable chunks
3. **Use @file.dart** references when discussing specific files
4. **Test locally** before committing
5. **Run `flutter analyze`** before push
6. **Write meaningful commit messages** (conventional commits)

## Git Commit Convention
feat: Add 432Hz pitch shift feature
fix: Resolve audio playback crash on iOS
docs: Update README with setup instructions
refactor: Simplify player state management
test: Add unit tests for frequency calculations

text

## Questions to Ask Before Implementing
1. Does this need to be premium or free?
2. Will this impact battery life?
3. Can this be done without blocking the UI?
4. Have I considered error cases?
5. Is this testable?

## Success Metrics
- App launch time: < 2 seconds
- Memory usage: < 150MB during playback
- Audio start latency: < 500ms
- 432Hz accuracy: ±2% (430-434 Hz)
- User rating goal: 4.5+ stars
- Conversion rate (free→premium): 5-10%

---

**Remember**: SoulTune is about providing a serene, healing music experience. Every feature should serve that mission. Keep the UI minimal, the UX smooth, and the audio quality pristine. 🎵✨