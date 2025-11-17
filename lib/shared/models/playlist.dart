/// SoulTune Playlist Model
///
/// Represents a user-created playlist containing multiple audio tracks.
/// Stored in Hive for local persistence.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'playlist.freezed.dart';
part 'playlist.g.dart';

/// Playlist model for organizing audio files.
///
/// ## Usage
///
/// ```dart
/// final playlist = Playlist(
///   id: 'playlist_1',
///   name: 'Relaxation Mix',
///   trackIds: ['track1', 'track2', 'track3'],
///   dateCreated: DateTime.now(),
///   dateModified: DateTime.now(),
/// );
/// ```
@freezed
class Playlist with _$Playlist {
  /// Creates a [Playlist].
  ///
  /// ## Parameters
  ///
  /// - [id]: Unique identifier (UUID v4)
  /// - [name]: Playlist name (max 100 chars)
  /// - [trackIds]: List of audio file IDs in playlist
  /// - [dateCreated]: Creation timestamp
  /// - [dateModified]: Last modification timestamp
  /// - [description]: Optional description
  const factory Playlist({
    required String id,
    required String name,
    required List<String> trackIds,
    required DateTime dateCreated,
    required DateTime dateModified,
    String? description,
  }) = _Playlist;

  /// Creates a [Playlist] from JSON.
  factory Playlist.fromJson(Map<String, dynamic> json) =>
      _$PlaylistFromJson(json);
}
