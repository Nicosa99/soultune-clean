/// AudioFile - Music Track Metadata Model
///
/// Represents a single audio file with complete metadata extracted from
/// ID3 tags, file system, and user interactions. This is the core data
/// model for SoulTune's music library.
///
/// ## Features
///
/// - Immutable with [Freezed] for value equality
/// - Persistent storage with Hive (TypeId: 1)
/// - JSON serialization for potential cloud sync
/// - Tracks user engagement (play count, favorites)
/// - Supports all common audio formats (MP3, FLAC, WAV, AAC, OGG)
///
/// ## Usage
///
/// ```dart
/// // Create from metadata extraction
/// final audioFile = AudioFile(
///   id: const Uuid().v4(),
///   filePath: '/storage/music/song.mp3',
///   title: 'Healing Meditation',
///   artist: 'Nature Sounds',
///   duration: const Duration(minutes: 5, seconds: 30),
///   dateAdded: DateTime.now(),
/// );
///
/// // Save to Hive
/// final box = Hive.box<AudioFile>('audio_files');
/// await box.put(audioFile.id, audioFile);
///
/// // Update play count
/// final updated = audioFile.copyWith(
///   playCount: audioFile.playCount + 1,
/// );
/// ```
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio_file.freezed.dart';
part 'audio_file.g.dart';

/// Immutable model representing a music track with metadata.
///
/// Stores complete information about an audio file including:
/// - File system path and metadata
/// - ID3 tag information (title, artist, album, etc.)
/// - User engagement data (play count, favorites)
/// - Album artwork reference
///
/// ## Persistence
///
/// Supports JSON serialization via `json_serializable`.
/// Hive storage uses manual TypeAdapter (see audio_file_adapter.dart).
///
/// ## Equality
///
/// Two AudioFile instances are equal if all fields match (Freezed
/// auto-generates == and hashCode). However, for collection operations,
/// prefer comparing by [id] for performance.
@freezed
class AudioFile with _$AudioFile {
  /// Creates an [AudioFile] with required and optional metadata.
  ///
  /// ## Required Fields
  ///
  /// - [id]: Unique identifier (UUID v4 recommended)
  /// - [filePath]: Absolute path to audio file
  /// - [title]: Track title (from ID3 or filename)
  /// - [duration]: Track length
  /// - [dateAdded]: When file was added to library
  ///
  /// ## Optional Fields
  ///
  /// - [artist]: Artist name from ID3 tags
  /// - [album]: Album name from ID3 tags
  /// - [albumArt]: Path to cached album art image
  /// - [genre]: Music genre from ID3 tags
  /// - [year]: Release year from ID3 tags
  /// - [trackNumber]: Track position in album
  /// - [playCount]: Number of times played (default: 0)
  /// - [isFavorite]: User favorite status (default: false)
  /// - [lastPlayed]: Timestamp of last playback
  const factory AudioFile({
    /// Unique identifier for this audio file.
    ///
    /// Use UUID v4 for guaranteed uniqueness:
    /// ```dart
    /// id: const Uuid().v4()
    /// ```
    required String id,

    /// Absolute file system path to the audio file.
    ///
    /// Example: `/storage/emulated/0/Music/song.mp3`
    ///
    /// Must be accessible with current app permissions.
    required String filePath,

    /// Track title.
    ///
    /// Extracted from ID3 tags (TIT2 frame) or derived from filename
    /// if metadata is missing.
    ///
    /// Example: "Healing Meditation in 432Hz"
    required String title,

    /// Artist or band name.
    ///
    /// Extracted from ID3 tags (TPE1 frame). May be null if metadata
    /// is missing or file is instrumental.
    ///
    /// Example: "Nature Sounds Collective"
    String? artist,

    /// Album name.
    ///
    /// Extracted from ID3 tags (TALB frame). May be null for singles
    /// or files without proper tagging.
    ///
    /// Example: "Meditation & Healing Frequencies Vol. 1"
    String? album,

    /// Path to cached album artwork image.
    ///
    /// Album art is extracted from ID3 APIC frame and cached locally
    /// to avoid repeated extraction. Path points to cached file in
    /// app's cache directory.
    ///
    /// Example: `/cache/album_art/a1b2c3d4.jpg`
    ///
    /// Null if no album art is available.
    String? albumArt,

    /// Music genre.
    ///
    /// Extracted from ID3 tags (TCON frame). Examples: "Meditation",
    /// "Ambient", "New Age", "Classical", etc.
    String? genre,

    /// Release year.
    ///
    /// Extracted from ID3 tags (TDRC or TYER frame). Null if not
    /// available in metadata.
    int? year,

    /// Track number in album.
    ///
    /// Extracted from ID3 tags (TRCK frame). Null for singles or
    /// files without proper album organization.
    int? trackNumber,

    /// Audio file duration.
    ///
    /// Calculated during metadata extraction. Required for seek bar
    /// and duration display.
    @DurationConverter() required Duration duration,

    /// Timestamp when file was added to library.
    ///
    /// Set once during initial import. Used for "Recently Added" sorting.
    @DateTimeConverter() required DateTime dateAdded,

    /// Number of times this track has been played.
    ///
    /// Incremented each time playback completes (reaches end or user
    /// plays >50% of duration). Used for "Most Played" sorting and
    /// analytics.
    ///
    /// Default: 0
    @Default(0) int playCount,

    /// Whether user marked this track as favorite.
    ///
    /// Used for quick access to favorite tracks and filtering.
    ///
    /// Default: false
    @Default(false) bool isFavorite,

    /// Timestamp of last playback.
    ///
    /// Updated each time track is played. Used for "Recently Played"
    /// sorting. Null if never played.
    @DateTimeConverter() DateTime? lastPlayed,
  }) = _AudioFile;

  /// Creates an [AudioFile] from JSON data.
  ///
  /// Used for serialization/deserialization and potential cloud sync.
  factory AudioFile.fromJson(Map<String, dynamic> json) =>
      _$AudioFileFromJson(json);

  // ---------------------------------------------------------------------------
  // Custom Methods (require private empty constructor)
  // ---------------------------------------------------------------------------

  const AudioFile._();

  /// Returns a display-friendly artist name.
  ///
  /// Falls back to "Unknown Artist" if artist metadata is missing.
  String get displayArtist => artist ?? 'Unknown Artist';

  /// Returns a display-friendly album name.
  ///
  /// Falls back to "Unknown Album" if album metadata is missing.
  String get displayAlbum => album ?? 'Unknown Album';

  /// Returns formatted duration string (e.g., "3:45" or "1:23:45").
  ///
  /// Automatically handles hours if duration >= 1 hour.
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Returns file extension (e.g., "mp3", "flac", "wav").
  ///
  /// Useful for format-specific handling or UI indicators.
  String get fileExtension {
    final parts = filePath.split('.');
    return parts.isEmpty ? '' : parts.last.toLowerCase();
  }

  /// Returns file name without extension.
  ///
  /// Example: "/path/to/song.mp3" -> "song"
  String get fileName {
    final parts = filePath.split('/');
    final fileWithExt = parts.isEmpty ? '' : parts.last;
    final nameParts = fileWithExt.split('.');
    nameParts.removeLast(); // Remove extension
    return nameParts.join('.');
  }

  /// Whether this track has been played at least once.
  bool get hasBeenPlayed => playCount > 0;

  /// Whether album artwork is available.
  bool get hasAlbumArt => albumArt != null && albumArt!.isNotEmpty;

  /// Whether this is a long track (>10 minutes).
  ///
  /// Useful for UI adaptations (e.g., meditation mode, extended seek).
  bool get isLongTrack => duration.inMinutes >= 10;

  /// Creates a copy with incremented play count and updated last played.
  ///
  /// Convenience method for tracking playback.
  ///
  /// ```dart
  /// final updated = audioFile.recordPlay();
  /// await repository.update(updated);
  /// ```
  AudioFile recordPlay() => copyWith(
        playCount: playCount + 1,
        lastPlayed: DateTime.now(),
      );

  /// Creates a copy with toggled favorite status.
  ///
  /// Convenience method for favorite management.
  ///
  /// ```dart
  /// final updated = audioFile.toggleFavorite();
  /// await repository.update(updated);
  /// ```
  AudioFile toggleFavorite() => copyWith(
        isFavorite: !isFavorite,
      );
}

// -----------------------------------------------------------------------------
// Custom JSON Converters for Hive
// -----------------------------------------------------------------------------

/// JSON converter for [Duration] type.
///
/// Stores duration as microseconds integer for compact Hive storage.
///
/// Example:
/// ```dart
/// Duration(minutes: 3, seconds: 45) -> 225000000 (int)
/// 225000000 (int) -> Duration(microseconds: 225000000)
/// ```
class DurationConverter implements JsonConverter<Duration, int> {
  /// Creates a [DurationConverter].
  const DurationConverter();

  @override
  Duration fromJson(int json) => Duration(microseconds: json);

  @override
  int toJson(Duration object) => object.inMicroseconds;
}

/// JSON converter for [DateTime] type.
///
/// Stores DateTime as milliseconds since epoch for compact Hive storage.
///
/// Example:
/// ```dart
/// DateTime(2024, 1, 15) -> 1705276800000 (int)
/// 1705276800000 (int) -> DateTime.fromMillisecondsSinceEpoch(...)
/// ```
class DateTimeConverter implements JsonConverter<DateTime, int> {
  /// Creates a [DateTimeConverter].
  const DateTimeConverter();

  @override
  DateTime fromJson(int json) => DateTime.fromMillisecondsSinceEpoch(json);

  @override
  int toJson(DateTime object) => object.millisecondsSinceEpoch;
}
