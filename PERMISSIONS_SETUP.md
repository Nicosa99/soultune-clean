# SoulTune Storage Permissions Setup

## Problem
Die App kann keine Musik-Dateien scannen, da die erforderlichen Storage-Berechtigungen fehlen.

## Lösung

### Android Permissions (AndroidManifest.xml)

Öffne die Datei:
```
android/app/src/main/AndroidManifest.xml
```

Füge folgende Permissions **vor** dem `<application>` Tag hinzu:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- Storage Permissions für Android -->

    <!-- Android 12 und niedriger (API < 33) -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
                     android:maxSdkVersion="32" />

    <!-- Android 13 und höher (API 33+) -->
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />

    <!-- Foreground Service für Background Playback -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />

    <application
        ...
    >
        ...
    </application>
</manifest>
```

### Vollständiges Beispiel

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- ========== PERMISSIONS ========== -->

    <!-- Storage Permissions -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
                     android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />

    <!-- Foreground Service -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />

    <!-- Internet (für zukünftige Features) -->
    <uses-permission android:name="android.permission.INTERNET" />

    <!-- ========== APPLICATION ========== -->

    <application
        android:label="SoulTune"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />

            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>

    <!-- Request legacy storage for API 29 (Android 10) -->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
                     android:maxSdkVersion="29" />

</manifest>
```

---

## Background Playback Setup

### Android Background Audio

#### Erforderliche Permissions

Die folgenden Permissions sind bereits im obigen Beispiel enthalten:

```xml
<!-- Foreground Service für Background Playback -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />
```

#### Zusätzliche Konfiguration (Optional)

Für optimale Background-Performance kann folgendes im `<application>` Tag hinzugefügt werden:

```xml
<application
    ...
    android:usesCleartextTraffic="false"
    android:requestLegacyExternalStorage="true">

    <!-- Foreground Service für Media Playback -->
    <service
        android:name="com.ryanheise.audioservice.AudioService"
        android:foregroundServiceType="mediaPlayback"
        android:exported="true">
        <intent-filter>
            <action android:name="android.media.browse.MediaBrowserService" />
        </intent-filter>
    </service>

    ...
</application>
```

**Hinweis**: Die Audio Session wird bereits im Code konfiguriert (`AudioPlayerService.init()`), daher funktioniert Background Playback meist ohne zusätzliche Service-Konfiguration.

#### Background Playback Testen

1. **App starten** und Musik abspielen
2. **Home Button** drücken → Musik sollte weiterlaufen ✓
3. **Screen Lock** → Musik sollte weiterlaufen ✓
4. **Notification** sollte Media-Controls zeigen (Play/Pause) - nur mit audio_service package

### iOS Background Audio

iOS erfordert zusätzliche Konfiguration in `Info.plist`:

```xml
<!-- Background Modes -->
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>processing</string>
</array>
```

---

## iOS Permissions (Info.plist)

Öffne die Datei:
```
ios/Runner/Info.plist
```

Füge folgende Keys hinzu (vor `</dict>`):

```xml
<!-- Music Library Access -->
<key>NSAppleMusicUsageDescription</key>
<string>SoulTune needs access to your music library to play and transform your audio files to healing frequencies (432Hz, 528Hz, 639Hz)</string>

<!-- Media Library (iOS 9.3+) -->
<key>NSAppleMusicUsageDescription</key>
<string>Access your music for playback with frequency transformation</string>

<!-- Microphone (for future visualizer) -->
<key>NSMicrophoneUsageDescription</key>
<string>SoulTune will use the microphone for audio visualization features</string>
```

---

## Nach den Änderungen

1. **Speichere** beide Dateien
2. **Stoppe** die laufende App komplett
3. **Deinstalliere** die App vom Device/Emulator:
   ```bash
   flutter clean
   ```
4. **Installiere neu**:
   ```bash
   flutter run
   ```

5. Beim ersten Start wird die App nun nach Storage-Berechtigungen fragen!

---

## Testen der Permissions

### Android
1. App starten
2. Auf "Scan for Music" tippen
3. Permission-Dialog sollte erscheinen: "Allow SoulTune to access music files?"
4. Auf "Allow" tippen
5. Scan startet automatisch

### Wenn Permission-Dialog nicht erscheint:
1. Gehe zu Geräte-Einstellungen
2. Apps → SoulTune → Permissions
3. Aktiviere "Files and media" oder "Music and audio"
4. Zurück zur App
5. Scan erneut versuchen

---

## Häufige Probleme

### "Permission permanently denied"
- App deinstallieren
- Neu installieren
- Bei erneutem Permission-Request auf "Allow" tippen

### "No music found" trotz Berechtigung
- Überprüfe, ob Musik in `/Music` oder `/Download` Ordnern liegt
- Unterstützte Formate: MP3, FLAC, WAV, M4A, AAC, OGG

### Berechtigungen in Settings nicht sichtbar
- AndroidManifest.xml wurde nicht korrekt geändert
- `flutter clean` und neu installieren

---

## Technische Details

### Android API Levels
- **API 23-32** (Android 6-12): `READ_EXTERNAL_STORAGE`
- **API 33+** (Android 13+): `READ_MEDIA_AUDIO` (granular permissions)

### Permission Request Flow
1. App ruft `PermissionService.requestStoragePermission()` auf
2. `permission_handler` package zeigt nativen Dialog
3. Bei "Allow": `scanAndImportLibrary()` startet
4. Bei "Deny": User sieht Fehlermeldung

### Fallback
Wenn Permissions verweigert wurden:
- User kann über `importFilesAction` manuell Dateien auswählen
- File Picker benötigt keine Runtime-Permission

---

## Code-Referenz

Die Permission-Logik ist in:
- `lib/shared/services/file/permission_service.dart`
- `lib/features/player/data/repositories/player_repository.dart`
- `lib/features/library/presentation/screens/library_screen.dart`

Bei Fragen siehe CLAUDE.md für weitere Details.
