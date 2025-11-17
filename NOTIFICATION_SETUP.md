# 🔔 SoulTune Notification Player Setup

## Übersicht

Der Notification Player ermöglicht:
- ✅ **System Media Controls** (Lock Screen, Bluetooth, Android Auto)
- ✅ **Background Playback** ohne Unterbrechung
- ✅ **Notification mit Play/Pause/Skip**
- ✅ **Frequency Indicator** (432Hz/528Hz/639Hz)
- ✅ **Album Artwork in Notification**

---

## 📋 Setup-Schritte

### 1. Dependencies installieren

Die Dependency ist bereits in `pubspec.yaml` hinzugefügt:

```yaml
audio_service: ^0.18.15
```

Führe aus:
```bash
flutter pub get
```

---

### 2. Android Configuration

#### a) AndroidManifest.xml

**Datei**: `android/app/src/main/AndroidManifest.xml`

Füge folgende Permissions **vor** dem `<application>` Tag hinzu:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- ========== AUDIO SERVICE PERMISSIONS ========== -->

    <!-- Foreground Service für Background Playback -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />

    <!-- Wake Lock für Background Audio -->
    <uses-permission android:name="android.permission.WAKE_LOCK" />

    <!-- Media Button Controls -->
    <uses-permission android:name="android.permission.MEDIA_CONTENT_CONTROL" />

    <!-- ========== APPLICATION ========== -->

    <application
        android:label="SoulTune"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">

        <!-- ========== AUDIO SERVICE ========== -->

        <service
            android:name="com.ryanheise.audioservice.AudioService"
            android:foregroundServiceType="mediaPlayback"
            android:exported="true">
            <intent-filter>
                <action android:name="android.media.browse.MediaBrowserService" />
            </intent-filter>
        </service>

        <!-- ========== RECEIVER FOR MEDIA BUTTONS ========== -->

        <receiver
            android:name="com.ryanheise.audioservice.MediaButtonReceiver"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MEDIA_BUTTON" />
            </intent-filter>
        </receiver>

        <!-- Your MainActivity etc. -->
        <activity
            android:name=".MainActivity"
            ...>
        </activity>

    </application>
</manifest>
```

#### b) build.gradle (Optional)

**Datei**: `android/app/build.gradle`

Stelle sicher, dass `minSdkVersion >= 21`:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Required for audio_service
        targetSdkVersion 34
    }
}
```

---

### 3. iOS Configuration

**Datei**: `ios/Runner/Info.plist`

Füge Background Modes hinzu (vor `</dict>`):

```xml
<!-- Background Audio Playback -->
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>

<!-- Audio Session -->
<key>UIRequiresPersistentWiFi</key>
<false/>
```

---

### 4. App Initialization

**Datei**: `lib/main.dart`

Initialisiere NotificationService **vor** `runApp()`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:soultune/shared/services/audio/notification_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // 🔔 Initialize Notification Service
  await NotificationService.init();

  // Run app
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

---

## 🧪 Testing

### Android

1. **Build & Install**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Play Audio**
   - Spiele einen Song ab
   - Du solltest eine Notification sehen mit:
     - Track Title & Artist
     - Album Artwork
     - Play/Pause Button
     - Skip Forward/Backward
     - Frequency Badge (432Hz)

3. **Lock Screen**
   - Drücke Power Button (Lock Screen)
   - Du solltest Controls auf dem Lock Screen sehen

4. **Background Playback**
   - Drücke Home Button
   - Musik sollte weiterlaufen
   - Notification bleibt sichtbar

5. **Bluetooth/Headset**
   - Verbinde Bluetooth Kopfhörer
   - Play/Pause Taste sollte funktionieren
   - Skip Tasten sollten funktionieren

### iOS

1. **Build & Install**
   ```bash
   flutter run -d <ios-device>
   ```

2. **Control Center**
   - Wische nach oben (oder nach unten auf neueren iPhones)
   - Du solltest die Media Controls sehen

3. **Lock Screen**
   - Ähnlich wie Android

---

## 🔧 Troubleshooting

### "AudioService not initialized"

**Problem**: App crashed beim Starten von Audio

**Lösung**:
```dart
// Stelle sicher, dass NotificationService.init() aufgerufen wurde
await NotificationService.init();
```

### Notification erscheint nicht

**Problem**: Keine Notification beim Abspielen

**Lösungen**:
1. Check `AndroidManifest.xml` - Service korrekt deklariert?
2. Check Permissions - `FOREGROUND_SERVICE` vorhanden?
3. Check `flutter clean && flutter run`
4. Check Device Notification Settings - erlaubt?

### "FOREGROUND_SERVICE_MEDIA_PLAYBACK Permission denied"

**Problem**: Android 14+ braucht explizite Permission

**Lösung**:
```xml
<!-- In AndroidManifest.xml -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />
```

### Notification bleibt nach App-Schließung

**Problem**: Notification persistent

**Lösung**:
Das ist beabsichtigt! Ermöglicht Background Playback.
Zum Beenden: Pause Button in Notification → dann Swipe away

### Album Art fehlt in Notification

**Problem**: Nur Placeholder Icon

**Lösung**:
- Check ob `audioFile.albumArt` Pfad gültig ist
- Check Datei-Permissions
- Album Art wird nur für lokale Dateien unterstützt

---

## 📱 Notification Features

### Angezeigt in Notification:

1. **Track Info**
   - Title
   - Artist
   - Album (optional)

2. **Album Artwork**
   - Aus Metadaten extrahiert
   - Oder Placeholder Icon

3. **Controls**
   - ⏮ Skip Previous
   - ⏯ Play/Pause
   - ⏭ Skip Next

4. **Frequency Badge** (geplant)
   - Wird als Subtitle angezeigt
   - "432Hz - Deep Peace"

### System Integration:

- ✅ **Lock Screen Controls**
- ✅ **Bluetooth Button Support**
- ✅ **Android Auto / CarPlay** (basic)
- ✅ **Wear OS Controls** (automatisch)
- ✅ **Google Assistant** ("Hey Google, play music")

---

## 🎨 Notification Customization

### Notification Icon

Standard: `mipmap/ic_launcher`

Custom Icon erstellen:
1. Erstelle `android/app/src/main/res/drawable/notification_icon.png`
2. Update in `notification_service.dart`:
   ```dart
   androidNotificationIcon: 'drawable/notification_icon',
   ```

### Notification Color

```dart
// In notification_service.dart
notificationColor: Color(0xFF6366F1), // SoulTune Primary Color
```

---

## 📚 Code-Referenz

### Notification Service
- `lib/shared/services/audio/notification_service.dart`
- `lib/shared/services/audio/soultune_audio_handler.dart`

### Integration
- `lib/features/player/data/repositories/player_repository.dart`
- `lib/features/player/presentation/providers/player_providers.dart`

---

## 🚀 Next Steps

Nach erfolgreichem Setup:

1. **Test auf echtem Device** (nicht Emulator für beste Ergebnisse)
2. **Test Bluetooth Controls**
3. **Test Android Auto** (falls verfügbar)
4. **Custom Notification Actions** hinzufügen (z.B. "Favorite")

---

## ✅ Checkliste

- [ ] `pubspec.yaml` - audio_service dependency
- [ ] `AndroidManifest.xml` - Permissions & Service
- [ ] `Info.plist` - Background Modes (iOS)
- [ ] `main.dart` - NotificationService.init()
- [ ] Build & Test auf echtem Device
- [ ] Background Playback funktioniert
- [ ] Lock Screen Controls funktionieren
- [ ] Bluetooth Controls funktionieren

---

**Bei Problemen**: Check Logs mit `flutter logs` während der App läuft.
