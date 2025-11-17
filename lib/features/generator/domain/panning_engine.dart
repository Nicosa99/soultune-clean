/// Panning Modulation Engine
///
/// Implements smooth L→R→L stereo panning for enhanced
/// brain hemisphere synchronization based on 2024 PLOS research.
library;

import 'dart:async';
import 'dart:math' as math;

/// Configuration for panning modulation.
class PanningConfig {
  /// Creates a [PanningConfig].
  const PanningConfig({
    this.cycleSeconds = 15.0,
    this.depth = 0.35,
    this.updateIntervalMs = 50,
  });

  /// Duration of one full L→R→L cycle (10-20 sec optimal).
  final double cycleSeconds;

  /// Panning depth 0.0-1.0 (0.35 = 35% modulation optimal).
  final double depth;

  /// Update interval in milliseconds (50ms = 20Hz update rate).
  final int updateIntervalMs;

  /// Default configuration based on research.
  static const research = PanningConfig(
    cycleSeconds: 15.0, // Optimal per 2024 PLOS study
    depth: 0.35, // Sweet spot for brain sync
    updateIntervalMs: 50, // 20Hz smooth update
  );

  /// Slow panning for deep meditation.
  static const slow = PanningConfig(
    cycleSeconds: 20.0,
    depth: 0.25,
    updateIntervalMs: 50,
  );

  /// Fast panning for alertness.
  static const fast = PanningConfig(
    cycleSeconds: 10.0,
    depth: 0.4,
    updateIntervalMs: 50,
  );
}

/// Callback for pan position changes.
typedef PanChangeCallback = void Function(double leftVolume, double rightVolume);

/// Engine for L→R→L stereo panning modulation.
///
/// Creates smooth sine-wave panning that prevents habituation
/// and enhances brain hemisphere synchronization.
class PanningEngine {
  /// Timer for periodic pan updates.
  Timer? _panningTimer;

  /// Current pan position (-1.0 = full left, 1.0 = full right).
  double _currentPanPosition = 0.0;

  /// Whether panning is currently active.
  bool _isActive = false;

  /// Stream controller for pan position updates.
  final _panPositionController = StreamController<double>.broadcast();

  /// Current configuration.
  PanningConfig _config = PanningConfig.research;

  /// Stream of pan position changes.
  Stream<double> get panPositionStream => _panPositionController.stream;

  /// Current pan position (-1.0 to 1.0).
  double get currentPanPosition => _currentPanPosition;

  /// Whether panning is active.
  bool get isActive => _isActive;

  /// Current configuration.
  PanningConfig get config => _config;

  /// Starts panning modulation.
  ///
  /// [config]: Panning configuration (cycle time, depth, update rate).
  /// [onPanChange]: Callback with left and right volume multipliers.
  void startPanning({
    PanningConfig config = const PanningConfig(),
    required PanChangeCallback onPanChange,
  }) {
    if (_isActive) {
      stopPanning();
    }

    _config = config;
    _isActive = true;

    final steps = (config.cycleSeconds * 1000) / config.updateIntervalMs;
    final stepSize = (2 * math.pi) / steps;
    var tickCount = 0;

    _panningTimer = Timer.periodic(
      Duration(milliseconds: config.updateIntervalMs),
      (timer) {
        tickCount++;

        // Sine-wave panning: smooth L→R→L
        _currentPanPosition = math.sin(tickCount * stepSize);

        // Broadcast position for UI updates
        _panPositionController.add(_currentPanPosition);

        // Calculate stereo volumes (centered at 1.0)
        // When pan is -1.0 (left): leftVol = 1.35, rightVol = 0.65
        // When pan is 0.0 (center): leftVol = 1.0, rightVol = 1.0
        // When pan is 1.0 (right): leftVol = 0.65, rightVol = 1.35
        final leftVolume = 1.0 - (config.depth * _currentPanPosition);
        final rightVolume = 1.0 + (config.depth * _currentPanPosition);

        onPanChange(leftVolume, rightVolume);
      },
    );
  }

  /// Stops panning and resets to center.
  void stopPanning() {
    _panningTimer?.cancel();
    _panningTimer = null;
    _isActive = false;
    _currentPanPosition = 0.0;
    _panPositionController.add(0.0);
  }

  /// Updates panning configuration while running.
  void updateConfig(PanningConfig newConfig, PanChangeCallback onPanChange) {
    if (_isActive) {
      stopPanning();
      startPanning(config: newConfig, onPanChange: onPanChange);
    } else {
      _config = newConfig;
    }
  }

  /// Disposes the engine and releases resources.
  void dispose() {
    stopPanning();
    _panPositionController.close();
  }
}
