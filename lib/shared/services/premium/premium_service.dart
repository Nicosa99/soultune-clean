/// Premium subscription service interface.
///
/// Defines the contract for premium subscription management across
/// different implementations (RevenueCat, Google Play Billing, etc.).
///
/// This abstraction allows for:
/// - Easy testing with mock implementations
/// - Platform-agnostic subscription logic
/// - Future integration with different payment providers
library;

import 'package:soultune/shared/services/premium/models/premium_status.dart';

/// Abstract premium subscription service.
///
/// Implementations must provide:
/// - Real-time subscription status
/// - Purchase initiation
/// - Subscription restoration
/// - Status change notifications
///
/// ## Implementations
///
/// - [MockPremiumService]: Development/testing (always free)
/// - RevenueCatPremiumService: Production (coming soon)
///
/// ## Usage
///
/// ```dart
/// // Inject via Riverpod
/// final premiumService = ref.watch(premiumServiceProvider);
///
/// // Check status
/// final status = await premiumService.getStatus();
/// if (status.isPremium) {
///   // Grant access
/// }
///
/// // Initiate purchase
/// await premiumService.purchaseMonthly();
///
/// // Restore purchases
/// await premiumService.restorePurchases();
/// ```
abstract class PremiumService {
  /// Stream of premium status changes.
  ///
  /// Emits new [PremiumStatus] whenever subscription state changes:
  /// - Purchase completed
  /// - Subscription expired
  /// - Subscription restored
  /// - Grace period started/ended
  ///
  /// UI should listen to this stream to reactively update premium features.
  Stream<PremiumStatus> get statusStream;

  /// Current premium status.
  ///
  /// Returns cached status synchronously.
  /// For most recent status, await [refreshStatus] first.
  PremiumStatus get currentStatus;

  /// Refresh premium status from backend.
  ///
  /// Queries subscription provider (Google Play, App Store) for latest
  /// subscription state. Updates [statusStream] if changed.
  ///
  /// Call this on:
  /// - App launch
  /// - Return from background
  /// - After purchase flow
  /// - Manual refresh by user
  ///
  /// Returns updated [PremiumStatus].
  Future<PremiumStatus> refreshStatus();

  /// Initialize premium service.
  ///
  /// Must be called before any other methods.
  /// Typically called in app initialization (main.dart).
  ///
  /// Performs:
  /// - SDK initialization (RevenueCat, etc.)
  /// - Initial status fetch
  /// - Event listener setup
  ///
  /// Throws [PremiumServiceException] if initialization fails.
  Future<void> initialize();

  /// Whether service has been initialized.
  bool get isInitialized;

  // ---------------------------------------------------------------------------
  // Purchase Methods
  // ---------------------------------------------------------------------------

  /// Purchase monthly subscription ($4.99/month).
  ///
  /// Initiates platform-specific purchase flow.
  ///
  /// Returns true if purchase successful, false if cancelled.
  /// Throws [PremiumServiceException] on errors.
  ///
  /// On success, [statusStream] will emit updated status.
  Future<bool> purchaseMonthly();

  /// Purchase annual subscription ($29.99/year).
  ///
  /// Best value option (50% savings vs monthly).
  ///
  /// Returns true if purchase successful, false if cancelled.
  /// Throws [PremiumServiceException] on errors.
  Future<bool> purchaseAnnual();

  /// Purchase lifetime access ($69.99 one-time).
  ///
  /// Limited availability during launch period.
  ///
  /// Returns true if purchase successful, false if cancelled.
  /// Throws [PremiumServiceException] on errors.
  Future<bool> purchaseLifetime();

  /// Start free trial (7 days, no credit card).
  ///
  /// Available for first-time users only.
  ///
  /// Returns true if trial started, false if user cancelled.
  /// Throws [PremiumServiceException] if user ineligible.
  Future<bool> startFreeTrial();

  // ---------------------------------------------------------------------------
  // Restoration & Management
  // ---------------------------------------------------------------------------

  /// Restore previous purchases.
  ///
  /// Required for:
  /// - New device login
  /// - App reinstall
  /// - Manual restore by user
  ///
  /// Queries platform (Google Play, App Store) for existing purchases
  /// linked to user's account.
  ///
  /// Returns true if purchases found and restored.
  /// Returns false if no purchases found.
  /// Throws [PremiumServiceException] on errors.
  Future<bool> restorePurchases();

  /// Cancel active subscription.
  ///
  /// Opens platform-specific subscription management:
  /// - Google Play: Subscription settings
  /// - App Store: Subscription management
  ///
  /// Note: Cancellation is handled by platform, not in-app.
  /// User retains access until current period ends.
  Future<void> openSubscriptionManagement();

  // ---------------------------------------------------------------------------
  // Entitlement Checks (Convenience Methods)
  // ---------------------------------------------------------------------------

  /// Check if user has premium access.
  ///
  /// Convenience method for `currentStatus.isPremium`.
  /// Use this for quick premium checks in UI.
  bool get isPremium => currentStatus.isPremium;

  /// Check if user is on free tier.
  bool get isFree => currentStatus.tier == PremiumTier.free;

  /// Check if subscription expires soon (within 7 days).
  ///
  /// Use this to show renewal reminders.
  bool get expiresSoon => currentStatus.expiresSoon;

  /// Dispose resources.
  ///
  /// Called when service is no longer needed.
  /// Closes streams, cancels listeners, etc.
  void dispose();
}

/// Exception thrown by [PremiumService] implementations.
///
/// Used for all premium-related errors:
/// - Initialization failures
/// - Purchase errors
/// - Network errors
/// - Platform errors
class PremiumServiceException implements Exception {
  /// Creates a [PremiumServiceException].
  const PremiumServiceException(this.message, [this.cause]);

  /// Human-readable error message.
  final String message;

  /// Optional underlying cause/error.
  final Object? cause;

  @override
  String toString() {
    if (cause != null) {
      return 'PremiumServiceException: $message (caused by: $cause)';
    }
    return 'PremiumServiceException: $message';
  }
}
