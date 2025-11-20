/// SoulTune Frequency Generator Screen
///
/// Main interface for browsing and playing frequency presets.
/// Features tabbed navigation by category and preset selection.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soultune/features/generator/data/models/frequency_preset.dart';
import 'package:soultune/features/generator/data/models/predefined_presets.dart';
import 'package:soultune/features/generator/data/models/preset_category.dart';
import 'package:soultune/features/generator/presentation/providers/generator_providers.dart';
import 'package:soultune/features/generator/presentation/screens/binaural_editor_screen.dart';
import 'package:soultune/features/generator/presentation/screens/custom_generator_screen.dart';
import 'package:soultune/features/generator/presentation/screens/frequency_now_playing_screen.dart';
import 'package:soultune/features/generator/presentation/widgets/preset_detail_sheet.dart';
import 'package:soultune/shared/services/premium/premium_providers.dart';
import 'package:soultune/shared/widgets/premium/premium_widgets.dart';

/// Generator screen for frequency presets.
///
/// Displays available frequency presets organized by category.
/// Users can browse, favorite, and play presets.
class GeneratorScreen extends ConsumerStatefulWidget {
  /// Creates a [GeneratorScreen].
  const GeneratorScreen({super.key});

  @override
  ConsumerState<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends ConsumerState<GeneratorScreen>
    with SingleTickerProviderStateMixin {
  /// Tab controller for category tabs.
  late TabController _tabController;

  /// All available presets.
  late List<FrequencyPreset> _presets;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    _presets = getPredefinedPresets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Watch generator state from providers
    final currentPreset = ref.watch(currentGeneratorPresetProvider).valueOrNull;
    final isPlaying = ref.watch(generatorIsPlayingProvider).valueOrNull ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Frequency Generator',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            _buildTab(PresetCategory.sleep),
            _buildTab(PresetCategory.meditation),
            _buildTab(PresetCategory.focus),
            _buildTab(PresetCategory.healing),
            _buildTab(PresetCategory.energy),
            _buildTab(PresetCategory.cia),
            _buildTab(PresetCategory.oobe),
            _buildTab(PresetCategory.remoteViewing),
            _buildTab(PresetCategory.consciousness),
          ],
        ),
      ),
      body: Column(
        children: [
          // Preset list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPresetList(PresetCategory.sleep),
                _buildPresetList(PresetCategory.meditation),
                _buildPresetList(PresetCategory.focus),
                _buildPresetList(PresetCategory.healing),
                _buildPresetList(PresetCategory.energy),
                _buildPresetList(PresetCategory.cia),
                _buildPresetList(PresetCategory.oobe),
                _buildPresetList(PresetCategory.remoteViewing),
                _buildPresetList(PresetCategory.consciousness),
              ],
            ),
          ),

          // Now playing bar (if preset selected, even if paused)
          if (currentPreset != null) _buildNowPlayingBar(currentPreset, isPlaying, colorScheme),
        ],
      ),
      floatingActionButton: _buildFAB(colorScheme),
    );
  }

  /// Builds the floating action button with menu.
  Widget _buildFAB(ColorScheme colorScheme) {
    // Get current preset to check if now playing bar is visible
    final currentPreset = ref.watch(currentGeneratorPresetProvider).valueOrNull;

    return Padding(
      // Add bottom padding when now playing bar is visible to avoid overlap
      padding: EdgeInsets.only(
        bottom: currentPreset != null ? 80 : 0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Binaural Editor button (PREMIUM)
          FloatingActionButton.small(
            heroTag: 'binaural',
            onPressed: () => _handleBinauralEditorTap(),
            backgroundColor: colorScheme.secondaryContainer,
            child: const Icon(Icons.headphones),
          ),
          const SizedBox(height: 8),
          // Custom Generator button (PREMIUM)
          FloatingActionButton(
            heroTag: 'custom',
            onPressed: () => _handleCustomGeneratorTap(),
            child: const Icon(Icons.tune),
          ),
        ],
      ),
    );
  }

  /// Handles binaural editor button tap with premium check.
  void _handleBinauralEditorTap() {
    HapticFeedback.lightImpact();

    final isPremiumAsync = ref.read(isPremiumProvider);
    final isPremium = isPremiumAsync.valueOrNull ?? false;

    if (isPremium) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const BinauralEditorScreen(),
        ),
      );
    } else {
      PremiumUpgradeDialog.show(
        context,
        feature: 'Binaural Beat Editor',
      );
    }
  }

  /// Handles custom generator button tap with premium check.
  void _handleCustomGeneratorTap() {
    HapticFeedback.mediumImpact();

    final isPremiumAsync = ref.read(isPremiumProvider);
    final isPremium = isPremiumAsync.valueOrNull ?? false;

    if (isPremium) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const CustomGeneratorScreen(),
        ),
      );
    } else {
      PremiumUpgradeDialog.show(
        context,
        feature: 'Custom Generator',
      );
    }
  }

  /// Builds a tab with emoji and text.
  Widget _buildTab(PresetCategory category) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.emoji),
          const SizedBox(width: 6),
          Text(category.displayName),
        ],
      ),
    );
  }

  /// Builds the preset list for a category.
  Widget _buildPresetList(PresetCategory category) {
    final categoryPresets =
        _presets.where((p) => p.category == category).toList();

    if (categoryPresets.isEmpty) {
      return _buildEmptyState(category);
    }

    // Get current state from providers
    final currentPreset = ref.watch(currentGeneratorPresetProvider).valueOrNull;
    final isPlaying = ref.watch(generatorIsPlayingProvider).valueOrNull ?? false;

    return ListView.builder(
      itemCount: categoryPresets.length,
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemBuilder: (context, index) {
        final preset = categoryPresets[index];
        return ConditionalPremiumWrapper(
          gated: preset.isPremium,
          feature: preset.name,
          child: _PresetCard(
            preset: preset,
            isPlaying: currentPreset?.id == preset.id && isPlaying,
            onPlay: () => _playPreset(preset),
            onStop: _stopPreset,
            onFavorite: () => _toggleFavorite(preset),
            onTap: () => _showPresetDetails(preset),
          ),
        );
      },
    );
  }

  /// Shows the preset detail bottom sheet.
  void _showPresetDetails(FrequencyPreset preset) {
    HapticFeedback.selectionClick();

    // Get current state
    final currentPreset = ref.read(currentGeneratorPresetProvider).valueOrNull;
    final isPlaying = ref.read(generatorIsPlayingProvider).valueOrNull ?? false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PresetDetailSheet(
        preset: preset,
        isPlaying: currentPreset?.id == preset.id && isPlaying,
        onPlay: () {
          Navigator.of(context).pop();
          _playPreset(preset);
        },
        onStop: () {
          Navigator.of(context).pop();
          _stopPreset();
        },
        onFavorite: () => _toggleFavorite(preset),
      ),
    );
  }

  /// Builds empty state for a category.
  Widget _buildEmptyState(PresetCategory category) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category.emoji,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${category.displayName} Presets',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Custom presets coming soon!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the now playing bar at the bottom.
  Widget _buildNowPlayingBar(
    FrequencyPreset preset,
    bool isPlaying,
    ColorScheme colorScheme,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      // Tap to open fullscreen
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => const FrequencyNowPlayingScreen(),
          ),
        );
      },

      // Swipe up to open fullscreen
      onVerticalDragEnd: (details) {
        // Check if swipe was upward (negative velocity)
        if (details.primaryVelocity != null && details.primaryVelocity! < -500) {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const FrequencyNowPlayingScreen(),
            ),
          );
        }
      },

      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // Preset info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${preset.category.emoji} ${preset.name}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preset.frequencySummary,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Play/Stop button
              IconButton.filled(
                onPressed: isPlaying ? _stopPreset : () => _playPreset(preset),
                icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                iconSize: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Plays a frequency preset.
  Future<void> _playPreset(FrequencyPreset preset) async {
    HapticFeedback.mediumImpact();

    try {
      final playPreset = ref.read(playFrequencyPresetProvider);
      await playPreset(preset);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Playing ${preset.name}'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to play: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Stops the current preset.
  Future<void> _stopPreset() async {
    HapticFeedback.lightImpact();

    try {
      final stopGeneration = ref.read(stopFrequencyGenerationProvider);
      await stopGeneration();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stopped frequency generation'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error stopping: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Toggles favorite status for a preset.
  void _toggleFavorite(FrequencyPreset preset) {
    HapticFeedback.lightImpact();

    // TODO: Persist favorite status in Hive
    setState(() {
      final index = _presets.indexWhere((p) => p.id == preset.id);
      if (index != -1) {
        _presets[index] = preset.copyWith(isFavorite: !preset.isFavorite);
      }
    });

    final message = preset.isFavorite
        ? 'Removed from favorites'
        : 'Added to favorites';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

/// Preset card widget.
class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.preset,
    required this.isPlaying,
    required this.onPlay,
    required this.onStop,
    required this.onFavorite,
    required this.onTap,
  });

  final FrequencyPreset preset;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onStop;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: isPlaying ? 4 : 1,
      color: isPlaying
          ? colorScheme.primaryContainer.withOpacity(0.3)
          : colorScheme.surfaceContainerLow,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Play button
                  _buildPlayButton(colorScheme),

                  const SizedBox(width: 12),

                  // Title and frequency
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preset.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isPlaying
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          preset.frequencySummary,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Favorite button
                  IconButton(
                    onPressed: onFavorite,
                    icon: Icon(
                      preset.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: preset.isFavorite
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                preset.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Tags and duration
              Row(
                children: [
                  // Duration chip
                  _buildChip(
                    context,
                    Icons.timer_outlined,
                    preset.formattedDuration,
                  ),

                  const SizedBox(width: 8),

                  // Binaural indicator
                  if (preset.binauralConfig != null)
                    _buildChip(
                      context,
                      Icons.headphones,
                      '${preset.binauralConfig!.beatFrequency.toStringAsFixed(1)}Hz Beat',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the play/stop button.
  Widget _buildPlayButton(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        if (isPlaying) {
          onStop();
        } else {
          onPlay();
        }
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isPlaying ? colorScheme.primary : colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
          size: 32,
          color: isPlaying
              ? colorScheme.onPrimary
              : colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  /// Builds a small info chip.
  Widget _buildChip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
