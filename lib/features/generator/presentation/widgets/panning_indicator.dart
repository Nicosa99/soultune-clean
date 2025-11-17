/// Panning Indicator Widget
///
/// Visual indicator showing current stereo pan position.
/// Displays smooth L→R→L movement during panning modulation.
library;

import 'package:flutter/material.dart';

/// Visual indicator for current pan position.
///
/// Shows the stereo panning position with animated dot and
/// color-coded L/R indicators.
class PanningIndicator extends StatelessWidget {
  /// Creates a [PanningIndicator].
  const PanningIndicator({
    required this.panPosition,
    this.isActive = true,
    this.height = 48,
    super.key,
  });

  /// Current pan position (-1.0 = full left, 1.0 = full right).
  final double panPosition;

  /// Whether panning is currently active.
  final bool isActive;

  /// Height of the indicator.
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!isActive) {
      return const SizedBox.shrink();
    }

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Label
          Text(
            'Panning L↔R',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          // Indicator bar
          Expanded(
            child: Row(
              children: [
                // Left indicator
                _buildSideIndicator(
                  context,
                  'L',
                  isLeft: true,
                  intensity: panPosition < 0 ? -panPosition : 0,
                ),

                const SizedBox(width: 8),

                // Center track with moving dot
                Expanded(
                  child: _buildCenterTrack(context),
                ),

                const SizedBox(width: 8),

                // Right indicator
                _buildSideIndicator(
                  context,
                  'R',
                  isLeft: false,
                  intensity: panPosition > 0 ? panPosition : 0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a side indicator (L or R).
  Widget _buildSideIndicator(
    BuildContext context,
    String label, {
    required bool isLeft,
    required double intensity,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = isLeft ? Colors.blue : Colors.red;
    final bgColor = baseColor.withOpacity(0.1 + (intensity * 0.5));

    return Container(
      width: 40,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: baseColor.withOpacity(intensity * 0.8),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: intensity > 0.3
                ? baseColor
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  /// Builds the center track with moving dot.
  Widget _buildCenterTrack(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dot position
        // panPosition: -1.0 to 1.0 → position: 0 to maxWidth
        final normalizedPosition = (panPosition + 1) / 2;
        final dotPosition = normalizedPosition * constraints.maxWidth;

        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Track background
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Center line
            Positioned(
              left: constraints.maxWidth / 2 - 1,
              child: Container(
                width: 2,
                height: 12,
                color: colorScheme.outline,
              ),
            ),

            // Moving dot
            AnimatedPositioned(
              duration: const Duration(milliseconds: 50),
              left: dotPosition.clamp(0, constraints.maxWidth - 16),
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _getDotColor(colorScheme),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getDotColor(colorScheme).withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Gets dot color based on position.
  Color _getDotColor(ColorScheme colorScheme) {
    if (panPosition < -0.3) {
      return Colors.blue;
    } else if (panPosition > 0.3) {
      return Colors.red;
    } else {
      return colorScheme.primary;
    }
  }
}

/// Compact panning indicator for mini players.
class CompactPanningIndicator extends StatelessWidget {
  /// Creates a [CompactPanningIndicator].
  const CompactPanningIndicator({
    required this.panPosition,
    super.key,
  });

  /// Current pan position.
  final double panPosition;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 60,
      height: 20,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // L/R labels
          const Positioned(
            left: 4,
            child: Text('L', style: TextStyle(fontSize: 10)),
          ),
          const Positioned(
            right: 4,
            child: Text('R', style: TextStyle(fontSize: 10)),
          ),

          // Moving dot
          AnimatedPositioned(
            duration: const Duration(milliseconds: 50),
            left: 10 + ((panPosition + 1) / 2) * 40,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
