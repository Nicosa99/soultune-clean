/// FrequencySetting - Healing Frequency Configuration Model
///
/// Represents a tuning frequency configuration for audio transformation.
/// Each frequency setting contains the scientific parameters needed to
/// shift standard 440Hz audio to healing frequencies like 432Hz, 528Hz, etc.
///
/// This model uses [Freezed] for immutability and value equality, ensuring
/// type-safe, predictable frequency configurations throughout the app.
///
/// ## Example Usage
///
/// ```dart
/// // Use predefined frequency
/// final freq432 = FrequencySetting.hz432();
///
/// // Access properties
/// print(freq432.displayName); // "432 Hz - Deep Peace"
/// print(freq432.pitchShift);  // -0.31767
///
/// // Check premium status
/// if (!frequency.isPremium) {
///   applyFrequency(frequency);
/// }
/// ```
library;

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:soultune/app/constants/frequencies.dart';
import 'package:soultune/shared/theme/app_colors.dart';

part 'frequency_setting.freezed.dart';
part 'frequency_setting.g.dart';

/// Immutable model representing a healing frequency configuration.
///
/// Each frequency setting contains all parameters needed to transform
/// audio from standard 440Hz tuning to healing frequencies.
///
/// ## Fields
///
/// - **id**: Unique identifier (e.g., "432", "528")
/// - **targetHz**: Target frequency in Hertz
/// - **displayName**: User-friendly name shown in UI
/// - **description**: Detailed explanation of frequency benefits
/// - **pitchShift**: Calculated semitone shift from 440Hz
/// - **isPremium**: Whether this frequency requires premium subscription
/// - **color**: Distinctive color for visual identification
///
/// ## Serialization
///
/// Supports JSON serialization via `json_serializable` and Hive storage
/// via type adapter (TypeId: 0).
@freezed
@HiveType(typeId: 0)
class FrequencySetting with _$FrequencySetting {
  /// Creates a [FrequencySetting] with all required parameters.
  const factory FrequencySetting({
    /// Unique identifier for this frequency setting.
    ///
    /// Examples: "432", "528", "639", "standard"
    @HiveField(0) required String id,

    /// Target frequency in Hertz (e.g., 432.0, 528.0).
    @HiveField(1) required double targetHz,

    /// User-friendly display name.
    ///
    /// Examples: "432 Hz - Deep Peace", "528 Hz - Love Frequency"
    @HiveField(2) required String displayName,

    /// Detailed description of frequency benefits and characteristics.
    @HiveField(3) required String description,

    /// Pitch shift in semitones from standard 440Hz tuning.
    ///
    /// Negative values shift down, positive values shift up.
    /// Example: -0.31767 for 432Hz
    @HiveField(4) required double pitchShift,

    /// Whether this frequency requires premium subscription.
    ///
    /// Free tier includes only 432Hz. All other frequencies require premium.
    @HiveField(5) @Default(false) bool isPremium,

    /// Distinctive color for UI representation.
    ///
    /// Used for frequency selector chips, indicators, and visualizations.
    @HiveField(6) @ColorConverter() required Color color,
  }) = _FrequencySetting;

  /// Creates a [FrequencySetting] from JSON data.
  ///
  /// Used for serialization/deserialization and potential cloud sync.
  factory FrequencySetting.fromJson(Map<String, dynamic> json) =>
      _$FrequencySettingFromJson(json);

  // ---------------------------------------------------------------------------
  // Predefined Frequency Factory Constructors
  // ---------------------------------------------------------------------------

  /// Standard 440Hz tuning (ISO 16 concert pitch).
  ///
  /// No pitch shift applied. Use this to disable frequency transformation
  /// and play audio at its original tuning.
  factory FrequencySetting.standard() => const FrequencySetting(
        id: 'standard',
        targetHz: kStandardPitchHz,
        displayName: kFrequencyNameStandard,
        description: kFrequencyDescStandard,
        pitchShift: kPitchStandard,
        isPremium: false,
        color: AppColors.frequencyStandard,
      );

  /// 432 Hz - Deep Peace & Harmony (FREE).
  ///
  /// Often called "Verdi's A" or "Nature's frequency". Proponents claim
  /// it resonates with natural vibrations and promotes healing, relaxation,
  /// and harmony with the universe.
  ///
  /// **Scientific Note**: 432Hz is 8Hz lower than standard tuning.
  /// Pitch shift: -0.31767 semitones
  ///
  /// **Availability**: Free tier (no premium required)
  factory FrequencySetting.hz432() => const FrequencySetting(
        id: '432',
        targetHz: 432.0,
        displayName: kFrequencyName432Hz,
        description: kFrequencyDesc432Hz,
        pitchShift: kPitch432Hz,
        isPremium: false,
        color: AppColors.frequency432,
      );

  /// 528 Hz - Love Frequency (PREMIUM).
  ///
  /// One of the ancient Solfeggio frequencies, often called the "Love
  /// frequency" or "Miracle tone". Associated with DNA repair,
  /// transformation, and positive energy.
  ///
  /// **Scientific Note**: This is an approximation. True Solfeggio tuning
  /// may require per-note transposition (Phase 2 feature).
  /// Pitch shift: +0.37851 semitones (approximation)
  ///
  /// **Availability**: Premium subscription required
  factory FrequencySetting.hz528() => const FrequencySetting(
        id: '528',
        targetHz: 528.0,
        displayName: kFrequencyName528Hz,
        description: kFrequencyDesc528Hz,
        pitchShift: kPitch528Hz,
        isPremium: true,
        color: AppColors.frequency528,
      );

  /// 639 Hz - Harmony & Connection (PREMIUM).
  ///
  /// A Solfeggio frequency associated with connecting/reconnecting
  /// relationships, harmony, and communication. Said to balance emotions
  /// and elevate mood.
  ///
  /// **Scientific Note**: Similar to 528Hz, this is a simplified
  /// approximation suitable for MVP.
  /// Pitch shift: +0.69877 semitones (approximation)
  ///
  /// **Availability**: Premium subscription required
  factory FrequencySetting.hz639() => const FrequencySetting(
        id: '639',
        targetHz: 639.0,
        displayName: kFrequencyName639Hz,
        description: kFrequencyDesc639Hz,
        pitchShift: kPitch639Hz,
        isPremium: true,
        color: AppColors.frequency639,
      );

  // ---------------------------------------------------------------------------
  // Static Lists
  // ---------------------------------------------------------------------------

  /// All available frequency settings in display order.
  ///
  /// Use this list to populate frequency selector UI components.
  ///
  /// ```dart
  /// ListView.builder(
  ///   itemCount: FrequencySetting.all.length,
  ///   itemBuilder: (context, index) {
  ///     final freq = FrequencySetting.all[index];
  ///     return FrequencyChip(frequency: freq);
  ///   },
  /// );
  /// ```
  static final List<FrequencySetting> all = [
    FrequencySetting.standard(),
    FrequencySetting.hz432(),
    FrequencySetting.hz528(),
    FrequencySetting.hz639(),
  ];

  /// Only free-tier frequency settings.
  ///
  /// Use this to show available options for non-premium users.
  static final List<FrequencySetting> free = all
      .where((freq) => !freq.isPremium)
      .toList(growable: false);

  /// Only premium frequency settings.
  ///
  /// Use this to show locked options in UI or premium upsell screens.
  static final List<FrequencySetting> premium = all
      .where((freq) => freq.isPremium)
      .toList(growable: false);
}

// -----------------------------------------------------------------------------
// Custom JSON Converters
// -----------------------------------------------------------------------------

/// JSON converter for [Color] type.
///
/// Serializes Color as hex integer (0xAARRGGBB format) for compact storage.
///
/// Example:
/// ```dart
/// Color(0xFF6366F1) -> 0xFF6366F1 (int)
/// 0xFF6366F1 (int) -> Color(0xFF6366F1)
/// ```
class ColorConverter implements JsonConverter<Color, int> {
  /// Creates a [ColorConverter].
  const ColorConverter();

  @override
  Color fromJson(int json) => Color(json);

  @override
  int toJson(Color object) => object.value;
}
