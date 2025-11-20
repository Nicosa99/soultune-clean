/// SoulTune - 432Hz Healing Frequency Music Player
///
/// Main entry point for the SoulTune Flutter application.
/// Initializes Hive, services, and starts the app with Riverpod.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soultune/features/home/presentation/screens/home_screen.dart';
import 'package:soultune/shared/services/audio/notification_service.dart';
import 'package:soultune/shared/services/premium/premium_service.dart';
import 'package:soultune/shared/services/premium/revenue_cat_service.dart';
import 'package:soultune/shared/services/storage/hive_service.dart';
import 'package:soultune/shared/theme/app_theme.dart';
import 'package:soultune/shared/widgets/splash_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

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

      // Show splash screen during initialization
      home: const AppInitializer(),
    );
  }
}

/// App initializer widget that shows splash screen during initialization.
class AppInitializer extends StatefulWidget {
  /// Creates an [AppInitializer].
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _initialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Start time for minimum splash duration
      final startTime = DateTime.now();

      debugPrint('🎵 SoulTune initializing...');

      // Initialize Hive database
      await HiveService.instance.init();
      debugPrint('✅ Hive initialized');

      // Initialize notification service for system media controls
      try {
        await NotificationService.init();
        debugPrint(
          '✅ NotificationService initialized - system controls enabled!',
        );
      } catch (e) {
        debugPrint('⚠️ NotificationService failed to initialize: $e');
        debugPrint('📱 App will continue without system notifications');
      }

      // Initialize RevenueCat for subscription management
      try {
        await RevenueCatService.instance.initialize(
          apiKey: 'test_YVgpnblAlLpIHOzxPrFlCyZQTES',
        );
        PremiumService.instance.initialize();
        debugPrint('✅ RevenueCat initialized - subscriptions enabled!');
      } catch (e) {
        debugPrint('⚠️ RevenueCat failed to initialize: $e');
        debugPrint('📱 App will continue without premium features');
      }

      // Ensure minimum splash duration (2.5 seconds for smooth UX)
      final elapsedTime = DateTime.now().difference(startTime);
      final remainingTime = const Duration(milliseconds: 2500) - elapsedTime;

      if (remainingTime > Duration.zero) {
        await Future<void>.delayed(remainingTime);
      }

      debugPrint('✅ SoulTune initialization complete');

      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Initialization error: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize app: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      // Show error screen
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F1E),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 64,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Initialization Error',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _errorMessage = null;
                      _initialized = false;
                    });
                    _initializeApp();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_initialized) {
      // Show splash screen during initialization
      return const SplashScreen();
    }

    // Navigate to home screen
    return const HomeScreen();
  }
}
