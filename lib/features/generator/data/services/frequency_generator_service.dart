/// Frequency Generator Service
///
/// Real-time audio synthesis service for generating healing frequencies.
/// Uses SoLoud engine for low-latency waveform generation.
library;

import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logger/logger.dart';
import 'package:soultune/features/generator/data/models/binaural_config.dart';
import 'package:soultune/features/generator/data/models/frequency_layer.dart';
import 'package:soultune/features/generator/data/models/frequency_preset.dart';
import 'package:soultune/features/generator/data/models/waveform.dart';
import 'package:soultune/features/generator/domain/panning_engine.dart';
import 'package:soultune/shared/exceptions/app_exceptions.dart';
import 'package:soultune/shared/services/audio/notification_service.dart';

/// Service for generating and playing frequency tones.
///
/// Supports:
/// - Multi-layer frequency mixing
/// - Different waveform types (sine, square, triangle, sawtooth)
/// - Binaural beats (stereo separation)
/// - L→R→L panning modulation for enhanced brain sync
/// - Real-time volume control
/// - System notification integration
class FrequencyGeneratorService {
  /// Creates a [FrequencyGeneratorService].
  FrequencyGeneratorService() : _logger = Logger() {
    _setupNotificationCallbacks();
  }

  final Logger _logger;

  /// SoLoud audio engine instance.
  SoLoud? _soLoud;

  /// Panning modulation engine.
  final PanningEngine _panningEngine = PanningEngine();

  /// Currently active sound handles.
  final List<SoundHandle> _activeHandles = [];

  /// Currently loaded audio sources.
  final List<AudioSource> _activeSources = [];

  /// Currently playing preset.
  FrequencyPreset? _currentPreset;

  /// Whether the service is initialized.
  bool _isInitialized = false;

  /// Whether audio is currently playing.
  bool _isPlaying = false;

  /// Whether panning is enabled.
  bool _panningEnabled = false;

  /// Current panning configuration.
  PanningConfig? _currentPanningConfig;

  /// Stream controller for playing state.
  final _playingController = StreamController<bool>.broadcast();

  /// Stream controller for current preset.
  final _presetController = StreamController<FrequencyPreset?>.broadcast();

  /// Stream of playing state changes.
  Stream<bool> get playingStream => _playingController.stream;

  /// Stream of current preset changes.
  Stream<FrequencyPreset?> get presetStream => _presetController.stream;

  /// Stream of pan position changes.
  Stream<double> get panPositionStream => _panningEngine.panPositionStream;

  /// Whether audio is currently playing.
  bool get isPlaying => _isPlaying;

  /// Currently playing preset.
  FrequencyPreset? get currentPreset => _currentPreset;

  /// Whether panning is currently active.
  bool get isPanningActive => _panningEngine.isActive;

  /// Current pan position (-1.0 to 1.0).
  double get currentPanPosition => _panningEngine.currentPanPosition;

  /// Sets up notification callbacks for system media controls.
  void _setupNotificationCallbacks() {
    if (!NotificationService.isInitialized) return;

    try {
      final handler = NotificationService.audioHandler;

      // Resume playback from notification
      handler.onPlayFrequency = () async {
        if (_currentPreset != null && !_isPlaying) {
          await playPreset(_currentPreset!);
        }
      };

      // Pause from notification
      handler.onPauseFrequency = () async {
        await stop();
      };

      // Stop from notification
      handler.onStopFrequency = () async {
        await stop();
      };

      _logger.i('Frequency generator notification callbacks registered');
    } catch (e) {
      _logger.w('Failed to setup notification callbacks', error: e);
    }
  }

  /// Initializes the SoLoud audio engine.
  ///
  /// Must be called before playing any frequencies.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _soLoud = SoLoud.instance;
      await _soLoud!.init();
      _isInitialized = true;
      _logger.i('FrequencyGeneratorService initialized');
    } catch (e) {
      _logger.e('Failed to initialize SoLoud', error: e);
      throw AudioException('Failed to initialize frequency generator', e);
    }
  }

  /// Plays a frequency preset.
  ///
  /// Generates and mixes all frequency layers defined in the preset.
  /// If binaural configuration is present, creates stereo separation.
  Future<void> playPreset(FrequencyPreset preset) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Stop any currently playing preset
    await stop();

    try {
      _currentPreset = preset;
      _presetController.add(preset);

      // Generate and play each layer
      if (preset.binauralConfig != null) {
        await _playBinauralBeat(preset);
      } else {
        for (final layer in preset.layers) {
          await _playLayer(layer);
        }
      }

      _isPlaying = true;
      _playingController.add(true);

      // Update notification
      _updateNotification(playing: true);

      _logger.i('Playing preset: ${preset.name}');
    } catch (e) {
      _logger.e('Failed to play preset: ${preset.name}', error: e);
      await stop();
      throw AudioException('Failed to play frequency preset', e);
    }
  }

  /// Plays a frequency preset with optional panning modulation.
  ///
  /// When [enablePanning] is true, applies L→R→L stereo panning
  /// for enhanced brain hemisphere synchronization.
  Future<void> playPresetWithPanning(
    FrequencyPreset preset, {
    bool enablePanning = false,
    PanningConfig panningConfig = const PanningConfig(),
  }) async {
    // First play the preset normally
    await playPreset(preset);

    // Then enable panning if requested
    if (enablePanning) {
      _panningEnabled = true;
      _panningEngine.startPanning(
        config: panningConfig,
        onPanChange: _applyPanning,
      );
      _logger.i(
        'Panning enabled: ${panningConfig.cycleSeconds}s cycle, '
        '${(panningConfig.depth * 100).toInt()}% depth',
      );
    }
  }

  /// Applies panning volumes to all active handles.
  void _applyPanning(double leftVolume, double rightVolume) {
    if (!_isInitialized || _soLoud == null) return;

    // Use fade time to prevent clicking/popping
    // Fade duration = half of update interval for smooth transition
    final fadeDuration = (_currentPanningConfig?.updateIntervalMs ?? 50) / 2000.0;

    // For binaural beats, we adjust the volume of left/right channels
    // For mono layers, we adjust the overall volume based on position
    for (var i = 0; i < _activeHandles.length; i++) {
      final handle = _activeHandles[i];
      final baseVolume = _currentPreset?.volume ?? 0.7;

      // If we have stereo binaural (2 handles = left/right)
      if (_activeHandles.length == 2) {
        if (i == 0) {
          // Left channel - fade to prevent clicks
          _soLoud!.fadeVolume(handle, baseVolume * leftVolume, fadeDuration);
        } else {
          // Right channel - fade to prevent clicks
          _soLoud!.fadeVolume(handle, baseVolume * rightVolume, fadeDuration);
        }
      } else {
        // Mono layers - apply average modulation with fade
        final avgVolume = (leftVolume + rightVolume) / 2;
        _soLoud!.fadeVolume(handle, baseVolume * avgVolume, fadeDuration);
      }
    }
  }

  /// Enables or disables panning on currently playing preset.
  void setPanningEnabled(bool enabled, {PanningConfig? config}) {
    if (!_isPlaying) return;

    if (enabled && !_panningEnabled) {
      _panningEnabled = true;
      _currentPanningConfig = config ?? PanningConfig.research;
      _panningEngine.startPanning(
        config: _currentPanningConfig!,
        onPanChange: _applyPanning,
      );
      _logger.i('Panning enabled');
    } else if (!enabled && _panningEnabled) {
      _panningEnabled = false;
      _currentPanningConfig = null;
      _panningEngine.stopPanning();
      // Reset volumes to base smoothly
      final baseVolume = _currentPreset?.volume ?? 0.7;
      for (final handle in _activeHandles) {
        _soLoud!.fadeVolume(handle, baseVolume, 0.1);
      }
      _logger.i('Panning disabled');
    }
  }

  /// Plays a single frequency layer.
  Future<void> _playLayer(FrequencyLayer layer) async {
    final waveData = _generateWaveform(
      frequency: layer.frequency,
      waveform: layer.waveform,
      durationSeconds: 10, // Loop duration
      sampleRate: 44100,
    );

    final source = await _soLoud!.loadMem(
      'layer_${layer.frequency}',
      waveData,
    );

    _activeSources.add(source);

    final handle = await _soLoud!.play(
      source,
      volume: layer.volume * (_currentPreset?.volume ?? 0.7),
      looping: true,
    );

    _activeHandles.add(handle);
  }

  /// Plays binaural beat configuration.
  ///
  /// Creates two tones with slightly different frequencies for left and right
  /// channels to produce the binaural beat effect.
  Future<void> _playBinauralBeat(FrequencyPreset preset) async {
    final config = preset.binauralConfig!;

    // Generate left channel
    final leftWaveData = _generateWaveform(
      frequency: config.leftFrequency,
      waveform: Waveform.sine,
      durationSeconds: 10,
      sampleRate: 44100,
    );

    // Generate right channel
    final rightWaveData = _generateWaveform(
      frequency: config.rightFrequency,
      waveform: Waveform.sine,
      durationSeconds: 10,
      sampleRate: 44100,
    );

    // Load and play left channel (panned left)
    final leftSource = await _soLoud!.loadMem(
      'binaural_left',
      leftWaveData,
    );
    _activeSources.add(leftSource);

    final leftHandle = await _soLoud!.play(
      leftSource,
      volume: preset.volume,
      looping: true,
      pan: -1.0, // Full left
    );
    _activeHandles.add(leftHandle);

    // Load and play right channel (panned right)
    final rightSource = await _soLoud!.loadMem(
      'binaural_right',
      rightWaveData,
    );
    _activeSources.add(rightSource);

    final rightHandle = await _soLoud!.play(
      rightSource,
      volume: preset.volume,
      looping: true,
      pan: 1.0, // Full right
    );
    _activeHandles.add(rightHandle);

    _logger.i(
      'Playing binaural beat: ${config.leftFrequency}Hz / '
      '${config.rightFrequency}Hz = ${config.beatFrequency}Hz beat',
    );
  }

  /// Generates raw PCM waveform data.
  ///
  /// Creates a WAV file in memory with the specified waveform.
  Uint8List _generateWaveform({
    required double frequency,
    required Waveform waveform,
    required int durationSeconds,
    required int sampleRate,
  }) {
    final numSamples = sampleRate * durationSeconds;
    final samples = Float32List(numSamples);

    // Generate waveform samples
    for (var i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final phase = 2 * math.pi * frequency * t;

      samples[i] = switch (waveform) {
        Waveform.sine => math.sin(phase),
        Waveform.square => math.sin(phase) >= 0 ? 1.0 : -1.0,
        Waveform.triangle => 2 * (phase / (2 * math.pi) % 1) - 1,
        Waveform.sawtooth =>
          2 * ((frequency * t) % 1) - 1,
      };

      // Apply slight amplitude to avoid clipping
      samples[i] *= 0.8;
    }

    // Convert to WAV format
    return _createWavFile(samples, sampleRate);
  }

  /// Creates a WAV file from raw samples.
  Uint8List _createWavFile(Float32List samples, int sampleRate) {
    final numChannels = 1;
    final bitsPerSample = 16;
    final byteRate = sampleRate * numChannels * bitsPerSample ~/ 8;
    final blockAlign = numChannels * bitsPerSample ~/ 8;
    final dataSize = samples.length * bitsPerSample ~/ 8;
    final fileSize = 36 + dataSize;

    final buffer = ByteData(44 + dataSize);
    var offset = 0;

    // RIFF header
    buffer.setUint8(offset++, 0x52); // R
    buffer.setUint8(offset++, 0x49); // I
    buffer.setUint8(offset++, 0x46); // F
    buffer.setUint8(offset++, 0x46); // F
    buffer.setUint32(offset, fileSize, Endian.little);
    offset += 4;
    buffer.setUint8(offset++, 0x57); // W
    buffer.setUint8(offset++, 0x41); // A
    buffer.setUint8(offset++, 0x56); // V
    buffer.setUint8(offset++, 0x45); // E

    // fmt subchunk
    buffer.setUint8(offset++, 0x66); // f
    buffer.setUint8(offset++, 0x6D); // m
    buffer.setUint8(offset++, 0x74); // t
    buffer.setUint8(offset++, 0x20); // space
    buffer.setUint32(offset, 16, Endian.little); // Subchunk1Size
    offset += 4;
    buffer.setUint16(offset, 1, Endian.little); // AudioFormat (PCM)
    offset += 2;
    buffer.setUint16(offset, numChannels, Endian.little);
    offset += 2;
    buffer.setUint32(offset, sampleRate, Endian.little);
    offset += 4;
    buffer.setUint32(offset, byteRate, Endian.little);
    offset += 4;
    buffer.setUint16(offset, blockAlign, Endian.little);
    offset += 2;
    buffer.setUint16(offset, bitsPerSample, Endian.little);
    offset += 2;

    // data subchunk
    buffer.setUint8(offset++, 0x64); // d
    buffer.setUint8(offset++, 0x61); // a
    buffer.setUint8(offset++, 0x74); // t
    buffer.setUint8(offset++, 0x61); // a
    buffer.setUint32(offset, dataSize, Endian.little);
    offset += 4;

    // Write samples as 16-bit PCM
    for (final sample in samples) {
      final intSample = (sample * 32767).clamp(-32768, 32767).toInt();
      buffer.setInt16(offset, intSample, Endian.little);
      offset += 2;
    }

    return buffer.buffer.asUint8List();
  }

  /// Stops all currently playing frequencies.
  Future<void> stop() async {
    if (!_isInitialized || !_isPlaying) return;

    try {
      // Stop panning first
      if (_panningEnabled) {
        _panningEngine.stopPanning();
        _panningEnabled = false;
      }

      // Stop all handles
      for (final handle in _activeHandles) {
        _soLoud!.stop(handle);
      }
      _activeHandles.clear();

      // Dispose all sources
      for (final source in _activeSources) {
        _soLoud!.disposeSource(source);
      }
      _activeSources.clear();

      _isPlaying = false;
      // Keep _currentPreset so the Now Playing bar stays visible (paused state)

      _playingController.add(false);
      // Don't emit null to preset stream - keep current preset

      // Update notification to paused state
      _updateNotification(playing: false);

      _logger.i('Paused frequency generation');
    } catch (e) {
      _logger.e('Error stopping frequency generation', error: e);
    }
  }

  /// Updates the system notification with current playback state.
  void _updateNotification({required bool playing}) {
    if (!NotificationService.isInitialized) return;

    try {
      final handler = NotificationService.audioHandler;

      if (_currentPreset != null) {
        handler.updateFrequencyPlaybackState(
          playing: playing,
          preset: _currentPreset,
        );
      }
    } catch (e) {
      _logger.w('Failed to update notification', error: e);
    }
  }

  /// Sets the master volume for all playing frequencies.
  void setVolume(double volume) {
    if (!_isInitialized) return;

    final clampedVolume = volume.clamp(0.0, 1.0);
    for (final handle in _activeHandles) {
      _soLoud!.setVolume(handle, clampedVolume);
    }
  }

  /// Disposes the service and releases resources.
  Future<void> dispose() async {
    await stop();

    // Dispose panning engine
    _panningEngine.dispose();

    if (_isInitialized && _soLoud != null) {
      _soLoud!.deinit();
      _isInitialized = false;
    }

    await _playingController.close();
    await _presetController.close();

    _logger.i('FrequencyGeneratorService disposed');
  }
}

