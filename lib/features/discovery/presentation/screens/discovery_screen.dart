/// Discovery Lab Screen
///
/// Educational content about CIA Gateway Process, OBE, Remote Viewing,
/// and the science behind frequency synchronization.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soultune/features/generator/data/models/predefined_presets.dart';
import 'package:soultune/features/generator/presentation/providers/generator_providers.dart';

/// Discovery Lab screen for education and trust building.
///
/// Explains the science behind brain synchronization, CIA declassified
/// research, and validated paranormal phenomena.
class DiscoveryScreen extends ConsumerWidget {
  /// Creates a [DiscoveryScreen].
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discovery Lab',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'The Science Behind Brain Sync',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _buildCIASection(context, ref),
          _buildOBESection(context, ref),
          _buildRemoteViewingSection(context, ref),
          _buildScienceSection(context),
        ],
      ),
    );
  }

  /// CIA Gateway Process Section.
  Widget _buildCIASection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: ExpansionTile(
        leading: const Text('🔓', style: TextStyle(fontSize: 32)),
        title: const Text(
          'CIA Gateway Process',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Declassified 1983 - Public 2003'),
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THE GATEWAY PROCESS',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'In 1983, U.S. Army Intelligence assessed the Monroe '
                  'Institute\'s Gateway Experience for military applications.\n\n'
                  'Key Findings:\n'
                  '• Binaural beats induce measurable brain changes\n'
                  '• Out-of-body experiences are trainable states\n'
                  '• Remote viewing capability can be developed\n'
                  '• Consciousness exists beyond spacetime\n\n'
                  'Declassified: 2003 • CIA CREST Database: 2017',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Try Focus 21 (Gateway State)'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _playPreset(
                        context,
                        ref,
                        'cia_focus21',
                        'Focus 21',
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Out-of-Body Experiences Section.
  Widget _buildOBESection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: const Text('👁️', style: TextStyle(fontSize: 32)),
        title: const Text(
          'Out-of-Body Experiences',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Scientific research & techniques'),
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THE SCIENCE OF OBEs',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Out-of-body experiences are trainable altered states. '
                  'NIH fMRI studies show specific brain activation in the '
                  'temporoparietal junction (TPJ) during OBEs.\n\n'
                  'Research:\n'
                  '• University of Ottawa: OBE brain mapping (2014)\n'
                  '• 10% of population has spontaneous OBEs\n'
                  '• Training increases OBE probability 5-10x\n\n'
                  'Optimal Conditions:\n'
                  '• 3-6 AM (melatonin peak)\n'
                  '• After 4-6 hours sleep\n'
                  '• Theta frequency (4-8 Hz)',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.bedtime),
                    label: const Text('OBE Initiation Protocol'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _playPreset(
                        context,
                        ref,
                        'obe_deep',
                        'Deep OBE State',
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Remote Viewing Section.
  Widget _buildRemoteViewingSection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: const Text('🔭', style: TextStyle(fontSize: 32)),
        title: const Text(
          'Remote Viewing',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Project Stargate (1978-1995)'),
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CIA PROJECT STARGATE',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'For 17 years, the CIA trained remote viewers to perceive '
                  'distant targets using consciousness alone.\n\n'
                  'Joseph McMoneagle (Agent 001):\n'
                  '• 450+ successful operational missions\n'
                  '• Located Soviet submarine (1979)\n'
                  '• 85%+ accuracy on verifiable targets\n\n'
                  'Frequencies Used:\n'
                  '• Focus 10-15 for target acquisition\n'
                  '• Beta waves (15-20 Hz) for active RV',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.visibility),
                    label: const Text('RV Training Protocol'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _playPreset(
                        context,
                        ref,
                        'rv_focus15',
                        'Remote Viewing Focus 15',
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The Science Section.
  Widget _buildScienceSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: const Text('🧠', style: TextStyle(fontSize: 32)),
        title: const Text(
          'The Science',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('How brain sync actually works'),
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FREQUENCY FOLLOWING RESPONSE',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your brain naturally synchronizes with external rhythms.\n\n'
                  'How Binaural Beats Work:\n'
                  '1. Left ear: 200 Hz\n'
                  '2. Right ear: 207 Hz\n'
                  '3. Brain perceives: 7 Hz "beat"\n'
                  '4. Brainwaves entrain to 7 Hz (Theta)\n\n'
                  '2024 PLOS Study:\n'
                  '"Panning beats show significantly more pronounced '
                  'effects on brain activity than static binaural beats."\n\n'
                  'This app uses advanced panning (0.1s-10s cycles) '
                  'for maximum effectiveness.',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to play a preset from Discovery screen.
  Future<void> _playPreset(
    BuildContext context,
    WidgetRef ref,
    String presetId,
    String fallbackName,
  ) async {
    try {
      // Find preset by ID
      final allPresets = getPredefinedPresets();
      final preset = allPresets.firstWhere(
        (p) => p.id == presetId,
        orElse: () => allPresets.first, // Fallback to first preset
      );

      // Play preset
      final playPreset = ref.read(playFrequencyPresetProvider);
      await playPreset(preset);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Playing ${preset.name}'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
