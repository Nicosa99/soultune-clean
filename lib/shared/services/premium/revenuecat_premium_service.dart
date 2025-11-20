/// RevenueCat Premium Service Implementation
///
/// Production implementation of PremiumService using RevenueCat SDK.
library;

import 'dart:async';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:soultune/shared/services/premium/models/premium_status.dart';
import 'package:soultune/shared/services/premium/premium_service.dart';
import 'package:soultune/shared/services/premium/revenuecat_config.dart';

/// RevenueCat implementation of [PremiumService].
///
/// This is the production implementation that uses RevenueCat SDK
/// for real subscription management.
///
/// ## Usage
///
/// ```dart
/// final service = RevenueCatPremiumService();
/// await service.initialize();
///
/// // Listen to status changes
/// service.statusStream.listen((status) {
///   print('Premium status: ${status.isPremium}');
/// });
///
/// // Purchase subscription
/// final success = await service.purchaseAnnual();
/// ```
class RevenueCatPremiumService implements PremiumService {
  /// Creates a [RevenueCatPremiumService].
  RevenueCatPremiumService() {
    _logger.i('🎫 RevenueCatPremiumService created');
  }

  /// Logger instance for debug output.
  final _logger = Logger();

  /// Stream controller for premium status updates.
  final _statusController = StreamController<PremiumStatus>.broadcast();

  /// Current premium status (cached).
  PremiumStatus _currentStatus = PremiumStatus.free();

  /// Whether the service has been initialized.
  bool _isInitialized = false;

  @override
  PremiumStatus get currentStatus => _currentStatus;

  @override
  Stream<PremiumStatus> get statusStream => _statusController.stream;

  @override
  bool get isPremium => _currentStatus.isPremium;

  @override
  bool get hasActiveSubscription =>
      _currentStatus.isPremium && _currentStatus.tier != PremiumTier.lifetime;

  @override
  PremiumTier get currentTier => _currentStatus.tier;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.w('⚠️  RevenueCat already initialized');
      return;
    }

    _logger.i('🚀 Initializing RevenueCat SDK...');

    try {
      // Configure SDK
      final configuration = PurchasesConfiguration(
        RevenueCatConfig.getApiKey()!,
      );

      if (RevenueCatConfig.enableDebugLogs) {
        configuration.logLevel = LogLevel.debug;
      }

      // Initialize Purchases
      await Purchases.configure(configuration);

      _logger.i('✅ RevenueCat SDK initialized');

      // Set up customer info listener
      Purchases.addCustomerInfoUpdateListener(_handleCustomerInfoUpdate);

      // Fetch initial customer info
      await refreshStatus();

      _isInitialized = true;
      _logger.i('✅ RevenueCatPremiumService fully initialized');
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to initialize RevenueCat', error: e, stackTrace: stackTrace);
      throw PremiumServiceException('Failed to initialize RevenueCat: $e');
    }
  }

  @override
  Future<PremiumStatus> refreshStatus() async {
    _logger.i('🔄 Refreshing customer info...');

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _currentStatus = _parseCustomerInfo(customerInfo);

      _logger.i(
        '✅ Customer info refreshed: '
        'Premium=${_currentStatus.isPremium}, '
        'Tier=${_currentStatus.tier.name}',
      );

      _statusController.add(_currentStatus);
      return _currentStatus;
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to refresh status', error: e, stackTrace: stackTrace);
      throw PremiumServiceException('Failed to refresh status: $e');
    }
  }

  @override
  Future<bool> purchaseMonthly() async {
    return _purchaseProduct(RevenueCatConfig.productIdMonthly);
  }

  @override
  Future<bool> purchaseAnnual() async {
    return _purchaseProduct(RevenueCatConfig.productIdYearly);
  }

  @override
  Future<bool> purchaseLifetime() async {
    return _purchaseProduct(RevenueCatConfig.productIdLifetime);
  }

  @override
  Future<bool> startFreeTrial() async {
    // RevenueCat handles trials automatically via store configuration
    // Trial is attached to the product, so we purchase the annual product
    _logger.i('🎁 Starting free trial (via annual subscription)...');
    return purchaseAnnual();
  }

  @override
  Future<bool> restorePurchases() async {
    _logger.i('🔄 Restoring purchases...');

    try {
      final customerInfo = await Purchases.restorePurchases();
      _currentStatus = _parseCustomerInfo(customerInfo);

      _logger.i('✅ Purchases restored');
      _statusController.add(_currentStatus);

      return _currentStatus.isPremium;
    } on PlatformException catch (e) {
      _logger.e('❌ Failed to restore purchases: ${e.message}');
      throw PremiumServiceException('Failed to restore purchases: ${e.message}');
    }
  }

  @override
  Future<void> openSubscriptionManagement() async {
    _logger.i('📱 Opening subscription management...');

    try {
      if (Platform.isAndroid) {
        // Open Google Play subscriptions
        await Purchases.showInAppMessages();
      } else if (Platform.isIOS) {
        // Open App Store subscriptions
        // Note: This requires iOS 15+
        // For older iOS versions, direct user to Settings > [User] > Subscriptions
        final customerInfo = await Purchases.getCustomerInfo();
        final managementUrl = customerInfo.managementURL;

        if (managementUrl != null) {
          _logger.i('📎 Management URL: $managementUrl');
          // TODO: Open URL with url_launcher when needed
        }
      }
    } catch (e) {
      _logger.e('❌ Failed to open subscription management: $e');
    }
  }

  @override
  void dispose() {
    _logger.i('🗑️  Disposing RevenueCatPremiumService');
    _statusController.close();
  }

  // ---------------------------------------------------------------------------
  // Private Methods
  // ---------------------------------------------------------------------------

  /// Purchases a product by identifier.
  Future<bool> _purchaseProduct(String productId) async {
    _logger.i('💳 Purchasing product: $productId');

    try {
      // Get current offerings
      final offerings = await Purchases.getOfferings();
      final offering = offerings.current;

      if (offering == null) {
        _logger.e('❌ No offerings available');
        throw PremiumServiceException('No offerings available');
      }

      // Find package by product ID
      Package? package;
      for (final pkg in offering.availablePackages) {
        if (pkg.storeProduct.identifier == productId) {
          package = pkg;
          break;
        }
      }

      if (package == null) {
        _logger.e('❌ Product not found: $productId');
        throw PremiumServiceException('Product not found: $productId');
      }

      // Make purchase
      _logger.i('💰 Initiating purchase for ${package.storeProduct.title}');
      final purchaseResult = await Purchases.purchasePackage(package);

      // Update status
      _currentStatus = _parseCustomerInfo(purchaseResult.customerInfo);
      _statusController.add(_currentStatus);

      final success = _currentStatus.isPremium;
      _logger.i(success ? '✅ Purchase successful!' : '❌ Purchase failed');

      return success;
    } on PlatformException catch (e) {
      _logger.e('❌ Purchase error: ${e.code} - ${e.message}');

      // Handle specific error codes
      if (e.code == PurchasesErrorHelper.purchaseCancelledError) {
        _logger.i('ℹ️  User cancelled purchase');
        return false;
      }

      throw PremiumServiceException('Purchase failed: ${e.message}');
    }
  }

  /// Parses CustomerInfo into PremiumStatus.
  PremiumStatus _parseCustomerInfo(CustomerInfo customerInfo) {
    // Check for premium entitlement
    final hasPremiumEntitlement = customerInfo.entitlements.active
        .containsKey(RevenueCatConfig.premiumEntitlementId);

    if (!hasPremiumEntitlement) {
      return PremiumStatus.free();
    }

    // Get active entitlement
    final entitlement =
        customerInfo.entitlements.active[RevenueCatConfig.premiumEntitlementId]!;

    // Determine tier based on product identifier
    final productId = entitlement.productIdentifier;
    PremiumTier tier;

    if (productId == RevenueCatConfig.productIdLifetime) {
      tier = PremiumTier.lifetime;
    } else if (productId == RevenueCatConfig.productIdYearly) {
      tier = PremiumTier.annual;
    } else if (productId == RevenueCatConfig.productIdMonthly) {
      tier = PremiumTier.monthly;
    } else {
      _logger.w('⚠️  Unknown product ID: $productId, defaulting to annual');
      tier = PremiumTier.annual;
    }

    // Parse dates
    final expiresDate = entitlement.expirationDate;
    final purchaseDate = entitlement.originalPurchaseDate;

    return PremiumStatus(
      tier: tier,
      isPremium: true,
      expiresAt: expiresDate != null ? DateTime.parse(expiresDate) : null,
      purchasedAt: purchaseDate != null ? DateTime.parse(purchaseDate) : null,
      subscriptionId: productId,
    );
  }

  /// Handles customer info updates from RevenueCat.
  void _handleCustomerInfoUpdate(CustomerInfo customerInfo) {
    _logger.i('🔔 Customer info updated');
    _currentStatus = _parseCustomerInfo(customerInfo);
    _statusController.add(_currentStatus);
  }
}
