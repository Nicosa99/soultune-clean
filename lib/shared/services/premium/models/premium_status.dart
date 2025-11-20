/// Premium subscription status and entitlements.
///
/// This model encapsulates all premium-related information including
/// subscription status, tier, expiration, and feature entitlements.
///
/// Used by [PremiumService] implementations to communicate subscription
/// state throughout the app.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'premium_status.freezed.dart';
part 'premium_status.g.dart';

/// Premium subscription tier.
///
/// Determines pricing and feature access level.
enum PremiumTier {
  /// Free tier - limited features.
  ///
  /// Access:
  /// - 432 Hz player only
  /// - 1 generator preset (Deep Sleep)
  /// - 432 Hz browser only
  free,

  /// Monthly subscription - $4.99/month.
  ///
  /// Full access to all features.
  monthly,

  /// Annual subscription - $29.99/year (Best Value).
  ///
  /// Full access to all features.
  /// Saves 50% vs monthly ($30/year vs $60/year).
  annual,

  /// Lifetime purchase - $69.99 one-time.
  ///
  /// All features forever, no recurring payments.
  /// Limited availability (launch period only).
  lifetime,
}

/// Premium subscription status model.
///
/// Immutable representation of user's premium subscription state.
/// Used throughout the app to gate features and show upgrade prompts.
///
/// ## Usage
///
/// ```dart
/// final status = ref.watch(premiumStatusProvider);
///
/// if (status.isPremium) {
///   // Grant access to premium features
/// } else {
///   // Show upgrade prompt
/// }
/// ```
@freezed
class PremiumStatus with _$PremiumStatus {
  /// Creates a [PremiumStatus].
  const factory PremiumStatus({
    /// Current subscription tier.
    required PremiumTier tier,

    /// Whether user has active premium subscription.
    ///
    /// True if tier is monthly, annual, or lifetime.
    /// False if tier is free or subscription expired.
    required bool isPremium,

    /// Expiration date for time-limited subscriptions.
    ///
    /// Null for free tier and lifetime purchases.
    /// Present for monthly and annual subscriptions.
    DateTime? expiresAt,

    /// Whether subscription is in grace period.
    ///
    /// True if subscription expired but user still has temporary access
    /// (e.g., payment failed but retrying).
    @Default(false) bool isGracePeriod,

    /// Original purchase date.
    ///
    /// Null for free tier users.
    DateTime? purchasedAt,

    /// Platform-specific subscription identifier.
    ///
    /// Used for subscription management and restoration.
    /// Format: "google_play_subscription_id" or "apple_subscription_id"
    String? subscriptionId,
  }) = _PremiumStatus;

  /// Private constructor for custom getters.
  const PremiumStatus._();

  /// Creates [PremiumStatus] from JSON.
  factory PremiumStatus.fromJson(Map<String, dynamic> json) =>
      _$PremiumStatusFromJson(json);

  /// Free tier status (no premium).
  ///
  /// Default status for new users and users without subscription.
  factory PremiumStatus.free() => const PremiumStatus(
        tier: PremiumTier.free,
        isPremium: false,
      );

  /// Monthly subscription status.
  factory PremiumStatus.monthly({
    required DateTime expiresAt,
    required DateTime purchasedAt,
    String? subscriptionId,
  }) =>
      PremiumStatus(
        tier: PremiumTier.monthly,
        isPremium: true,
        expiresAt: expiresAt,
        purchasedAt: purchasedAt,
        subscriptionId: subscriptionId,
      );

  /// Annual subscription status.
  factory PremiumStatus.annual({
    required DateTime expiresAt,
    required DateTime purchasedAt,
    String? subscriptionId,
  }) =>
      PremiumStatus(
        tier: PremiumTier.annual,
        isPremium: true,
        expiresAt: expiresAt,
        purchasedAt: purchasedAt,
        subscriptionId: subscriptionId,
      );

  /// Lifetime purchase status.
  factory PremiumStatus.lifetime({
    required DateTime purchasedAt,
    String? subscriptionId,
  }) =>
      PremiumStatus(
        tier: PremiumTier.lifetime,
        isPremium: true,
        purchasedAt: purchasedAt,
        subscriptionId: subscriptionId,
      );

  // ---------------------------------------------------------------------------
  // Computed Properties
  // ---------------------------------------------------------------------------

  /// Whether subscription has expired.
  ///
  /// Always false for free tier and lifetime purchases.
  bool get isExpired {
    if (tier == PremiumTier.free || tier == PremiumTier.lifetime) {
      return false;
    }

    if (expiresAt == null) return false;

    return DateTime.now().isAfter(expiresAt!);
  }

  /// Whether subscription expires soon (within 7 days).
  ///
  /// Used to show renewal reminders.
  bool get expiresSoon {
    if (tier == PremiumTier.free || tier == PremiumTier.lifetime) {
      return false;
    }

    if (expiresAt == null) return false;

    final daysUntilExpiry = expiresAt!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 7 && daysUntilExpiry > 0;
  }

  /// Days remaining until expiration.
  ///
  /// Null for free tier, lifetime, or if no expiration date set.
  int? get daysRemaining {
    if (expiresAt == null) return null;

    final diff = expiresAt!.difference(DateTime.now());
    return diff.inDays.clamp(0, double.infinity).toInt();
  }

  /// User-friendly tier display name.
  String get tierDisplayName {
    switch (tier) {
      case PremiumTier.free:
        return 'Free';
      case PremiumTier.monthly:
        return 'Premium Monthly';
      case PremiumTier.annual:
        return 'Premium Annual';
      case PremiumTier.lifetime:
        return 'Lifetime Premium';
    }
  }

  /// User-friendly price display.
  String get priceDisplay {
    switch (tier) {
      case PremiumTier.free:
        return 'Free';
      case PremiumTier.monthly:
        return r'$4.99/month';
      case PremiumTier.annual:
        return r'$29.99/year';
      case PremiumTier.lifetime:
        return r'$69.99 one-time';
    }
  }
}
