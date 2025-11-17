/// Custom Frequency Generator Screen
///
/// Allows users to create and play custom frequency combinations.
/// Supports up to 3 layers with different waveforms.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soultune/features/generator/data/models/frequency_constants.dart';
import 'package:soultune/features/generator/data/models/frequency_layer.dart';
import 'package:soultune/features/generator/data/models/frequency_preset.dart';
import 'package:soultune/features/generator/data/models/preset_category.dart';
import 'package:soultune/features/generator/data/models/waveform.dart';
import 'package:soultune/features/generator/presentation/providers/generator_providers.dart';
import 'package:uuid/uuid.dart';

/// Screen for creating custom frequency combinations.
class CustomGeneratorScreen extends ConsumerStatefulWidget {
  /// Creates a [CustomGeneratorScreen].
  const CustomGeneratorScreen({super.key});

  @override
  ConsumerState<CustomGeneratorScreen> createState() =>
      _CustomGeneratorScreenState();
}

class _CustomGeneratorScreenState
    extends ConsumerState<CustomGeneratorScreen> {
  /// Current frequency layers.
  final List<_LayerConfig> _layers = [
    _LayerConfig(
      frequency: kSolfeggio528Hz,
      waveform: Waveform.sine,
      volume: 0.7,
    ),
  ];

  /// Selected session duration in minutes.
  int _durationMinutes = 15;

  /// Master volume.
  double _masterVolume = 0.8;

  /// Whether currently playing.
  bool _isPlaying = false;

  /// Session timer.
  Timer? _sessionTimer;

  /// Remaining session time.
  Duration _remainingTime = Duration.zero;

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Generator'),
        actions: [
          if (_isPlaying)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  _formatDuration(_remainingTime),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Frequency Layers
            _buildLayersSection(theme, colorScheme),

            const SizedBox(height: 24),

            // Session Duration
            _buildDurationSection(theme, colorScheme),

            const SizedBox(height: 24),

            // Master Volume
            _buildVolumeSection(theme, colorScheme),

            const SizedBox(height: 32),

            // Play Button
            _buildPlayButton(colorScheme),

            const SizedBox(height: 16),

            // Save Preset Button
            if (!_isPlaying)
              OutlinedButton.icon(
                onPressed: _saveAsPreset,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save as Preset'),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds the frequency layers section.
  Widget _buildLayersSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Frequency Layers',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_layers.length < kMaxFrequencyLayers)
              TextButton.icon(
                onPressed: _addLayer,
                icon: const Icon(Icons.add),
                label: const Text('Add Layer'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ..._layers.asMap().entries.map((entry) {
          return _buildLayerCard(entry.key, entry.value, theme, colorScheme);
        }),
      ],
    );
  }

  /// Builds a single layer configuration card.
  Widget _buildLayerCard(
    int index,
    _LayerConfig layer,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Layer header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Layer ${index + 1}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_layers.length > 1)
                  IconButton(
                    onPressed: () => _removeLayer(index),
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Frequency display
            Center(
              child: Text(
                '${layer.frequency.toStringAsFixed(1)} Hz',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Frequency slider
            Slider(
              value: layer.frequency,
              min: kMinFrequency,
              max: kMaxFrequency,
              divisions: 1000,
              onChanged: (value) => _updateLayerFrequency(index, value),
            ),

            // Frequency presets
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFrequencyChip('174', 174, index),
                _buildFrequencyChip('285', 285, index),
                _buildFrequencyChip('396', 396, index),
                _buildFrequencyChip('432', 432, index),
                _buildFrequencyChip('528', 528, index),
                _buildFrequencyChip('639', 639, index),
                _buildFrequencyChip('741', 741, index),
                _buildFrequencyChip('852', 852, index),
                _buildFrequencyChip('963', 963, index),
              ],
            ),

            const SizedBox(height: 16),

            // Waveform selector
            Text(
              'Waveform',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<Waveform>(
              segments: Waveform.values.map((w) {
                return ButtonSegment(
                  value: w,
                  label: Text(w.displayName),
                  icon: Icon(_getWaveformIcon(w), size: 18),
                );
              }).toList(),
              selected: {layer.waveform},
              onSelectionChanged: (selected) {
                _updateLayerWaveform(index, selected.first);
              },
            ),

            const SizedBox(height: 16),

            // Volume slider
            Row(
              children: [
                Text(
                  'Volume',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: layer.volume,
                    min: 0,
                    max: 1,
                    onChanged: (value) => _updateLayerVolume(index, value),
                  ),
                ),
                Text(
                  '${(layer.volume * 100).toInt()}%',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a frequency preset chip.
  Widget _buildFrequencyChip(String label, double frequency, int layerIndex) {
    final isSelected = (_layers[layerIndex].frequency - frequency).abs() < 1;

    return ActionChip(
      label: Text('$label Hz'),
      onPressed: () => _updateLayerFrequency(layerIndex, frequency),
      backgroundColor:
          isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
    );
  }

  /// Builds the session duration section.
  Widget _buildDurationSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session Duration',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 5, label: Text('5m')),
            ButtonSegment(value: 15, label: Text('15m')),
            ButtonSegment(value: 30, label: Text('30m')),
            ButtonSegment(value: 60, label: Text('1h')),
            ButtonSegment(value: 0, label: Text('∞')),
          ],
          selected: {_durationMinutes},
          onSelectionChanged: (selected) {
            setState(() {
              _durationMinutes = selected.first;
            });
          },
        ),
      ],
    );
  }

  /// Builds the master volume section.
  Widget _buildVolumeSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Master Volume',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.volume_down),
            Expanded(
              child: Slider(
                value: _masterVolume,
                min: 0,
                max: 1,
                onChanged: (value) {
                  setState(() {
                    _masterVolume = value;
                  });
                  if (_isPlaying) {
                    final setVolume = ref.read(setGeneratorVolumeProvider);
                    setVolume(value);
                  }
                },
              ),
            ),
            const Icon(Icons.volume_up),
            const SizedBox(width: 8),
            Text('${(_masterVolume * 100).toInt()}%'),
          ],
        ),
      ],
    );
  }

  /// Builds the main play/stop button.
  Widget _buildPlayButton(ColorScheme colorScheme) {
    return SizedBox(
      height: 64,
      child: FilledButton.icon(
        onPressed: _isPlaying ? _stopPlayback : _startPlayback,
        icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow, size: 32),
        label: Text(
          _isPlaying ? 'STOP' : 'PLAY',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor:
              _isPlaying ? colorScheme.error : colorScheme.primary,
        ),
      ),
    );
  }

  /// Gets icon for waveform type.
  IconData _getWaveformIcon(Waveform waveform) {
    return switch (waveform) {
      Waveform.sine => Icons.waves,
      Waveform.square => Icons.square_outlined,
      Waveform.triangle => Icons.change_history,
      Waveform.sawtooth => Icons.show_chart,
    };
  }

  /// Formats duration for display.
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Adds a new layer.
  void _addLayer() {
    if (_layers.length >= kMaxFrequencyLayers) return;

    HapticFeedback.lightImpact();
    setState(() {
      _layers.add(
        _LayerConfig(
          frequency: kSolfeggio432Hz,
          waveform: Waveform.sine,
          volume: 0.5,
        ),
      );
    });
  }

  /// Removes a layer.
  void _removeLayer(int index) {
    if (_layers.length <= 1) return;

    HapticFeedback.lightImpact();
    setState(() {
      _layers.removeAt(index);
    });
  }

  /// Updates layer frequency.
  void _updateLayerFrequency(int index, double frequency) {
    setState(() {
      _layers[index] = _layers[index].copyWith(frequency: frequency);
    });
  }

  /// Updates layer waveform.
  void _updateLayerWaveform(int index, Waveform waveform) {
    HapticFeedback.selectionClick();
    setState(() {
      _layers[index] = _layers[index].copyWith(waveform: waveform);
    });
  }

  /// Updates layer volume.
  void _updateLayerVolume(int index, double volume) {
    setState(() {
      _layers[index] = _layers[index].copyWith(volume: volume);
    });
  }

  /// Starts playback of current configuration.
  Future<void> _startPlayback() async {
    HapticFeedback.mediumImpact();

    final preset = FrequencyPreset(
      id: const Uuid().v4(),
      name: 'Custom',
      category: PresetCategory.custom,
      description: 'Custom frequency configuration',
      layers: _layers
          .map(
            (l) => FrequencyLayer(
              frequency: l.frequency,
              waveform: l.waveform,
              volume: l.volume,
            ),
          )
          .toList(),
      durationMinutes: _durationMinutes,
      volume: _masterVolume,
      isCustom: true,
      createdAt: DateTime.now(),
    );

    try {
      final playPreset = ref.read(playFrequencyPresetProvider);
      await playPreset(preset);

      setState(() {
        _isPlaying = true;
        if (_durationMinutes > 0) {
          _remainingTime = Duration(minutes: _durationMinutes);
          _startSessionTimer();
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Playing custom frequency'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
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

  /// Stops playback.
  Future<void> _stopPlayback() async {
    HapticFeedback.lightImpact();

    _sessionTimer?.cancel();

    try {
      final stopGeneration = ref.read(stopFrequencyGenerationProvider);
      await stopGeneration();

      setState(() {
        _isPlaying = false;
        _remainingTime = Duration.zero;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stopped'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Starts the session countdown timer.
  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds <= 0) {
        timer.cancel();
        _stopPlayback();
        return;
      }

      setState(() {
        _remainingTime = _remainingTime - const Duration(seconds: 1);
      });
    });
  }

  /// Saves current configuration as a preset.
  void _saveAsPreset() {
    // TODO: Implement save dialog and Hive persistence
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Save preset coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Internal layer configuration.
class _LayerConfig {
  _LayerConfig({
    required this.frequency,
    required this.waveform,
    required this.volume,
  });

  final double frequency;
  final Waveform waveform;
  final double volume;

  _LayerConfig copyWith({
    double? frequency,
    Waveform? waveform,
    double? volume,
  }) {
    return _LayerConfig(
      frequency: frequency ?? this.frequency,
      waveform: waveform ?? this.waveform,
      volume: volume ?? this.volume,
    );
  }
}
