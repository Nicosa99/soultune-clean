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

## Monetization Strategy (Freemium Model)

SoulTune uses a **freemium model** with NO ADS. The free tier provides real value while premium unlocks advanced features.

### Free Tier (No Subscription Required)

```
✅ Music Player:
   - 432 Hz pitch shifting (unlimited)
   - 440 Hz standard playback

✅ Frequency Generator:
   - 1 Preset: "Deep Sleep" (Delta waves + 174 Hz Solfeggio)
   - All other 19+ presets locked

✅ Browser (432 Hz Web Browser):
   - 432 Hz frequency injection only
   - Works with YouTube, Spotify Web, etc.
   - Gentle upgrade prompts for other frequencies

✅ Discovery Lab:
   - Full access to all educational content
   - CIA Gateway Process articles
   - OBE, Remote Viewing research
   - Trust-building & marketing content

✅ Gateway Protocol Screen:
   - Readable content
   - "Start Session" buttons locked

❌ NO ADS - Clean experience for maximum retention
```

### Premium Tier ($29.99/year or $4.99/month)

```
🔒 Music Player:
   - All Solfeggio frequencies (528 Hz, 639 Hz, etc.)
   - Complete healing frequency library (174-963 Hz)

🔒 Frequency Generator:
   - All 20+ scientifically-designed presets
   - CIA Gateway Process (Focus 10, 12, 15, 21)
   - OBE & Astral Projection presets
   - Remote Viewing protocols
   - All categories unlocked

🔒 Custom Generator:
   - Create custom frequency presets (Coming Soon)
   - Save unlimited custom configurations
   - Advanced binaural beat controls

🔒 Browser:
   - All 9 Solfeggio frequencies
   - Full frequency control

🔒 Gateway Protocol:
   - Start all training sessions
   - Progress tracking
   - Session history
```

### Lifetime Option

```
💎 One-time payment: $69.99
   - All Premium features forever
   - No recurring payments
   - Limited availability (launch period only)
```

### Implementation Details

**Premium Checks:**
- `FrequencySetting.isPremium`: Player frequencies (528 Hz, 639 Hz require premium)
- `FrequencyPreset.isPremium`: Generator presets (only "Deep Sleep" is free)
- Browser: Check premium status before allowing non-432 Hz frequencies
- Custom Generator: Show "Coming Soon" or premium upgrade prompt
- Discovery Lab: Always free (marketing/trust-building)

**Conversion Strategy:**
Users experience real value in free tier (432 Hz works perfectly), then upgrade when they want advanced frequencies (528 Hz "Love Frequency"), CIA Gateway protocols, or OBE training presets.

**Target conversion rate**: 5-8% free to paid (realistic for freemium apps)

---

## Architecture Overview

Feature-first clean architecture with Riverpod state management:

```
lib/
├── main.dart                           # Entry: Hive init, NotificationService init, HomeScreen launch
├── app/constants/frequencies.dart      # Frequency preset definitions (kPitch432Hz, etc.)
├── features/
│   ├── home/                           # Main screen with bottom navigation
│   │   └── presentation/screens/home_screen.dart   # Entry point (Library, Generator, Browser, Discovery tabs)
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
│   ├── generator/                                       # ⭐ Frequency Generator
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
│   ├── browser/                                         # 432 Hz Web Browser
│   │   └── presentation/screens/hz432_browser_screen.dart  # WebView with frequency injection via Web Audio API
│   ├── discovery/                                       # Discovery Lab
│   │   └── presentation/screens/discovery_screen.dart      # Educational content about CIA Gateway, OBE, science
│   ├── gateway/                                         # Gateway Protocol (8-week program)
│   │   └── presentation/screens/gateway_protocol_screen.dart  # Guided CIA Gateway training with progress tracking
│   ├── equalizer/                                       # Audio equalizer feature (future)
│   └── settings/                                        # App settings feature (future)
└── shared/
    ├── models/                         # Freezed data models + Hive adapters
    │   ├── audio_file.dart             # Core audio file model
    │   ├── playlist.dart               # Playlist model
    │   ├── frequency_setting.dart      # Frequency configuration
    │   ├── loop_mode.dart              # Playback loop mode enum
    │   ├── gateway_progress.dart       # Gateway Protocol progress tracking
    │   ├── user_stats.dart             # User statistics (listening time, sessions, etc.)
    │   ├── achievement.dart            # Achievement/badge system
    │   ├── journal_entry.dart          # User journal for tracking experiences
    │   ├── json_converters.dart        # Custom JSON converters for Freezed
    │   └── hive_adapters.dart          # Hive type adapters registration
    ├── services/
    │   ├── audio/
    │   │   ├── audio_player_service.dart        # just_audio wrapper with pitch shift
    │   │   ├── notification_service.dart        # System media controls (audio_service)
    │   │   ├── metadata_service.dart            # ID3 tag extraction
    │   │   ├── soultune_audio_handler.dart      # audio_service handler implementation
    │   │   └── audio_service_integration.dart   # Integrates audio_service with player
    │   ├── premium/                             # ⭐ Premium subscription service
    │   │   ├── models/premium_status.dart       # PremiumStatus model (Freezed)
    │   │   ├── premium_service.dart             # Abstract interface
    │   │   ├── mock_premium_service.dart        # Development implementation
    │   │   └── premium_providers.dart           # Riverpod state management
    │   ├── storage/hive_service.dart            # Local database initialization
    │   └── file/                                # File system & permissions
    │       ├── file_system_service.dart         # File scanning and selection
    │       ├── permission_service.dart          # Storage permission handling
    │       └── download_scanner_service.dart    # Auto-scan Downloads folder for new audio files
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

### 3. 432 Hz Web Browser (WebView with Frequency Injection)

Embedded WebView browser that injects healing frequencies into website audio:

```dart
// lib/features/browser/presentation/screens/hz432_browser_screen.dart
// Uses webview_flutter with Web Audio API JavaScript injection
// Allows mixing 432 Hz or Solfeggio frequencies with any website's audio
```

**Browser Features:**
- **Universal frequency injection**: Works with YouTube, Spotify Web, SoundCloud, etc.
- **Web Audio API**: JavaScript injection intercepts website audio streams
- **Volume control**: Adjustable frequency layer volume
- **Quick bookmarks**: Pre-configured sites for healing music
- **Download integration**: Auto-scans Downloads folder for audio files from downloader sites (loader.to, savenow.to)
- **Standard navigation**: Back, forward, refresh, URL bar

### 4. Discovery Lab (Educational Content)

Educational screen about the science behind frequency synchronization:

**Discovery Lab Features:**
- **CIA Gateway Process**: Declassified research on brain synchronization
- **Out-of-Body Experiences**: Scientific studies and methods
- **Remote Viewing**: History and applications
- **Brainwave Science**: How different frequencies affect consciousness
- **Interactive presets**: Direct links to try relevant frequency presets
- **External resources**: Links to research papers and documentation

### 5. Gateway Protocol (8-Week Program)

Guided training program based on CIA Gateway Process:

**Gateway Protocol Features:**
- **8-week structure**: Progressive training program
  - Week 1-2: Focus 10 (Body Asleep, Mind Awake)
  - Week 3-4: Focus 12 (Expanded Awareness)
  - Week 5-6: Focus 15 (No Time)
  - Week 7-8: Focus 21 (Other Energy Systems)
- **Progress tracking**: Session completion and week advancement
- **Integrated frequency presets**: Direct access to relevant binaural beats
- **Journal integration**: Log experiences and insights (future)

### 6. Gamification System

User engagement and progress tracking:

**Gamification Models:**
- `user_stats.dart`: Track listening time, sessions, favorite frequencies
- `achievement.dart`: Badge system for milestones (e.g., "7-day meditation streak")
- `journal_entry.dart`: Personal logs for tracking experiences with different frequencies
- `gateway_progress.dart`: Specific tracking for Gateway Protocol advancement

## Navigation Structure

The app uses a PageView-based bottom navigation (NOT go_router):

```dart
// lib/features/home/presentation/screens/home_screen.dart
// Bottom Navigation Tabs (4 tabs):
// 1. Library - Music files, playlists, local audio
// 2. Generator - Frequency presets, custom frequencies, binaural beats
// 3. Browser - 432 Hz web browser with frequency injection
// 4. Discovery - Educational content, science, research

// Mini Player: Shown on all tabs when audio is playing (Library, Generator, Browser, Discovery)
// Full Player: Modal screen (NowPlayingScreen) - swipe up from mini player
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

### Premium Service Architecture

Enterprise-grade subscription management with clean architecture principles:

```dart
// Architecture layers:
PremiumService (Abstract Interface)
    ↓
MockPremiumService (Development)
RevenueCatPremiumService (Production - TODO)
    ↓
Riverpod Providers (State Management)
    ↓
UI Components (Feature Gating)
```

**Core Components:**

1. **PremiumStatus Model** (`lib/shared/services/premium/models/premium_status.dart`)
   - Freezed immutable model
   - Tracks tier (free/monthly/annual/lifetime)
   - Expiration dates, grace periods
   - Computed properties (daysRemaining, expiresSoon)

2. **PremiumService Interface** (`lib/shared/services/premium/premium_service.dart`)
   - Abstract contract for all implementations
   - Methods: initialize(), purchaseMonthly/Annual/Lifetime(), restorePurchases()
   - Status stream for reactive UI
   - Platform-agnostic

3. **MockPremiumService** (`lib/shared/services/premium/mock_premium_service.dart`)
   - Development/testing implementation
   - Simulates purchase flows (2s delay)
   - Force premium for testing: `mockService.forcePremium()`
   - Default: FREE tier

4. **Riverpod Providers** (`lib/shared/services/premium/premium_providers.dart`)
   - `premiumServiceProvider`: Singleton service instance
   - `premiumStatusProvider`: Stream of status changes
   - `isPremiumProvider`: Derived boolean for quick checks
   - Action providers: `purchaseAnnualActionProvider`, etc.

**Usage Examples:**

```dart
// Check premium status in UI
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumAsync = ref.watch(isPremiumProvider);

    return isPremiumAsync.when(
      data: (isPremium) => isPremium
          ? PremiumFeature()
          : UpgradeButton(),
      loading: () => CircularProgressIndicator(),
      error: (_, __) => UpgradeButton(), // Default to free on error
    );
  }
}

// Initiate purchase
final purchaseAction = ref.read(purchaseAnnualActionProvider);
final success = await purchaseAction();

if (success) {
  // Status automatically updates via stream
  // UI rebuilds reactively
}

// Feature gating
final status = ref.watch(premiumStatusProvider).value;
if (status?.isPremium ?? false) {
  // Grant access
} else {
  // Show upgrade dialog
}
```

**Production Migration:**

When ready for production, replace MockPremiumService with RevenueCat:

```dart
// lib/shared/services/premium/premium_providers.dart
@Riverpod(keepAlive: true)
PremiumService premiumService(PremiumServiceRef ref) {
  // return MockPremiumService(); // Development
  return RevenueCatPremiumService(); // Production
}
```

**Important Notes:**
- Always default to FREE tier on errors (fail-safe)
- Never block UI while checking premium status
- Use streams for reactive updates
- Test with `MockPremiumService.forcePremium()` during development

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

**Documentation:**
- `NOTIFICATION_SETUP.md` - Android media notification configuration
- `PERMISSIONS_SETUP.md` - Storage permission setup
- `PLAN.md` - Feature roadmap and implementation phases
- `ANDROID_V2_FIX.md` - Android v2 embedding migration fixes

**Core Architecture:**
- `lib/main.dart` - App entry point with Hive and NotificationService initialization
- `lib/features/home/presentation/screens/home_screen.dart` - Main app with bottom navigation (4 tabs)
- `lib/shared/widgets/mini_player.dart` - Persistent mini player UI (shown on all tabs)

**Player Feature:**
- `lib/app/constants/frequencies.dart` - Frequency constants for pitch shifting
- `lib/features/player/presentation/providers/player_providers.dart` - Player state management
- `lib/features/player/presentation/screens/now_playing_screen.dart` - Full player screen
- `lib/shared/services/audio/audio_player_service.dart` - just_audio wrapper with pitch shift

**Playlist Feature:**
- `lib/features/playlist/presentation/providers/playlist_providers.dart` - Playlist state management
- `lib/features/playlist/data/datasources/hive_playlist_datasource.dart` - Playlist data access

**Generator Feature:**
- `lib/features/generator/presentation/providers/generator_providers.dart` - Generator state management
- `lib/features/generator/presentation/screens/generator_screen.dart` - Main generator UI
- `lib/features/generator/data/models/frequency_constants.dart` - Solfeggio & brainwave frequencies
- `lib/features/generator/data/models/predefined_presets.dart` - All preset definitions (CIA Gateway, OBE, etc.)
- `lib/features/generator/data/services/frequency_generator_service.dart` - SoLoud synthesis engine
- `lib/features/generator/domain/panning_engine.dart` - Adaptive panning algorithm

**Browser Feature:**
- `lib/features/browser/presentation/screens/hz432_browser_screen.dart` - WebView with frequency injection
- `lib/shared/services/file/download_scanner_service.dart` - Auto-scan Downloads for audio files

**Discovery & Gateway Features:**
- `lib/features/discovery/presentation/screens/discovery_screen.dart` - Educational content screen
- `lib/features/gateway/presentation/screens/gateway_protocol_screen.dart` - 8-week training program

**Gamification:**
- `lib/shared/models/user_stats.dart` - User statistics tracking
- `lib/shared/models/achievement.dart` - Achievement/badge system
- `lib/shared/models/journal_entry.dart` - User journal for experiences
- `lib/shared/models/gateway_progress.dart` - Gateway Protocol progress

## Git Commit Convention

Use conventional commits:
```
feat: add sleep timer functionality
fix: resolve audio interruption on incoming calls
refactor: simplify frequency selector state management
docs: update permission setup guide
```
