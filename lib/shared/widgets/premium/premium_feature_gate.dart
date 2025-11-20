/// Premium feature gate wrapper widget.
///
/// Automatically gates content based on premium subscription status.
/// Shows child widget if premium, shows upgrade prompt if not premium.
///
/// ## Usage
///
/// ```dart
/// // Simple gating
/// PremiumFeatureGate(
///   feature: '528 Hz Frequency',
///   child: FrequencyPlayerWidget(),
/// )
///
/// // Custom fallback
/// PremiumFeatureGate(
///   feature: 'CIA Gateway',
///   fallback: (context, showUpgrade) => Card(
///     child: ListTile(
///       title: Text('Premium Feature'),
///       trailing: PremiumBadge(),
///       onTap: showUpgrade,
///     ),
///   ),
///   child: CIAGatewayWidget(),
/// )
///
/// // With custom upgrade button
/// PremiumFeatureGate.button(
///   feature: 'Advanced Presets',
///   buttonText: 'Unlock 20+ Presets',
///   onPressed: () => navigateToPresets(),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soultune/shared/services/premium/premium_providers.dart';
import 'package:soultune/shared/widgets/premium/premium_badge.dart';
import 'package:soultune/shared/widgets/premium/premium_upgrade_dialog.dart';

/// Premium feature gate widget.
///
/// Conditionally renders premium content or upgrade prompt based on
/// subscription status.
class PremiumFeatureGate extends ConsumerWidget {
  /// Creates a [PremiumFeatureGate].
  const PremiumFeatureGate({
    required this.child,
    this.feature,
    this.fallback,
    this.showBadge = true,
    this.onUpgrade,
    super.key,
  });

  /// Widget to show when user has premium access.
  final Widget child;

  /// Feature name for analytics and messaging.
  ///
  /// Example: "528 Hz Frequency", "CIA Gateway Protocols"
  final String? feature;

  /// Custom fallback widget when not premium.
  ///
  /// If null, shows default upgrade prompt card.
  /// Receives context and showUpgrade callback.
  final Widget Function(BuildContext context, VoidCallback showUpgrade)?
      fallback;

  /// Whether to show premium badge on fallback.
  final bool showBadge;

  /// Custom callback when upgrade is triggered.
  ///
  /// If null, shows [PremiumUpgradeDialog].
  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumAsync = ref.watch(isPremiumProvider);

    return isPremiumAsync.when(
      data: (isPremium) {
        if (isPremium) {
          return child;
        }

        // Not premium - show fallback
        return fallback?.call(context, () => _showUpgrade(context)) ??
            _buildDefaultFallback(context);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (_, __) => _buildDefaultFallback(context), // Fail-safe: free tier
    );
  }

  Widget _buildDefaultFallback(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _showUpgrade(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showBadge) ...[
              const PremiumBadge(size: 48, iconSize: 24),
              const SizedBox(height: 16),
            ],
            Text(
              feature != null ? 'Unlock "$feature"' : 'Premium Feature',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Upgrade to access all premium features',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _showUpgrade(context),
              icon: const Icon(Icons.workspace_premium_rounded),
              label: const Text('Upgrade Now'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFB300),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpgrade(BuildContext context) {
    if (onUpgrade != null) {
      onUpgrade!();
    } else {
      PremiumUpgradeDialog.show(context, feature: feature);
    }
  }

  /// Creates a premium-gated button.
  ///
  /// Shows upgrade dialog when pressed if not premium.
  /// Executes [onPressed] if premium.
  ///
  /// ## Usage
  ///
  /// ```dart
  /// PremiumFeatureGate.button(
  ///   feature: 'Advanced Features',
  ///   buttonText: 'Access Premium Content',
  ///   onPressed: () => navigateToPremiumContent(),
  /// )
  /// ```
  static Widget button({
    required String feature,
    required String buttonText,
    required VoidCallback onPressed,
    IconData? icon,
    Key? key,
  }) {
    return Consumer(
      builder: (context, ref, _) {
        final isPremiumAsync = ref.watch(isPremiumProvider);

        return isPremiumAsync.when(
          data: (isPremium) {
            if (isPremium) {
              // Premium - execute action
              return icon != null
                  ? FilledButton.icon(
                      onPressed: onPressed,
                      icon: Icon(icon),
                      label: Text(buttonText),
                    )
                  : FilledButton(
                      onPressed: onPressed,
                      child: Text(buttonText),
                    );
            }

            // Not premium - show upgrade
            return Stack(
              clipBehavior: Clip.none,
              children: [
                icon != null
                    ? FilledButton.icon(
                        onPressed: () => PremiumUpgradeDialog.show(
                          context,
                          feature: feature,
                        ),
                        icon: Icon(icon),
                        label: Text(buttonText),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB300),
                          foregroundColor: Colors.white,
                        ),
                      )
                    : FilledButton(
                        onPressed: () => PremiumUpgradeDialog.show(
                          context,
                          feature: feature,
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB300),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(buttonText),
                      ),
                const Positioned(
                  top: -4,
                  right: -4,
                  child: PremiumBadge(size: 20, iconSize: 12, animated: false),
                ),
              ],
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => FilledButton(
            onPressed: () => PremiumUpgradeDialog.show(context),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFFB300),
              foregroundColor: Colors.white,
            ),
            child: Text(buttonText),
          ),
        );
      },
    );
  }
}

/// Simple premium check widget.
///
/// Shows [child] if premium, shows [fallback] if not premium.
/// Does not include default upgrade UI - you provide both widgets.
///
/// ## Usage
///
/// ```dart
/// PremiumCheck(
///   child: AdvancedFeatureWidget(),
///   fallback: Text('Premium required'),
/// )
/// ```
class PremiumCheck extends ConsumerWidget {
  /// Creates a [PremiumCheck].
  const PremiumCheck({
    required this.child,
    required this.fallback,
    super.key,
  });

  /// Widget to show when premium.
  final Widget child;

  /// Widget to show when not premium.
  final Widget fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumAsync = ref.watch(isPremiumProvider);

    return isPremiumAsync.when(
      data: (isPremium) => isPremium ? child : fallback,
      loading: () => fallback, // Default to restricted while loading
      error: (_, __) => fallback, // Fail-safe: default to free tier
    );
  }
}

/// Conditional premium wrapper.
///
/// Wraps child with premium badge overlay if not premium and [gated] is true.
///
/// ## Usage
///
/// ```dart
/// ConditionalPremiumWrapper(
///   gated: preset.isPremium,
///   feature: preset.name,
///   child: PresetCard(preset),
/// )
/// ```
class ConditionalPremiumWrapper extends ConsumerWidget {
  /// Creates a [ConditionalPremiumWrapper].
  const ConditionalPremiumWrapper({
    required this.child,
    required this.gated,
    this.feature,
    this.onTap,
    super.key,
  });

  /// Child widget to wrap.
  final Widget child;

  /// Whether this feature is premium-gated.
  final bool gated;

  /// Feature name for upgrade dialog.
  final String? feature;

  /// Custom tap handler when locked.
  ///
  /// If null and gated, shows upgrade dialog.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!gated) {
      return child;
    }

    final isPremiumAsync = ref.watch(isPremiumProvider);

    return isPremiumAsync.when(
      data: (isPremium) {
        if (isPremium) {
          return child;
        }

        // Not premium - show with lock overlay
        return Stack(
          children: [
            // Dimmed child
            Opacity(
              opacity: 0.5,
              child: child,
            ),

            // Lock overlay
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap ??
                      () => PremiumUpgradeDialog.show(
                            context,
                            feature: feature,
                          ),
                  child: Container(
                    alignment: Alignment.center,
                    child: const PremiumBadge(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => child,
      error: (_, __) => Stack(
        children: [
          Opacity(opacity: 0.5, child: child),
          const Positioned.fill(
            child: Center(child: PremiumBadge()),
          ),
        ],
      ),
    );
  }
}
