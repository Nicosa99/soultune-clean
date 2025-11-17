/// Preset Detail Bottom Sheet
///
/// Shows detailed information about a frequency preset including
/// technical specifications, benefits, and play controls.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soultune/features/generator/data/models/frequency_preset.dart';

/// Bottom sheet showing preset details.
class PresetDetailSheet extends StatelessWidget {
  /// Creates a [PresetDetailSheet].
  const PresetDetailSheet({
    required this.preset,
    required this.isPlaying,
    required this.onPlay,
    required this.onStop,
    required this.onFavorite,
    super.key,
  });

  /// The preset to display.
  final FrequencyPreset preset;

  /// Whether this preset is currently playing.
  final bool isPlaying;

  /// Called when play is pressed.
  final VoidCallback onPlay;

  /// Called when stop is pressed.
  final VoidCallback onStop;

  /// Called when favorite is toggled.
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Header with icon and name
                _buildHeader(theme, colorScheme),

                const SizedBox(height: 24),

                // Description
                Text(
                  preset.description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 24),

                // Technical Details
                _buildTechnicalDetails(theme, colorScheme),

                const SizedBox(height: 24),

                // Benefits
                _buildBenefits(theme, colorScheme),

                const SizedBox(height: 32),

                // Action Buttons
                _buildActions(theme, colorScheme),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the header with emoji, name, and favorite button.
  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        // Category emoji
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              preset.category.emoji,
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Name and category
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                preset.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                preset.category.displayName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Favorite button
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            onFavorite();
          },
          icon: Icon(
            preset.isFavorite ? Icons.favorite : Icons.favorite_border,
            color:
                preset.isFavorite ? colorScheme.error : colorScheme.onSurface,
            size: 28,
          ),
        ),
      ],
    );
  }

  /// Builds the technical details section.
  Widget _buildTechnicalDetails(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Technical Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Frequency layers
              if (preset.layers.isNotEmpty) ...[
                _buildDetailRow(
                  'Frequencies',
                  preset.layers
                      .map((l) => '${l.frequency.toStringAsFixed(0)}Hz')
                      .join(' + '),
                  theme,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Waveforms',
                  preset.layers.map((l) => l.waveform.displayName).join(', '),
                  theme,
                ),
              ],

              // Binaural config
              if (preset.binauralConfig != null) ...[
                _buildDetailRow(
                  'Left Ear',
                  '${preset.binauralConfig!.leftFrequency.toStringAsFixed(0)} Hz',
                  theme,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Right Ear',
                  '${preset.binauralConfig!.rightFrequency.toStringAsFixed(0)} Hz',
                  theme,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Beat Frequency',
                  '${preset.binauralConfig!.beatFrequency.toStringAsFixed(1)} Hz '
                      '(${preset.binauralConfig!.brainwaveCategory})',
                  theme,
                ),
              ],

              const SizedBox(height: 8),
              _buildDetailRow(
                'Duration',
                preset.formattedDuration,
                theme,
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Volume',
                '${(preset.volume * 100).toInt()}%',
                theme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds a single detail row.
  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
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

  /// Builds the benefits section.
  Widget _buildBenefits(ThemeData theme, ColorScheme colorScheme) {
    final benefits = _getBenefits();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Benefits',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...benefits.map((benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      benefit,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  /// Gets benefits based on preset category and frequencies.
  List<String> _getBenefits() {
    return switch (preset.category) {
      _ when preset.binauralConfig != null => _getBinauralBenefits(),
      _ => _getCategoryBenefits(),
    };
  }

  /// Gets benefits for binaural presets.
  List<String> _getBinauralBenefits() {
    final category = preset.binauralConfig!.brainwaveCategory;
    return switch (category) {
      'Delta' => [
          'Promotes deep restorative sleep',
          'Supports physical healing',
          'Enhances hormone balance',
          'Reduces stress and anxiety',
        ],
      'Theta' => [
          'Deepens meditation practice',
          'Enhances creativity and intuition',
          'Promotes emotional healing',
          'Improves memory consolidation',
        ],
      'Alpha' => [
          'Induces calm, relaxed alertness',
          'Reduces mental stress',
          'Improves learning ability',
          'Enhances mind-body coordination',
        ],
      'Beta' => [
          'Increases focus and concentration',
          'Enhances cognitive performance',
          'Boosts alertness and energy',
          'Supports problem-solving',
        ],
      'Gamma' => [
          'Promotes peak mental performance',
          'Enhances information processing',
          'Supports insight and perception',
          'Increases cognitive flexibility',
        ],
      _ => [],
    };
  }

  /// Gets benefits based on preset category.
  List<String> _getCategoryBenefits() {
    return switch (preset.category) {
      _ when preset.tags.contains('sleep') => [
          'Promotes restful sleep',
          'Calms the nervous system',
          'Reduces sleep onset time',
          'Supports natural sleep cycles',
        ],
      _ when preset.tags.contains('meditation') => [
          'Deepens meditation state',
          'Calms mental chatter',
          'Enhances inner awareness',
          'Promotes spiritual connection',
        ],
      _ when preset.tags.contains('focus') => [
          'Sharpens mental clarity',
          'Improves concentration',
          'Reduces distractions',
          'Enhances productivity',
        ],
      _ when preset.tags.contains('healing') => [
          'Supports cellular repair',
          'Promotes emotional balance',
          'Reduces physical tension',
          'Enhances natural healing',
        ],
      _ when preset.tags.contains('energy') => [
          'Boosts vitality and energy',
          'Enhances motivation',
          'Supports physical performance',
          'Promotes positive mood',
        ],
      _ => [
          'Promotes overall wellness',
          'Balances mind and body',
          'Reduces stress',
          'Enhances relaxation',
        ],
    };
  }

  /// Builds the action buttons.
  Widget _buildActions(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Play/Stop button
        SizedBox(
          height: 56,
          child: FilledButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              if (isPlaying) {
                onStop();
              } else {
                onPlay();
              }
            },
            icon: Icon(
              isPlaying ? Icons.stop : Icons.play_arrow,
              size: 28,
            ),
            label: Text(
              isPlaying ? 'STOP' : 'PLAY NOW',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor:
                  isPlaying ? colorScheme.error : colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
