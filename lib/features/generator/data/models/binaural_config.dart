/// Binaural beat configuration.
///
/// Defines the left and right ear frequencies for binaural beat generation.
/// The difference between the two frequencies creates the perceived beat.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'binaural_config.freezed.dart';
part 'binaural_config.g.dart';

/// Configuration for binaural beat generation.
///
/// Binaural beats occur when two slightly different frequencies are
/// presented to each ear separately. The brain perceives a third tone
/// equal to the difference between the two frequencies.
///
/// Example: 200Hz (left) + 207Hz (right) = 7Hz beat (Theta wave)
@freezed
class BinauralConfig with _$BinauralConfig {
  /// Creates a [BinauralConfig].
  const factory BinauralConfig({
    /// Frequency for left ear in Hertz.
    required double leftFrequency,

    /// Frequency for right ear in Hertz.
    required double rightFrequency,
  }) = _BinauralConfig;

  /// Private constructor for adding custom getters.
  const BinauralConfig._();

  /// Creates a [BinauralConfig] from JSON.
  factory BinauralConfig.fromJson(Map<String, dynamic> json) =>
      _$BinauralConfigFromJson(json);

  /// The beat frequency (difference between left and right).
  double get beatFrequency => (rightFrequency - leftFrequency).abs();

  /// Returns the brainwave category for this beat frequency.
  String get brainwaveCategory {
    final beat = beatFrequency;

    if (beat <= 4) {
      return 'Delta';
    } else if (beat <= 8) {
      return 'Theta';
    } else if (beat <= 12) {
      return 'Alpha';
    } else if (beat <= 30) {
      return 'Beta';
    } else {
      return 'Gamma';
    }
  }

  /// Returns a description of the brainwave state.
  String get brainwaveDescription {
    final beat = beatFrequency;

    if (beat <= 4) {
      return 'Deep Sleep & Physical Healing';
    } else if (beat <= 8) {
      return 'Meditation & Deep Relaxation';
    } else if (beat <= 12) {
      return 'Relaxed Awareness & Learning';
    } else if (beat <= 30) {
      return 'Focus & Analysis';
    } else {
      return 'Peak Cognitive Function';
    }
  }
}
