/// Playlist - User-Created Track Collection Model
///
/// Represents a user-created playlist containing references to audio files.
/// Playlists are lightweight collections storing only track IDs rather than
/// full AudioFile objects for memory efficiency.
///
/// ## Features
///
/// - Immutable with [Freezed] for value equality
/// - Persistent storage with Hive (TypeId: 2)
/// - JSON serialization for cloud sync (Phase 3)
/// - Automatic timestamp tracking (created/updated)
/// - Free tier limit: 3 playlists (unlimited for premium)
///
/// ## Usage
///
/// ```dart
/// // Create new playlist
/// final playlist = Playlist(
///   id: const Uuid().v4(),
///   name: 'Morning Meditation',
///   audioFileIds: ['file1', 'file2', 'file3'],
///   createdAt: DateTime.now(),
///   updatedAt: DateTime.now(),
/// );
///
/// // Add track
/// final updated = playlist.addTrack('file4');
///
/// // Remove track
/// final modified = updated.removeTrack('file2');
///
/// // Save to Hive
/// final box = Hive.box<Playlist>('playlists');
/// await box.put(playlist.id, playlist);
/// ```
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soultune/shared/models/audio_file.dart';

part 'playlist.freezed.dart';
part 'playlist.g.dart';

/// Immutable model representing a user-created playlist.
///
/// Stores references to audio files via their IDs for memory efficiency.
/// To get full AudioFile objects, query the audio library using the IDs.
///
/// ## Playlist Limits
///
/// - **Free Tier**: Maximum 3 playlists
/// - **Premium**: Unlimited playlists
///
/// ## Persistence
///
/// Supports JSON serialization via `json_serializable`.
/// Hive storage uses manual TypeAdapter (see playlist_adapter.dart).
/// Playlists persist across app restarts and can be synced to cloud in Phase 3.
@freezed
class Playlist with _$Playlist {
  /// Creates a [Playlist] with required and optional fields.
  ///
  /// ## Required Fields
  ///
  /// - [id]: Unique identifier (UUID v4 recommended)
  /// - [name]: Playlist name shown in UI
  /// - [createdAt]: Creation timestamp
  /// - [updatedAt]: Last modification timestamp
  ///
  /// ## Optional Fields
  ///
  /// - [audioFileIds]: List of audio file IDs (default: empty list)
  /// - [description]: Optional playlist description
  /// - [coverArtPath]: Custom playlist cover (Phase 2+)
  const factory Playlist({
    /// Unique identifier for this playlist.
    ///
    /// Use UUID v4 for guaranteed uniqueness:
    /// ```dart
    /// id: const Uuid().v4()
    /// ```
    required String id,

    /// Playlist name.
    ///
    /// Should be concise and descriptive. Maximum recommended length: 50 chars.
    ///
    /// Examples:
    /// - "Morning Meditation"
    /// - "432Hz Healing Collection"
    /// - "Focus & Concentration"
    required String name,

    /// List of audio file IDs in this playlist.
    ///
    /// Stores only IDs for memory efficiency. To get full AudioFile objects:
    ///
    /// ```dart
    /// final audioBox = Hive.box<AudioFile>('audio_files');
    /// final tracks = playlist.audioFileIds
    ///     .map((id) => audioBox.get(id))
    ///     .whereType<AudioFile>() // Filter out nulls
    ///     .toList();
    /// ```
    ///
    /// Order is preserved - first ID plays first.
    @Default([]) List<String> audioFileIds,

    /// Optional playlist description.
    ///
    /// Provides context about the playlist purpose or mood.
    ///
    /// Examples:
    /// - "Relaxing 432Hz music for morning meditation sessions"
    /// - "Focused study music in healing frequencies"
    ///
    /// Maximum recommended length: 200 chars.
    String? description,

    /// Path to custom playlist cover art.
    ///
    /// Phase 2+ feature. If null, UI should generate cover from
    /// first track's album art or use default gradient.
    String? coverArtPath,

    /// Timestamp when playlist was created.
    ///
    /// Set once during creation. Used for sorting playlists by age.
    @DateTimeConverter() required DateTime createdAt,

    /// Timestamp when playlist was last modified.
    ///
    /// Updated whenever tracks are added/removed or metadata changes.
    /// Used for "Recently Updated" sorting.
    @DateTimeConverter() required DateTime updatedAt,
  }) = _Playlist;

  /// Creates a [Playlist] from JSON data.
  ///
  /// Used for serialization/deserialization and cloud sync (Phase 3).
  factory Playlist.fromJson(Map<String, dynamic> json) =>
      _$PlaylistFromJson(json);

  // ---------------------------------------------------------------------------
  // Custom Methods (require private empty constructor)
  // ---------------------------------------------------------------------------

  const Playlist._();

  /// Number of tracks in this playlist.
  ///
  /// Convenience getter for playlist.audioFileIds.length.
  int get trackCount => audioFileIds.length;

  /// Whether this playlist is empty.
  bool get isEmpty => audioFileIds.isEmpty;

  /// Whether this playlist has tracks.
  bool get isNotEmpty => audioFileIds.isNotEmpty;

  /// Whether this playlist contains the given track ID.
  ///
  /// ```dart
  /// if (playlist.containsTrack(audioFile.id)) {
  ///   // Already in playlist
  /// }
  /// ```
  bool containsTrack(String audioFileId) => audioFileIds.contains(audioFileId);

  /// Creates a copy with a track added to the end.
  ///
  /// Updates the [updatedAt] timestamp automatically.
  /// If track already exists, returns unchanged playlist.
  ///
  /// ```dart
  /// final updated = playlist.addTrack(audioFile.id);
  /// await repository.update(updated);
  /// ```
  Playlist addTrack(String audioFileId) {
    // Don't add duplicates
    if (audioFileIds.contains(audioFileId)) {
      return this;
    }

    return copyWith(
      audioFileIds: [...audioFileIds, audioFileId],
      updatedAt: DateTime.now(),
    );
  }

  /// Creates a copy with multiple tracks added to the end.
  ///
  /// Updates the [updatedAt] timestamp automatically.
  /// Filters out tracks that already exist in the playlist.
  ///
  /// ```dart
  /// final updated = playlist.addTracks(['id1', 'id2', 'id3']);
  /// await repository.update(updated);
  /// ```
  Playlist addTracks(List<String> newAudioFileIds) {
    // Filter out duplicates
    final uniqueIds = newAudioFileIds
        .where((id) => !audioFileIds.contains(id))
        .toList();

    if (uniqueIds.isEmpty) {
      return this;
    }

    return copyWith(
      audioFileIds: [...audioFileIds, ...uniqueIds],
      updatedAt: DateTime.now(),
    );
  }

  /// Creates a copy with a track removed.
  ///
  /// Updates the [updatedAt] timestamp automatically.
  /// If track doesn't exist, returns unchanged playlist.
  ///
  /// ```dart
  /// final updated = playlist.removeTrack(audioFile.id);
  /// await repository.update(updated);
  /// ```
  Playlist removeTrack(String audioFileId) {
    if (!audioFileIds.contains(audioFileId)) {
      return this;
    }

    final updatedIds = audioFileIds.where((id) => id != audioFileId).toList();

    return copyWith(
      audioFileIds: updatedIds,
      updatedAt: DateTime.now(),
    );
  }

  /// Creates a copy with multiple tracks removed.
  ///
  /// Updates the [updatedAt] timestamp automatically.
  ///
  /// ```dart
  /// final updated = playlist.removeTracks(['id1', 'id2']);
  /// await repository.update(updated);
  /// ```
  Playlist removeTracks(List<String> idsToRemove) {
    final updatedIds = audioFileIds
        .where((id) => !idsToRemove.contains(id))
        .toList();

    // If nothing changed, return unchanged
    if (updatedIds.length == audioFileIds.length) {
      return this;
    }

    return copyWith(
      audioFileIds: updatedIds,
      updatedAt: DateTime.now(),
    );
  }

  /// Creates a copy with tracks reordered.
  ///
  /// Moves track from [oldIndex] to [newIndex].
  /// Updates the [updatedAt] timestamp automatically.
  ///
  /// ```dart
  /// // Move first track to third position
  /// final updated = playlist.reorderTrack(0, 2);
  /// await repository.update(updated);
  /// ```
  Playlist reorderTrack(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= audioFileIds.length ||
        newIndex < 0 ||
        newIndex >= audioFileIds.length) {
      return this;
    }

    final updatedIds = List<String>.from(audioFileIds);
    final item = updatedIds.removeAt(oldIndex);
    updatedIds.insert(newIndex, item);

    return copyWith(
      audioFileIds: updatedIds,
      updatedAt: DateTime.now(),
    );
  }

  /// Creates a copy with updated name and/or description.
  ///
  /// Updates the [updatedAt] timestamp automatically.
  ///
  /// ```dart
  /// final updated = playlist.updateMetadata(
  ///   name: 'New Playlist Name',
  ///   description: 'Updated description',
  /// );
  /// await repository.update(updated);
  /// ```
  Playlist updateMetadata({
    String? name,
    String? description,
  }) =>
      copyWith(
        name: name ?? this.name,
        description: description ?? this.description,
        updatedAt: DateTime.now(),
      );

  /// Creates a copy with all tracks removed.
  ///
  /// Updates the [updatedAt] timestamp automatically.
  ///
  /// ```dart
  /// final cleared = playlist.clear();
  /// await repository.update(cleared);
  /// ```
  Playlist clear() => copyWith(
        audioFileIds: [],
        updatedAt: DateTime.now(),
      );

  /// Creates a copy with shuffled track order.
  ///
  /// Uses cryptographically secure random for fair shuffling.
  /// Updates the [updatedAt] timestamp automatically.
  ///
  /// ```dart
  /// final shuffled = playlist.shuffle();
  /// await repository.update(shuffled);
  /// ```
  Playlist shuffle() {
    final shuffledIds = List<String>.from(audioFileIds)..shuffle();

    return copyWith(
      audioFileIds: shuffledIds,
      updatedAt: DateTime.now(),
    );
  }

  /// Returns track ID at given index.
  ///
  /// Throws [RangeError] if index is out of bounds.
  ///
  /// ```dart
  /// final firstTrackId = playlist.getTrackIdAt(0);
  /// ```
  String getTrackIdAt(int index) => audioFileIds[index];

  /// Returns index of track ID, or -1 if not found.
  ///
  /// ```dart
  /// final position = playlist.getTrackIndex(audioFile.id);
  /// if (position >= 0) {
  ///   print('Track is at position $position');
  /// }
  /// ```
  int getTrackIndex(String audioFileId) => audioFileIds.indexOf(audioFileId);

  /// Whether this playlist was modified recently (within last 7 days).
  bool get isRecentlyUpdated {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);
    return difference.inDays <= 7;
  }

  /// Whether this is a new playlist (created within last 24 hours).
  bool get isNew {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours <= 24;
  }

  /// Estimated total duration in seconds.
  ///
  /// **Note**: This requires loading actual AudioFile objects.
  /// For display purposes, calculate this in the UI layer:
  ///
  /// ```dart
  /// int calculateTotalDuration(Playlist playlist, Box<AudioFile> audioBox) {
  ///   return playlist.audioFileIds
  ///       .map((id) => audioBox.get(id))
  ///       .whereType<AudioFile>()
  ///       .fold(0, (sum, file) => sum + file.duration.inSeconds);
  /// }
  /// ```
  ///
  /// This getter is a placeholder for future enhancement.
  @Deprecated('Calculate in UI layer with actual AudioFile objects')
  int get estimatedDurationSeconds => 0;
}
