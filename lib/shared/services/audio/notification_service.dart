/// SoulTune Notification Service
///
/// Initializes and manages audio_service for system notifications and
/// media controls. Provides a singleton instance of SoulTuneAudioHandler.
///
/// ## Features
///
/// - Initializes audio_service on app startup
/// - Provides global access to AudioHandler
/// - Configures notification style and controls
/// - Handles Android/iOS platform differences
///
/// ## Usage
///
/// ```dart
/// // Initialize during app startup
/// await NotificationService.init();
///
/// // Access audio handler
/// final handler = NotificationService.audioHandler;
/// await handler.playAudioFile(audioFile);
/// ```
library;

import 'package:audio_service/audio_service.dart';
import 'package:logger/logger.dart';
import 'package:soultune/shared/services/audio/soultune_audio_handler.dart';

/// Service for managing system media notifications.
///
/// Wraps audio_service initialization and provides global access to the
/// custom audio handler.
class NotificationService {
  /// Private constructor (singleton pattern).
  NotificationService._();

  /// Logger instance.
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// The audio handler instance.
  static SoulTuneAudioHandler? _audioHandler;

  /// Whether the service is initialized.
  static bool _isInitialized = false;

  /// Gets the audio handler instance.
  ///
  /// Throws if not initialized. Call [init] first.
  static SoulTuneAudioHandler get audioHandler {
    if (_audioHandler == null) {
      throw StateError(
        'NotificationService not initialized. Call NotificationService.init() first.',
      );
    }
    return _audioHandler!;
  }

  /// Whether the service is initialized.
  static bool get isInitialized => _isInitialized;

  /// Initializes audio_service and creates audio handler.
  ///
  /// Must be called during app startup, before using any audio features.
  ///
  /// ## Example
  ///
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await NotificationService.init();
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// ## Throws
  ///
  /// - Exception if initialization fails
  static Future<void> init() async {
    if (_isInitialized) {
      _logger.w('NotificationService already initialized');
      return;
    }

    try {
      _logger.i('Initializing NotificationService...');

      // Initialize audio_service and create handler
      _audioHandler = await AudioService.init(
        builder: () => SoulTuneAudioHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.example.soultune.audio',
          androidNotificationChannelName: 'SoulTune Playback',
          androidNotificationChannelDescription:
              'Notification controls for SoulTune music player',
          androidNotificationOngoing: false,
          androidStopForegroundOnPause: true,
          androidNotificationIcon: 'mipmap/ic_launcher',
          notificationColor: null, // Uses app primary color
        ),
      );

      _isInitialized = true;

      _logger.i('✓ NotificationService initialized');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to initialize NotificationService',
        error: e,
        stackTrace: stackTrace,
      );

      throw Exception('Failed to initialize notification service: $e');
    }
  }

  /// Disposes the notification service.
  ///
  /// Should be called when app is shutting down.
  static Future<void> dispose() async {
    if (!_isInitialized) {
      return;
    }

    _logger.d('Disposing NotificationService...');

    await _audioHandler?.dispose();
    _audioHandler = null;
    _isInitialized = false;

    _logger.i('✓ NotificationService disposed');
  }
}
