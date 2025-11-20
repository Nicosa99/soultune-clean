/// RevenueCat Service - Subscription Management
///
/// Wraps RevenueCat SDK functionality with error handling and logging.
/// Handles initialization, customer info, purchases, and entitlements.
library;

import 'dart:async';

import 'package:logger/logger.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat service for subscription management.
///
/// This service wraps the RevenueCat SDK and provides:
/// - SDK initialization
/// - Customer info retrieval
/// - Purchase management
/// - Entitlement checking
/// - Restore purchases
///
/// Usage:
/// ```dart
/// await RevenueCatService.instance.initialize(apiKey: 'your_api_key');
/// final isPro = await RevenueCatService.instance.hasEntitlement('pro');
/// ```
class RevenueCatService {
  RevenueCatService._();

  /// Singleton instance.
  static final RevenueCatService instance = RevenueCatService._();

  /// Logger instance.
  final _logger = Logger();

  /// Whether the service has been initialized.
  bool _isInitialized = false;

  /// Whether the service has been initialized.
  bool get isInitialized => _isInitialized;

  /// Customer info stream controller.
  final _customerInfoController =
      StreamController<CustomerInfo>.broadcast();

  /// Stream of customer info updates.
  ///
  /// Emits whenever customer info changes (purchase, restore, etc.).
  Stream<CustomerInfo> get customerInfoStream =>
      _customerInfoController.stream;

  /// Initialize RevenueCat SDK.
  ///
  /// Must be called before any other RevenueCat operations.
  ///
  /// Parameters:
  /// - [apiKey]: RevenueCat API key (from dashboard)
  /// - [appUserId]: Optional user ID (anonymous by default)
  /// - [observerMode]: If true, SDK won't handle purchases automatically
  ///
  /// Throws [Exception] if initialization fails.
  Future<void> initialize({
    required String apiKey,
    String? appUserId,
    bool observerMode = false,
  }) async {
    if (_isInitialized) {
      _logger.w('RevenueCat already initialized');
      return;
    }

    try {
      _logger.i('Initializing RevenueCat SDK...');

      // Configure SDK
      final configuration = PurchasesConfiguration(apiKey)
        ..appUserID = appUserId
        ..observerMode = observerMode;

      await Purchases.configure(configuration);

      // Set up customer info listener
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _logger.d('Customer info updated');
        _customerInfoController.add(customerInfo);
      });

      // Enable debug logs in debug mode
      await Purchases.setLogLevel(LogLevel.debug);

      _isInitialized = true;
      _logger.i('✅ RevenueCat initialized successfully');

      // Fetch initial customer info
      await getCustomerInfo();
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to initialize RevenueCat',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('RevenueCat initialization failed: $e');
    }
  }

  /// Get current customer info.
  ///
  /// Returns customer info including:
  /// - Active entitlements
  /// - Active subscriptions
  /// - Purchase history
  /// - Original app user ID
  ///
  /// Returns null if SDK not initialized or fetch fails.
  Future<CustomerInfo?> getCustomerInfo() async {
    if (!_isInitialized) {
      _logger.e('RevenueCat not initialized');
      return null;
    }

    try {
      _logger.d('Fetching customer info...');
      final customerInfo = await Purchases.getCustomerInfo();
      _customerInfoController.add(customerInfo);
      return customerInfo;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to get customer info',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Check if user has specific entitlement.
  ///
  /// Entitlements represent access to specific features/content.
  /// Configure entitlements in RevenueCat dashboard.
  ///
  /// Example:
  /// ```dart
  /// final hasPro = await hasEntitlement('pro');
  /// if (hasPro) {
  ///   // Show premium features
  /// }
  /// ```
  ///
  /// Returns true if user has active entitlement, false otherwise.
  Future<bool> hasEntitlement(String entitlementId) async {
    try {
      final customerInfo = await getCustomerInfo();
      if (customerInfo == null) return false;

      final entitlement =
          customerInfo.entitlements.active[entitlementId];
      final hasAccess = entitlement != null;

      _logger.d(
        'Entitlement "$entitlementId": ${hasAccess ? "✅ ACTIVE" : "❌ INACTIVE"}',
      );

      return hasAccess;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to check entitlement: $entitlementId',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Get all active entitlements.
  ///
  /// Returns a map of entitlement IDs to EntitlementInfo objects.
  /// Empty map if no active entitlements or error occurs.
  Future<Map<String, EntitlementInfo>> getActiveEntitlements() async {
    try {
      final customerInfo = await getCustomerInfo();
      if (customerInfo == null) return {};

      return customerInfo.entitlements.active;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to get active entitlements',
        error: e,
        stackTrace: stackTrace,
      );
      return {};
    }
  }

  /// Get available offerings.
  ///
  /// Offerings contain packages (products) configured in RevenueCat.
  /// Typically includes: monthly, annual, lifetime packages.
  ///
  /// Returns null if SDK not initialized or fetch fails.
  Future<Offerings?> getOfferings() async {
    if (!_isInitialized) {
      _logger.e('RevenueCat not initialized');
      return null;
    }

    try {
      _logger.d('Fetching offerings...');
      final offerings = await Purchases.getOfferings();

      if (offerings.current == null) {
        _logger.w('No current offering found');
      } else {
        _logger.i(
          'Current offering: ${offerings.current!.identifier} '
          '(${offerings.current!.availablePackages.length} packages)',
        );
      }

      return offerings;
    } catch (e, stackTrace) {
      _logger.e('Failed to get offerings', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Purchase a package.
  ///
  /// Initiates purchase flow for the given package.
  /// Automatically updates customer info on success.
  ///
  /// Returns:
  /// - CustomerInfo on success
  /// - null on cancellation or error
  ///
  /// Throws [PurchasesException] for purchase errors.
  Future<CustomerInfo?> purchasePackage(Package package) async {
    if (!_isInitialized) {
      _logger.e('RevenueCat not initialized');
      return null;
    }

    try {
      _logger.i('Initiating purchase: ${package.identifier}');
      final purchaseResult = await Purchases.purchasePackage(package);
      _logger.i('✅ Purchase successful!');
      return purchaseResult.customerInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        _logger.i('Purchase cancelled by user');
      } else if (errorCode ==
          PurchasesErrorCode.purchaseNotAllowedError) {
        _logger.e('Purchase not allowed (parental controls?)');
      } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
        _logger.w('Payment pending (will complete later)');
      } else {
        _logger.e('Purchase failed: ${e.message}', error: e);
      }
      return null;
    } catch (e, stackTrace) {
      _logger.e('Unexpected purchase error', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Restore previous purchases.
  ///
  /// Use this when user switches devices or reinstalls app.
  /// Syncs purchases from App Store/Play Store.
  ///
  /// Returns:
  /// - CustomerInfo with restored purchases
  /// - null on error
  Future<CustomerInfo?> restorePurchases() async {
    if (!_isInitialized) {
      _logger.e('RevenueCat not initialized');
      return null;
    }

    try {
      _logger.i('Restoring purchases...');
      final customerInfo = await Purchases.restorePurchases();
      _logger.i('✅ Purchases restored successfully');
      return customerInfo;
    } catch (e, stackTrace) {
      _logger.e('Failed to restore purchases', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Identify user with custom ID.
  ///
  /// Use this to sync purchases across devices for logged-in users.
  /// Call after user logs in.
  ///
  /// Warning: This can transfer purchases to the new user ID.
  Future<CustomerInfo?> login(String appUserId) async {
    if (!_isInitialized) {
      _logger.e('RevenueCat not initialized');
      return null;
    }

    try {
      _logger.i('Logging in user: $appUserId');
      final result = await Purchases.logIn(appUserId);
      _logger.i('✅ User logged in');
      return result.customerInfo;
    } catch (e, stackTrace) {
      _logger.e('Failed to login user', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Log out current user.
  ///
  /// Clears current user ID and generates new anonymous ID.
  /// Call after user logs out.
  Future<CustomerInfo?> logout() async {
    if (!_isInitialized) {
      _logger.e('RevenueCat not initialized');
      return null;
    }

    try {
      _logger.i('Logging out user...');
      final customerInfo = await Purchases.logOut();
      _logger.i('✅ User logged out');
      return customerInfo;
    } catch (e, stackTrace) {
      _logger.e('Failed to logout user', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Get app user ID.
  ///
  /// Returns current user ID (custom or anonymous).
  Future<String?> getAppUserId() async {
    if (!_isInitialized) {
      _logger.e('RevenueCat not initialized');
      return null;
    }

    try {
      return await Purchases.appUserID;
    } catch (e) {
      _logger.e('Failed to get app user ID', error: e);
      return null;
    }
  }

  /// Invalidate customer info cache.
  ///
  /// Forces fresh fetch from RevenueCat servers on next request.
  /// Use sparingly - cached data is usually sufficient.
  Future<void> invalidateCustomerInfoCache() async {
    if (!_isInitialized) {
      _logger.e('RevenueCat not initialized');
      return;
    }

    try {
      await Purchases.invalidateCustomerInfoCache();
      _logger.d('Customer info cache invalidated');
    } catch (e) {
      _logger.e('Failed to invalidate cache', error: e);
    }
  }

  /// Dispose of resources.
  ///
  /// Call when service is no longer needed.
  void dispose() {
    _customerInfoController.close();
  }
}
