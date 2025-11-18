/// Waveform types for frequency generation.
///
/// Each waveform has distinct harmonic characteristics that affect
/// the sound quality and therapeutic properties.
library;

/// Supported waveform types for frequency synthesis.
enum Waveform {
  /// Pure sine wave - smooth, natural sound.
  ///
  /// Best for meditation and relaxation. Contains only the fundamental
  /// frequency with no harmonics.
  sine('Sine', 'Pure, smooth tone'),

  /// Square wave - rich in odd harmonics.
  ///
  /// Creates a fuller, more intense sound. Good for alertness and focus.
  square('Square', 'Rich, intense tone'),

  /// Triangle wave - softer than square, limited harmonics.
  ///
  /// Balanced sound between sine and square. Gentle yet present.
  triangle('Triangle', 'Soft, balanced tone'),

  /// Sawtooth wave - contains all harmonics.
  ///
  /// Bright, buzzy sound. Most harmonically rich waveform.
  sawtooth('Sawtooth', 'Bright, buzzy tone');

  /// Creates a [Waveform] with display name and description.
  const Waveform(this.displayName, this.description);

  /// Human-readable name for UI display.
  final String displayName;

  /// Short description of the waveform characteristics.
  final String description;
}
