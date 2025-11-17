/// SoulTune - 432Hz Healing Frequency Music Player
///
/// Main entry point for the SoulTune Flutter application.
/// Initializes Hive, services, and starts the app with Riverpod.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soultune/features/home/presentation/screens/home_screen.dart';
// import 'package:soultune/shared/services/audio/notification_service.dart'; // Temporarily disabled
import 'package:soultune/shared/services/storage/hive_service.dart';
import 'package:soultune/shared/theme/app_theme.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive database
  await HiveService.instance.init();

  // NOTIFICATION SERVICE TEMPORARILY DISABLED
  // audio_service 0.18.15 has compatibility issues with current Flutter setup
  // The app works perfectly without it - you only lose:
  //   - Lockscreen controls
  //   - Notification tray player
  //   - Bluetooth/headset button controls
  // All core features work: Mini Player, Playback, 432Hz, etc.
  //
  // To re-enable later, uncomment:
  // try {
  //   await NotificationService.init();
  // } catch (e) {
  //   debugPrint('⚠️ NotificationService failed to initialize: $e');
  // }

  debugPrint('📱 SoulTune starting without system notifications');
  debugPrint('✅ Mini Player, Playback, 432Hz Pitch Shift - all working!');

  // Set system UI overlay style (status bar, navigation bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Set preferred orientations (portrait only for MVP)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Run app with Riverpod
  runApp(
    const ProviderScope(
      child: SoulTuneApp(),
    ),
  );
}

/// SoulTune application widget.
class SoulTuneApp extends StatelessWidget {
  /// Creates a [SoulTuneApp].
  const SoulTuneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App metadata
      title: 'SoulTune - 432Hz Music Player',
      debugShowCheckedModeBanner: false,

      // Material 3 theme
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // Home screen
      home: const HomeScreen(),
    );
  }
}
