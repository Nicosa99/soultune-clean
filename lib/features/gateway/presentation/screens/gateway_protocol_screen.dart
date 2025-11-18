/// Gateway Protocol Screen
///
/// 8-week guided CIA Gateway Program with progress tracking.
library;

import 'package:flutter/material.dart';

/// Gateway Protocol screen for guided 8-week program.
///
/// Structure:
/// - Week 1-2: Focus 10 (Body Asleep, Mind Awake)
/// - Week 3-4: Focus 12 (Expanded Awareness)
/// - Week 5-6: Focus 15 (No Time)
/// - Week 7-8: Focus 21 (Other Energy Systems)
class GatewayProtocolScreen extends StatelessWidget {
  /// Creates a [GatewayProtocolScreen].
  const GatewayProtocolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // TODO: Replace with actual Riverpod provider
    const currentWeek = 1;
    const completedSessions = 0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gateway Protocol',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Your 8-Week Journey',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(theme, currentWeek, completedSessions),
          const SizedBox(height: 24),
          _buildPhaseCard(
            theme,
            'Week 1-2: Focus 10',
            'Body Asleep, Mind Awake',
            0,
            14,
            isLocked: false,
            isCurrent: currentWeek <= 2,
          ),
          _buildPhaseCard(
            theme,
            'Week 3-4: Focus 12',
            'Expanded Awareness',
            0,
            14,
            isLocked: completedSessions < 14,
            isCurrent: currentWeek >= 3 && currentWeek <= 4,
          ),
          _buildPhaseCard(
            theme,
            'Week 5-6: Focus 15',
            'No Time',
            0,
            14,
            isLocked: completedSessions < 28,
            isCurrent: currentWeek >= 5 && currentWeek <= 6,
          ),
          _buildPhaseCard(
            theme,
            'Week 7-8: Focus 21',
            'Gateway State',
            0,
            14,
            isLocked: completedSessions < 42,
            isCurrent: currentWeek >= 7,
          ),
          const SizedBox(height: 24),
          _buildInfoCard(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, int week, int totalSessions) {
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'WEEK $week / 8',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Focus 10: Body Asleep',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: totalSessions / 56.0,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              '$totalSessions / 56 sessions • ${(totalSessions / 56 * 100).toInt()}% Complete',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseCard(
    ThemeData theme,
    String title,
    String subtitle,
    int completed,
    int required, {
    bool isLocked = false,
    bool isCurrent = false,
  }) {
    final colorScheme = theme.colorScheme;
    final isCompleted = completed >= required;

    Color cardColor;
    if (isCurrent) {
      cardColor = colorScheme.primaryContainer.withOpacity(0.3);
    } else if (isLocked) {
      cardColor = colorScheme.surfaceContainerLow;
    } else {
      cardColor = colorScheme.surfaceContainerLow;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isLocked
                  ? colorScheme.surfaceContainerHighest
                  : isCompleted
                      ? Colors.green
                      : isCurrent
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerHighest,
              child: Icon(
                isLocked
                    ? Icons.lock
                    : isCompleted
                        ? Icons.check
                        : Icons.radio_button_unchecked,
                color: isLocked
                    ? colorScheme.onSurfaceVariant
                    : isCurrent
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (!isLocked) ...[
                    const SizedBox(height: 8),
                    Text(
                      '$completed / $required sessions',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: completed / required,
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ],
                  if (isLocked)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Complete previous phase to unlock',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (!isLocked && isCurrent)
              ElevatedButton(
                onPressed: () {
                  // TODO: Start session
                },
                child: const Text('START'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.tertiaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'About Gateway Protocol',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'The Gateway Protocol is based on the declassified CIA '
              'program for developing advanced consciousness techniques.\n\n'
              'Complete each phase in sequence to unlock deeper states '
              'of awareness and perception.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onTertiaryContainer,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
