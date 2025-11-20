/// Paywall Screen - Premium subscription upgrade UI
///
/// Uses RevenueCat Paywall UI for seamless purchase experience.
/// Displays subscription offerings and handles purchase flow.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:soultune/shared/providers/premium_providers.dart';
import 'package:soultune/shared/services/premium/premium_service.dart';

/// Paywall screen for upgrading to premium.
///
/// Features:
/// - RevenueCat Paywall UI integration
/// - Subscription package selection
/// - Purchase flow handling
/// - Restore purchases option
/// - Custom feature list
class PaywallScreen extends ConsumerStatefulWidget {
  /// Creates a [PaywallScreen].
  const PaywallScreen({
    super.key,
    this.feature,
    this.offering,
  });

  /// Optional feature that triggered paywall (for analytics).
  final PremiumFeature? feature;

  /// Optional specific offering to display.
  final String? offering;

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  final _logger = Logger();
  bool _isRestoring = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // RevenueCat Paywall UI
            PaywallView(
              offering: widget.offering,
              displayCloseButton: true,
              onRestoreCompleted: _handleRestoreComplete,
              onPurchaseCompleted: _handlePurchaseComplete,
              onPurchaseError: _handlePurchaseError,
              onDismiss: () => Navigator.of(context).pop(),
            ),

            // Custom header with feature highlight
            if (widget.feature != null)
              Positioned(
                top: 16,
                left: 16,
                right: 56, // Space for close button
                child: _buildFeatureHeader(),
              ),

            // Restore purchases button
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: _buildRestoreButton(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build feature header highlighting the locked feature.
  Widget _buildFeatureHeader() {
    final theme = Theme.of(context);
    final feature = widget.feature;
    if (feature == null) return const SizedBox.shrink();

    final featureInfo = _getFeatureInfo(feature);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            featureInfo.icon,
            size: 32,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  featureInfo.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  featureInfo.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build restore purchases button.
  Widget _buildRestoreButton() {
    return Center(
      child: TextButton.icon(
        onPressed: _isRestoring ? null : _handleRestorePurchases,
        icon: _isRestoring
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.restore),
        label: Text(_isRestoring ? 'Restoring...' : 'Restore Purchases'),
      ),
    );
  }

  /// Handle restore purchases.
  Future<void> _handleRestorePurchases() async {
    setState(() => _isRestoring = true);

    try {
      final restored = await ref.read(restorePurchasesProvider.future);

      if (!mounted) return;

      if (restored) {
        // Purchases restored successfully
        _logger.i('Purchases restored - user is now premium');
        _showSnackBar('Purchases restored successfully!', isError: false);
        Navigator.of(context).pop(true); // Return true = upgraded
      } else {
        // No purchases to restore
        _showSnackBar(
          'No purchases to restore. Try purchasing below.',
          isError: false,
        );
      }
    } catch (e) {
      _logger.e('Failed to restore purchases', error: e);
      _showSnackBar(
        'Failed to restore purchases. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }

  /// Handle purchase completed (from RevenueCat Paywall UI).
  void _handlePurchaseComplete(CustomerInfo customerInfo) {
    _logger.i('Purchase completed successfully!');

    // Refresh premium status
    ref.invalidate(isPremiumProvider);
    ref.invalidate(customerInfoProvider);

    if (!mounted) return;

    _showSnackBar('Welcome to SoulTune Pro! 🎉', isError: false);

    // Close paywall with success result
    Navigator.of(context).pop(true); // Return true = upgraded
  }

  /// Handle purchase error.
  void _handlePurchaseError(PurchasesError error) {
    _logger.e('Purchase error: ${error.message}', error: error);

    if (!mounted) return;

    // Don't show error for user cancellation
    if (error.code == PurchasesErrorCode.purchaseCancelledError) {
      _logger.d('User cancelled purchase');
      return;
    }

    _showSnackBar(
      'Purchase failed: ${error.message}',
      isError: true,
    );
  }

  /// Handle restore completed (from RevenueCat Paywall UI).
  void _handleRestoreComplete(CustomerInfo customerInfo) {
    _logger.i('Restore completed');

    // Refresh premium status
    ref.invalidate(isPremiumProvider);
    ref.invalidate(customerInfoProvider);

    if (!mounted) return;

    final hasPremium = customerInfo.entitlements.active
        .containsKey('SoulTune Pro');

    if (hasPremium) {
      _showSnackBar('Purchases restored successfully!', isError: false);
      Navigator.of(context).pop(true); // Return true = upgraded
    } else {
      _showSnackBar(
        'No purchases to restore.',
        isError: false,
      );
    }
  }

  /// Show snackbar message.
  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Get feature info for display.
  _FeatureInfo _getFeatureInfo(PremiumFeature feature) {
    switch (feature) {
      case PremiumFeature.ciaGatewayPresets:
        return const _FeatureInfo(
          icon: Icons.psychology,
          title: 'CIA Gateway Process',
          description: 'Unlock all Focus levels (10/12/15/21)',
        );
      case PremiumFeature.oobePresets:
        return const _FeatureInfo(
          icon: Icons.airline_seat_flat,
          title: 'Out-of-Body Experience',
          description: 'Advanced OBE & Astral Projection protocols',
        );
      case PremiumFeature.customGenerator:
        return const _FeatureInfo(
          icon: Icons.tune,
          title: 'Custom Generator',
          description: 'Create unlimited frequency combinations',
        );
      case PremiumFeature.allPresets:
        return const _FeatureInfo(
          icon: Icons.library_music,
          title: 'All 23+ Presets',
          description: 'Full access to Sleep, Focus, Healing, and more',
        );
      case PremiumFeature.dualLayerAudioUnlimited:
        return const _FeatureInfo(
          icon: Icons.layers,
          title: 'Dual-Layer Audio',
          description: 'Mix any music with any frequency',
        );
      case PremiumFeature.browserAllFrequencies:
        return const _FeatureInfo(
          icon: Icons.web,
          title: 'Browser - All Frequencies',
          description: 'Inject all Solfeggio frequencies into websites',
        );
      default:
        return const _FeatureInfo(
          icon: Icons.star,
          title: 'Premium Feature',
          description: 'Upgrade to unlock this feature',
        );
    }
  }
}

/// Feature info for paywall display.
class _FeatureInfo {
  const _FeatureInfo({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
