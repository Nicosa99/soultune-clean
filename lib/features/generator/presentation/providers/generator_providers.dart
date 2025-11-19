/// Frequency Generator Providers
///
/// Riverpod providers for managing frequency generator state.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soultune/features/generator/data/models/frequency_preset.dart';
import 'package:soultune/features/generator/data/services/frequency_generator_service.dart';
import 'package:soultune/features/generator/domain/panning_engine.dart';

part 'generator_providers.g.dart';

/// Provides singleton instance of FrequencyGeneratorService.
@Riverpod(keepAlive: true)
FrequencyGeneratorService frequencyGeneratorService(
  FrequencyGeneratorServiceRef ref,
) {
  final service = FrequencyGeneratorService();

  ref.onDispose(() async {
    await service.dispose();
  });

  return service;
}

/// Stream of whether generator is currently playing.
@riverpod
Stream<bool> generatorIsPlaying(GeneratorIsPlayingRef ref) async* {
  final service = ref.watch(frequencyGeneratorServiceProvider);
  yield service.isPlaying;
  yield* service.playingStream;
}

/// Stream of currently playing preset.
@riverpod
Stream<FrequencyPreset?> currentGeneratorPreset(
  CurrentGeneratorPresetRef ref,
) async* {
  final service = ref.watch(frequencyGeneratorServiceProvider);
  yield service.currentPreset;
  yield* service.presetStream;
}

/// Action to play a frequency preset.
///
/// Automatically enables panning if the preset has it configured.
@riverpod
Future<void> Function(FrequencyPreset) playFrequencyPreset(
  PlayFrequencyPresetRef ref,
) {
  return (FrequencyPreset preset) async {
    final service = ref.read(frequencyGeneratorServiceProvider);

    // Check if preset has panning enabled
    if (preset.panningEnabled) {
      // Use preset's custom cycle time or auto-detect from binaural config
      PanningConfig panningConfig;
      if (preset.panningCycleSeconds != null) {
        panningConfig = PanningConfig(
          cycleSeconds: preset.panningCycleSeconds!,
          depth: 0.35, // Default depth
          updateIntervalMs: preset.panningCycleSeconds! <= 0.5 ? 10 : 25,
        );
      } else if (preset.binauralConfig != null) {
        // Auto-detect from binaural beat frequency
        panningConfig = PanningConfig.forBeatFrequency(
          preset.binauralConfig!.beatFrequency,
        );
      } else {
        panningConfig = PanningConfig.research;
      }

      await service.playPresetWithPanning(
        preset,
        enablePanning: true,
        panningConfig: panningConfig,
      );
    } else {
      await service.playPreset(preset);
    }
  };
}

/// Action to stop frequency generation.
@riverpod
Future<void> Function() stopFrequencyGeneration(
  StopFrequencyGenerationRef ref,
) {
  return () async {
    final service = ref.read(frequencyGeneratorServiceProvider);
    await service.stop();
  };
}

/// Provides current generator volume (0.0 - 1.0).
@riverpod
double currentGeneratorVolume(CurrentGeneratorVolumeRef ref) {
  final service = ref.watch(frequencyGeneratorServiceProvider);
  return service.currentVolume;
}

/// Action to set generator volume.
@riverpod
void Function(double) setGeneratorVolume(SetGeneratorVolumeRef ref) {
  return (double volume) {
    final service = ref.read(frequencyGeneratorServiceProvider);
    service.setVolume(volume);
    // Invalidate to trigger rebuild
    ref.invalidate(currentGeneratorVolumeProvider);
  };
}

/// Stream of current pan position (-1.0 to 1.0).
@riverpod
Stream<double> panPosition(PanPositionRef ref) async* {
  final service = ref.watch(frequencyGeneratorServiceProvider);
  yield service.currentPanPosition;
  yield* service.panPositionStream;
}

/// Whether panning is currently active.
@riverpod
bool isPanningActive(IsPanningActiveRef ref) {
  final service = ref.watch(frequencyGeneratorServiceProvider);
  return service.isPanningActive;
}

/// Action to play preset with panning.
@riverpod
Future<void> Function(FrequencyPreset, {bool enablePanning, PanningConfig? config})
    playPresetWithPanning(PlayPresetWithPanningRef ref) {
  return (
    FrequencyPreset preset, {
    bool enablePanning = false,
    PanningConfig? config,
  }) async {
    final service = ref.read(frequencyGeneratorServiceProvider);
    await service.playPresetWithPanning(
      preset,
      enablePanning: enablePanning,
      panningConfig: config ?? PanningConfig.research,
    );
  };
}

/// Action to toggle panning on/off.
@riverpod
void Function(bool, {PanningConfig? config}) setPanningEnabled(
  SetPanningEnabledRef ref,
) {
  return (bool enabled, {PanningConfig? config}) {
    final service = ref.read(frequencyGeneratorServiceProvider);
    service.setPanningEnabled(enabled, config: config);
  };
}
