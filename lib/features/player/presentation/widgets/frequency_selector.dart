/// SoulTune Frequency Selector Widget
///
/// Beautiful Material 3 frequency selector for 432Hz healing transformations.
/// The CORE FEATURE of SoulTune - real-time frequency transformation.
///
/// ## Features
///
/// - 432 Hz (Deep Peace & Harmony) - FREE
/// - 528 Hz (Love & Healing) - PREMIUM
/// - 639 Hz (Relationships & Connection) - PREMIUM
/// - Real-time transformation while playing
/// - Smooth animations and haptic feedback
/// - Premium badges with visual differentiation
/// - Beautiful color-coded chips
///
/// ## Usage
///
/// ```dart
/// FrequencySelector()
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soultune/app/constants/frequencies.dart';
import 'package:soultune/features/player/presentation/providers/player_providers.dart';
import 'package:soultune/shared/services/premium/premium_providers.dart';
import 'package:soultune/shared/theme/app_colors.dart';
import 'package:soultune/shared/widgets/premium/premium_widgets.dart';

/// Frequency selector widget for 432Hz healing transformations.
///
/// Displays available frequency options as selectable chips.
/// Automatically updates when frequency changes.
class FrequencySelector extends ConsumerWidget {
  /// Creates a [FrequencySelector] widget.
  const FrequencySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPitchShift = ref.watch(currentPitchShiftProvider);
    final currentFile = ref.watch(currentAudioFileProvider);
    final isPremiumAsync = ref.watch(isPremiumProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Disable if no audio loaded
    final isEnabled = currentFile != null;

    // Get premium status
    final isPremium = isPremiumAsync.valueOrNull ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            'Healing Frequencies',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Frequency chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // 396 Hz - Liberation from Fear (PREMIUM)
              _FrequencyChip(
                label: '396 Hz',
                subtitle: 'Liberation',
                pitchShift: kPitch396Hz,
                currentPitchShift: currentPitchShift,
                color: AppColors.frequency396,
                isEnabled: isEnabled,
                isPremium: true,
                hasAccess: isPremium,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  if (isPremium) {
                    ref.read(changePitchShiftProvider)(kPitch396Hz);
                  } else {
                    PremiumUpgradeDialog.show(
                      context,
                      feature: '396 Hz Liberation Frequency',
                    );
                  }
                },
              ),

              // 417 Hz - Trauma Healing (PREMIUM)
              _FrequencyChip(
                label: '417 Hz',
                subtitle: 'Trauma Healing',
                pitchShift: kPitch417Hz,
                currentPitchShift: currentPitchShift,
                color: AppColors.frequency417,
                isEnabled: isEnabled,
                isPremium: true,
                hasAccess: isPremium,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  if (isPremium) {
                    ref.read(changePitchShiftProvider)(kPitch417Hz);
                  } else {
                    PremiumUpgradeDialog.show(
                      context,
                      feature: '417 Hz Trauma Healing Frequency',
                    );
                  }
                },
              ),

              // 432 Hz - Deep Peace (FREE)
              _FrequencyChip(
                label: '432 Hz',
                subtitle: 'Deep Peace',
                pitchShift: kPitch432Hz,
                currentPitchShift: currentPitchShift,
                color: AppColors.frequency432,
                isEnabled: isEnabled,
                isPremium: false,
                hasAccess: true,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ref.read(changePitchShiftProvider)(kPitch432Hz);
                },
              ),

              // 528 Hz - Love Frequency (PREMIUM)
              _FrequencyChip(
                label: '528 Hz',
                subtitle: 'Love Frequency',
                pitchShift: kPitch528Hz,
                currentPitchShift: currentPitchShift,
                color: AppColors.frequency528,
                isEnabled: isEnabled,
                isPremium: true,
                hasAccess: isPremium,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  if (isPremium) {
                    ref.read(changePitchShiftProvider)(kPitch528Hz);
                  } else {
                    PremiumUpgradeDialog.show(
                      context,
                      feature: '528 Hz Love Frequency',
                    );
                  }
                },
              ),

              // 639 Hz - Harmony & Connection (PREMIUM)
              _FrequencyChip(
                label: '639 Hz',
                subtitle: 'Harmony',
                pitchShift: kPitch639Hz,
                currentPitchShift: currentPitchShift,
                color: AppColors.frequency639,
                isEnabled: isEnabled,
                isPremium: true,
                hasAccess: isPremium,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  if (isPremium) {
                    ref.read(changePitchShiftProvider)(kPitch639Hz);
                  } else {
                    PremiumUpgradeDialog.show(
                      context,
                      feature: '639 Hz Harmony Frequency',
                    );
                  }
                },
              ),

              // Standard tuning (440 Hz) (FREE)
              _FrequencyChip(
                label: 'Standard',
                subtitle: '440 Hz',
                pitchShift: 0.0,
                currentPitchShift: currentPitchShift,
                color: colorScheme.surfaceContainerHighest,
                isEnabled: isEnabled,
                isPremium: false,
                hasAccess: true,
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(changePitchShiftProvider)(0.0);
                },
              ),
            ],
          ),
        ),

        // Info text
        if (isEnabled)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Frequency transformation happens in real-time without quality loss',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Individual frequency chip widget.
class _FrequencyChip extends StatelessWidget {
  const _FrequencyChip({
    required this.label,
    required this.subtitle,
    required this.pitchShift,
    required this.currentPitchShift,
    required this.color,
    required this.isEnabled,
    required this.isPremium,
    required this.hasAccess,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final double pitchShift;
  final double currentPitchShift;
  final Color color;
  final bool isEnabled;
  final bool isPremium;
  final bool hasAccess;
  final VoidCallback onTap;

  bool get isSelected {
    // Consider selected if pitch shift is within 0.001 semitones (rounding tolerance)
    return (currentPitchShift - pitchShift).abs() < 0.001;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Check if chip should be fully enabled
    final isChipEnabled = isEnabled && hasAccess;
    // Visual opacity for locked premium features
    final opacity = (isPremium && !hasAccess) ? 0.6 : 1.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: opacity,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(0.2)
                  : colorScheme.surfaceContainerHigh.withOpacity(
                      isEnabled ? 1.0 : 0.5,
                    ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? color
                    : colorScheme.outline.withOpacity(
                        isEnabled ? 0.3 : 0.1,
                      ),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Frequency label
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isSelected
                                ? color
                                : colorScheme.onSurface.withOpacity(
                                    isEnabled ? 1.0 : 0.5,
                                  ),
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                        // Premium indicator badge
                        if (isPremium && !hasAccess) ...[
                          const SizedBox(width: 6),
                          const PremiumIndicator(size: 14),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(
                          isEnabled ? 1.0 : 0.5,
                        ),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                // Selected indicator
                if (isSelected) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.check_circle,
                    size: 20,
                    color: color,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
