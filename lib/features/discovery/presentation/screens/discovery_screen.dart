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
          _buildHowToUseSection(context),
          _buildBrowserSection(context),
          _buildFrequenciesSection(context),
          _buildCIASection(context, ref),
          _buildOBESection(context, ref),
          _buildRemoteViewingSection(context, ref),
          _buildScienceSection(context),
        ],
      ),
    );
  }

  /// How to Use SoulTune Section.
  Widget _buildHowToUseSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: ExpansionTile(
        leading: const Text('📱', style: TextStyle(fontSize: 32)),
        title: const Text(
          'How to Use SoulTune',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Your complete guide to healing frequencies'),
        initiallyExpanded: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '4 POWERFUL FEATURES',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  '🎵 Library',
                  'Play your music files with 432 Hz pitch shifting',
                  theme,
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  '🌊 Generator',
                  'Pure frequency synthesis with binaural beats and '
                      'Solfeggio frequencies',
                  theme,
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  '🌐 Browser',
                  'Listen to YouTube, Spotify, SoundCloud with 432 Hz '
                      'frequency injection',
                  theme,
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  '🔬 Discovery',
                  'Learn the science behind brain synchronization',
                  theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to build a feature item.
  Widget _buildFeatureItem(String title, String description, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Browser & Download Section.
  Widget _buildBrowserSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: const Text('⬇️', style: TextStyle(fontSize: 32)),
        title: const Text(
          'Browser & Downloads',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Download music and inject healing frequencies'),
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HOW TO DOWNLOAD MUSIC',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '1. Open Browser tab\n'
                  '2. Go to YouTube or tap "Loader.to" quick link\n'
                  '3. Find the music you want\n'
                  '4. On Loader.to: paste YouTube URL and download\n'
                  '5. Downloads save automatically to your device\n'
                  '6. Use "Scan Downloads" to import to Library\n\n'
                  '432 Hz WEB INJECTION:\n'
                  'Toggle "432 Hz" switch while browsing to inject healing '
                  'frequencies into any website\'s audio in real-time.\n\n'
                  'Works on:\n'
                  '• YouTube, Spotify, SoundCloud, Apple Music\n'
                  '• Any website with audio/video\n'
                  '• Choose from 174-963 Hz Solfeggio frequencies\n\n'
                  'Ad Blocker & Popup Blocker included!',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Solfeggio Frequencies Section.
  Widget _buildFrequenciesSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: const Text('🎼', style: TextStyle(fontSize: 32)),
        title: const Text(
          'Solfeggio Frequencies',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Ancient healing tones'),
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THE SACRED FREQUENCIES',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '174 Hz - Pain Relief & Grounding\n'
                  '285 Hz - Cellular Healing & Tissue Repair\n'
                  '396 Hz - Liberation from Fear (Root Chakra)\n'
                  '417 Hz - Facilitating Change (Sacral Chakra)\n'
                  '528 Hz - DNA Repair & Love (Solar Plexus) ★\n'
                  '639 Hz - Relationships & Connection (Heart)\n'
                  '741 Hz - Awakening Intuition (Throat Chakra)\n'
                  '852 Hz - Spiritual Awareness (Third Eye)\n'
                  '963 Hz - Divine Enlightenment (Crown)\n\n'
                  '★ 528 Hz is called the "Love Frequency" or '
                  '"Miracle Tone" - used by biochemists to repair DNA.\n\n'
                  '432 Hz:\n'
                  'The "Natural Frequency" - mathematically consistent '
                  'with the universe. Concert pitch A=432 Hz instead '
                  'of the modern A=440 Hz creates more harmonious sound.',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
              ],
            ),
          ),
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
