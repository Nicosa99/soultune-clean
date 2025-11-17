/// Frequency Generator Providers
///
/// Riverpod providers for managing frequency generator state.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soultune/features/generator/data/models/frequency_preset.dart';
import 'package:soultune/features/generator/data/services/frequency_generator_service.dart';

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
@riverpod
Future<void> Function(FrequencyPreset) playFrequencyPreset(
  PlayFrequencyPresetRef ref,
) {
  return (FrequencyPreset preset) async {
    final service = ref.read(frequencyGeneratorServiceProvider);
    await service.playPreset(preset);
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

/// Action to set generator volume.
@riverpod
void Function(double) setGeneratorVolume(SetGeneratorVolumeRef ref) {
  return (double volume) {
    final service = ref.read(frequencyGeneratorServiceProvider);
    service.setVolume(volume);
  };
}
