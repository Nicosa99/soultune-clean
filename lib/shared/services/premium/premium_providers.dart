/// Riverpod providers for premium subscription state management.
///
/// Exposes [PremiumService] and [PremiumStatus] to the app via
/// dependency injection. All premium-related UI should consume
/// these providers.
///
/// ## Providers
///
/// - [premiumServiceProvider]: Singleton premium service instance
/// - [premiumStatusProvider]: Stream of premium status changes
/// - [isPremiumProvider]: Derived boolean for premium status
///
/// ## Usage in Widgets
///
/// ```dart
/// class MyWidget extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final isPremium = ref.watch(isPremiumProvider);
///
///     if (isPremium) {
///       return PremiumFeatureWidget();
///     } else {
///       return UpgradePromptWidget();
///     }
///   }
/// }
/// ```
///
/// ## Purchase Flow
///
/// ```dart
/// // In button onPressed:
/// final service = ref.read(premiumServiceProvider);
/// final success = await service.purchaseAnnual();
///
/// if (success) {
///   // Status automatically updates via stream
///   // UI rebuilds automatically
/// }
/// ```
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soultune/shared/services/premium/mock_premium_service.dart';
import 'package:soultune/shared/services/premium/models/premium_status.dart';
import 'package:soultune/shared/services/premium/premium_service.dart';

part 'premium_providers.g.dart';

// -----------------------------------------------------------------------------
// Service Provider
// -----------------------------------------------------------------------------

/// Premium service singleton provider.
///
/// Provides access to [PremiumService] throughout the app.
///
/// **Current Implementation**: [MockPremiumService] (development)
/// **Production**: Replace with RevenueCatPremiumService
///
/// ## Usage
///
/// ```dart
/// // Access service directly (for actions)
/// final service = ref.read(premiumServiceProvider);
/// await service.purchaseAnnual();
///
/// // Don't use for status checks - use isPremiumProvider instead
/// ```
///
/// **Note**: This provider should NOT be watched for status changes.
/// Use [premiumStatusProvider] or [isPremiumProvider] instead.
@Riverpod(keepAlive: true)
PremiumService premiumService(PremiumServiceRef ref) {
  // TODO: Replace with production service before release
  // return RevenueCatPremiumService();

  final service = MockPremiumService();

  // Initialize on first access
  service.initialize();

  // Dispose when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
}

// -----------------------------------------------------------------------------
// Status Providers
// -----------------------------------------------------------------------------

/// Premium status stream provider.
///
/// Emits [PremiumStatus] whenever subscription state changes.
/// UI widgets should watch this to reactively update premium features.
///
/// ## Usage
///
/// ```dart
/// final statusAsync = ref.watch(premiumStatusProvider);
///
/// return statusAsync.when(
///   data: (status) {
///     if (status.isPremium) {
///       return Text('Premium Active: ${status.tierDisplayName}');
///     } else {
///       return Text('Free Tier');
///     }
///   },
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
@riverpod
Stream<PremiumStatus> premiumStatus(PremiumStatusRef ref) {
  final service = ref.watch(premiumServiceProvider);
  return service.statusStream;
}

/// Derived provider: Is user premium?
///
/// Convenience provider for quick premium checks in UI.
/// Returns true if user has active premium subscription.
///
/// ## Usage
///
/// ```dart
/// final isPremium = ref.watch(isPremiumProvider);
///
/// return isPremium.when(
///   data: (premium) => premium
///       ? PremiumFeature()
///       : UpgradeButton(),
///   loading: () => CircularProgressIndicator(),
///   error: (_, __) => UpgradeButton(), // Default to free on error
/// );
/// ```
///
/// **Best Practice**: For feature gating, default to `false` (free tier)
/// on loading/error states to prevent unauthorized access.
@riverpod
Stream<bool> isPremium(IsPremiumRef ref) {
  return ref
      .watch(premiumStatusProvider.stream)
      .map((status) => status.isPremium);
}

/// Derived provider: Current premium tier.
///
/// Returns user's subscription tier (free, monthly, annual, lifetime).
///
/// ## Usage
///
/// ```dart
/// final tierAsync = ref.watch(premiumTierProvider);
///
/// return tierAsync.when(
///   data: (tier) => Text('Tier: ${tier.name}'),
///   loading: () => Text('Loading...'),
///   error: (_, __) => Text('Free'),
/// );
/// ```
@riverpod
Stream<PremiumTier> premiumTier(PremiumTierRef ref) {
  return ref.watch(premiumStatusProvider.stream).map((status) => status.tier);
}

/// Derived provider: Days until subscription expires.
///
/// Returns number of days remaining, or null for free/lifetime.
///
/// ## Usage
///
/// ```dart
/// final daysAsync = ref.watch(daysUntilExpiryProvider);
///
/// return daysAsync.when(
///   data: (days) {
///     if (days == null) return Text('Never expires');
///     if (days <= 7) return Text('Expires in $days days! Renew now.');
///     return Text('$days days remaining');
///   },
///   loading: () => SizedBox.shrink(),
///   error: (_, __) => SizedBox.shrink(),
/// );
/// ```
@riverpod
Stream<int?> daysUntilExpiry(DaysUntilExpiryRef ref) {
  return ref
      .watch(premiumStatusProvider.stream)
      .map((status) => status.daysRemaining);
}

// -----------------------------------------------------------------------------
// Action Providers
// -----------------------------------------------------------------------------

/// Purchase annual subscription action.
///
/// Returns a function that initiates annual subscription purchase flow.
///
/// ## Usage
///
/// ```dart
/// ElevatedButton(
///   onPressed: () async {
///     final purchaseAction = ref.read(purchaseAnnualActionProvider);
///     final success = await purchaseAction();
///
///     if (success) {
///       ScaffoldMessenger.of(context).showSnackBar(
///         SnackBar(content: Text('Premium activated!')),
///       );
///     }
///   },
///   child: Text('Upgrade to Annual - \$29.99/year'),
/// )
/// ```
@riverpod
Future<bool> Function() purchaseAnnualAction(
  PurchaseAnnualActionRef ref,
) {
  return () async {
    final service = ref.read(premiumServiceProvider);
    return service.purchaseAnnual();
  };
}

/// Purchase monthly subscription action.
///
/// Returns a function that initiates monthly subscription purchase flow.
@riverpod
Future<bool> Function() purchaseMonthlyAction(
  PurchaseMonthlyActionRef ref,
) {
  return () async {
    final service = ref.read(premiumServiceProvider);
    return service.purchaseMonthly();
  };
}

/// Purchase lifetime access action.
///
/// Returns a function that initiates lifetime purchase flow.
@riverpod
Future<bool> Function() purchaseLifetimeAction(
  PurchaseLifetimeActionRef ref,
) {
  return () async {
    final service = ref.read(premiumServiceProvider);
    return service.purchaseLifetime();
  };
}

/// Start free trial action.
///
/// Returns a function that initiates 7-day free trial.
@riverpod
Future<bool> Function() startFreeTrialAction(StartFreeTrialActionRef ref) {
  return () async {
    final service = ref.read(premiumServiceProvider);
    return service.startFreeTrial();
  };
}

/// Restore purchases action.
///
/// Returns a function that restores previous purchases from platform.
///
/// ## Usage
///
/// ```dart
/// TextButton(
///   onPressed: () async {
///     final restoreAction = ref.read(restorePurchasesActionProvider);
///     final restored = await restoreAction();
///
///     if (restored) {
///       ScaffoldMessenger.of(context).showSnackBar(
///         SnackBar(content: Text('Purchases restored!')),
///       );
///     } else {
///       ScaffoldMessenger.of(context).showSnackBar(
///         SnackBar(content: Text('No purchases found')),
///       );
///     }
///   },
///   child: Text('Restore Purchases'),
/// )
/// ```
@riverpod
Future<bool> Function() restorePurchasesAction(
  RestorePurchasesActionRef ref,
) {
  return () async {
    final service = ref.read(premiumServiceProvider);
    return service.restorePurchases();
  };
}
