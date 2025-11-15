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
import 'package:soultune/shared/theme/app_colors.dart';

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
    

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Disable if no audio loaded
    final isEnabled = currentFile != null;

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
              // 432 Hz - FREE (Deep Peace)
              _FrequencyChip(
                label: '432 Hz',
                subtitle: 'Deep Peace',
                pitchShift: kPitch432Hz,
                currentPitchShift: currentPitchShift,
                color: AppColors.frequency432,
                isEnabled: isEnabled,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ref.read(changePitchShiftProvider)(kPitch432Hz);
                },
              ),

              // 528 Hz - PREMIUM (Love Frequency)
              _FrequencyChip(
                label: '528 Hz',
                subtitle: 'Love Frequency',
                pitchShift: kPitch528Hz,
                currentPitchShift: currentPitchShift,
                color: AppColors.frequency528,
                
                isEnabled: isEnabled,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  
                  ref.read(changePitchShiftProvider)(kPitch528Hz);
                },
              ),

              // 639 Hz - PREMIUM (Relationships)
              _FrequencyChip(
                label: '639 Hz',
                subtitle: 'Relationships',
                pitchShift: kPitch639Hz,
                currentPitchShift: currentPitchShift,
                color: AppColors.frequency639,
                
                isEnabled: isEnabled,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  
                  ref.read(changePitchShiftProvider)(kPitch639Hz);
                },
              ),

              // Standard tuning (440 Hz) - OFF
              _FrequencyChip(
                label: 'Standard',
                subtitle: '440 Hz',
                pitchShift: 0.0,
                currentPitchShift: currentPitchShift,
                color: colorScheme.surfaceContainerHighest,
                
                isEnabled: isEnabled,
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
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final double pitchShift;
  final double currentPitchShift;
  final Color color;
  final bool isEnabled;
  final VoidCallback onTap;

  bool get isSelected {
    // Consider selected if pitch shift is within 0.001 semitones (rounding tolerance)
    return (currentPitchShift - pitchShift).abs() < 0.001;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
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
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
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
    );
  }
}
