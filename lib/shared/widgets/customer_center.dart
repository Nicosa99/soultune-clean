/// Customer Center - Subscription management UI
///
/// Uses RevenueCat Customer Center for managing subscriptions.
/// Allows users to view subscription details, cancel, and get support.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:soultune/shared/providers/premium_providers.dart';

/// Customer Center screen for subscription management.
///
/// Features:
/// - View subscription details
/// - Manage subscription (cancel, change plan)
/// - Access support resources
/// - Restore purchases
class CustomerCenterScreen extends ConsumerWidget {
  /// Creates a [CustomerCenterScreen].
  const CustomerCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomerCenterView(
        displayCloseButton: true,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }
}

/// Customer Center button widget.
///
/// Shows "Manage Subscription" button that opens Customer Center.
/// Only visible to premium users.
class CustomerCenterButton extends ConsumerWidget {
  /// Creates a [CustomerCenterButton].
  const CustomerCenterButton({super.key});

  final _logger = Logger();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumAsync = ref.watch(isPremiumProvider);

    return isPremiumAsync.when(
      data: (isPremium) {
        if (!isPremium) return const SizedBox.shrink();

        return ListTile(
          leading: const Icon(Icons.card_membership),
          title: const Text('Manage Subscription'),
          subtitle: const Text('View details, change plan, or cancel'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _openCustomerCenter(context),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Open Customer Center screen.
  void _openCustomerCenter(BuildContext context) {
    _logger.d('Opening Customer Center');
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CustomerCenterScreen(),
        fullscreenDialog: true,
      ),
    );
  }
}

/// Subscription info card widget.
///
/// Displays current subscription status and details.
class SubscriptionInfoCard extends ConsumerWidget {
  /// Creates a [SubscriptionInfoCard].
  const SubscriptionInfoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final subscriptionAsync = ref.watch(activeSubscriptionProvider);

    return subscriptionAsync.when(
      data: (subscription) {
        if (subscription == null) {
          // Free tier
          return _buildFreeTierCard(context);
        }

        // Premium subscription
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SoulTune Pro',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  context,
                  'Plan',
                  subscription.type,
                  Icons.card_membership,
                ),
                const SizedBox(height: 8),
                if (subscription.expirationDate != null)
                  _buildInfoRow(
                    context,
                    subscription.willRenew ? 'Renews' : 'Expires',
                    _formatDate(subscription.expirationDate!),
                    subscription.willRenew
                        ? Icons.autorenew
                        : Icons.event_busy,
                  ),
                if (subscription.isTrial) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '🎉 Free Trial Active',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                if (subscription.billingIssueDetected) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Billing issue detected. Please update payment.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _openCustomerCenter(context),
                    icon: const Icon(Icons.settings),
                    label: const Text('Manage Subscription'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error loading subscription: $error'),
        ),
      ),
    );
  }

  /// Build free tier card.
  Widget _buildFreeTierCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.music_note,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'SoulTune Free',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Upgrade to unlock all features',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build info row.
  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Format ISO 8601 date.
  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.month}/${date.day}/${date.year}';
    } catch (e) {
      return isoDate;
    }
  }

  /// Open Customer Center.
  void _openCustomerCenter(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CustomerCenterScreen(),
        fullscreenDialog: true,
      ),
    );
  }
}
