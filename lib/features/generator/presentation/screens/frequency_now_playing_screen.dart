/// Fullscreen Now Playing Screen for Frequency Generator.
///
/// Provides an immersive visual experience for brain sync sessions
/// with real-time waveform visualization, panning indicators,
/// layer controls, and session progress tracking.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soultune/features/generator/data/models/frequency_layer.dart';
import 'package:soultune/features/generator/data/models/frequency_preset.dart';
import 'package:soultune/features/generator/data/models/waveform.dart';
import 'package:soultune/features/generator/presentation/providers/generator_providers.dart';
import 'package:soultune/features/generator/presentation/widgets/waveform_visualizer.dart';

/// Fullscreen Now Playing Screen for Frequency Generator.
///
/// Features:
/// - 60% screen: Real-time waveform visualization
/// - Panning indicator (L→R→L motion)
/// - Active layer display with volume controls
/// - Session timer with progress
/// - Big playback controls (90px play button)
/// - Frequency-based color theming
/// - Immersive black background with pulsing effects
class FrequencyNowPlayingScreen extends ConsumerStatefulWidget {
  /// Creates a [FrequencyNowPlayingScreen].
  const FrequencyNowPlayingScreen({super.key});

  @override
  ConsumerState<FrequencyNowPlayingScreen> createState() =>
      _FrequencyNowPlayingScreenState();
}

class _FrequencyNowPlayingScreenState
    extends ConsumerState<FrequencyNowPlayingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  double _masterVolume = 0.7;
  int _elapsedSeconds = 0;
  Timer? _sessionTimer;

  @override
  void initState() {
    super.initState();

    // Initialize pulse animation for background
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Start session timer
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sessionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final presetAsync = ref.watch(currentGeneratorPresetProvider);
    final isPlayingAsync = ref.watch(generatorIsPlayingProvider);
    final panPosition = ref.watch(panPositionProvider).value ?? 0.0;
    final isPanningActive = ref.watch(isPanningActiveProvider);

    return presetAsync.when(
      data: (preset) {
        if (preset == null) {
          // Redirect back if no preset playing
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.pop(context);
            }
          });
          return const SizedBox.shrink();
        }

        final isPlaying = isPlayingAsync.value ?? false;
        final displayFrequency = _getDisplayFrequency(preset);
        final frequencyColor = _getColorForFrequency(displayFrequency);
        final brainwaveCategory = _getBrainwaveCategory(displayFrequency);

        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
              children: [
                // Top Bar (minimalist - back button only)
                _buildTopBar(context, frequencyColor),

                // MAIN: Waveform Visualization (60% height)
                _buildWaveformSection(
                  displayFrequency,
                  brainwaveCategory,
                  frequencyColor,
                  isPlaying,
                ),

                // Preset Description (scrollable)
                if (preset.description.isNotEmpty)
                  _buildDescription(preset, frequencyColor),

                // Panning Indicator (when active)
                if (isPanningActive)
                  _buildPanningIndicator(panPosition, frequencyColor),

                // Session Progress
                _buildSessionProgress(preset, frequencyColor),

                // Playback Controls (BIG)
                _buildPlaybackControls(isPlaying, frequencyColor),

                // Volume Controls
                _buildVolumeControls(),

                const SizedBox(height: 40),
              ],
            ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  /// Builds minimalist top bar with back button.
  Widget _buildTopBar(BuildContext context, Color frequencyColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: frequencyColor,
              size: 32,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          // Optional: Add menu button for settings
          IconButton(
            icon: Icon(
              Icons.more_vert_rounded,
              color: Colors.white.withOpacity(0.6),
              size: 24,
            ),
            onPressed: () {
              // TODO: Show options menu
            },
          ),
        ],
      ),
    );
  }

  /// Gets the display frequency (binaural beat if available, otherwise primary).
  double _getDisplayFrequency(FrequencyPreset preset) {
    if (preset.binauralConfig != null) {
      // Show binaural beat frequency (difference between L and R)
      return (preset.binauralConfig!.rightFrequency -
              preset.binauralConfig!.leftFrequency)
          .abs();
    }
    return preset.primaryFrequency ?? 432.0;
  }

  /// Builds waveform visualization section (60% of screen).
  Widget _buildWaveformSection(
    double displayFrequency,
    String brainwaveCategory,
    Color frequencyColor,
    bool isPlaying,
  ) {

    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.6, // 60% of screen!
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            frequencyColor.withOpacity(0.4),
            Colors.black,
          ],
          center: Alignment.center,
          radius: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Background: Pulsing Circles (Hypnotic)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return CustomPaint(
                  painter: PulsingCirclePainter(
                    progress: _pulseController.value,
                    color: frequencyColor,
                    frequency: displayFrequency,
                  ),
                );
              },
            ),
          ),

          // Main: Real-time Waveform (full size!)
          Positioned.fill(
            child: WaveformVisualizer(
              frequency: displayFrequency,
              waveformType: Waveform.sine,
              isPlaying: isPlaying,
              color: frequencyColor,
            ),
          ),

          // Overlay: Frequency Display (Center)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display Frequency (HUGE - binaural beat!)
                Text(
                  '${displayFrequency.toStringAsFixed(1)} Hz',
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.w100,
                    color: Colors.white,
                    letterSpacing: 4,
                    shadows: [
                      Shadow(
                        color: frequencyColor,
                        blurRadius: 30,
                      ),
                      const Shadow(
                        color: Colors.black,
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Brainwave Category
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: frequencyColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: frequencyColor, width: 2),
                  ),
                  child: Text(
                    brainwaveCategory.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: frequencyColor,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds preset description section (scrollable).
  Widget _buildDescription(FrequencyPreset preset, Color frequencyColor) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 100),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: SingleChildScrollView(
        child: Text(
          preset.description,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.7),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Builds panning indicator showing L→R→L motion.
  ///
  /// Smooth, meditative visualization without harsh colors.
  Widget _buildPanningIndicator(double panPosition, Color frequencyColor) {
    // Normalize pan position to 0-1 for horizontal position
    final normalizedPosition = (panPosition + 1) / 2; // -1..1 → 0..1

    return Container(
      height: 71,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      color: Colors.black,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            'SPATIAL AUDIO',
            style: TextStyle(
              fontSize: 9,
              color: frequencyColor.withOpacity(0.6),
              letterSpacing: 2.5,
              fontWeight: FontWeight.w300,
            ),
          ),

          const SizedBox(height: 8),

          // Panning Track (Smooth flowing visualization)
          SizedBox(
            height: 36,
            child: Stack(
              children: [
                // Background track
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),

                // L & R labels (subtle)
                Positioned(
                  left: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Text(
                      'L',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.3),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Text(
                      'R',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.3),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),

                // Flowing gradient indicator
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 50),
                  left: normalizedPosition * (MediaQuery.of(context).size.width - 64 - 80),
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          frequencyColor.withOpacity(0.0),
                          frequencyColor.withOpacity(0.6),
                          frequencyColor.withOpacity(0.0),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: frequencyColor.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ),

                // Center dot (always visible, glows with movement)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 50),
                  left: normalizedPosition * (MediaQuery.of(context).size.width - 64) - 6,
                  top: 12,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: frequencyColor,
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds session progress with timer and progress bar.
  Widget _buildSessionProgress(
    FrequencyPreset preset,
    Color frequencyColor,
  ) {
    final totalSeconds = preset.durationMinutes * 60;
    final remainingSeconds = (totalSeconds - _elapsedSeconds).clamp(0, totalSeconds);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          // Progress Bar (thick with glow)
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: frequencyColor.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _elapsedSeconds / totalSeconds,
                backgroundColor: Colors.white10,
                color: frequencyColor,
                minHeight: 8,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Time Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(Duration(seconds: _elapsedSeconds)),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),

              // Remaining Time (Highlighted)
              Text(
                '${_formatDuration(Duration(seconds: remainingSeconds))} left',
                style: TextStyle(
                  color: frequencyColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),

              Text(
                _formatDuration(Duration(seconds: totalSeconds)),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds big playback controls.
  Widget _buildPlaybackControls(bool isPlaying, Color frequencyColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        // Play/Pause (BIG CENTERED)
        child: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            if (isPlaying) {
              ref.read(stopFrequencyGenerationProvider)();
            } else {
              // TODO: Resume playback
              // For now, this would restart the preset
            }
          },
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  frequencyColor,
                  frequencyColor.withOpacity(0.6),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: frequencyColor.withOpacity(0.6),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 50,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// Builds volume controls.
  Widget _buildVolumeControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const Icon(
            Icons.volume_down_rounded,
            color: Colors.white60,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 8,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 16,
                ),
              ),
              child: Slider(
                value: _masterVolume,
                min: 0,
                max: 1,
                activeColor: Colors.white,
                inactiveColor: Colors.white30,
                onChanged: (value) {
                  setState(() {
                    _masterVolume = value;
                  });
                  ref.read(setGeneratorVolumeProvider)(value);
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.volume_up_rounded,
            color: Colors.white60,
            size: 20,
          ),
        ],
      ),
    );
  }

  /// Maps frequency to color for visual feedback.
  Color _getColorForFrequency(double frequency) {
    if (frequency <= 4) {
      // Delta (0-4 Hz) - Deep Purple/Blue
      return const Color(0xFF1A237E); // Indigo 900
    } else if (frequency <= 8) {
      // Theta (4-8 Hz) - Purple
      return const Color(0xFF6A1B9A); // Purple 800
    } else if (frequency <= 12) {
      // Alpha (8-12 Hz) - Blue
      return const Color(0xFF0D47A1); // Blue 900
    } else if (frequency <= 30) {
      // Beta (12-30 Hz) - Green/Cyan
      return const Color(0xFF00897B); // Teal 600
    } else if (frequency <= 50) {
      // Gamma (30-50 Hz) - Orange
      return const Color(0xFFEF6C00); // Orange 800
    } else {
      // High Gamma (50+ Hz) - Red
      return const Color(0xFFC62828); // Red 800
    }
  }

  /// Gets brainwave category name.
  String _getBrainwaveCategory(double frequency) {
    if (frequency <= 4) return 'Delta Wave';
    if (frequency <= 8) return 'Theta Wave';
    if (frequency <= 12) return 'Alpha Wave';
    if (frequency <= 30) return 'Beta Wave';
    if (frequency <= 50) return 'Gamma Wave';
    return 'High Gamma';
  }

  /// Gets icon for waveform type.
  IconData _getWaveformIcon(Waveform waveform) {
    switch (waveform) {
      case Waveform.sine:
        return Icons.show_chart_rounded;
      case Waveform.square:
        return Icons.square_rounded;
      case Waveform.triangle:
        return Icons.change_history_rounded;
      case Waveform.sawtooth:
        return Icons.trending_up_rounded;
    }
  }

  /// Formats duration to MM:SS format.
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// CustomPainter for pulsing background circles.
///
/// Creates a hypnotic effect with 3 concentric circles
/// pulsing outward at different phases.
class PulsingCirclePainter extends CustomPainter {
  /// Creates a [PulsingCirclePainter].
  const PulsingCirclePainter({
    required this.progress,
    required this.color,
    required this.frequency,
  });

  /// Animation progress (0.0 to 1.0).
  final double progress;

  /// Color for the circles.
  final Color color;

  /// Frequency value (affects pulse speed visually).
  final double frequency;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.6;

    // Draw 3 concentric circles with different phases
    for (int i = 0; i < 3; i++) {
      final phase = (progress + i * 0.33) % 1.0;
      final radius = maxRadius * phase;
      final opacity = 1.0 - phase;

      final paint = Paint()
        ..color = color.withOpacity(opacity * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(PulsingCirclePainter oldDelegate) {
    return progress != oldDelegate.progress ||
        color != oldDelegate.color ||
        frequency != oldDelegate.frequency;
  }
}
