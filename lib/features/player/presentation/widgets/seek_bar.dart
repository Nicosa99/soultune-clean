/// SoulTune Seek Bar Widget
///
/// Material 3 seek bar with time display for audio playback control.
/// Shows current position, total duration, and provides seeking functionality.
///
/// ## Features
///
/// - Real-time position updates via Riverpod stream
/// - Smooth slider interaction with haptic feedback
/// - Formatted time display (mm:ss)
/// - Material 3 design with theme colors
/// - Responsive to different screen sizes
/// - Accessibility labels for screen readers
///
/// ## Usage
///
/// ```dart
/// SeekBar() // That's it! Riverpod handles the rest
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soultune/features/player/presentation/providers/player_providers.dart';

/// Seek bar widget for audio playback control.
///
/// Displays current position, total duration, and allows seeking via slider.
/// Automatically updates position in real-time using Riverpod streams.
class SeekBar extends ConsumerWidget {
  /// Creates a [SeekBar] widget.
  const SeekBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch playback position stream
    final positionAsync = ref.watch(playbackPositionProvider);

    // Watch duration
    final duration = ref.watch(playbackDurationProvider);

    return positionAsync.when(
      data: (position) => _buildSeekBar(
        context,
        ref,
        position,
        duration ?? Duration.zero,
      ),
      loading: () => _buildSeekBar(
        context,
        ref,
        Duration.zero,
        duration ?? Duration.zero,
      ),
      error: (_, __) => _buildSeekBar(
        context,
        ref,
        Duration.zero,
        duration ?? Duration.zero,
      ),
    );
  }

  /// Builds the seek bar UI.
  Widget _buildSeekBar(
    BuildContext context,
    WidgetRef ref,
    Duration position,
    Duration duration,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate slider value (0.0 - 1.0)
    final sliderValue = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Slider
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 8,
              elevation: 2,
            ),
            overlayShape: const RoundSliderOverlayShape(
              overlayRadius: 20,
            ),
            activeTrackColor: colorScheme.primary,
            inactiveTrackColor: colorScheme.surfaceContainerHighest,
            thumbColor: colorScheme.primary,
            overlayColor: colorScheme.primary.withOpacity(0.2),
          ),
          child: Slider(
            value: sliderValue.clamp(0.0, 1.0),
            onChanged: duration.inMilliseconds > 0
                ? (value) {
                    // Provide haptic feedback
                    HapticFeedback.selectionClick();

                    // Calculate new position
                    final newPosition = Duration(
                      milliseconds: (value * duration.inMilliseconds).round(),
                    );

                    // Seek to new position
                    ref.read(seekToProvider)(newPosition);
                  }
                : null,
            // Accessibility
            semanticFormatterCallback: (value) {
              final currentPos = Duration(
                milliseconds: (value * duration.inMilliseconds).round(),
              );
              return 'Position: ${_formatDuration(currentPos)} of ${_formatDuration(duration)}';
            },
          ),
        ),

        // Time labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Current position
              Text(
                _formatDuration(position),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontFeatures: const [
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),

              // Total duration
              Text(
                _formatDuration(duration),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontFeatures: const [
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Formats duration as mm:ss.
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
