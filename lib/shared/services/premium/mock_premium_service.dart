/// Mock implementation of [PremiumService] for development and testing.
///
/// This implementation simulates premium subscription behavior without
/// actual payment processing. Used during development to test premium
/// features and UI flows.
///
/// ## Behavior
///
/// - Initial status: FREE tier
/// - Purchase methods: Simulate 2-second delay, always succeed
/// - Restore: Returns false (no purchases to restore)
/// - Status changes: Emit via stream for UI testing
///
/// ## Usage
///
/// ```dart
/// // In development, inject mock service
/// final premiumService = MockPremiumService();
/// await premiumService.initialize();
///
/// // Simulate purchase
/// final success = await premiumService.purchaseAnnual();
/// // After 2s delay, user becomes premium
/// ```
///
/// ## Testing Premium Features
///
/// To test premium features without payment:
/// ```dart
/// final mockService = MockPremiumService();
/// await mockService.initialize();
///
/// // Force premium status for testing
/// await mockService.purchaseLifetime();
/// // Now isPremium = true
/// ```
library;

import 'dart:async';

import 'package:logger/logger.dart';
import 'package:soultune/shared/services/premium/models/premium_status.dart';
import 'package:soultune/shared/services/premium/premium_service.dart';

/// Mock premium service implementation.
///
/// For development and testing only. Replace with production
/// implementation (RevenueCat) before release.
class MockPremiumService implements PremiumService {
  /// Creates a [MockPremiumService].
  MockPremiumService() {
    _logger = Logger();
  }

  late final Logger _logger;

  final _statusController = StreamController<PremiumStatus>.broadcast();
  PremiumStatus _currentStatus = PremiumStatus.free();
  bool _isInitialized = false;

  @override
  Stream<PremiumStatus> get statusStream => _statusController.stream;

  @override
  PremiumStatus get currentStatus => _currentStatus;

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isPremium => _currentStatus.isPremium;

  @override
  bool get isFree => _currentStatus.tier == PremiumTier.free;

  @override
  bool get expiresSoon => _currentStatus.expiresSoon;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  @override
  Future<void> initialize() async {
    _logger.i('🧪 MockPremiumService: Initializing...');

    // Simulate initialization delay
    await Future<void>.delayed(const Duration(milliseconds: 500));

    _isInitialized = true;
    _logger.i('✅ MockPremiumService: Initialized (FREE tier)');

    // Emit initial status
    _statusController.add(_currentStatus);
  }

  @override
  Future<PremiumStatus> refreshStatus() async {
    _logger.d('🔄 MockPremiumService: Refreshing status...');

    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // In mock, status never changes externally
    _logger.d('✅ MockPremiumService: Status refreshed');
    return _currentStatus;
  }

  // ---------------------------------------------------------------------------
  // Purchase Methods
  // ---------------------------------------------------------------------------

  @override
  Future<bool> purchaseMonthly() async {
    _logger.i('💳 MockPremiumService: Purchasing Monthly subscription...');

    // Simulate purchase flow delay
    await Future<void>.delayed(const Duration(seconds: 2));

    final now = DateTime.now();
    final expiresAt = now.add(const Duration(days: 30));

    _currentStatus = PremiumStatus.monthly(
      expiresAt: expiresAt,
      purchasedAt: now,
      subscriptionId: 'mock_monthly_${now.millisecondsSinceEpoch}',
    );

    _statusController.add(_currentStatus);
    _logger.i('✅ MockPremiumService: Monthly subscription activated!');
    _logger.i('   Expires: ${expiresAt.toIso8601String()}');

    return true;
  }

  @override
  Future<bool> purchaseAnnual() async {
    _logger.i('💳 MockPremiumService: Purchasing Annual subscription...');

    // Simulate purchase flow delay
    await Future<void>.delayed(const Duration(seconds: 2));

    final now = DateTime.now();
    final expiresAt = now.add(const Duration(days: 365));

    _currentStatus = PremiumStatus.annual(
      expiresAt: expiresAt,
      purchasedAt: now,
      subscriptionId: 'mock_annual_${now.millisecondsSinceEpoch}',
    );

    _statusController.add(_currentStatus);
    _logger.i('✅ MockPremiumService: Annual subscription activated!');
    _logger.i('   Expires: ${expiresAt.toIso8601String()}');

    return true;
  }

  @override
  Future<bool> purchaseLifetime() async {
    _logger.i('💳 MockPremiumService: Purchasing Lifetime access...');

    // Simulate purchase flow delay
    await Future<void>.delayed(const Duration(seconds: 2));

    final now = DateTime.now();

    _currentStatus = PremiumStatus.lifetime(
      purchasedAt: now,
      subscriptionId: 'mock_lifetime_${now.millisecondsSinceEpoch}',
    );

    _statusController.add(_currentStatus);
    _logger.i('✅ MockPremiumService: Lifetime access activated!');
    _logger.i('   ♾️  Never expires');

    return true;
  }

  @override
  Future<bool> startFreeTrial() async {
    _logger.i('🎁 MockPremiumService: Starting free trial...');

    // Simulate trial activation delay
    await Future<void>.delayed(const Duration(seconds: 1));

    final now = DateTime.now();
    final expiresAt = now.add(const Duration(days: 7));

    _currentStatus = PremiumStatus.annual(
      expiresAt: expiresAt,
      purchasedAt: now,
      subscriptionId: 'mock_trial_${now.millisecondsSinceEpoch}',
    );

    _statusController.add(_currentStatus);
    _logger.i('✅ MockPremiumService: 7-day trial activated!');
    _logger.i('   Expires: ${expiresAt.toIso8601String()}');

    return true;
  }

  // ---------------------------------------------------------------------------
  // Restoration & Management
  // ---------------------------------------------------------------------------

  @override
  Future<bool> restorePurchases() async {
    _logger.i('🔄 MockPremiumService: Restoring purchases...');

    // Simulate restore delay
    await Future<void>.delayed(const Duration(seconds: 1));

    // Mock: No purchases to restore
    _logger.w('⚠️  MockPremiumService: No purchases found to restore');

    return false;
  }

  @override
  Future<void> openSubscriptionManagement() async {
    _logger.i('⚙️  MockPremiumService: Opening subscription management...');

    // In mock, just log
    _logger.i('   (Would open platform subscription settings)');

    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  // ---------------------------------------------------------------------------
  // Development Helpers
  // ---------------------------------------------------------------------------

  /// Reset to free tier (for testing).
  ///
  /// Development-only method to reset premium status.
  void resetToFree() {
    _logger.w('🔄 MockPremiumService: Resetting to FREE tier');

    _currentStatus = PremiumStatus.free();
    _statusController.add(_currentStatus);

    _logger.i('✅ MockPremiumService: Reset complete');
  }

  /// Force premium status (for testing UI).
  ///
  /// Development-only method to bypass purchase flow.
  void forcePremium({PremiumTier tier = PremiumTier.annual}) {
    _logger.w('⚠️  MockPremiumService: FORCING premium status');

    final now = DateTime.now();

    switch (tier) {
      case PremiumTier.free:
        _currentStatus = PremiumStatus.free();
      case PremiumTier.monthly:
        _currentStatus = PremiumStatus.monthly(
          expiresAt: now.add(const Duration(days: 30)),
          purchasedAt: now,
          subscriptionId: 'mock_forced_monthly',
        );
      case PremiumTier.annual:
        _currentStatus = PremiumStatus.annual(
          expiresAt: now.add(const Duration(days: 365)),
          purchasedAt: now,
          subscriptionId: 'mock_forced_annual',
        );
      case PremiumTier.lifetime:
        _currentStatus = PremiumStatus.lifetime(
          purchasedAt: now,
          subscriptionId: 'mock_forced_lifetime',
        );
    }

    _statusController.add(_currentStatus);
    _logger.i('✅ MockPremiumService: Forced to $tier');
  }

  // ---------------------------------------------------------------------------
  // Disposal
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _logger.d('🗑️  MockPremiumService: Disposing...');

    _statusController.close();
    _isInitialized = false;

    _logger.d('✅ MockPremiumService: Disposed');
  }
}
