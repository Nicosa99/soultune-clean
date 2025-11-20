/// Premium Providers - Riverpod state management for subscriptions
///
/// Provides reactive premium status and subscription info throughout app.
library;

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soultune/shared/services/premium/premium_service.dart';

part 'premium_providers.g.dart';

/// Premium service provider.
@riverpod
PremiumService premiumService(PremiumServiceRef ref) {
  return PremiumService.instance;
}

/// Premium status provider (stream-based).
///
/// Automatically updates when subscription status changes.
/// Use this for reactive UI that updates when user purchases/restores.
///
/// Example:
/// ```dart
/// final isPremium = ref.watch(isPremiumProvider);
/// isPremium.when(
///   data: (isPro) => isPro ? PremiumContent() : FreeContent(),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => ErrorWidget(err),
/// );
/// ```
@riverpod
Stream<bool> isPremium(IsPremiumRef ref) async* {
  final service = ref.watch(premiumServiceProvider);

  // Emit initial status
  final initialStatus = await service.isPremium();
  yield initialStatus;

  // Stream future updates
  yield* service.isPremiumStream;
}

/// Premium status provider (future-based).
///
/// One-time check for premium status.
/// Use this when you only need to check once (e.g., on screen load).
///
/// Example:
/// ```dart
/// final isPremium = await ref.read(isPremiumFutureProvider.future);
/// if (!isPremium) {
///   // Show upgrade prompt
/// }
/// ```
@riverpod
Future<bool> isPremiumFuture(IsPremiumFutureRef ref) async {
  final service = ref.watch(premiumServiceProvider);
  return service.isPremium();
}

/// Customer info provider.
///
/// Provides detailed subscription information.
/// Returns null if not subscribed or error occurs.
@riverpod
Future<CustomerInfo?> customerInfo(CustomerInfoRef ref) async {
  final service = ref.watch(premiumServiceProvider);
  return service.getCustomerInfo();
}

/// Active subscription provider.
///
/// Returns subscription details if user is premium.
/// Returns null if free tier or error occurs.
@riverpod
Future<SubscriptionInfo?> activeSubscription(
  ActiveSubscriptionRef ref,
) async {
  final service = ref.watch(premiumServiceProvider);
  return service.getActiveSubscription();
}

/// Offerings provider.
///
/// Provides available subscription packages (monthly, yearly, lifetime).
/// Returns null if error occurs.
@riverpod
Future<Offerings?> offerings(OfferingsRef ref) async {
  final service = ref.watch(premiumServiceProvider);
  return service.getOfferings();
}

/// Feature access provider.
///
/// Check if user has access to specific premium feature.
///
/// Example:
/// ```dart
/// final hasAccess = await ref.read(
///   featureAccessProvider(PremiumFeature.ciaGatewayPresets).future,
/// );
/// ```
@riverpod
Future<bool> featureAccess(
  FeatureAccessRef ref,
  PremiumFeature feature,
) async {
  final service = ref.watch(premiumServiceProvider);
  return service.hasFeatureAccess(feature);
}

/// Refresh premium status action.
///
/// Call this after purchase or restore to force refresh.
///
/// Example:
/// ```dart
/// await ref.read(refreshPremiumStatusProvider.future);
/// ```
@riverpod
Future<bool> refreshPremiumStatus(RefreshPremiumStatusRef ref) async {
  final service = ref.watch(premiumServiceProvider);
  return service.refreshPremiumStatus();
}

/// Purchase package action.
///
/// Initiates purchase flow for given package.
///
/// Example:
/// ```dart
/// final purchase = ref.read(purchasePackageProvider);
/// final result = await purchase(package);
/// ```
@riverpod
Future<CustomerInfo?> Function(Package) purchasePackage(
  PurchasePackageRef ref,
) {
  final service = ref.watch(premiumServiceProvider);
  return (package) => service.purchase(package);
}

/// Restore purchases action.
///
/// Restores previous purchases from App Store/Play Store.
///
/// Example:
/// ```dart
/// final restored = await ref.read(restorePurchasesProvider.future);
/// if (restored) {
///   // Show success message
/// }
/// ```
@riverpod
Future<bool> restorePurchases(RestorePurchasesRef ref) async {
  final service = ref.watch(premiumServiceProvider);
  return service.restorePurchases();
}
