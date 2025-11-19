# SoulTune Splash Screen Setup

## Overview

SoulTune features a **two-tier splash screen system** for a premium, Big Tech-like app experience:

1. **Native Splash Screen**: Shows immediately when app launches (native Android/iOS)
2. **Flutter Splash Screen**: Animated splash during app initialization (2.5+ seconds)

This provides:
- ✅ Instant visual feedback (no white screen)
- ✅ Smooth, professional animations
- ✅ Branding consistency
- ✅ Time for services to initialize

---

## Architecture

### 1. Native Splash Screen (Platform-Specific)

**Purpose**: Instant display while Flutter engine initializes
**Duration**: ~500ms - 1s
**Technology**: Native Android/iOS resources

**Visual Design**:
- Background: `#0F0F1E` (deep dark blue-purple)
- Icon: SoulTune app icon (centered)
- Full screen, no text

### 2. Flutter Splash Screen (Custom Widget)

**Purpose**: Beautiful animated loading during service initialization
**Duration**: 2.5+ seconds (minimum for UX)
**Location**: `lib/shared/widgets/splash_screen.dart`

**Features**:
- ✨ Smooth fade-in animations (800ms)
- 🌊 Pulsing app icon effect (2s cycles)
- 🎯 Scale animation with bounce (600ms)
- 🎨 Gradient background matching app theme
- 💫 Circular loading indicator
- 📝 Status text: "Synchronizing Frequencies..."

**Visual Elements**:
1. **App Icon** (160x160)
   - Rounded corners (32px border radius)
   - Pulsing glow effect (purple `#6C63FF`)
   - Scale animation on entry

2. **App Name** ("SoulTune")
   - Gradient shader mask (purple → cyan)
   - Large bold text (48px)
   - Letter spacing for elegance

3. **Tagline** ("Healing Frequency Music")
   - Light text with opacity
   - Uppercase with letter spacing

4. **432 Hz Badge**
   - Purple bordered chip
   - Brand frequency indicator

5. **Loading Indicator**
   - Circular progress (purple)
   - Bottom section with status text

---

## Implementation Details

### File Structure

```
lib/
├── main.dart                      # AppInitializer widget
├── shared/
│   └── widgets/
│       └── splash_screen.dart     # Custom splash screen widget

flutter_native_splash.yaml          # Native splash configuration
pubspec.yaml                        # Assets & dependencies
```

### Main App Flow

```dart
main()
  ↓
SoulTuneApp (MaterialApp)
  ↓
AppInitializer (StatefulWidget)
  ↓
initState → _initializeApp()
  ↓
[Show SplashScreen]
  • Initialize Hive
  • Initialize NotificationService
  • Wait minimum 2.5s for UX
  ↓
[Navigate to HomeScreen]
```

### Initialization Logic

**Location**: `lib/main.dart` → `AppInitializer._initializeApp()`

```dart
1. Record start time
2. Initialize Hive database
3. Initialize NotificationService (with error handling)
4. Calculate elapsed time
5. If < 2.5s, wait remaining time
6. Set _initialized = true
7. Show HomeScreen
```

**Error Handling**:
- Catches all initialization errors
- Shows error screen with retry button
- Logs errors to console

---

## Installation & Setup

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Generate Native Splash Screens

```bash
# Generate for Android & iOS
dart run flutter_native_splash:create
```

This creates:

**Android**:
- `android/app/src/main/res/drawable/launch_background.xml`
- `android/app/src/main/res/values/colors.xml` (splash color)
- Android 12+ adaptive splash resources

**iOS**:
- `ios/Runner/Assets.xcassets/LaunchImage.imageset/`
- `ios/Runner/Base.lproj/LaunchScreen.storyboard`

### 3. Verify Assets

Ensure `soultune-app-icon.png` is in project root:
```bash
ls -lh soultune-app-icon.png
# Should show ~808KB file
```

### 4. Run App

```bash
flutter run
```

**Expected Behavior**:
1. Native splash appears instantly (dark background + icon)
2. Flutter initializes (~500ms)
3. Animated splash screen appears (2.5s with animations)
4. Smooth transition to HomeScreen

---

## Customization

### Change Splash Duration

Edit `lib/main.dart`:

```dart
const Duration(milliseconds: 2500) // Change to desired duration
```

### Change Background Color

Edit `flutter_native_splash.yaml`:

```yaml
color: "#0F0F1E"  # Your color
```

Edit `lib/shared/widgets/splash_screen.dart`:

```dart
backgroundColor: const Color(0xFF0F0F1E), // Update here
```

### Change Animation Speed

Edit `lib/shared/widgets/splash_screen.dart`:

```dart
_fadeController = AnimationController(
  duration: const Duration(milliseconds: 800), // Adjust
  vsync: this,
);
```

### Add Custom Loading Text

Edit `lib/shared/widgets/splash_screen.dart` (line ~180):

```dart
Text(
  'Your custom text...',
  style: TextStyle(/* ... */),
),
```

---

## Color Palette

SoulTune splash screens use these brand colors:

| Element | Color | Hex |
|---------|-------|-----|
| Background | Deep Dark | `#0F0F1E` |
| Gradient 1 | Dark Blue-Purple | `#1A1A2E` |
| Gradient 2 | Slightly Lighter | `#16213E` |
| Primary Purple | Vibrant Purple | `#6C63FF` |
| Accent Cyan | Bright Cyan | `#48CAE4` |

---

## Troubleshooting

### White flash on startup

**Cause**: Native splash not configured
**Solution**: Run `dart run flutter_native_splash:create`

### App icon not showing

**Cause**: Asset not added to pubspec.yaml
**Solution**: Verify `assets:` section includes `soultune-app-icon.png`

### Splash too short/long

**Cause**: Minimum duration setting
**Solution**: Adjust `Duration(milliseconds: 2500)` in `main.dart`

### Animations stuttering

**Cause**: Heavy initialization blocking UI thread
**Solution**: Ensure initialization is async, not blocking

### Error: Image not found

**Cause**: Image path incorrect
**Solution**: Use `Image.asset('soultune-app-icon.png')` (not `assets/`)

---

## Platform-Specific Notes

### Android

- **Minimum SDK**: 24 (Android 7.0)
- **Android 12+**: Uses new splash screen API
- **Adaptive Icons**: Background color `#1A1A2E`
- **Status Bar**: Transparent with light icons

### iOS

- **Deployment Target**: 12.0+
- **Launch Storyboard**: Auto-generated
- **Safe Area**: Respected in splash layout
- **Dark Mode**: Always dark (matches app theme)

---

## Performance

**Benchmarks** (typical device):
- Native splash → Flutter ready: ~500-800ms
- Service initialization: ~200-500ms
- Animation time: 2500ms
- **Total splash time**: 3.2-3.8 seconds

This duration is:
- ✅ Short enough to not annoy users
- ✅ Long enough for smooth animations
- ✅ Sufficient for all services to initialize
- ✅ Matches Big Tech app standards

---

## Future Enhancements

Potential improvements (post-MVP):

- [ ] Animated Lottie intro sequence
- [ ] Dynamic status messages based on initialization step
- [ ] Progress bar showing actual initialization progress
- [ ] Skip button for returning users
- [ ] First-time tutorial after splash
- [ ] Personalized splash based on last frequency used

---

## References

- **flutter_native_splash**: https://pub.dev/packages/flutter_native_splash
- **Material Design Splash**: https://m3.material.io/styles/motion/transitions/applying-transitions
- **Android Splash Screen**: https://developer.android.com/develop/ui/views/launch/splash-screen
- **iOS Launch Screen**: https://developer.apple.com/design/human-interface-guidelines/launching
