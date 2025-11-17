/// Frequency layer for multi-layer mixing.
///
/// Represents a single frequency tone with its waveform and volume settings.
/// Multiple layers can be combined for complex healing frequencies.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soultune/features/generator/data/models/waveform.dart';

part 'frequency_layer.freezed.dart';
part 'frequency_layer.g.dart';

/// A single frequency layer with configurable parameters.
///
/// Used in multi-layer frequency generation where multiple tones
/// are mixed together to create complex healing soundscapes.
@freezed
class FrequencyLayer with _$FrequencyLayer {
  /// Creates a [FrequencyLayer].
  const factory FrequencyLayer({
    /// Frequency in Hertz (20Hz - 20,000Hz).
    required double frequency,

    /// Waveform type for this layer.
    required Waveform waveform,

    /// Volume level (0.0 to 1.0).
    @Default(0.7) double volume,

    /// Optional label for this layer.
    String? label,
  }) = _FrequencyLayer;

  /// Creates a [FrequencyLayer] from JSON.
  factory FrequencyLayer.fromJson(Map<String, dynamic> json) =>
      _$FrequencyLayerFromJson(json);
}
