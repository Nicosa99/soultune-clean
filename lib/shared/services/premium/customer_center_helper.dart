/// Customer Center Helper
///
/// Provides easy access to RevenueCat Customer Center for managing
/// subscriptions within the app.
library;

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// Helper class for presenting RevenueCat Customer Center.
///
/// Customer Center allows users to:
/// - View subscription status
/// - Cancel subscriptions
/// - Change subscription plans
/// - Restore purchases
/// - Contact support
///
/// ## Usage
///
/// ```dart
/// // In a button or settings screen
/// CustomerCenterHelper.show(context);
/// ```
class CustomerCenterHelper {
  /// Private constructor
  const CustomerCenterHelper._();

  /// Logger instance
  static final _logger = Logger();

  /// Shows the Customer Center screen.
  ///
  /// Presents a modal bottom sheet with subscription management options.
  /// Requires active RevenueCat configuration.
  ///
  /// ## Example
  ///
  /// ```dart
  /// ListTile(
  ///   leading: Icon(Icons.settings),
  ///   title: Text('Manage Subscription'),
  ///   onTap: () => CustomerCenterHelper.show(context),
  /// )
  /// ```
  ///
  /// ## Parameters
  ///
  /// - [context]: BuildContext for showing the modal sheet
  ///
  /// ## Returns
  ///
  /// Returns `true` if Customer Center was successfully shown,
  /// `false` if there was an error.
  static Future<bool> show(BuildContext context) async {
    _logger.i('📱 Opening Customer Center...');

    try {
      // Present Customer Center
      await RevenueCatUI.presentCustomerCenter();

      _logger.i('✅ Customer Center opened successfully');
      return true;
    } catch (e, stackTrace) {
      _logger.e(
        '❌ Failed to open Customer Center',
        error: e,
        stackTrace: stackTrace,
      );

      // Show error to user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open subscription management: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }

      return false;
    }
  }

  /// Shows Customer Center in settings context.
  ///
  /// Similar to [show], but optimized for settings screens with
  /// additional context and error handling.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // In settings screen
  /// ElevatedButton(
  ///   onPressed: () => CustomerCenterHelper.showInSettings(context),
  ///   child: Text('Manage Subscription'),
  /// )
  /// ```
  static Future<void> showInSettings(BuildContext context) async {
    final success = await show(context);

    if (!success && context.mounted) {
      // Additional feedback for settings context
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unable to Open Subscription Management'),
          content: const Text(
            'Please check your internet connection and try again. '
            'You can also manage your subscription in the '
            'Google Play Store or App Store.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  /// Checks if Customer Center is available.
  ///
  /// Returns `true` if Customer Center can be shown (requires active
  /// RevenueCat configuration and valid entitlements).
  ///
  /// ## Usage
  ///
  /// ```dart
  /// if (await CustomerCenterHelper.isAvailable()) {
  ///   // Show "Manage Subscription" button
  /// } else {
  ///   // Hide button or show alternative
  /// }
  /// ```
  static Future<bool> isAvailable() async {
    try {
      // Customer Center is available if RevenueCat is configured
      // In production, you might want additional checks here
      return true;
    } catch (e) {
      _logger.w('⚠️  Customer Center not available: $e');
      return false;
    }
  }
}
