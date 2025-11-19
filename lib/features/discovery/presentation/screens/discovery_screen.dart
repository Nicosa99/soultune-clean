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
import 'package:url_launcher/url_launcher.dart';

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
          _buildWhyItWorksSection(context),
          _buildBrowserSection(context),
          _buildFrequenciesSection(context),
          _buildCIASection(context, ref),
          _buildOBESection(context, ref),
          _buildRemoteViewingSection(context, ref),
          _buildScienceSection(context),
          _buildResearchSection(context),
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

  /// Why Frequencies Work - Scientific Explanation.
  Widget _buildWhyItWorksSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: const Text('🔬', style: TextStyle(fontSize: 32)),
        title: const Text(
          'Why Frequencies Work',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('The neuroscience behind brain synchronization'),
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FREQUENCY FOLLOWING RESPONSE (FFR)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your brain naturally synchronizes with external rhythmic '
                  'stimuli. This phenomenon, called Frequency Following '
                  'Response, has been documented in neuroscience since the '
                  '1930s.\n\n'
                  'HOW IT WORKS:\n\n'
                  '1️⃣ AUDITORY INPUT\n'
                  'Sound waves enter your ears and activate the auditory '
                  'cortex.\n\n'
                  '2️⃣ BRAINWAVE ENTRAINMENT\n'
                  'Your neurons begin firing in sync with the sound frequency. '
                  'This is automatic and involuntary - your brain MUST '
                  'respond.\n\n'
                  '3️⃣ STATE CHANGE\n'
                  'As brainwaves shift to match the target frequency, your '
                  'mental state changes accordingly.\n\n'
                  'EXAMPLE: 7 Hz Theta Frequency\n'
                  '• Left ear: 200 Hz tone\n'
                  '• Right ear: 207 Hz tone\n'
                  '• Brain perceives: 7 Hz difference (binaural beat)\n'
                  '• Brainwaves entrain: Theta state (deep meditation)\n'
                  '• Result: Reduced anxiety, enhanced creativity\n\n'
                  'SCIENTIFIC VALIDATION:\n'
                  '• 2019 Nature Study: FFR originates from both subcortical '
                  'AND cortical brain regions\n'
                  '• Measurable on EEG within 5-10 minutes\n'
                  '• Effects persist 15-30 minutes after exposure\n'
                  '• Cumulative benefits with regular use',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.secondary.withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.psychology,
                            color: colorScheme.secondary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'BRAINWAVE STATES',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildBrainwaveItem(
                        'Delta (0.5-4 Hz)',
                        'Deep sleep, healing, unconscious',
                        Colors.indigo,
                        theme,
                      ),
                      const SizedBox(height: 8),
                      _buildBrainwaveItem(
                        'Theta (4-8 Hz)',
                        'Meditation, creativity, REM sleep',
                        Colors.purple,
                        theme,
                      ),
                      const SizedBox(height: 8),
                      _buildBrainwaveItem(
                        'Alpha (8-13 Hz)',
                        'Relaxation, flow state, present moment',
                        Colors.blue,
                        theme,
                      ),
                      const SizedBox(height: 8),
                      _buildBrainwaveItem(
                        'Beta (13-30 Hz)',
                        'Active thinking, focus, alertness',
                        Colors.green,
                        theme,
                      ),
                      const SizedBox(height: 8),
                      _buildBrainwaveItem(
                        'Gamma (30-100 Hz)',
                        'Peak performance, learning, insight',
                        Colors.orange,
                        theme,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to build brainwave state item.
  Widget _buildBrainwaveItem(
    String name,
    String description,
    Color color,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall,
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
        leading: const Text('🌐', style: TextStyle(fontSize: 32)),
        title: const Text(
          'Integrated Browser',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Browse the web with frequency injection'),
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INTEGRATED WEB BROWSER',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Browse your favorite music platforms with built-in '
                  'frequency enhancement.\n\n'
                  '432 Hz WEB INJECTION:\n'
                  'Toggle the "432 Hz" switch while browsing to inject healing '
                  'frequencies into any website\'s audio in real-time.\n\n'
                  'Supported Platforms:\n'
                  '• YouTube, Spotify, SoundCloud, Apple Music\n'
                  '• Any website with audio/video content\n'
                  '• Choose from 174-963 Hz Solfeggio frequencies\n\n'
                  'Features:\n'
                  '• Ad Blocker & Popup Blocker included\n'
                  '• Automatic detection of audio files\n'
                  '• Downloads folder scanner for easy import\n'
                  '• Session persistence (stay logged in)\n\n'
                  'When you download music files through the browser, '
                  'use "Scan Downloads" to import them directly to your Library.',
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
        subtitle: const Text('Ancient healing tones & chakra alignment'),
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
                const SizedBox(height: 16),
                _buildFrequencyCard(
                  '174 Hz',
                  'Pain Relief & Grounding',
                  'Lowest Solfeggio frequency, foundation & security',
                  '🌍',
                  Colors.brown,
                  theme,
                ),
                const SizedBox(height: 12),
                _buildFrequencyCard(
                  '285 Hz',
                  'Cellular Healing',
                  'Tissue regeneration, wound healing, energy field restructuring',
                  '🔬',
                  Colors.teal,
                  theme,
                ),
                const SizedBox(height: 12),
                _buildFrequencyCard(
                  '396 Hz',
                  'Liberation from Fear',
                  'Root Chakra • Releases guilt and fear, grounding energy',
                  '🔴',
                  Colors.red,
                  theme,
                ),
                const SizedBox(height: 12),
                _buildFrequencyCard(
                  '417 Hz',
                  'Facilitating Change',
                  'Sacral Chakra • Clears trauma, enables transformation',
                  '🟠',
                  Colors.orange,
                  theme,
                ),
                const SizedBox(height: 12),
                _buildFrequencyCard(
                  '528 Hz',
                  'DNA Repair & Love ★',
                  'Solar Plexus • The "Miracle Tone" used by molecular '
                      'biologists for DNA repair in laboratory protocols',
                  '🟡',
                  Colors.amber,
                  theme,
                  isHighlighted: true,
                ),
                const SizedBox(height: 12),
                _buildFrequencyCard(
                  '639 Hz',
                  'Relationships & Connection',
                  'Heart Chakra • Harmonious relationships, balanced communication',
                  '🟢',
                  Colors.green,
                  theme,
                ),
                const SizedBox(height: 12),
                _buildFrequencyCard(
                  '741 Hz',
                  'Awakening Intuition',
                  'Throat Chakra • Expression, emotional detoxification',
                  '🔵',
                  Colors.blue,
                  theme,
                ),
                const SizedBox(height: 12),
                _buildFrequencyCard(
                  '852 Hz',
                  'Spiritual Awareness',
                  'Third Eye • Enhanced intuition, higher consciousness',
                  '🟣',
                  Colors.indigo,
                  theme,
                ),
                const SizedBox(height: 12),
                _buildFrequencyCard(
                  '963 Hz',
                  'Divine Connection',
                  'Crown Chakra • Pineal gland activation, oneness with universe',
                  '⚪',
                  Colors.purple,
                  theme,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🎵', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Text(
                            '432 Hz - The Natural Frequency',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mathematically consistent with the universe. '
                        'Concert pitch A=432 Hz (vs. modern A=440 Hz) '
                        'creates more harmonious resonance with nature.',
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Text(
                            'HOW TO USE SOLFEGGIO FREQUENCIES',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '1. IDENTIFY YOUR INTENTION\n'
                        '   • Physical healing? → 174/285 Hz\n'
                        '   • Emotional release? → 396/417 Hz\n'
                        '   • Love & relationships? → 528/639 Hz\n'
                        '   • Spiritual growth? → 741/852/963 Hz\n\n'
                        '2. LISTEN DURATION\n'
                        '   • Minimum: 15 minutes per session\n'
                        '   • Optimal: 20-30 minutes\n'
                        '   • Maximum benefit: 45-60 minutes\n\n'
                        '3. BEST PRACTICES\n'
                        '   • Use headphones for binaural beats\n'
                        '   • Quiet, distraction-free environment\n'
                        '   • Meditative or relaxed state\n'
                        '   • Daily use for cumulative effects\n\n'
                        '4. COMBINING FREQUENCIES\n'
                        '   You can layer multiple Solfeggio tones:\n'
                        '   • 528 Hz (DNA healing) + 432 Hz (base pitch)\n'
                        '   • 396 Hz (fear release) + 639 Hz (love)\n'
                        '   Use the Generator tab to create custom blends!',
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a frequency card with color coding.
  Widget _buildFrequencyCard(
    String frequency,
    String title,
    String description,
    String emoji,
    Color color,
    ThemeData theme, {
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlighted
            ? color.withOpacity(0.15)
            : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(isHighlighted ? 0.5 : 0.3),
          width: isHighlighted ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      frequency,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
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
                  'Document: "Analysis and Assessment of Gateway Process"\n'
                  'Author: Lt. Col. Wayne M. McDonnell (U.S. Army Intelligence)\n'
                  'Date: June 9, 1983 • Length: 29 pages\n'
                  'Declassified: 2003 • Public: CIA CREST 2017\n\n'
                  'The Missing Page 25:\n'
                  'Page 25 was missing from declassified document until 2021, '
                  'sparking conspiracy theories. When found, it contained '
                  'technical explanation of out-of-body mechanics.\n\n'
                  'Key CIA Conclusions:\n'
                  '• Binaural beats induce measurable brain changes\n'
                  '• Out-of-body experiences are trainable states\n'
                  '• Remote viewing capability can be developed\n'
                  '• "Consciousness may exist beyond spacetime"\n\n'
                  'Focus States (Monroe Institute Protocol):\n'
                  '• Focus 10: Mind Awake/Body Asleep\n'
                  '• Focus 12: Expanded Awareness\n'
                  '• Focus 15: "No-Time" State\n'
                  '• Focus 21: Gateway to Other Energy Systems\n\n'
                  'Viral Impact: 10M+ views on TikTok/YouTube (2021)',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 16),
                _buildLinkButton(
                  context,
                  'Read Official CIA Document',
                  'https://www.cia.gov/readingroom/document/cia-rdp96-00788r001700210016-5',
                  Icons.description,
                  theme,
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
                  'Scientific Definition:\n'
                  'An altered state where consciousness appears to separate '
                  'from the physical body, perceiving from an external vantage point.\n\n'
                  'Prevalence:\n'
                  '• 10% of population: spontaneous OBEs\n'
                  '• 25% report at least one in lifetime\n'
                  '• Training can increase probability 5-10x\n\n'
                  'University of Ottawa Study (2014):\n'
                  'fMRI brain mapping during induced OBEs revealed specific '
                  'activation in Temporoparietal Junction (TPJ) - the brain '
                  'region that processes body schema and spatial awareness.\n\n'
                  'Brain Regions Involved:\n'
                  '• Left Temporoparietal Junction (body dissociation)\n'
                  '• Left Supplementary Motor Area\n'
                  '• Left Cerebellum (kinesthetic imagery)\n\n'
                  'Optimal Conditions:\n'
                  '• 3-6 AM (melatonin peak)\n'
                  '• After 4-6 hours sleep ("wake back to bed")\n'
                  '• Theta frequency (4-8 Hz) binaural beats',
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
                  'Duration: 1978-1995 (17 years)\n'
                  'Budget: \$20 million total\n'
                  'Location: Fort Meade, Maryland\n'
                  'Unit Size: 15-20 trained viewers\n\n'
                  'Joseph McMoneagle (Agent 001):\n'
                  '• Most successful remote viewer in program\n'
                  '• 450+ operational missions completed\n'
                  '• 85%+ accuracy on verifiable targets\n'
                  '• Located Soviet submarine (1979)\n'
                  '• Awarded Legion of Merit for intelligence work\n\n'
                  'AIR Review (1995):\n'
                  '"Statistically significant effect has been observed '
                  'in laboratory" - though program was terminated due to '
                  'difficulty converting results into actionable intelligence.\n\n'
                  'Frequency Protocols:\n'
                  '• Focus 10-15: Target acquisition\n'
                  '• Beta waves (15-20 Hz): Active remote viewing\n'
                  '• Theta waves (4-8 Hz): Deep information access',
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
                  '1. Left ear: 200 Hz tone\n'
                  '2. Right ear: 207 Hz tone\n'
                  '3. Brain perceives: 7 Hz phantom "beat"\n'
                  '4. Brainwaves entrain to 7 Hz (Theta frequency)\n'
                  '5. Mental state shifts to match target frequency',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.science,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '2024 BREAKTHROUGH STUDY',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'PLOS ONE (July 2024) - Sudre et al.\n'
                        '"A new perspective on binaural beats: '
                        'Investigating the effects of spatially moving sounds"\n\n'
                        'KEY FINDING:\n'
                        '"Panning beats show significantly MORE PRONOUNCED '
                        'effects on brain activity than static binaural beats."\n\n'
                        '✨ SoulTune\'s Advantage:\n'
                        'Our Generator uses advanced ADAPTIVE PANNING '
                        '(0.1s-10s cycles) synchronized with brainwave '
                        'frequencies - exactly what the research shows '
                        'is most effective!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Additional 2024 Research:\n\n'
                  'Nature Study (1-month daily use):\n'
                  '• Week 2: Increased auditory P300 amplitude\n'
                  '• Week 3: Reduced P300 latency (faster processing)\n'
                  '• Week 4: Decreased reaction time (auditory + visual)\n'
                  '• Conclusion: Enhanced cognitive function with sustained use\n\n'
                  '40 Hz Gamma Study (48 subjects):\n'
                  '• Significantly enhanced reading comprehension\n'
                  '• Improved attention span\n'
                  '• Neural entrainment via gamma frequency power',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Research & Studies Section with external links.
  Widget _buildResearchSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: const Text('📚', style: TextStyle(fontSize: 32)),
        title: const Text(
          'Research & Studies',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Scientific papers and government documents'),
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GOVERNMENT DOCUMENTS',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildLinkButton(
                  context,
                  'CIA Gateway Process (1983)',
                  'https://www.cia.gov/readingroom/document/cia-rdp96-00788r001700210016-5',
                  Icons.description,
                  theme,
                ),
                const SizedBox(height: 8),
                _buildLinkButton(
                  context,
                  'Project Stargate Archive (CIA CREST)',
                  'https://www.cia.gov/readingroom/collection/stargate',
                  Icons.folder_open,
                  theme,
                ),
                const SizedBox(height: 20),
                Text(
                  'PEER-REVIEWED STUDIES',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildLinkButton(
                  context,
                  'PLOS ONE 2024 - Panning Binaural Beats',
                  'https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0306427',
                  Icons.article,
                  theme,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sudre et al., "A new perspective on binaural beats"\n'
                  '• Panning beats > static binaural beats\n'
                  '• Enhanced relaxation at 6 Hz and 40 Hz\n'
                  '• Spatial attributes crucial for effectiveness',
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 16),
                _buildLinkButton(
                  context,
                  'Nature 2024 - Cognitive Enhancement Study',
                  'https://www.nature.com/articles/s41598-024-68628-9',
                  Icons.article,
                  theme,
                ),
                const SizedBox(height: 8),
                Text(
                  '1-month daily 6 Hz binaural beat exposure:\n'
                  '• Increased P300 amplitude (attention marker)\n'
                  '• Reduced reaction time (faster processing)\n'
                  '• Enhanced cognitive function',
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 16),
                _buildLinkButton(
                  context,
                  'Frontiers 2014 - OBE Brain Mapping',
                  'https://pubmed.ncbi.nlm.nih.gov/24550805/',
                  Icons.article,
                  theme,
                ),
                const SizedBox(height: 8),
                Text(
                  'Smith & Messier, "Voluntary out-of-body experience: an fMRI study"\n'
                  '• University of Ottawa fMRI mapping during induced OBEs\n'
                  '• Temporoparietal junction activation\n'
                  '• Reproducible brain state',
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 20),
                Text(
                  '432 HZ RESEARCH',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildLinkButton(
                  context,
                  'Italian Study 2019 - Heart Rate Effects',
                  'https://pubmed.ncbi.nlm.nih.gov/31031095/',
                  Icons.favorite,
                  theme,
                ),
                const SizedBox(height: 8),
                Text(
                  'Calamassi & Pomponi: 432 Hz music decreased heart rate '
                  'by 4.79 bpm (p=0.05) compared to 440 Hz',
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 16),
                _buildLinkButton(
                  context,
                  'Chilean Dental Study 2020 - Cortisol Reduction',
                  'https://www.scielo.br/j/jaos/a/kkzqnX5PgqgdKzT3BhHdX7w/',
                  Icons.spa,
                  theme,
                ),
                const SizedBox(height: 8),
                Text(
                  'Aravena et al.: 432 Hz reduced salivary cortisol by 64% '
                  'compared to 440 Hz (p<0.05) - biological stress marker validation',
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 20),
                Text(
                  'MONROE INSTITUTE',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildLinkButton(
                  context,
                  'Monroe Institute - Hemi-Sync Research',
                  'https://www.monroeinstitute.org',
                  Icons.auto_graph,
                  theme,
                ),
                const SizedBox(height: 16),
                Text(
                  '• Founded 1971 by Robert Monroe\n'
                  '• Gateway Experience: Tens of thousands trained\n'
                  '• 2017 Military Study: 14.3% stress reduction\n'
                  '• EEG-validated protocols for consciousness research',
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a clickable link button.
  Widget _buildLinkButton(
    BuildContext context,
    String label,
    String url,
    IconData icon,
    ThemeData theme,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontSize: 13),
        ),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onPressed: () => _launchURL(context, url),
      ),
    );
  }

  /// Launches external URL in browser.
  Future<void> _launchURL(BuildContext context, String urlString) async {
    final url = Uri.parse(urlString);

    try {
      // First try: External application
      bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      // Second try: Platform default
      if (!launched) {
        launched = await launchUrl(
          url,
          mode: LaunchMode.platformDefault,
        );
      }

      // Third try: In-app WebView
      if (!launched) {
        launched = await launchUrl(
          url,
          mode: LaunchMode.inAppWebView,
        );
      }

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link: $urlString'),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: 'Copy',
              textColor: Colors.white,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: urlString));
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Could not open link'),
                const SizedBox(height: 4),
                Text(
                  urlString,
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: 'Copy URL',
              textColor: Colors.white,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: urlString));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ URL copied to clipboard'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
        );
      }
    }
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
