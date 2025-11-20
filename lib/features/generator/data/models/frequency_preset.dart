/// Frequency preset model.
///
/// Represents a complete frequency generation configuration including
/// layers, binaural beats, duration, and metadata.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soultune/features/generator/data/models/binaural_config.dart';
import 'package:soultune/features/generator/data/models/frequency_layer.dart';
import 'package:soultune/features/generator/data/models/preset_category.dart';
import 'package:soultune/features/generator/data/models/waveform.dart';
import 'package:soultune/shared/models/json_converters.dart';

part 'frequency_preset.freezed.dart';
part 'frequency_preset.g.dart';

/// A complete frequency generation preset.
///
/// Contains all parameters needed to generate healing frequencies,
/// including primary/secondary frequencies, binaural configuration,
/// session duration, and metadata.
@freezed
class FrequencyPreset with _$FrequencyPreset {
  /// Creates a [FrequencyPreset].
  const factory FrequencyPreset({
    /// Unique identifier (UUID v4).
    required String id,

    /// Display name for the preset.
    required String name,

    /// Category for grouping (sleep, focus, healing, etc.).
    required PresetCategory category,

    /// Detailed description of the preset's purpose.
    required String description,

    /// Frequency layers (primary + secondary frequencies).
    required List<FrequencyLayer> layers,

    /// Optional binaural beat configuration.
    BinauralConfig? binauralConfig,

    /// Session duration in minutes.
    @Default(15) int durationMinutes,

    /// Master volume (0.0 to 1.0).
    @Default(0.7) double volume,

    /// Tags for search and filtering.
    @Default([]) List<String> tags,

    /// Whether this preset is marked as favorite.
    @Default(false) bool isFavorite,

    /// Whether this is a user-created preset.
    @Default(false) bool isCustom,

    /// Whether this preset requires premium subscription.
    ///
    /// Free tier includes only 1 preset (Deep Sleep).
    /// All other presets require premium subscription ($29.99/year).
    @Default(true) bool isPremium,

    /// Whether L→R→L panning modulation is enabled.
    @Default(false) bool panningEnabled,

    /// Optional panning cycle time in seconds (null = auto-detect).
    ///
    /// If null, cycle time is automatically determined from binaural
    /// beat frequency. Values: 0.1s - 10s recommended.
    double? panningCycleSeconds,

    /// Creation timestamp.
    @DateTimeConverter() required DateTime createdAt,

    /// Last modification timestamp.
    @DateTimeConverter() DateTime? modifiedAt,
  }) = _FrequencyPreset;

  /// Private constructor for adding custom getters.
  const FrequencyPreset._();

  /// Creates a [FrequencyPreset] from JSON.
  factory FrequencyPreset.fromJson(Map<String, dynamic> json) =>
      _$FrequencyPresetFromJson(json);

  /// Primary frequency (first layer).
  double? get primaryFrequency =>
      layers.isNotEmpty ? layers.first.frequency : null;

  /// Primary waveform (first layer).
  Waveform? get primaryWaveform =>
      layers.isNotEmpty ? layers.first.waveform : null;

  /// Formatted duration string (e.g., "15 min" or "1h 30min").
  String get formattedDuration {
    if (durationMinutes < 60) {
      return '$durationMinutes min';
    } else {
      final hours = durationMinutes ~/ 60;
      final mins = durationMinutes % 60;
      if (mins == 0) {
        return '${hours}h';
      }
      return '${hours}h ${mins}min';
    }
  }

  /// Short summary of frequencies for display.
  String get frequencySummary {
    final parts = <String>[];

    // Add layer frequencies
    if (layers.isNotEmpty) {
      final layerFreqs =
          layers.map((l) => '${l.frequency.toStringAsFixed(0)}Hz');
      parts.addAll(layerFreqs);
    }

    // Add binaural beat frequency if present
    if (binauralConfig != null) {
      final beatFreq = binauralConfig!.beatFrequency.toStringAsFixed(1);
      parts.add('${beatFreq}Hz Binaural');
    }

    // Return combined or fallback
    if (parts.isEmpty) return 'No frequencies';
    return parts.join(' + ');
  }
}
