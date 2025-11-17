/// Binaural Beats Editor Screen
///
/// Allows users to create binaural beats by setting left and right
/// ear frequencies. The beat frequency is auto-calculated.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soultune/features/generator/data/models/binaural_config.dart';
import 'package:soultune/features/generator/data/models/frequency_constants.dart';
import 'package:soultune/features/generator/data/models/frequency_preset.dart';
import 'package:soultune/features/generator/data/models/preset_category.dart';
import 'package:soultune/features/generator/domain/panning_engine.dart';
import 'package:soultune/features/generator/presentation/providers/generator_providers.dart';
import 'package:soultune/features/generator/presentation/widgets/panning_indicator.dart';
import 'package:soultune/features/generator/presentation/widgets/waveform_visualizer.dart';
import 'package:uuid/uuid.dart';

/// Screen for creating and playing binaural beats.
class BinauralEditorScreen extends ConsumerStatefulWidget {
  /// Creates a [BinauralEditorScreen].
  const BinauralEditorScreen({super.key});

  @override
  ConsumerState<BinauralEditorScreen> createState() =>
      _BinauralEditorScreenState();
}

class _BinauralEditorScreenState extends ConsumerState<BinauralEditorScreen> {
  /// Left ear frequency.
  double _leftFrequency = 200;

  /// Right ear frequency.
  double _rightFrequency = 210;

  /// Master volume.
  double _volume = 0.7;

  /// Session duration in minutes.
  int _durationMinutes = 15;

  /// Whether currently playing.
  bool _isPlaying = false;

  /// Session timer.
  Timer? _sessionTimer;

  /// Remaining session time.
  Duration _remainingTime = Duration.zero;

  /// Whether panning modulation is enabled.
  bool _panningEnabled = false;

  /// Current pan position for visualization.
  double _panPosition = 0.0;

  /// Beat frequency (auto-calculated).
  double get _beatFrequency => (_rightFrequency - _leftFrequency).abs();

  /// Brainwave category based on beat frequency.
  String get _brainwaveCategory {
    if (_beatFrequency <= kDeltaMax) return 'Delta';
    if (_beatFrequency <= kThetaMax) return 'Theta';
    if (_beatFrequency <= kAlphaMax) return 'Alpha';
    if (_beatFrequency <= kBetaMax) return 'Beta';
    return 'Gamma';
  }

  /// Description for current brainwave category.
  String get _brainwaveDescription {
    return switch (_brainwaveCategory) {
      'Delta' => 'Deep sleep, healing, regeneration',
      'Theta' => 'Meditation, creativity, dreams',
      'Alpha' => 'Relaxed focus, calm awareness',
      'Beta' => 'Active thinking, concentration',
      'Gamma' => 'Peak performance, insight',
      _ => '',
    };
  }

  /// Color for brainwave category.
  Color _getBrainwaveColor(ColorScheme colorScheme) {
    return switch (_brainwaveCategory) {
      'Delta' => Colors.indigo,
      'Theta' => Colors.purple,
      'Alpha' => Colors.green,
      'Beta' => Colors.orange,
      'Gamma' => Colors.red,
      _ => colorScheme.primary,
    };
  }

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
        title: const Text('Binaural Beats'),
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
            // Beat Frequency Display (prominent)
            _buildBeatDisplay(theme, colorScheme),

            const SizedBox(height: 32),

            // Left Ear Frequency
            _buildFrequencyControl(
              title: 'Left Ear',
              icon: Icons.hearing,
              frequency: _leftFrequency,
              onChanged: (value) {
                setState(() {
                  _leftFrequency = value;
                });
              },
              theme: theme,
              colorScheme: colorScheme,
            ),

            const SizedBox(height: 24),

            // Right Ear Frequency
            _buildFrequencyControl(
              title: 'Right Ear',
              icon: Icons.hearing,
              frequency: _rightFrequency,
              onChanged: (value) {
                setState(() {
                  _rightFrequency = value;
                });
              },
              theme: theme,
              colorScheme: colorScheme,
            ),

            const SizedBox(height: 24),

            // Quick Presets
            _buildQuickPresets(theme, colorScheme),

            const SizedBox(height: 24),

            // Duration Selector
            _buildDurationSelector(theme, colorScheme),

            const SizedBox(height: 24),

            // Volume Control
            _buildVolumeControl(theme, colorScheme),

            const SizedBox(height: 24),

            // Panning Toggle
            _buildPanningToggle(theme, colorScheme),

            // Panning Indicator (when playing with panning)
            if (_isPlaying && _panningEnabled)
              _buildPanningVisualization(theme, colorScheme),

            const SizedBox(height: 32),

            // Play Button
            _buildPlayButton(colorScheme),
          ],
        ),
      ),
    );
  }

  /// Builds the beat frequency display card.
  Widget _buildBeatDisplay(ThemeData theme, ColorScheme colorScheme) {
    final brainwaveColor = _getBrainwaveColor(colorScheme);

    return Card(
      color: brainwaveColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Beat Frequency',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_beatFrequency.toStringAsFixed(1)} Hz',
              style: theme.textTheme.displaySmall?.copyWith(
                color: brainwaveColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: brainwaveColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_brainwaveCategory Wave',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: brainwaveColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _brainwaveDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a frequency control slider.
  Widget _buildFrequencyControl({
    required String title,
    required IconData icon,
    required double frequency,
    required ValueChanged<double> onChanged,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            '${frequency.toStringAsFixed(1)} Hz',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Slider(
          value: frequency,
          min: 100,
          max: 1000,
          divisions: 900,
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '100 Hz',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '1000 Hz',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds quick preset buttons.
  Widget _buildQuickPresets(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Presets',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPresetChip('2Hz Delta', 200, 202),
            _buildPresetChip('6Hz Theta', 200, 206),
            _buildPresetChip('10Hz Alpha', 200, 210),
            _buildPresetChip('20Hz Beta', 200, 220),
            _buildPresetChip('40Hz Gamma', 200, 240),
          ],
        ),
      ],
    );
  }

  /// Builds a preset chip button.
  Widget _buildPresetChip(String label, double left, double right) {
    final isSelected =
        (_leftFrequency - left).abs() < 1 && (_rightFrequency - right).abs() < 1;

    return ActionChip(
      label: Text(label),
      onPressed: () {
        HapticFeedback.selectionClick();
        setState(() {
          _leftFrequency = left;
          _rightFrequency = right;
        });
      },
      backgroundColor:
          isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
    );
  }

  /// Builds the duration selector.
  Widget _buildDurationSelector(ThemeData theme, ColorScheme colorScheme) {
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

  /// Builds the volume control.
  Widget _buildVolumeControl(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Volume',
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
                value: _volume,
                min: 0,
                max: 1,
                onChanged: (value) {
                  setState(() {
                    _volume = value;
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
            Text('${(_volume * 100).toInt()}%'),
          ],
        ),
      ],
    );
  }

  /// Builds the play/stop button.
  Widget _buildPlayButton(ColorScheme colorScheme) {
    return SizedBox(
      height: 64,
      child: FilledButton.icon(
        onPressed: _isPlaying ? _stopPlayback : _startPlayback,
        icon: Icon(_isPlaying ? Icons.stop : Icons.headphones, size: 32),
        label: Text(
          _isPlaying ? 'STOP' : 'PLAY BINAURAL BEAT',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor:
              _isPlaying ? colorScheme.error : colorScheme.primary,
        ),
      ),
    );
  }

  /// Formats duration for display.
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Starts binaural beat playback.
  Future<void> _startPlayback() async {
    HapticFeedback.mediumImpact();

    final preset = FrequencyPreset(
      id: const Uuid().v4(),
      name: 'Custom Binaural',
      category: PresetCategory.custom,
      description: '${_beatFrequency.toStringAsFixed(1)}Hz '
          '$_brainwaveCategory beat',
      layers: const [],
      binauralConfig: BinauralConfig(
        leftFrequency: _leftFrequency,
        rightFrequency: _rightFrequency,
      ),
      durationMinutes: _durationMinutes,
      volume: _volume,
      isCustom: true,
      createdAt: DateTime.now(),
    );

    try {
      if (_panningEnabled) {
        final playWithPanning = ref.read(playPresetWithPanningProvider);
        await playWithPanning(
          preset,
          enablePanning: true,
          config: PanningConfig.research,
        );

        // Start listening to pan position updates
        _listenToPanPosition();
      } else {
        final playPreset = ref.read(playFrequencyPresetProvider);
        await playPreset(preset);
      }

      setState(() {
        _isPlaying = true;
        if (_durationMinutes > 0) {
          _remainingTime = Duration(minutes: _durationMinutes);
          _startSessionTimer();
        }
      });

      if (mounted) {
        final panningInfo = _panningEnabled ? ' (L↔R Panning)' : '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Playing ${_beatFrequency.toStringAsFixed(1)}Hz '
              '$_brainwaveCategory beat$panningInfo',
            ),
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

  /// Starts session countdown timer.
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

  /// Listens to pan position stream for visualization.
  void _listenToPanPosition() {
    final service = ref.read(frequencyGeneratorServiceProvider);
    service.panPositionStream.listen((position) {
      if (mounted && _isPlaying) {
        setState(() {
          _panPosition = position;
        });
      }
    });
  }

  /// Builds the panning toggle switch.
  Widget _buildPanningToggle(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      color: _panningEnabled
          ? colorScheme.primaryContainer.withOpacity(0.3)
          : null,
      child: SwitchListTile(
        title: const Text('L↔R Panning Modulation'),
        subtitle: Text(
          _panningEnabled
              ? 'Enhanced brain sync (15s cycle, 35% depth)'
              : 'Enable for advanced brain hemisphere synchronization',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        secondary: Icon(
          Icons.surround_sound,
          color: _panningEnabled ? colorScheme.primary : null,
        ),
        value: _panningEnabled,
        onChanged: (value) {
          HapticFeedback.selectionClick();
          setState(() {
            _panningEnabled = value;
          });
        },
      ),
    );
  }

  /// Builds panning visualization when active.
  Widget _buildPanningVisualization(
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        const SizedBox(height: 16),
        // Panning indicator
        PanningIndicator(
          panPosition: _panPosition,
          isActive: _panningEnabled && _isPlaying,
        ),
        const SizedBox(height: 16),
        // Waveform visualization
        SizedBox(
          height: 120,
          child: Card(
            color: colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: WaveformVisualizer(
                frequency: _beatFrequency * 10, // Visualize beat frequency
                isPlaying: _isPlaying,
                color: _getBrainwaveColor(colorScheme),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

