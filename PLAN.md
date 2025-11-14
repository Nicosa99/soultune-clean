# SoulTune MVP - Phase 1 Implementation Plan

## Overview
This plan breaks down the MVP for SoulTune into small, reviewable tasks. Each main task should be completed and reviewed before moving to the next. Follow the order strictly due to dependencies.

---

## Phase 1.1: Project Foundation & Configuration

### Task 1.1.1: Configure Dependencies and Pubspec
**Priority**: Critical | **Estimated Time**: 30 min

- [ ] Update `pubspec.yaml` with required dependencies:
  - [ ] `just_audio: ^0.9.36` (audio playback)
  - [ ] `flutter_riverpod: ^2.5.0` (state management)
  - [ ] `riverpod_annotation: ^2.3.0` (code generation)
  - [ ] `hive: ^2.2.3` (local database)
  - [ ] `hive_flutter: ^1.1.0` (Hive initialization)
  - [ ] `freezed_annotation: ^2.4.1` (immutable models)
  - [ ] `json_annotation: ^4.8.1` (JSON serialization)
  - [ ] `file_picker: ^6.1.1` (file selection)
  - [ ] `path_provider: ^2.1.1` (app directories)
  - [ ] `permission_handler: ^11.1.0` (permissions)
  - [ ] `metadata_god: ^0.3.0` (audio metadata)
  - [ ] `logger: ^2.0.2` (logging)
  - [ ] `uuid: ^4.2.2` (ID generation)

- [ ] Add dev dependencies:
  - [ ] `build_runner: ^2.4.7`
  - [ ] `riverpod_generator: ^2.3.9`
  - [ ] `freezed: ^2.4.6`
  - [ ] `json_serializable: ^6.7.1`
  - [ ] `flutter_lints: ^3.0.1`

**Acceptance Criteria**:
- `flutter pub get` runs successfully
- No dependency conflicts
- All packages compatible with Flutter 3.24+

**Files**: `pubspec.yaml`

---

### Task 1.1.2: Configure Analysis Options (Linting)
**Priority**: Critical | **Estimated Time**: 15 min | **Depends on**: Task 1.1.1

- [ ] Create `analysis_options.yaml` with strict lint rules
- [ ] Enable all recommended Flutter lints
- [ ] Set max line length to 80 characters
- [ ] Configure analyzer for null safety
- [ ] Add custom lint rules:
  - [ ] `always_use_package_imports`
  - [ ] `prefer_const_constructors`
  - [ ] `prefer_final_fields`
  - [ ] `avoid_print`
  - [ ] `always_declare_return_types`

**Acceptance Criteria**:
- `flutter analyze` runs with 0 errors
- Lints enforce const constructors and trailing commas

**Files**: `analysis_options.yaml`

---

### Task 1.1.3: Create Directory Structure
**Priority**: Critical | **Estimated Time**: 20 min | **Depends on**: Task 1.1.1

- [ ] Create core app structure:
  - [ ] `lib/app/config/`
  - [ ] `lib/app/constants/`
  - [ ] `lib/app/routes/`
  - [ ] `lib/features/player/data/models/`
  - [ ] `lib/features/player/data/datasources/`
  - [ ] `lib/features/player/data/repositories/`
  - [ ] `lib/features/player/presentation/screens/`
  - [ ] `lib/features/player/presentation/widgets/`
  - [ ] `lib/features/player/presentation/providers/`
  - [ ] `lib/features/library/data/`
  - [ ] `lib/features/library/presentation/screens/`
  - [ ] `lib/features/library/presentation/widgets/`
  - [ ] `lib/shared/models/`
  - [ ] `lib/shared/services/audio/`
  - [ ] `lib/shared/services/file/`
  - [ ] `lib/shared/services/storage/`
  - [ ] `lib/shared/exceptions/`
  - [ ] `lib/shared/theme/`
  - [ ] `lib/shared/utils/extensions/`
  - [ ] `lib/shared/widgets/`

- [ ] Create placeholder `.gitkeep` files in empty directories

**Acceptance Criteria**:
- All directories from CLAUDE.md architecture exist
- Project structure matches feature-first clean architecture

**Files**: Multiple directories under `lib/`

---

## Phase 1.2: Core Infrastructure

### Task 1.2.1: Create Custom Exceptions
**Priority**: High | **Estimated Time**: 20 min | **Depends on**: Task 1.1.3

- [ ] Create `lib/shared/exceptions/app_exceptions.dart`
- [ ] Implement base `AppException` class
- [ ] Create specific exceptions:
  - [ ] `AudioException` (playback errors)
  - [ ] `FileException` (file access errors)
  - [ ] `StorageException` (Hive errors)
  - [ ] `PermissionException` (permission denied)
  - [ ] `MetadataException` (metadata parsing errors)

**Acceptance Criteria**:
- All exceptions have descriptive messages
- Each exception includes optional `cause` parameter
- Exceptions follow Dart conventions

**Files**: `lib/shared/exceptions/app_exceptions.dart`

---

### Task 1.2.2: Create Frequency Constants
**Priority**: High | **Estimated Time**: 15 min | **Depends on**: Task 1.1.3

- [ ] Create `lib/app/constants/frequencies.dart`
- [ ] Define pitch shift constants:
  - [ ] `PITCH_432_HZ = -0.31767`
  - [ ] `PITCH_528_HZ = 0.37851` (premium)
  - [ ] `PITCH_639_HZ = 0.69877` (premium)
- [ ] Add standard tuning constant: `STANDARD_440_HZ = 0.0`
- [ ] Add documentation comments explaining calculations

**Acceptance Criteria**:
- Constants are immutable (`const`)
- Formula documented: `12 * log2(target/standard)`
- Ready for use in audio service

**Files**: `lib/app/constants/frequencies.dart`

---

### Task 1.2.3: Initialize Hive Service
**Priority**: Critical | **Estimated Time**: 30 min | **Depends on**: Task 1.2.1

- [ ] Create `lib/shared/services/storage/hive_service.dart`
- [ ] Implement `HiveService` singleton class
- [ ] Add methods:
  - [ ] `Future<void> init()` - Initialize Hive
  - [ ] `Box<T> getBox<T>(String name)` - Get typed box
  - [ ] `Future<void> close()` - Close all boxes
- [ ] Register adapters for future use
- [ ] Add error handling with `StorageException`

**Acceptance Criteria**:
- Hive initializes on app startup
- Service uses path_provider for storage location
- Proper error handling and logging
- Can open and close boxes safely

**Files**: `lib/shared/services/storage/hive_service.dart`

---

### Task 1.2.4: Create App Theme
**Priority**: Medium | **Estimated Time**: 45 min | **Depends on**: Task 1.1.3

- [ ] Create `lib/shared/theme/app_colors.dart`:
  - [ ] Primary: Indigo/Purple gradient (healing vibe)
  - [ ] Secondary: Cyan/Teal (frequency indicator)
  - [ ] Background: Dark theme with subtle gradients
  - [ ] Surface colors with proper contrast

- [ ] Create `lib/shared/theme/app_text_styles.dart`:
  - [ ] Headings (h1-h6)
  - [ ] Body text (body1, body2)
  - [ ] Caption and labels
  - [ ] Button text styles

- [ ] Create `lib/shared/theme/app_theme.dart`:
  - [ ] Material 3 light theme
  - [ ] Material 3 dark theme (primary)
  - [ ] Custom component themes (buttons, cards, sliders)

**Acceptance Criteria**:
- Themes use Material 3 design
- Dark theme optimized for music player aesthetic
- All colors have accessibility-compliant contrast ratios
- Typography scales properly on different devices

**Files**:
- `lib/shared/theme/app_colors.dart`
- `lib/shared/theme/app_text_styles.dart`
- `lib/shared/theme/app_theme.dart`

---

## Phase 1.3: Shared Data Models

### Task 1.3.1: Create FrequencySetting Model
**Priority**: High | **Estimated Time**: 25 min | **Depends on**: Task 1.1.1, Task 1.2.2

- [ ] Create `lib/shared/models/frequency_setting.dart`
- [ ] Use `@freezed` annotation
- [ ] Define fields:
  - [ ] `String id`
  - [ ] `double targetHz`
  - [ ] `String displayName`
  - [ ] `String description`
  - [ ] `double pitchShift`
  - [ ] `bool isPremium`
  - [ ] `Color color`
- [ ] Add `fromJson` and `toJson` methods
- [ ] Create predefined frequency presets (432 Hz, 528 Hz, 639 Hz)

**Acceptance Criteria**:
- Model is immutable with Freezed
- JSON serialization works correctly
- Includes 432 Hz as free, others as premium
- Run `flutter pub run build_runner build` successfully

**Files**: `lib/shared/models/frequency_setting.dart`

---

### Task 1.3.2: Create AudioFile Model
**Priority**: Critical | **Estimated Time**: 30 min | **Depends on**: Task 1.1.1

- [ ] Create `lib/shared/models/audio_file.dart`
- [ ] Use `@freezed` annotation
- [ ] Define fields:
  - [ ] `String id` (UUID)
  - [ ] `String filePath`
  - [ ] `String title`
  - [ ] `String? artist`
  - [ ] `String? album`
  - [ ] `String? albumArt` (path to cached image)
  - [ ] `Duration duration`
  - [ ] `DateTime dateAdded`
  - [ ] `@Default(0) int playCount`
  - [ ] `@Default(false) bool isFavorite`
- [ ] Add `fromJson` and `toJson` methods
- [ ] Create `copyWith` factory (auto-generated by Freezed)

**Acceptance Criteria**:
- Model supports all metadata fields
- Nullable fields properly handled
- JSON serialization includes Duration conversion
- Run `flutter pub run build_runner build` successfully

**Files**: `lib/shared/models/audio_file.dart`

---

### Task 1.3.3: Create Playlist Model
**Priority**: Medium | **Estimated Time**: 20 min | **Depends on**: Task 1.3.2

- [ ] Create `lib/shared/models/playlist.dart`
- [ ] Use `@freezed` annotation
- [ ] Define fields:
  - [ ] `String id` (UUID)
  - [ ] `String name`
  - [ ] `List<String> audioFileIds` (references to AudioFile IDs)
  - [ ] `DateTime createdAt`
  - [ ] `DateTime updatedAt`
- [ ] Add `fromJson` and `toJson` methods
- [ ] Add helper method: `int get trackCount => audioFileIds.length`

**Acceptance Criteria**:
- Playlist stores references (IDs) not full AudioFile objects
- Timestamps auto-update on modifications
- Run `flutter pub run build_runner build` successfully

**Files**: `lib/shared/models/playlist.dart`

---

## Phase 1.4: Core Services

### Task 1.4.1: Create Permission Service
**Priority**: Critical | **Estimated Time**: 40 min | **Depends on**: Task 1.2.1

- [ ] Create `lib/shared/services/file/permission_service.dart`
- [ ] Implement methods:
  - [ ] `Future<bool> requestStoragePermission()`
  - [ ] `Future<bool> hasStoragePermission()`
  - [ ] `Future<bool> openAppSettings()`
- [ ] Handle Android API level differences (API 33+ vs older)
- [ ] Add proper error handling with `PermissionException`
- [ ] Add logging for permission events

**Acceptance Criteria**:
- Works on Android 7.0+ (minSdk 24)
- Handles scoped storage (Android 10+)
- Provides clear user feedback
- Logs permission status changes

**Files**: `lib/shared/services/file/permission_service.dart`

---

### Task 1.4.2: Create Metadata Service
**Priority**: High | **Estimated Time**: 45 min | **Depends on**: Task 1.2.1, Task 1.3.2

- [ ] Create `lib/shared/services/audio/metadata_service.dart`
- [ ] Implement using `metadata_god` package
- [ ] Add methods:
  - [ ] `Future<AudioFile> extractMetadata(String filePath)`
  - [ ] `Future<String?> extractAlbumArt(String filePath, String cacheDir)`
- [ ] Handle missing metadata gracefully (use filename as title)
- [ ] Cache album art to local storage
- [ ] Add error handling with `MetadataException`

**Acceptance Criteria**:
- Extracts title, artist, album, duration
- Album art saved to cache directory
- Returns AudioFile model
- Handles corrupted files gracefully

**Files**: `lib/shared/services/audio/metadata_service.dart`

---

### Task 1.4.3: Create FileSystem Service
**Priority**: High | **Estimated Time**: 50 min | **Depends on**: Task 1.4.1, Task 1.4.2

- [ ] Create `lib/shared/services/file/file_system_service.dart`
- [ ] Implement methods:
  - [ ] `Future<List<AudioFile>> scanMusicDirectory()`
  - [ ] `Future<AudioFile?> pickAudioFile()` (using file_picker)
  - [ ] `Future<List<AudioFile>> pickMultipleAudioFiles()`
- [ ] Filter supported formats: MP3, FLAC, WAV, AAC, OGG
- [ ] Use `MetadataService` to extract info
- [ ] Add progress callback for scanning
- [ ] Handle permission checks via `PermissionService`

**Acceptance Criteria**:
- Scans common music directories (Music, Downloads)
- Shows progress during scanning
- Only returns supported audio files
- Handles permission denial gracefully

**Files**: `lib/shared/services/file/file_system_service.dart`

---

### Task 1.4.4: Create Audio Player Service (Core)
**Priority**: Critical | **Estimated Time**: 60 min | **Depends on**: Task 1.2.1, Task 1.2.2, Task 1.3.2

- [ ] Create `lib/shared/services/audio/audio_player_service.dart`
- [ ] Initialize `just_audio` AudioPlayer instance
- [ ] Implement core methods:
  - [ ] `Future<void> play(AudioFile audioFile, {double pitchShift = 0.0})`
  - [ ] `Future<void> pause()`
  - [ ] `Future<void> resume()`
  - [ ] `Future<void> stop()`
  - [ ] `Future<void> seek(Duration position)`
  - [ ] `Future<void> setPitchShift(double semitones)`
  - [ ] `Stream<PlayerState> get playerStateStream`
  - [ ] `Stream<Duration> get positionStream`
  - [ ] `Stream<Duration?> get durationStream`

- [ ] Implement pitch shift logic:
  ```dart
  // Pitch formula: player.setPitch(1.0 + (semitones / 12.0))
  ```

- [ ] Add error handling with `AudioException`
- [ ] Implement proper disposal

**Acceptance Criteria**:
- Plays audio files successfully
- 432 Hz pitch shift works correctly (±2% tolerance)
- Position and duration streams update in real-time
- No memory leaks on dispose
- Handles file not found errors

**Files**: `lib/shared/services/audio/audio_player_service.dart`

---

## Phase 1.5: Player Feature - Data Layer

### Task 1.5.1: Create Hive Audio Data Source
**Priority**: High | **Estimated Time**: 40 min | **Depends on**: Task 1.2.3, Task 1.3.2

- [ ] Create `lib/features/player/data/datasources/hive_audio_source.dart`
- [ ] Register Hive adapters for AudioFile (use TypeAdapter)
- [ ] Implement methods:
  - [ ] `Future<void> saveAudioFile(AudioFile file)`
  - [ ] `Future<void> saveAudioFiles(List<AudioFile> files)`
  - [ ] `Future<AudioFile?> getAudioFile(String id)`
  - [ ] `Future<List<AudioFile>> getAllAudioFiles()`
  - [ ] `Future<void> updateAudioFile(AudioFile file)`
  - [ ] `Future<void> deleteAudioFile(String id)`
  - [ ] `Future<List<AudioFile>> getFavorites()`

**Acceptance Criteria**:
- Data persists across app restarts
- CRUD operations work correctly
- Uses box name: `audio_files`
- Proper error handling with StorageException

**Files**: `lib/features/player/data/datasources/hive_audio_source.dart`

---

### Task 1.5.2: Create Player Repository
**Priority**: High | **Estimated Time**: 35 min | **Depends on**: Task 1.5.1

- [ ] Create `lib/features/player/data/repositories/player_repository.dart`
- [ ] Inject `HiveAudioSource` dependency
- [ ] Implement methods:
  - [ ] `Future<List<AudioFile>> getRecentlyAdded({int limit = 20})`
  - [ ] `Future<List<AudioFile>> getFavorites()`
  - [ ] `Future<void> toggleFavorite(String audioFileId)`
  - [ ] `Future<void> incrementPlayCount(String audioFileId)`
  - [ ] `Future<AudioFile?> getById(String id)`

**Acceptance Criteria**:
- Recently added sorted by `dateAdded` DESC
- Play count increments correctly
- Favorite toggle works bidirectionally

**Files**: `lib/features/player/data/repositories/player_repository.dart`

---

## Phase 1.6: Player Feature - State Management

### Task 1.6.1: Create Player Providers
**Priority**: Critical | **Estimated Time**: 60 min | **Depends on**: Task 1.4.4, Task 1.5.2

- [ ] Create `lib/features/player/presentation/providers/player_providers.dart`
- [ ] Use Riverpod code generation (`@riverpod` annotation)

- [ ] Create providers:
  - [ ] `audioPlayerServiceProvider` - Singleton audio service
  - [ ] `currentAudioFileProvider` - StateProvider<AudioFile?>
  - [ ] `currentFrequencyProvider` - StateProvider<FrequencySetting>
  - [ ] `isPlayingProvider` - StreamProvider<bool>
  - [ ] `positionProvider` - StreamProvider<Duration>
  - [ ] `durationProvider` - StreamProvider<Duration?>
  - [ ] `playProgressProvider` - Provider<double> (0.0 to 1.0)

- [ ] Implement player control methods:
  - [ ] `playAudio(AudioFile file, double pitchShift)`
  - [ ] `togglePlayPause()`
  - [ ] `seekTo(Duration position)`
  - [ ] `changeFrequency(FrequencySetting frequency)`

**Acceptance Criteria**:
- All providers use AutoDispose where appropriate
- Streams properly connected to AudioPlayerService
- Run `flutter pub run build_runner build` successfully
- State updates trigger UI rebuilds

**Files**: `lib/features/player/presentation/providers/player_providers.dart`

---

## Phase 1.7: Player Feature - UI Components

### Task 1.7.1: Create Seek Bar Widget
**Priority**: High | **Estimated Time**: 45 min | **Depends on**: Task 1.6.1

- [ ] Create `lib/features/player/presentation/widgets/seek_bar.dart`
- [ ] Display current position and total duration
- [ ] Implement draggable slider for seeking
- [ ] Show time in format: "2:34 / 5:12"
- [ ] Watch `positionProvider` and `durationProvider`
- [ ] Handle seek on slider change
- [ ] Add smooth animations

**Acceptance Criteria**:
- Time updates in real-time
- Seeking works smoothly
- Displays "0:00 / 0:00" when no track loaded
- Uses Material 3 Slider styling
- Accessible with proper semantics

**Files**: `lib/features/player/presentation/widgets/seek_bar.dart`

---

### Task 1.7.2: Create Player Controls Widget
**Priority**: Critical | **Estimated Time**: 50 min | **Depends on**: Task 1.6.1

- [ ] Create `lib/features/player/presentation/widgets/player_controls.dart`
- [ ] Implement buttons:
  - [ ] Play/Pause toggle (icon changes based on state)
  - [ ] Skip previous (disabled in MVP)
  - [ ] Skip next (disabled in MVP)
- [ ] Watch `isPlayingProvider` for play/pause state
- [ ] Add icon animations (play ↔ pause)
- [ ] Implement proper button sizing (56x56dp for primary button)

**Acceptance Criteria**:
- Play/Pause works correctly
- Icons animated smoothly
- Disabled buttons have 50% opacity
- Follows Material 3 guidelines
- Haptic feedback on button press

**Files**: `lib/features/player/presentation/widgets/player_controls.dart`

---

### Task 1.7.3: Create Frequency Selector Widget
**Priority**: Critical | **Estimated Time**: 55 min | **Depends on**: Task 1.3.1, Task 1.6.1

- [ ] Create `lib/features/player/presentation/widgets/frequency_selector.dart`
- [ ] Display frequency options as chips/cards:
  - [ ] 432 Hz (free, highlighted)
  - [ ] 528 Hz (premium, locked icon)
  - [ ] 639 Hz (premium, locked icon)
- [ ] Watch `currentFrequencyProvider`
- [ ] Allow switching to 432 Hz freely
- [ ] Show "Premium" badge on locked frequencies
- [ ] Trigger pitch shift on frequency change
- [ ] Add visual feedback (color, border) for active frequency

**Acceptance Criteria**:
- 432 Hz selectable by default
- Premium frequencies show lock icon
- Active frequency visually distinct
- Smooth frequency switching
- No audio glitches during switch

**Files**: `lib/features/player/presentation/widgets/frequency_selector.dart`

---

### Task 1.7.4: Create Now Playing Screen
**Priority**: Critical | **Estimated Time**: 60 min | **Depends on**: Task 1.7.1, Task 1.7.2, Task 1.7.3

- [ ] Create `lib/features/player/presentation/screens/now_playing_screen.dart`
- [ ] Design layout:
  - [ ] Album art (large, centered with gradient background)
  - [ ] Track title (headline5, scrolling if long)
  - [ ] Artist name (subtitle1, secondary color)
  - [ ] Seek bar
  - [ ] Player controls
  - [ ] Frequency selector
- [ ] Watch `currentAudioFileProvider` for metadata
- [ ] Show placeholder when no track loaded
- [ ] Add background blur effect with album art
- [ ] Implement swipe-down to minimize (future)

**Acceptance Criteria**:
- All widgets integrated correctly
- Responsive layout (portrait/landscape)
- Smooth animations
- Shows fallback image for missing album art
- Dark theme optimized

**Files**: `lib/features/player/presentation/screens/now_playing_screen.dart`

---

## Phase 1.8: Library Feature

### Task 1.8.1: Create Library Provider
**Priority**: High | **Estimated Time**: 40 min | **Depends on**: Task 1.4.3, Task 1.5.1

- [ ] Create `lib/features/library/presentation/providers/library_providers.dart`
- [ ] Use Riverpod code generation

- [ ] Create providers:
  - [ ] `fileSystemServiceProvider` - FileSystemService instance
  - [ ] `audioLibraryProvider` - FutureProvider<List<AudioFile>>
  - [ ] `scanningProgressProvider` - StateProvider<double> (0.0 to 1.0)
  - [ ] `isScanningProvider` - StateProvider<bool>

- [ ] Implement methods:
  - [ ] `Future<void> scanLibrary()`
  - [ ] `Future<void> addFilesFromPicker()`

**Acceptance Criteria**:
- Scanning triggers loading state
- Progress updates during scan
- Scanned files saved to Hive automatically
- Run `flutter pub run build_runner build` successfully

**Files**: `lib/features/library/presentation/providers/library_providers.dart`

---

### Task 1.8.2: Create Audio File List Item Widget
**Priority**: Medium | **Estimated Time**: 35 min | **Depends on**: Task 1.3.2

- [ ] Create `lib/features/library/presentation/widgets/audio_file_list_item.dart`
- [ ] Display:
  - [ ] Small album art thumbnail (48x48dp)
  - [ ] Track title (body1)
  - [ ] Artist name (caption)
  - [ ] Duration (caption, right-aligned)
  - [ ] Favorite icon (if `isFavorite == true`)
- [ ] Add tap handler to play track
- [ ] Add long-press for context menu (future)
- [ ] Use `const` constructor

**Acceptance Criteria**:
- Compact list item (72dp height)
- Smooth scrolling in lists
- Shows placeholder for missing metadata
- Follows Material 3 ListTile design

**Files**: `lib/features/library/presentation/widgets/audio_file_list_item.dart`

---

### Task 1.8.3: Create Library Screen
**Priority**: High | **Estimated Time**: 55 min | **Depends on**: Task 1.8.1, Task 1.8.2

- [ ] Create `lib/features/library/presentation/screens/library_screen.dart`
- [ ] Design layout:
  - [ ] AppBar with "My Library" title
  - [ ] FAB: "Scan Library" button
  - [ ] ListView.builder for audio files
  - [ ] Empty state: "No music found. Tap + to scan."
  - [ ] Loading state during scan
  - [ ] Error state if scan fails
- [ ] Watch `audioLibraryProvider`
- [ ] Sort by recently added (default)
- [ ] Tap item → navigate to Now Playing and play
- [ ] Show scan progress indicator

**Acceptance Criteria**:
- Uses ListView.builder (not ListView)
- Shows meaningful empty/loading/error states
- Smooth navigation to Now Playing
- Pulls data from Hive on app restart

**Files**: `lib/features/library/presentation/screens/library_screen.dart`

---

## Phase 1.9: App Integration

### Task 1.9.1: Create App Configuration
**Priority**: Medium | **Estimated Time**: 20 min | **Depends on**: Task 1.1.3

- [ ] Create `lib/app/config/app_config.dart`
- [ ] Define constants:
  - [ ] `appName = 'SoulTune'`
  - [ ] `appVersion = '1.0.0'`
  - [ ] `maxFreePlaylists = 3`
  - [ ] `defaultFrequency = PITCH_432_HZ`
- [ ] Add environment checks (dev/prod)

**Acceptance Criteria**:
- Constants accessible app-wide
- Version matches pubspec.yaml

**Files**: `lib/app/config/app_config.dart`

---

### Task 1.9.2: Create App Router
**Priority**: High | **Estimated Time**: 40 min | **Depends on**: Task 1.7.4, Task 1.8.3

- [ ] Add `go_router` to pubspec.yaml
- [ ] Create `lib/app/routes/app_router.dart`
- [ ] Define routes:
  - [ ] `/` → Library Screen (home)
  - [ ] `/now-playing` → Now Playing Screen
- [ ] Configure transition animations
- [ ] Add Riverpod provider for router

**Acceptance Criteria**:
- Navigation works with `context.go()`
- Back button returns to library
- Smooth page transitions

**Files**: `lib/app/routes/app_router.dart`

---

### Task 1.9.3: Update Main Entry Point
**Priority**: Critical | **Estimated Time**: 45 min | **Depends on**: Task 1.2.3, Task 1.2.4, Task 1.9.2

- [ ] Update `lib/main.dart`
- [ ] Initialize Hive in `main()` before `runApp()`
- [ ] Wrap app in `ProviderScope` (Riverpod)
- [ ] Configure MaterialApp with:
  - [ ] App theme from `app_theme.dart`
  - [ ] Router from `app_router.dart`
  - [ ] Dark mode as default
- [ ] Add error handling for initialization failures
- [ ] Set up logger instance

**Acceptance Criteria**:
- App launches successfully
- Hive initializes before UI loads
- Dark theme applied globally
- No initialization errors

**Files**: `lib/main.dart`

---

## Phase 1.10: Android Platform Configuration

### Task 1.10.1: Configure Android Manifest
**Priority**: Critical | **Estimated Time**: 30 min

- [ ] Update `android/app/src/main/AndroidManifest.xml`
- [ ] Add permissions:
  - [ ] `READ_EXTERNAL_STORAGE` (Android <13)
  - [ ] `READ_MEDIA_AUDIO` (Android 13+)
  - [ ] `FOREGROUND_SERVICE` (background playback)
- [ ] Configure application name and label
- [ ] Set `android:requestLegacyExternalStorage="true"` for Android 10

**Acceptance Criteria**:
- Permissions requested correctly on different Android versions
- App name displays correctly

**Files**: `android/app/src/main/AndroidManifest.xml`

---

### Task 1.10.2: Update Android Build Configuration
**Priority**: High | **Estimated Time**: 20 min

- [ ] Update `android/app/build.gradle`
- [ ] Set `minSdkVersion 24` (Android 7.0)
- [ ] Set `targetSdkVersion 34`
- [ ] Set `compileSdkVersion 34`
- [ ] Enable multidex if needed

**Acceptance Criteria**:
- Builds successfully for Android 7.0+
- No compatibility warnings

**Files**: `android/app/build.gradle`

---

## Phase 1.11: Testing & Quality Assurance

### Task 1.11.1: Run Build Runner
**Priority**: Critical | **Estimated Time**: 10 min | **Depends on**: All model tasks

- [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs`
- [ ] Verify all generated files:
  - [ ] `*.freezed.dart` for models
  - [ ] `*.g.dart` for JSON serialization
  - [ ] `*.g.dart` for Riverpod providers
- [ ] Fix any generation errors

**Acceptance Criteria**:
- No build runner errors
- All generated files present
- Imports resolve correctly

**Files**: Generated files across `lib/`

---

### Task 1.11.2: Run Flutter Analyze
**Priority**: Critical | **Estimated Time**: 15 min | **Depends on**: All code tasks

- [ ] Run `flutter analyze`
- [ ] Fix all errors and warnings
- [ ] Ensure 0 linting issues
- [ ] Check for unused imports
- [ ] Verify const correctness

**Acceptance Criteria**:
- `flutter analyze` returns 0 issues
- All lints pass

**Files**: All Dart files

---

### Task 1.11.3: Manual Testing Checklist
**Priority**: Critical | **Estimated Time**: 60 min | **Depends on**: Task 1.9.3

- [ ] **Library Screen**:
  - [ ] Empty state displays correctly
  - [ ] Scan button requests permissions
  - [ ] Scan finds audio files
  - [ ] Files saved to Hive
  - [ ] List displays after scan

- [ ] **Now Playing Screen**:
  - [ ] Tap track → navigates and plays
  - [ ] Album art displays (or placeholder)
  - [ ] Title and artist shown
  - [ ] Play/Pause works
  - [ ] Seek bar updates in real-time
  - [ ] Seeking works smoothly

- [ ] **432 Hz Feature**:
  - [ ] Frequency selector shows 432 Hz active by default
  - [ ] Audio pitch shifted correctly
  - [ ] Switching to 432 Hz from standard works
  - [ ] Premium frequencies locked

- [ ] **Persistence**:
  - [ ] Close and reopen app
  - [ ] Library persists
  - [ ] Last state remembered

**Acceptance Criteria**:
- All manual tests pass
- No crashes or errors
- Smooth user experience

---

## Phase 1.12: Final Review & Documentation

### Task 1.12.1: Update README
**Priority**: Medium | **Estimated Time**: 20 min

- [ ] Update `README.md` with:
  - [ ] Project description
  - [ ] Setup instructions
  - [ ] Build instructions
  - [ ] MVP feature list
  - [ ] Known limitations

**Acceptance Criteria**:
- README clear and accurate
- Instructions tested

**Files**: `README.md`

---

### Task 1.12.2: Git Commit & Push
**Priority**: Critical | **Estimated Time**: 10 min | **Depends on**: Task 1.11.2

- [ ] Stage all changes: `git add .`
- [ ] Commit with message: `feat: implement SoulTune MVP with 432Hz playback`
- [ ] Push to branch: `git push -u origin claude/soultune-mvp-planning-01BdCzMTVLwZ6d35EzWoVPKu`

**Acceptance Criteria**:
- All code committed
- Push successful
- Branch up to date

---

## MVP Completion Checklist

### Core Features ✓
- [ ] Local music file scanning (MP3, FLAC, WAV)
- [ ] Basic Now Playing screen
- [ ] Play/Pause controls
- [ ] Seek bar with time display
- [ ] **432Hz pitch-shift toggle**
- [ ] Simple playlist (recently added)
- [ ] Favorites marking
- [ ] Hive database for persistence

### Technical Requirements ✓
- [ ] Flutter 3.24+ / Dart 3.5+
- [ ] Riverpod state management with code generation
- [ ] just_audio integration
- [ ] Freezed models
- [ ] Clean Architecture (feature-first)
- [ ] Material 3 dark theme
- [ ] 0 linting errors
- [ ] Android 7.0+ support

---

## Out of Scope (Post-MVP)
- ❌ Background playback (Phase 1.5)
- ❌ Equalizer (Phase 2)
- ❌ Multiple frequencies (Phase 2)
- ❌ Visualizer (Phase 2)
- ❌ Cloud sync (Phase 3)

---

## Review Process

After each main section (1.1, 1.2, etc.), **STOP** and request review:
1. Confirm implementation matches requirements
2. Verify coding standards followed
3. Check for potential improvements
4. Get approval before proceeding to next section

**Remember**: Small, reviewable increments > large monolithic changes.

---

**Let's build SoulTune! 🎵✨**
Start with Task 1.1.1 when ready.
