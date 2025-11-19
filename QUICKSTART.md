# SoulTune - Quick Start Guide

## 🚀 First Time Setup

After cloning/pulling this repository, follow these steps:

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Generate App Assets (REQUIRED!)

**The app icon and splash screens need to be generated before running the app.**

#### Option A: Use the provided script (Recommended)

**Linux/Mac:**
```bash
./generate_assets.sh
```

**Windows:**
```cmd
generate_assets.bat
```

#### Option B: Manual generation

```bash
# Generate app icons
dart run flutter_launcher_icons

# Generate native splash screens
dart run flutter_native_splash:create
```

### 3. Run the App

```bash
flutter run
```

---

## 📱 What You'll See

### On Launch:

1. **Native Splash Screen** (~500ms)
   - Dark background with app icon
   - Instant display, no white screen

2. **Animated Flutter Splash** (~2.5s)
   - Pulsing app icon with glow effect
   - Gradient background
   - "Synchronizing Frequencies..." text
   - Loading indicator

3. **Home Screen**
   - Bottom navigation with 4 tabs
   - Library, Generator, Browser, Discovery

---

## 🎨 App Features

### 1. Library (Tab 1)
- Import music files from device
- Play with 432 Hz pitch shifting
- Create playlists
- View metadata and album art

### 2. Generator (Tab 2)
- Real-time frequency synthesis
- Binaural beats (CIA Gateway, OBE, Focus, Sleep)
- Solfeggio frequencies (174-963 Hz)
- Custom frequency editor
- Adaptive panning effects

### 3. Browser (Tab 3)
- WebView with frequency injection
- Works with YouTube, Spotify, SoundCloud
- Mix 432 Hz or Solfeggio frequencies with web audio
- Auto-scan Downloads folder

### 4. Discovery (Tab 4)
- Educational content
- CIA Gateway Process information
- Scientific research papers
- Out-of-Body Experience guides
- Remote Viewing history

---

## 🛠️ Common Commands

```bash
# Run the app
flutter run

# Run on specific device
flutter run -d <device-id>

# Build release APK (Android)
flutter build apk --release

# Build release IPA (iOS)
flutter build ios --release

# Generate code (after model changes)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for continuous generation
dart run build_runner watch --delete-conflicting-outputs

# Code analysis
flutter analyze

# Format code
dart format .

# Clean build
flutter clean
```

---

## 🔧 Troubleshooting

### Icon Not Showing?

1. **Clean and rebuild:**
   ```bash
   flutter clean
   flutter pub get
   ./generate_assets.sh  # or generate_assets.bat on Windows
   flutter run
   ```

2. **On physical device:** Uninstall the app first, then reinstall

3. **On iOS:** Open Xcode, clean build folder (Cmd+Shift+K)

### White Screen on Launch?

This means native splash wasn't generated:
```bash
dart run flutter_native_splash:create
flutter clean
flutter run
```

### App Crashes on Startup?

Check console for initialization errors:
```bash
flutter run --verbose
```

Common issues:
- Hive initialization failed (check permissions)
- NotificationService error (check MainActivity extends FlutterFragmentActivity)

### Icons Look Wrong?

Make sure `soultune-app-icon.png` is in the project root:
```bash
ls -lh soultune-app-icon.png
# Should show ~808KB file
```

---

## 📚 Documentation

- **CLAUDE.md** - Architecture and code patterns
- **SPLASH_SCREEN_SETUP.md** - Detailed splash screen documentation
- **ICON_SETUP.md** - App icon configuration
- **NOTIFICATION_SETUP.md** - Android notification setup
- **PERMISSIONS_SETUP.md** - Storage permissions guide
- **PLAN.md** - Feature roadmap

---

## 🎯 Project Structure

```
soultune-clean/
├── lib/
│   ├── main.dart                  # Entry point with splash screen
│   ├── features/                  # Feature modules
│   │   ├── home/                 # Bottom navigation
│   │   ├── player/               # Audio player
│   │   ├── library/              # Music library
│   │   ├── playlist/             # Playlist management
│   │   ├── generator/            # Frequency generator
│   │   ├── browser/              # 432 Hz browser
│   │   ├── discovery/            # Educational content
│   │   └── gateway/              # Gateway Protocol
│   └── shared/                   # Shared code
│       ├── models/               # Data models
│       ├── services/             # Services
│       ├── widgets/              # UI components
│       └── theme/                # Material 3 theme
├── android/                      # Android project
├── ios/                          # iOS project (if configured)
├── generate_assets.sh            # Asset generation script (Linux/Mac)
├── generate_assets.bat           # Asset generation script (Windows)
├── soultune-app-icon.png        # App icon (808KB)
└── pubspec.yaml                 # Dependencies
```

---

## 🌟 Development Tips

1. **Always run code generation after model changes:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **Use watch mode during development:**
   ```bash
   dart run build_runner watch --delete-conflicting-outputs
   ```

3. **Follow the linting rules:**
   - Max 80 characters per line
   - Single quotes for strings
   - Trailing commas for multi-line
   - Use Logger instead of print()

4. **Test on real devices:**
   - Audio features require real hardware
   - Emulators have limited audio support

---

## 🚨 Known Issues

1. **NotificationService initialization may fail**
   - App continues without system media controls
   - Check MainActivity.kt extends FlutterFragmentActivity

2. **First launch may take 3-4 seconds**
   - Normal for service initialization
   - Subsequent launches are faster

3. **WebView may not work on older Android versions**
   - Requires Android 7.0+ (API 24)

---

## 📞 Support

For issues or questions:
1. Check documentation files in project root
2. Run `flutter doctor` to verify setup
3. Check console logs with `flutter run --verbose`

---

**Happy frequency tuning! 🎵✨**
