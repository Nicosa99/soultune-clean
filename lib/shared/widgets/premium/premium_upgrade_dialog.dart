/// Premium upgrade dialog (paywall).
///
/// Full-screen modal presenting premium subscription options.
/// Optimized for conversion with clear benefits and pricing.
///
/// ## Usage
///
/// ```dart
/// // Show dialog
/// showDialog(
///   context: context,
///   builder: (_) => const PremiumUpgradeDialog(
///     feature: 'CIA Gateway Protocols',
///   ),
/// );
///
/// // Or use convenience method
/// PremiumUpgradeDialog.show(
///   context,
///   feature: 'Advanced Frequency Presets',
/// );
/// ```
///
/// ## Design Principles
///
/// - Clear value proposition (benefits-first)
/// - Social proof (user count, ratings)
/// - Urgency (limited-time offers)
/// - Multiple price points (monthly/annual/lifetime)
/// - Easy restoration (bottom link)
/// - Dismissible (X button)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soultune/shared/services/premium/models/premium_status.dart';
import 'package:soultune/shared/services/premium/premium_providers.dart';

/// Premium upgrade dialog widget.
///
/// Full-screen modal with benefits, pricing, and CTA buttons.
class PremiumUpgradeDialog extends ConsumerStatefulWidget {
  /// Creates a [PremiumUpgradeDialog].
  const PremiumUpgradeDialog({
    this.feature,
    this.onUpgradeSuccess,
    super.key,
  });

  /// Feature name that triggered the upgrade prompt.
  ///
  /// Used for analytics and contextual messaging.
  /// Example: "CIA Gateway Protocols", "528 Hz Frequency"
  final String? feature;

  /// Callback when upgrade succeeds.
  ///
  /// Called after successful purchase with new premium status.
  final void Function(PremiumStatus status)? onUpgradeSuccess;

  @override
  ConsumerState<PremiumUpgradeDialog> createState() =>
      _PremiumUpgradeDialogState();

  /// Show the upgrade dialog.
  ///
  /// Convenience method for showing dialog.
  static Future<void> show(
    BuildContext context, {
    String? feature,
    void Function(PremiumStatus status)? onUpgradeSuccess,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => PremiumUpgradeDialog(
        feature: feature,
        onUpgradeSuccess: onUpgradeSuccess,
      ),
    );
  }
}

class _PremiumUpgradeDialogState
    extends ConsumerState<PremiumUpgradeDialog> {
  PremiumTier _selectedTier = PremiumTier.annual; // Default to best value
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  _buildHeader(theme),
                  const SizedBox(height: 24),

                  // Feature context (if provided)
                  if (widget.feature != null) ...[
                    _buildFeatureContext(theme),
                    const SizedBox(height: 24),
                  ],

                  // Benefits list
                  _buildBenefits(theme),
                  const SizedBox(height: 24),

                  // Pricing options
                  _buildPricingOptions(theme),
                  const SizedBox(height: 24),

                  // CTA buttons
                  _buildCTAButtons(theme),
                  const SizedBox(height: 16),

                  // Restore purchases link
                  _buildRestoreLink(theme),
                  const SizedBox(height: 8),

                  // Legal text
                  _buildLegalText(theme),
                ],
              ),
            ),

            // Close button
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close',
              ),
            ),

            // Loading overlay
            if (_isProcessing)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        // Premium icon
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFB300), Color(0xFFFFA000)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB300).withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.workspace_premium_rounded,
            size: 36,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          'Unlock Your Full Potential',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Experience CIA-backed meditation and healing frequencies',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeatureContext(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB300).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFB300).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lock_open_rounded,
            color: Color(0xFFFFB300),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Unlock "${widget.feature}"',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefits(ThemeData theme) {
    final benefits = [
      _Benefit(
        icon: Icons.music_note_rounded,
        title: 'All Solfeggio Frequencies',
        description: '528 Hz, 639 Hz, 741 Hz, 852 Hz, 963 Hz',
      ),
      _Benefit(
        icon: Icons.auto_awesome_rounded,
        title: 'CIA Gateway Protocols',
        description: 'Focus 10, 12, 15, 21 - Declassified techniques',
      ),
      _Benefit(
        icon: Icons.nights_stay_rounded,
        title: 'OBE & Astral Projection',
        description: 'Advanced consciousness exploration presets',
      ),
      _Benefit(
        icon: Icons.psychology_rounded,
        title: 'Remote Viewing Training',
        description: 'Project Stargate protocols',
      ),
      _Benefit(
        icon: Icons.tune_rounded,
        title: 'Custom Frequency Generator',
        description: 'Create and save unlimited presets',
      ),
      _Benefit(
        icon: Icons.web_rounded,
        title: 'Full Browser Integration',
        description: 'All frequencies on YouTube, Spotify Web, etc.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What you\'ll get:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...benefits.map((benefit) => _buildBenefitItem(theme, benefit)),
      ],
    );
  }

  Widget _buildBenefitItem(ThemeData theme, _Benefit benefit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB300).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              benefit.icon,
              size: 20,
              color: const Color(0xFFFFB300),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  benefit.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingOptions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose your plan:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildPricingOption(
          theme,
          tier: PremiumTier.annual,
          price: r'$29.99/year',
          subtitle: 'Save 50% - Best Value',
          badge: 'RECOMMENDED',
        ),
        const SizedBox(height: 8),
        _buildPricingOption(
          theme,
          tier: PremiumTier.monthly,
          price: r'$4.99/month',
          subtitle: 'Try first, cancel anytime',
        ),
        const SizedBox(height: 8),
        _buildPricingOption(
          theme,
          tier: PremiumTier.lifetime,
          price: r'$69.99 one-time',
          subtitle: 'Pay once, use forever',
          badge: 'LIMITED',
        ),
      ],
    );
  }

  Widget _buildPricingOption(
    ThemeData theme, {
    required PremiumTier tier,
    required String price,
    required String subtitle,
    String? badge,
  }) {
    final isSelected = _selectedTier == tier;

    return GestureDetector(
      onTap: () => setState(() => _selectedTier = tier),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFB300).withOpacity(0.1)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFB300)
                : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio button
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFFFFB300) : null,
            ),
            const SizedBox(width: 12),

            // Price info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        price,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTAButtons(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary CTA
        FilledButton(
          onPressed: _isProcessing ? null : _handlePurchase,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFFB300),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _selectedTier == PremiumTier.lifetime
                ? 'Buy Lifetime Access'
                : 'Start Subscription',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Secondary CTA (Free trial)
        if (_selectedTier != PremiumTier.lifetime)
          OutlinedButton(
            onPressed: _isProcessing ? null : _handleFreeTrial,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Try Free for 7 Days',
              style: theme.textTheme.titleMedium,
            ),
          ),
      ],
    );
  }

  Widget _buildRestoreLink(ThemeData theme) {
    return Center(
      child: TextButton(
        onPressed: _isProcessing ? null : _handleRestore,
        child: Text(
          'Restore Purchases',
          style: theme.textTheme.bodyMedium?.copyWith(
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildLegalText(ThemeData theme) {
    return Text(
      'Subscriptions automatically renew unless cancelled at least '
      '24 hours before the end of the current period. '
      'Cancel anytime in your account settings.',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.5),
        fontSize: 11,
      ),
      textAlign: TextAlign.center,
    );
  }

  // -------------------------------------------------------------------------
  // Actions
  // -------------------------------------------------------------------------

  Future<void> _handlePurchase() async {
    setState(() => _isProcessing = true);

    try {
      late final Future<bool> Function() purchaseAction;

      switch (_selectedTier) {
        case PremiumTier.monthly:
          purchaseAction = ref.read(purchaseMonthlyActionProvider);
        case PremiumTier.annual:
          purchaseAction = ref.read(purchaseAnnualActionProvider);
        case PremiumTier.lifetime:
          purchaseAction = ref.read(purchaseLifetimeActionProvider);
        case PremiumTier.free:
          return; // Should never happen
      }

      final success = await purchaseAction();

      if (success && mounted) {
        // Get new status
        final newStatus = ref.read(premiumServiceProvider).currentStatus;

        // Callback
        widget.onUpgradeSuccess?.call(newStatus);

        // Close dialog
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Premium activated! Welcome aboard!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: $e'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleFreeTrial() async {
    // NOTE: In production (RevenueCat), this triggers the platform's
    // native free trial via Google Play/App Store subscription APIs.
    // The trial period (7 days) is configured in the Store Console.
    // No credit card required - handled automatically by the platform.
    setState(() => _isProcessing = true);

    try {
      final trialAction = ref.read(startFreeTrialActionProvider);
      final success = await trialAction();

      if (success && mounted) {
        final newStatus = ref.read(premiumServiceProvider).currentStatus;
        widget.onUpgradeSuccess?.call(newStatus);

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎁 7-day trial started! Enjoy full access!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trial activation failed: $e'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isProcessing = true);

    try {
      final restoreAction = ref.read(restorePurchasesActionProvider);
      final restored = await restoreAction();

      if (mounted) {
        if (restored) {
          final newStatus = ref.read(premiumServiceProvider).currentStatus;
          widget.onUpgradeSuccess?.call(newStatus);

          Navigator.of(context).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Purchases restored successfully!'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No purchases found to restore'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

// -----------------------------------------------------------------------------
// Helper Models
// -----------------------------------------------------------------------------

class _Benefit {
  const _Benefit({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
