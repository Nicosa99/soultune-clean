/// Frequency constants for healing frequencies and brainwave states.
///
/// Includes Solfeggio frequencies, brainwave ranges, and preset definitions
/// used throughout the frequency generator feature.
library;

// =============================================================================
// Solfeggio Frequencies (Ancient Healing Tones)
// =============================================================================

/// 174 Hz - Pain Relief & Grounding.
const double kSolfeggio174Hz = 174.0;

/// 285 Hz - Cellular Healing & Regeneration.
const double kSolfeggio285Hz = 285.0;

/// 396 Hz - Liberating Guilt & Fear (Root Chakra).
const double kSolfeggio396Hz = 396.0;

/// 417 Hz - Undoing Situations & Facilitating Change (Sacral Chakra).
const double kSolfeggio417Hz = 417.0;

/// 528 Hz - Transformation & DNA Repair (Solar Plexus) - THE MIRACLE FREQUENCY.
const double kSolfeggio528Hz = 528.0;

/// 639 Hz - Connecting Relationships & Harmony (Heart Chakra).
const double kSolfeggio639Hz = 639.0;

/// 741 Hz - Awakening Intuition & Expression (Throat Chakra).
const double kSolfeggio741Hz = 741.0;

/// 852 Hz - Spiritual Awareness & Return to Order (Third Eye Chakra).
const double kSolfeggio852Hz = 852.0;

/// 963 Hz - Enlightenment & Returning to Oneness (Crown Chakra).
const double kSolfeggio963Hz = 963.0;

// =============================================================================
// Brainwave Frequency Ranges
// =============================================================================

/// Delta waves (0.5-4 Hz) - Deep Sleep, Physical Healing.
const double kDeltaMin = 0.5;

/// Delta waves maximum frequency.
const double kDeltaMax = 4.0;

/// Theta waves (4-8 Hz) - Meditation, Deep Relaxation, Creativity.
const double kThetaMin = 4.0;

/// Theta waves maximum frequency.
const double kThetaMax = 8.0;

/// Alpha waves (8-12 Hz) - Relaxed Awareness, Learning, Imagination.
const double kAlphaMin = 8.0;

/// Alpha waves maximum frequency.
const double kAlphaMax = 12.0;

/// Beta waves (12-30 Hz) - Normal Waking, Focus, Analysis.
const double kBetaMin = 12.0;

/// Beta waves maximum frequency.
const double kBetaMax = 30.0;

/// Gamma waves (30-100 Hz) - Peak Cognitive Function, Consciousness.
const double kGammaMin = 30.0;

/// Gamma waves maximum frequency.
const double kGammaMax = 100.0;

/// Schumann Resonance - Earth's natural frequency.
const double kSchumannResonance = 7.83;

// =============================================================================
// Generator Limits
// =============================================================================

/// Minimum frequency for generator (Hz).
const double kMinFrequency = 20.0;

/// Maximum frequency for generator (Hz).
const double kMaxFrequency = 20000.0;

/// Minimum binaural carrier frequency (Hz).
const double kMinBinauralCarrier = 20.0;

/// Maximum binaural carrier frequency (Hz).
const double kMaxBinauralCarrier = 2000.0;

/// Maximum number of frequency layers.
const int kMaxLayers = 3;

/// Default session duration in minutes.
const int kDefaultSessionMinutes = 15;

/// Minimum session duration in minutes.
const int kMinSessionMinutes = 1;

/// Maximum session duration in minutes (12 hours).
const int kMaxSessionMinutes = 720;

/// Fade out duration in seconds for session end.
const int kFadeOutSeconds = 30;

// =============================================================================
// Audio Quality Settings
// =============================================================================

/// Sample rate for audio generation (Hz).
const int kSampleRate = 44100;

/// Bit depth for audio generation.
const int kBitDepth = 16;

/// Number of audio channels (stereo for binaural).
const int kAudioChannels = 2;
