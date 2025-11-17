# SoulTune Changelog

All notable changes to SoulTune will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased] - MVP Development

### Added

#### Core Audio Engine
- Real-time 432Hz frequency transformation using just_audio pitch-shift API
- Support for multiple healing frequencies: 432Hz (free), 528Hz, 639Hz (premium)
- Background audio playback with audio_session configuration
- Gapless playback between tracks
- Playback speed control (0.5x - 2.0x)
- Volume control with system integration
- Loop modes: Off, One (repeat track), All (repeat playlist)

#### Music Library
- Automatic music library scanning for MP3, FLAC, WAV, AAC, OGG formats
- Metadata extraction (title, artist, album, duration) using audiotags
- Album art extraction and caching
- Manual file import via file picker
- Favorites system with toggle functionality
- Play count tracking
- Recently added sorting
- Most played sorting
- Text search across title and artist

#### User Interface
- **Now Playing Screen**
  - Full-screen player with album art display
  - Interactive seek bar with time labels
  - Play/Pause/Previous/Next controls
  - Frequency selector (432Hz/440Hz/528Hz/639Hz)
  - Loop mode toggle with visual indicator
  - 3-dot menu with "Add to Favorites" option
  - Glassmorphism design with blur effects

- **Library Screen with Tabs**
  - Songs tab: All tracks sorted by date added
  - Folders tab: Browse by directory structure with navigation
  - Artists tab: Group songs by artist with expandable views
  - Favorites tab: Quick access to favorited tracks
  - Favorite toggle button on each song tile (heart icon)
  - Tap to play, long-press for options

- **Mini Player (Spotify-style)**
  - Persistent bottom bar showing current track
  - Album art thumbnail
  - Track title and artist
  - Play/Pause button
  - Tap to expand to full Now Playing screen
  - Glassmorphism background with blur
  - Positioned directly above navigation bar

- **Home Screen**
  - Bottom navigation with Library, Playlists, Settings tabs
  - Mini Player integration
  - Modal bottom sheet for Now Playing

- **Playlist Management**
  - Create new playlists with name and description
  - Add songs to playlists via dialog
  - View playlist details
  - Edit playlist metadata
  - Delete playlists
  - Reorder tracks (future)

#### Data Persistence
- Hive NoSQL database for local storage
- AudioFile model with full metadata
- Playlist model with song references
- Automatic persistence of favorites, play counts, last played
- Reactive streams for library updates

#### State Management
- Riverpod for all application state
- Reactive providers for playback state
- Auto-dispose for memory efficiency
- Action providers for user interactions
- Stream providers for real-time updates

#### Architecture
- Feature-first Clean Architecture
- Repository pattern for business logic
- Service layer abstraction
- Custom exception types for error handling
- Comprehensive logging with emoji indicators

### Changed
- Default frequency set to 432Hz (was 440Hz standard)
- Mini Player positioning: now flush against navigation bar (fixed 2-3cm gap)
- Favorite button replaced play button in song tiles for better UX
- MainActivity changed to FlutterFragmentActivity for audio_service support

### Fixed
- Mini Player positioning gap above navigation tabs
- Compilation errors in notification service integration
- AudioServiceIntegration method signatures (positional vs named parameters)
- SoulTuneAudioHandler removed duplicate AudioPlayer instance

### Known Issues
- **NotificationService PlatformException**: System media controls fail to initialize despite FlutterFragmentActivity configuration
- Notification buttons don't control actual playback (bidirectional sync not implemented)
- No unit/widget/integration tests yet
- No monetization or ads implemented
- No localization (all strings hardcoded in English)

---

## Technical Debt

### High Priority
1. NotificationService Android configuration needs MainApplication.kt
2. Missing test coverage (target: 70%+)
3. Error handling UI (user-friendly messages)
4. Performance profiling for large libraries

### Medium Priority
1. Album art memory optimization (lazy loading)
2. Incremental library scanning (only new files)
3. Database migration strategy for future updates
4. Crash reporting integration (Sentry/Firebase)

### Low Priority
1. Code documentation (dartdoc comments)
2. CI/CD pipeline setup
3. Automated release process
4. Analytics integration

---

## Upcoming Releases

### v1.1.0 - Phase 2 (Planned)
- 10-Band Equalizer
- Audio Visualizer (waveform/spectrum)
- Sleep Timer
- Enhanced error handling
- Performance optimizations

### v1.2.0 - Phase 3 (Planned)
- Monetization (Premium features, Ads)
- Localization (EN, DE, FR)
- Cloud backup (Firebase)
- Custom themes
- Apple Watch / Wear OS support

### v2.0.0 - Future
- Streaming service integration
- Social features (share playlists)
- AI-powered frequency recommendations
- Binaural beats generator
- Meditation timer with frequency programs

---

## Version History

### Development Timeline

**November 2025 - MVP Sprint**

| Date | Commit | Changes |
|------|--------|---------|
| Nov 17 | `398a6a7` | Fix compilation errors in notification service |
| Nov 17 | `ec3a767` | Integrate NotificationService with PlayerRepository |
| Nov 17 | `dbdd3b0` | Add Artists tab and improved favorites |
| Nov 17 | `befdd71` | Add tabbed library with folder browsing, 432Hz default |
| Nov 17 | `b222c73` | Re-enable NotificationService with FlutterFragmentActivity |

---

## Contributors

- Development: AI-assisted (Claude Code)
- Project Owner: @Nicosa99

---

## License

Proprietary - All rights reserved.

---

*This changelog is automatically updated with each release.*
