/// SoulTune Permission Service
///
/// Manages runtime permissions for Android platform, specifically handling
/// storage access required to scan and play local music files.
///
/// ## Android Storage Permissions Evolution
///
/// - **Android 6-9 (API 23-28)**: `READ_EXTERNAL_STORAGE`
/// - **Android 10-12 (API 29-31)**: Scoped Storage + `READ_EXTERNAL_STORAGE`
/// - **Android 13+ (API 33+)**: `READ_MEDIA_AUDIO` (granular media permissions)
///
/// This service handles all API level differences automatically.
///
/// ## Usage
///
/// ```dart
/// final permissionService = PermissionService();
///
/// // Check permission status
/// final hasPermission = await permissionService.hasStoragePermission();
///
/// // Request permission
/// final granted = await permissionService.requestStoragePermission();
///
/// if (!granted) {
///   // Guide user to settings
///   await permissionService.openAppSettings();
/// }
/// ```
library;

import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:soultune/shared/exceptions/app_exceptions.dart';

/// Service for managing runtime permissions on Android/iOS.
///
/// Handles storage permissions required for accessing local music files.
/// Automatically adapts to different Android API levels and provides
/// user-friendly permission flow management.
class PermissionService {
  /// Creates a [PermissionService] instance.
  PermissionService() {
    _logger.d('PermissionService initialized');
  }

  /// Logger instance for debugging and error tracking.
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  // ---------------------------------------------------------------------------
  // Storage Permission Methods
  // ---------------------------------------------------------------------------

  /// Checks if storage permission is currently granted.
  ///
  /// Returns `true` if the app has access to read audio files from external
  /// storage. The specific permission checked depends on Android API level:
  ///
  /// - Android 13+ (API 33+): Checks `READ_MEDIA_AUDIO`
  /// - Android 6-12 (API 23-32): Checks `READ_EXTERNAL_STORAGE`
  ///
  /// ## Example
  ///
  /// ```dart
  /// if (await permissionService.hasStoragePermission()) {
  ///   // Proceed with library scan
  ///   scanMusicLibrary();
  /// } else {
  ///   // Request permission first
  ///   await permissionService.requestStoragePermission();
  /// }
  /// ```
  ///
  /// ## Returns
  ///
  /// `true` if permission is granted, `false` otherwise.
  Future<bool> hasStoragePermission() async {
    try {
      _logger.d('Checking storage permission status...');

      // Android 13+ uses granular media permissions
      final Permission permission = _getStoragePermission();

      final status = await permission.status;
      final granted = status.isGranted;

      _logger.i(
        'Storage permission status: ${status.name} (granted: $granted)',
      );

      return granted;
    } on Exception catch (e, stackTrace) {
      _logger.e(
        'Error checking storage permission',
        error: e,
        stackTrace: stackTrace,
      );

      // If we can't check permissions, assume denied for safety
      return false;
    }
  }

  /// Requests storage permission from the user.
  ///
  /// Displays the system permission dialog to the user. The behavior differs
  /// based on previous user interactions:
  ///
  /// - **First Request**: Shows standard permission dialog
  /// - **Denied Once**: Shows dialog again (user can still grant)
  /// - **Permanently Denied**: Returns false immediately (must use Settings)
  ///
  /// ## Returns
  ///
  /// `true` if permission was granted, `false` if denied.
  ///
  /// ## Throws
  ///
  /// - [PermissionException.permanentlyDenied]: If user permanently denied
  ///   permission. App should guide user to Settings in this case.
  ///
  /// ## Example
  ///
  /// ```dart
  /// try {
  ///   final granted = await permissionService.requestStoragePermission();
  ///
  ///   if (granted) {
  ///     // Permission granted - proceed with music scan
  ///     scanMusicLibrary();
  ///   } else {
  ///     // Permission denied - show explanation
  ///     showPermissionRationale();
  ///   }
  /// } on PermissionException catch (e) {
  ///   if (e.isPermanentlyDenied) {
  ///     // Guide user to app settings
  ///     showSettingsDialog();
  ///   }
  /// }
  /// ```
  Future<bool> requestStoragePermission() async {
    try {
      _logger.i('Requesting storage permission...');

      final Permission permission = _getStoragePermission();

      // Check if already granted
      if (await permission.isGranted) {
        _logger.d('Permission already granted');
        return true;
      }

      // Check if permanently denied
      if (await permission.isPermanentlyDenied) {
        _logger.w('Permission permanently denied');
        throw const PermissionException.permanentlyDenied(
          'Storage permission is permanently denied. '
          'Please enable it in app settings to access your music library.',
        );
      }

      // Request permission
      final status = await permission.request();

      final granted = status.isGranted;
      _logger.i('Permission request result: ${status.name} (granted: $granted)');

      // Check if user permanently denied this time
      if (status.isPermanentlyDenied) {
        _logger.w('User permanently denied permission');
        throw const PermissionException.permanentlyDenied(
          'Storage permission is required to access your music library. '
          'Please enable it in app settings.',
        );
      }

      if (!granted) {
        _logger.w('User denied permission');
        throw const PermissionException(
          'Storage permission denied. SoulTune needs access to your music '
          'files to play and transform them to healing frequencies.',
        );
      }

      return granted;
    } on PermissionException {
      // Re-throw PermissionException as-is
      rethrow;
    } on Exception catch (e, stackTrace) {
      _logger.e(
        'Error requesting storage permission',
        error: e,
        stackTrace: stackTrace,
      );

      throw PermissionException(
        'Failed to request storage permission',
        e,
      );
    }
  }

  /// Opens the app's settings page in system settings.
  ///
  /// Use this when permission is permanently denied to guide the user to
  /// manually enable the permission.
  ///
  /// ## Returns
  ///
  /// `true` if settings were opened successfully, `false` otherwise.
  ///
  /// ## Example
  ///
  /// ```dart
  /// Future<void> handlePermanentlyDenied() async {
  ///   final goToSettings = await showDialog<bool>(
  ///     context: context,
  ///     builder: (context) => AlertDialog(
  ///       title: Text('Permission Required'),
  ///       content: Text(
  ///         'Please enable storage permission in app settings to use SoulTune.',
  ///       ),
  ///       actions: [
  ///         TextButton(
  ///           onPressed: () => Navigator.pop(context, false),
  ///           child: Text('Cancel'),
  ///         ),
  ///         ElevatedButton(
  ///           onPressed: () => Navigator.pop(context, true),
  ///           child: Text('Open Settings'),
  ///         ),
  ///       ],
  ///     ),
  ///   );
  ///
  ///   if (goToSettings == true) {
  ///     await permissionService.openAppSettings();
  ///   }
  /// }
  /// ```
  Future<bool> openAppSettings() async {
    try {
      _logger.i('Opening app settings...');

      final opened = await openAppSettings();

      if (opened) {
        _logger.i('App settings opened successfully');
      } else {
        _logger.w('Failed to open app settings');
      }

      return opened;
    } on Exception catch (e, stackTrace) {
      _logger.e(
        'Error opening app settings',
        error: e,
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Helper Methods
  // ---------------------------------------------------------------------------

  /// Returns the appropriate storage permission for the current Android version.
  ///
  /// - Android 13+ (API 33+): Returns `Permission.audio`
  /// - Android 6-12 (API 23-32): Returns `Permission.storage`
  Permission _getStoragePermission() {
    // permission_handler automatically handles API level differences
    // Permission.audio is used for Android 13+
    // Permission.storage is used for older versions
    return Permission.audio;
  }

  /// Checks if the app should show permission rationale.
  ///
  /// Returns `true` if the user previously denied permission but didn't
  /// select "Don't ask again". In this case, the app should explain why
  /// the permission is needed before requesting again.
  ///
  /// ## Example
  ///
  /// ```dart
  /// if (await permissionService.shouldShowRationale()) {
  ///   // Show explanation dialog
  ///   await showDialog(
  ///     context: context,
  ///     builder: (context) => AlertDialog(
  ///       title: Text('Storage Access Required'),
  ///       content: Text(
  ///         'SoulTune needs access to your music files to:\n'
  ///         '• Scan and display your music library\n'
  ///         '• Play audio files\n'
  ///         '• Transform music to healing frequencies (432Hz, etc.)',
  ///       ),
  ///       actions: [
  ///         ElevatedButton(
  ///           onPressed: () {
  ///             Navigator.pop(context);
  ///             permissionService.requestStoragePermission();
  ///           },
  ///           child: Text('Grant Permission'),
  ///         ),
  ///       ],
  ///     ),
  ///   );
  /// }
  /// ```
  Future<bool> shouldShowRationale() async {
    try {
      final permission = _getStoragePermission();
      final status = await permission.status;

      // Should show rationale if denied but not permanently
      final shouldShow = status.isDenied && !status.isPermanentlyDenied;

      _logger.d('Should show permission rationale: $shouldShow');

      return shouldShow;
    } on Exception catch (e) {
      _logger.e('Error checking permission rationale', error: e);
      return false;
    }
  }

  /// Checks all relevant permissions and returns a summary.
  ///
  /// Useful for debugging and diagnostic screens.
  ///
  /// ## Returns
  ///
  /// Map of permission names to their status strings.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final summary = await permissionService.getPermissionSummary();
  /// print('Permission Status:');
  /// summary.forEach((permission, status) {
  ///   print('  $permission: $status');
  /// });
  /// ```
  Future<Map<String, String>> getPermissionSummary() async {
    try {
      final summary = <String, String>{};

      // Check audio permission (Android 13+) or storage (older)
      final audioStatus = await Permission.audio.status;
      summary['Audio/Storage'] = audioStatus.name;

      // Check other potentially useful permissions
      final notificationStatus = await Permission.notification.status;
      summary['Notifications'] = notificationStatus.name;

      _logger.d('Permission summary: $summary');

      return summary;
    } on Exception catch (e) {
      _logger.e('Error getting permission summary', error: e);
      return {'Error': e.toString()};
    }
  }
}
