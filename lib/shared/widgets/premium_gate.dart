/// Premium Gate Widgets - Feature access control
///
/// Provides reusable widgets for gating premium features.
/// Shows paywall when free users try to access premium content.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soultune/shared/providers/premium_providers.dart';
import 'package:soultune/shared/services/premium/premium_service.dart';
import 'package:soultune/shared/widgets/paywall_screen.dart';

/// Premium gate widget - conditionally shows content or upgrade prompt.
///
/// Usage:
/// ```dart
/// PremiumGate(
///   feature: PremiumFeature.customGenerator,
///   child: CustomGeneratorScreen(),
/// )
/// ```
class PremiumGate extends ConsumerWidget {
  /// Creates a [PremiumGate].
  const PremiumGate({
    required this.child,
    this.feature,
    this.fallback,
    super.key,
  });

  /// Content to show if user is premium.
  final Widget child;

  /// Feature being gated (for analytics).
  final PremiumFeature? feature;

  /// Widget to show if user is not premium.
  /// If null, shows default upgrade prompt.
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumAsync = ref.watch(isPremiumProvider);

    return isPremiumAsync.when(
      data: (isPremium) {
        if (isPremium) {
          return child;
        } else {
          return fallback ?? _DefaultUpgradePrompt(feature: feature);
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => child, // Show content on error (fail-open)
    );
  }
}

/// Premium lock icon - shows lock icon on premium content.
///
/// Usage:
/// ```dart
/// Stack(
///   children: [
///     PresetCard(...),
///     PremiumLockIcon(feature: PremiumFeature.ciaGatewayPresets),
///   ],
/// )
/// ```
class PremiumLockIcon extends ConsumerWidget {
  /// Creates a [PremiumLockIcon].
  const PremiumLockIcon({
    required this.feature,
    this.size = 24,
    super.key,
  });

  /// Feature being gated.
  final PremiumFeature feature;

  /// Icon size.
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumAsync = ref.watch(isPremiumProvider);

    return isPremiumAsync.when(
      data: (isPremium) {
        if (isPremium) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock,
            size: size,
            color: Colors.amber,
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Premium badge - shows "PRO" badge on premium content.
///
/// Usage:
/// ```dart
/// Row(
///   children: [
///     Text('Custom Generator'),
///     PremiumBadge(),
///   ],
/// )
/// ```
class PremiumBadge extends ConsumerWidget {
  /// Creates a [PremiumBadge].
  const PremiumBadge({
    this.showIfPremium = false,
    super.key,
  });

  /// If true, shows badge even for premium users.
  final bool showIfPremium;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumAsync = ref.watch(isPremiumProvider);
    final theme = Theme.of(context);

    return isPremiumAsync.when(
      data: (isPremium) {
        if (isPremium && !showIfPremium) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.shade600,
                Colors.orange.shade600,
              ],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'PRO',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Premium button - shows paywall when tapped by free users.
///
/// Usage:
/// ```dart
/// PremiumButton(
///   feature: PremiumFeature.customGenerator,
///   onPressed: () => navigateToCustomGenerator(),
///   child: Text('Create Custom Preset'),
/// )
/// ```
class PremiumButton extends ConsumerWidget {
  /// Creates a [PremiumButton].
  const PremiumButton({
    required this.onPressed,
    required this.child,
    this.feature,
    this.style,
    super.key,
  });

  /// Callback when button is pressed (premium users only).
  final VoidCallback onPressed;

  /// Button content.
  final Widget child;

  /// Feature being gated.
  final PremiumFeature? feature;

  /// Button style.
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumAsync = ref.watch(isPremiumProvider);

    return isPremiumAsync.when(
      data: (isPremium) {
        return ElevatedButton(
          onPressed: () async {
            if (isPremium) {
              onPressed();
            } else {
              // Show paywall
              final upgraded = await Navigator.of(context).push<bool>(
                MaterialPageRoute<bool>(
                  builder: (_) => PaywallScreen(feature: feature),
                  fullscreenDialog: true,
                ),
              );

              // If user upgraded, call onPressed
              if (upgraded == true) {
                onPressed();
              }
            }
          },
          style: style,
          child: child,
        );
      },
      loading: () => ElevatedButton(
        onPressed: null,
        style: style,
        child: child,
      ),
      error: (_, __) => ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
    );
  }
}

/// Default upgrade prompt shown in PremiumGate.
class _DefaultUpgradePrompt extends StatelessWidget {
  const _DefaultUpgradePrompt({this.feature});

  final PremiumFeature? feature;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.shade600,
                    Colors.orange.shade600,
                  ],
                ),
              ),
              child: const Icon(
                Icons.star,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Premium Feature',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Upgrade to SoulTune Pro to unlock this feature',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PaywallScreen(feature: feature),
                      fullscreenDialog: true,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Upgrade to Pro',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper function to show paywall.
///
/// Usage:
/// ```dart
/// final upgraded = await showPaywall(
///   context,
///   feature: PremiumFeature.customGenerator,
/// );
/// if (upgraded) {
///   // User purchased!
/// }
/// ```
Future<bool> showPaywall(
  BuildContext context, {
  PremiumFeature? feature,
  String? offering,
}) async {
  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute<bool>(
      builder: (_) => PaywallScreen(
        feature: feature,
        offering: offering,
      ),
      fullscreenDialog: true,
    ),
  );

  return result ?? false;
}
