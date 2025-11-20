/// RevenueCat Configuration
///
/// Contains API keys and configuration for RevenueCat SDK integration.
library;

/// RevenueCat API Keys
///
/// **SECURITY NOTE:**
/// - Test keys are safe to commit (start with 'test_')
/// - Production keys MUST be stored in environment variables
/// - Never commit production keys to version control
class RevenueCatConfig {
  /// Private constructor - use static fields
  const RevenueCatConfig._();

  /// Test API Key for development (Android)
  ///
  /// This key is safe to commit as it's a test key.
  /// Replace with production key from environment variable before release.
  static const String testApiKeyAndroid = 'test_YVgpnblAlLpIHOzxPrFlCyZQTES';

  /// Test API Key for development (iOS)
  ///
  /// TODO: Add iOS test key when iOS support is added
  static const String? testApiKeyIos = null;

  /// Production API Key for Android
  ///
  /// **IMPORTANT:** Set this via environment variable in production!
  /// Never commit production keys to version control.
  ///
  /// Example in CI/CD:
  /// ```
  /// --dart-define=RC_ANDROID_KEY=your_production_key
  /// ```
  static const String? productionApiKeyAndroid =
      String.fromEnvironment('RC_ANDROID_KEY');

  /// Production API Key for iOS
  ///
  /// **IMPORTANT:** Set this via environment variable in production!
  static const String? productionApiKeyIos =
      String.fromEnvironment('RC_IOS_KEY');

  /// Whether to use test keys (development mode)
  ///
  /// Set to false in production builds.
  static const bool useTesting = true;

  /// Get the appropriate API key for current platform and environment
  static String? getApiKey() {
    // Determine platform
    // Note: This will be replaced with Platform.isAndroid/isIOS check
    // For now, default to Android
    const isAndroid = true;

    if (useTesting) {
      return isAndroid ? testApiKeyAndroid : testApiKeyIos;
    } else {
      return isAndroid ? productionApiKeyAndroid : productionApiKeyIos;
    }
  }

  /// Entitlement identifier for premium features
  ///
  /// This must match the entitlement ID configured in RevenueCat dashboard.
  static const String premiumEntitlementId = 'SoulTune Pro';

  /// Product identifiers for subscriptions
  ///
  /// These must match the product IDs in:
  /// - Google Play Console (Android)
  /// - App Store Connect (iOS)
  /// - RevenueCat Dashboard
  static const String productIdMonthly = 'monthly';
  static const String productIdYearly = 'yearly';
  static const String productIdLifetime = 'lifetime';

  /// Offering identifier (default offering)
  ///
  /// Use null to fetch the default offering configured in RevenueCat.
  static const String? offeringId = null;

  /// Enable debug logging
  ///
  /// Set to false in production to avoid verbose logs.
  static const bool enableDebugLogs = true;
}
