/// Session Journal Entry Model
///
/// Records user experiences and notes from frequency sessions.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'journal_entry.freezed.dart';
part 'journal_entry.g.dart';

/// A journal entry for a frequency session.
///
/// Users can log their experience, rate the session, add notes,
/// and tag specific phenomena (OBE, lucid dreams, etc.).
@freezed
class JournalEntry with _$JournalEntry {
  /// Creates a [JournalEntry].
  @HiveType(typeId: 12, adapterName: 'JournalEntryImplAdapter')
  const factory JournalEntry({
    /// Unique identifier (UUID v4).
    @HiveField(0) required String id,

    /// Frequency preset ID that was used.
    @HiveField(1) required String presetId,

    /// Preset name (cached for display).
    @HiveField(2) required String presetName,

    /// Session timestamp.
    @HiveField(3) required DateTime timestamp,

    /// Session rating (1-5 stars).
    @HiveField(4) @Default(3) int rating,

    /// User notes and observations.
    @HiveField(5) @Default('') String notes,

    /// Experience tags.
    @HiveField(6) @Default([]) List<String> tags,

    /// Session duration in minutes.
    @HiveField(7) @Default(0) int durationMinutes,
  }) = _JournalEntry;

  /// Private constructor for adding custom getters.
  const JournalEntry._();

  /// Creates a [JournalEntry] from JSON.
  factory JournalEntry.fromJson(Map<String, dynamic> json) =>
      _$JournalEntryFromJson(json);

  /// Formatted duration string.
  String get formattedDuration {
    if (durationMinutes < 60) {
      return '$durationMinutes min';
    }
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    return '${hours}h ${mins}min';
  }
}

/// Common journal entry tags.
class JournalTags {
  /// Private constructor.
  JournalTags._();

  /// Deep relaxation achieved.
  static const String deepRelaxation = 'Deep Relaxation';

  /// Vivid visual experiences.
  static const String vividVisuals = 'Vivid Visuals';

  /// Out-of-body experience.
  static const String obe = 'OBE';

  /// Lucid dream state.
  static const String lucidDream = 'Lucid Dream';

  /// Enhanced focus and clarity.
  static const String enhancedFocus = 'Enhanced Focus';

  /// Physical vibrations felt.
  static const String vibrations = 'Vibrations';

  /// Time distortion.
  static const String timeDistortion = 'Time Distortion';

  /// Emotional release.
  static const String emotionalRelease = 'Emotional Release';

  /// All available tags.
  static const List<String> all = [
    deepRelaxation,
    vividVisuals,
    obe,
    lucidDream,
    enhancedFocus,
    vibrations,
    timeDistortion,
    emotionalRelease,
  ];
}
