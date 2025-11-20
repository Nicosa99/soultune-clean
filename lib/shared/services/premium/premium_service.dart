/// Premium Service - High-level subscription logic
///
/// Provides business logic layer on top of RevenueCat for SoulTune.
/// Handles premium status, feature gating, and subscription management.
library;

import 'dart:async';

import 'package:logger/logger.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:soultune/shared/services/premium/revenue_cat_service.dart';

/// Premium service for SoulTune subscription management.
///
/// This service provides high-level premium logic:
/// - Check if user is premium (has "SoulTune Pro" entitlement)
/// - Stream premium status changes
/// - Feature-specific gating logic
/// - Subscription info retrieval
class PremiumService {
  PremiumService._();

  /// Singleton instance.
  static final PremiumService instance = PremiumService._();

  /// Logger instance.
  final _logger = Logger();

  /// RevenueCat service.
  final _revenueCat = RevenueCatService.instance;

  /// Premium entitlement ID (configured in RevenueCat dashboard).
  static const String _proEntitlementId = 'SoulTune Pro';

  /// Premium status stream controller.
  final _isPremiumController = StreamController<bool>.broadcast();

  /// Stream of premium status updates.
  ///
  /// Emits true when user gains premium access, false when it expires.
  Stream<bool> get isPremiumStream => _isPremiumController.stream;

  /// Current premium status (cached).
  bool _cachedPremiumStatus = false;

  /// Last time premium status was checked.
  DateTime? _lastStatusCheck;

  /// Cache duration (5 minutes).
  static const _cacheDuration = Duration(minutes: 5);

  /// Initialize premium service.
  ///
  /// Sets up listener for customer info changes.
  void initialize() {
    _logger.i('Initializing PremiumService...');

    // Listen to customer info updates from RevenueCat
    _revenueCat.customerInfoStream.listen((customerInfo) {
      final isPremium = customerInfo.entitlements.active
          .containsKey(_proEntitlementId);
      _updatePremiumStatus(isPremium);
    });

    _logger.i('✅ PremiumService initialized');
  }

  /// Check if user is premium.
  ///
  /// Returns cached value if available and fresh (< 5 minutes old).
  /// Otherwise, fetches from RevenueCat.
  ///
  /// This is the primary method for checking premium status.
  Future<bool> isPremium() async {
    // Return cached value if fresh
    if (_lastStatusCheck != null &&
        DateTime.now().difference(_lastStatusCheck!) < _cacheDuration) {
      _logger.d('Returning cached premium status: $_cachedPremiumStatus');
      return _cachedPremiumStatus;
    }

    // Fetch fresh status
    final isPremium = await _revenueCat.hasEntitlement(_proEntitlementId);
    _updatePremiumStatus(isPremium);
    return isPremium;
  }

  /// Update cached premium status and notify listeners.
  void _updatePremiumStatus(bool isPremium) {
    if (_cachedPremiumStatus != isPremium) {
      _logger.i('Premium status changed: $_cachedPremiumStatus → $isPremium');
      _cachedPremiumStatus = isPremium;
      _isPremiumController.add(isPremium);
    }
    _lastStatusCheck = DateTime.now();
  }

  /// Force refresh premium status.
  ///
  /// Bypasses cache and fetches from RevenueCat servers.
  /// Use when you need guaranteed fresh data (e.g., after purchase).
  Future<bool> refreshPremiumStatus() async {
    _logger.d('Force refreshing premium status...');
    await _revenueCat.invalidateCustomerInfoCache();
    _lastStatusCheck = null; // Invalidate cache
    return isPremium();
  }

  /// Get customer info.
  ///
  /// Returns detailed subscription information.
  Future<CustomerInfo?> getCustomerInfo() async {
    return _revenueCat.getCustomerInfo();
  }

  /// Get active subscription info.
  ///
  /// Returns subscription details if user is premium, null otherwise.
  Future<SubscriptionInfo?> getActiveSubscription() async {
    final customerInfo = await _revenueCat.getCustomerInfo();
    if (customerInfo == null) return null;

    final entitlement = customerInfo.entitlements.active[_proEntitlementId];
    if (entitlement == null) return null;

    return SubscriptionInfo(
      productId: entitlement.productIdentifier,
      billingIssueDetected: entitlement.billingIssueDetectedAt != null,
      willRenew: entitlement.willRenew,
      expirationDate: entitlement.expirationDate,
      originalPurchaseDate: entitlement.originalPurchaseDate,
      periodType: entitlement.periodType,
    );
  }

  /// Check if user has access to specific feature.
  ///
  /// Feature-specific gating logic for SoulTune.
  Future<bool> hasFeatureAccess(PremiumFeature feature) async {
    // All premium features require SoulTune Pro entitlement
    return isPremium();
  }

  /// Get offerings (subscription packages).
  Future<Offerings?> getOfferings() async {
    return _revenueCat.getOfferings();
  }

  /// Purchase package.
  Future<CustomerInfo?> purchase(Package package) async {
    final result = await _revenueCat.purchasePackage(package);
    if (result != null) {
      // Purchase successful - refresh status
      await refreshPremiumStatus();
    }
    return result;
  }

  /// Restore purchases.
  Future<bool> restorePurchases() async {
    final customerInfo = await _revenueCat.restorePurchases();
    if (customerInfo != null) {
      await refreshPremiumStatus();
      return _cachedPremiumStatus;
    }
    return false;
  }

  /// Get user ID.
  Future<String?> getUserId() async {
    return _revenueCat.getAppUserId();
  }

  /// Dispose of resources.
  void dispose() {
    _isPremiumController.close();
  }
}

/// Premium features in SoulTune.
enum PremiumFeature {
  /// All Solfeggio frequencies (174-963 Hz).
  allSolfeggioFrequencies,

  /// CIA Gateway Process presets (Focus 10/12/15/21).
  ciaGatewayPresets,

  /// Out-of-Body Experience presets.
  oobePresets,

  /// Remote Viewing presets.
  remoteViewingPresets,

  /// Custom frequency generator.
  customGenerator,

  /// All 23+ binaural beat presets.
  allPresets,

  /// Browser - all frequencies (not just 432 Hz).
  browserAllFrequencies,

  /// Dual-layer audio (all combinations).
  dualLayerAudioUnlimited,

  /// Discovery Lab full content.
  discoveryLabFull,

  /// Gateway Protocol full program.
  gatewayProtocolFull,

  /// Usage analytics & stats.
  usageAnalytics,

  /// Achievements & badges.
  achievements,

  /// Journal for experiences.
  journal,
}

/// Subscription information.
class SubscriptionInfo {
  /// Creates a [SubscriptionInfo].
  const SubscriptionInfo({
    required this.productId,
    required this.billingIssueDetected,
    required this.willRenew,
    this.expirationDate,
    this.originalPurchaseDate,
    this.periodType,
  });

  /// Product identifier (e.g., 'monthly', 'yearly').
  final String productId;

  /// Whether billing issue was detected.
  final bool billingIssueDetected;

  /// Whether subscription will auto-renew.
  final bool willRenew;

  /// Expiration date (null for lifetime).
  final String? expirationDate;

  /// Original purchase date.
  final String? originalPurchaseDate;

  /// Period type (intro, trial, normal).
  final PeriodType? periodType;

  /// Get human-readable subscription type.
  String get type {
    if (expirationDate == null) return 'Lifetime';
    if (productId.contains('month')) return 'Monthly';
    if (productId.contains('year')) return 'Yearly';
    return 'Subscription';
  }

  /// Whether subscription is in trial period.
  bool get isTrial => periodType == PeriodType.trial;

  /// Whether subscription is in intro period.
  bool get isIntro => periodType == PeriodType.intro;
}
