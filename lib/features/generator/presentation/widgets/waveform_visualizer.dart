/// Waveform Visualizer Widget
///
/// Real-time animated waveform visualization using CustomPainter.
/// Displays sine, square, triangle, or sawtooth waves.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:soultune/features/generator/data/models/waveform.dart';

/// Real-time animated waveform visualization.
///
/// Uses CustomPainter for smooth 60 FPS rendering of
/// various waveform types.
class WaveformVisualizer extends StatefulWidget {
  /// Creates a [WaveformVisualizer].
  const WaveformVisualizer({
    required this.frequency,
    this.waveformType = Waveform.sine,
    this.isPlaying = true,
    this.color,
    this.strokeWidth = 2.0,
    this.amplitude = 0.6,
    super.key,
  });

  /// Frequency in Hz (affects wave density).
  final double frequency;

  /// Type of waveform to display.
  final Waveform waveformType;

  /// Whether animation is active.
  final bool isPlaying;

  /// Color of the waveform line.
  final Color? color;

  /// Width of the waveform stroke.
  final double strokeWidth;

  /// Amplitude of the wave (0.0 to 1.0).
  final double amplitude;

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(WaveformVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final waveColor = widget.color ?? _getFrequencyColor(colorScheme);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _WaveformPainter(
            frequency: widget.frequency,
            waveformType: widget.waveformType,
            phase: _controller.value * 2 * math.pi,
            color: waveColor,
            strokeWidth: widget.strokeWidth,
            amplitude: widget.amplitude,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  /// Gets color based on frequency range.
  Color _getFrequencyColor(ColorScheme colorScheme) {
    // Low frequencies: warm colors
    // High frequencies: cool colors
    if (widget.frequency < 200) {
      return Colors.red.shade400;
    } else if (widget.frequency < 500) {
      return Colors.orange.shade400;
    } else if (widget.frequency < 1000) {
      return Colors.yellow.shade600;
    } else if (widget.frequency < 2000) {
      return Colors.green.shade400;
    } else if (widget.frequency < 5000) {
      return Colors.cyan.shade400;
    } else if (widget.frequency < 10000) {
      return Colors.blue.shade400;
    } else {
      return Colors.purple.shade400;
    }
  }
}

/// CustomPainter for drawing waveforms.
class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.frequency,
    required this.waveformType,
    required this.phase,
    required this.color,
    required this.strokeWidth,
    required this.amplitude,
  });

  final double frequency;
  final Waveform waveformType;
  final double phase;
  final Color color;
  final double strokeWidth;
  final double amplitude;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = strokeWidth + 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = _createWaveformPath(size);

    // Draw glow first
    canvas.drawPath(path, glowPaint);
    // Then main line
    canvas.drawPath(path, paint);
  }

  Path _createWaveformPath(Size size) {
    final path = Path();
    final numPoints = 300;

    // Normalize frequency to visible wavelengths
    // Higher frequencies show more cycles
    final cyclesVisible = (frequency / 100.0).clamp(1.0, 20.0);
    final wavelength = size.width / cyclesVisible;

    for (var i = 0; i < numPoints; i++) {
      final x = (i / numPoints) * size.width;
      final t = (x / wavelength) * 2 * math.pi + phase;

      double y;
      switch (waveformType) {
        case Waveform.sine:
          y = math.sin(t);

        case Waveform.square:
          y = math.sin(t) > 0 ? 1.0 : -1.0;

        case Waveform.triangle:
          // Triangle wave formula
          final normalized = (t / (2 * math.pi)) % 1;
          if (normalized < 0.5) {
            y = 4 * normalized - 1;
          } else {
            y = 3 - 4 * normalized;
          }

        case Waveform.sawtooth:
          // Sawtooth wave formula
          final normalized = (t / (2 * math.pi)) % 1;
          y = 2 * normalized - 1;
      }

      final yPos = size.height / 2 - (y * size.height * amplitude / 2);

      if (i == 0) {
        path.moveTo(x, yPos);
      } else {
        path.lineTo(x, yPos);
      }
    }

    return path;
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) {
    return phase != oldDelegate.phase ||
        frequency != oldDelegate.frequency ||
        waveformType != oldDelegate.waveformType ||
        color != oldDelegate.color;
  }
}

/// Multi-layer waveform visualization for complex presets.
class MultiLayerWaveformVisualizer extends StatelessWidget {
  /// Creates a [MultiLayerWaveformVisualizer].
  const MultiLayerWaveformVisualizer({
    required this.frequencies,
    required this.waveforms,
    this.isPlaying = true,
    super.key,
  });

  /// List of frequencies to visualize.
  final List<double> frequencies;

  /// List of waveform types (must match frequencies length).
  final List<Waveform> waveforms;

  /// Whether animation is active.
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    if (frequencies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        for (var i = 0; i < frequencies.length; i++)
          Positioned.fill(
            child: WaveformVisualizer(
              frequency: frequencies[i],
              waveformType:
                  i < waveforms.length ? waveforms[i] : Waveform.sine,
              isPlaying: isPlaying,
              amplitude: 0.5 - (i * 0.1), // Decreasing amplitude for layers
              strokeWidth: 2.0 - (i * 0.3), // Thinner for layers
            ),
          ),
      ],
    );
  }
}

/// Compact waveform indicator for mini players.
class CompactWaveformIndicator extends StatelessWidget {
  /// Creates a [CompactWaveformIndicator].
  const CompactWaveformIndicator({
    required this.isPlaying,
    this.color,
    super.key,
  });

  /// Whether playback is active.
  final bool isPlaying;

  /// Color of the indicator.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final indicatorColor = color ?? colorScheme.primary;

    if (!isPlaying) {
      return Icon(
        Icons.waves,
        color: colorScheme.onSurfaceVariant,
        size: 24,
      );
    }

    return SizedBox(
      width: 40,
      height: 24,
      child: WaveformVisualizer(
        frequency: 200,
        waveformType: Waveform.sine,
        isPlaying: true,
        color: indicatorColor,
        strokeWidth: 1.5,
        amplitude: 0.8,
      ),
    );
  }
}
