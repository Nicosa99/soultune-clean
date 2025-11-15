/// SoulTune Hive Playlist Data Source
///
/// Low-level CRUD operations for Playlist persistence using Hive.
/// Manages local storage of user-created playlists and their track
/// associations.
///
/// ## Storage Strategy
///
/// - **Box Name**: `playlists`
/// - **Key Format**: Playlist.id (UUID v4)
/// - **Value Type**: Playlist (via JSON-based TypeAdapter)
/// - **Storage Location**: App documents directory
///
/// ## Data Operations
///
/// - **Create**: Add new playlists
/// - **Read**: Query all, by ID, search by name
/// - **Update**: Modify playlist metadata, add/remove tracks
/// - **Delete**: Remove playlists from library
///
/// ## Features
///
/// - Batch operations for performance
/// - Reactive streams for real-time updates
/// - Track association management
/// - Sorted by creation/modification date
/// - Search by playlist name
///
/// ## Usage
///
/// ```dart
/// final dataSource = HivePlaylistDataSource();
/// await dataSource.init();
///
/// // Create new playlist
/// await dataSource.savePlaylist(playlist);
///
/// // Get all playlists
/// final allPlaylists = await dataSource.getAllPlaylists();
///
/// // Add track to playlist
/// await dataSource.addTrackToPlaylist(playlistId, trackId);
///
/// // Remove track from playlist
/// await dataSource.removeTrackFromPlaylist(playlistId, trackId);
/// ```
library;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:soultune/shared/exceptions/app_exceptions.dart';
import 'package:soultune/shared/models/playlist.dart';
import 'package:soultune/shared/services/storage/hive_service.dart';

/// Data source for Playlist persistence using Hive.
///
/// Provides type-safe CRUD operations and query methods for managing
/// user-created playlists. All operations are asynchronous and return
/// Futures for proper async/await handling.
///
/// **Lifecycle**: Call [init] before any operations, [dispose] on cleanup.
class HivePlaylistDataSource {
  /// Creates a [HivePlaylistDataSource] instance.
  ///
  /// Optionally accepts custom [HiveService] for dependency injection.
  HivePlaylistDataSource({HiveService? hiveService})
      : _hiveService = hiveService ?? HiveService.instance {
    _logger.d('HivePlaylistDataSource created');
  }

  /// Logger instance for debugging.
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Hive service for box management.
  final HiveService _hiveService;

  /// Box name for playlists storage.
  static const String _boxName = 'playlists';

  /// The Hive box containing Playlist objects.
  late Box<Playlist> _playlistBox;

  /// Whether the data source has been initialized.
  bool _isInitialized = false;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Initializes the data source and opens the Hive box.
  ///
  /// Must be called before any CRUD operations. Opens or creates the
  /// `playlists` box and prepares it for use.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final dataSource = HivePlaylistDataSource();
  /// await dataSource.init();
  /// ```
  ///
  /// ## Throws
  ///
  /// [StorageException] if box cannot be opened.
  Future<void> init() async {
    if (_isInitialized) {
      _logger.w('HivePlaylistDataSource already initialized');
      return;
    }

    try {
      _logger.i('Initializing HivePlaylistDataSource...');

      // Ensure HiveService is initialized
      await _hiveService.init();

      // Open playlists box
      _playlistBox = await _hiveService.openBox<Playlist>(_boxName);

      _isInitialized = true;

      _logger.i(
        '✓ HivePlaylistDataSource initialized '
        '(${_playlistBox.length} playlists)',
      );
    } on Exception catch (e, stackTrace) {
      _logger.e(
        'Failed to initialize HivePlaylistDataSource',
        error: e,
        stackTrace: stackTrace,
      );

      throw StorageException(
        'Failed to initialize playlist database',
        e,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Create Operations
  // ---------------------------------------------------------------------------

  /// Saves a single playlist.
  ///
  /// If a playlist with the same ID already exists, it will be replaced.
  ///
  /// ## Parameters
  ///
  /// - [playlist]: The playlist to save
  ///
  /// ## Example
  ///
  /// ```dart
  /// await dataSource.savePlaylist(playlist);
  /// ```
  ///
  /// ## Throws
  ///
  /// [StorageException] if save operation fails.
  Future<void> savePlaylist(Playlist playlist) async {
    _ensureInitialized();

    try {
      await _playlistBox.put(playlist.id, playlist);

      _logger.d('Saved playlist: ${playlist.name} (${playlist.id})');
    } on Exception catch (e) {
      _logger.e('Failed to save playlist', error: e);
      throw StorageException('Failed to save playlist', e);
    }
  }

  /// Saves multiple playlists in a batch operation.
  ///
  /// More efficient than calling [savePlaylist] multiple times.
  /// Existing playlists with matching IDs will be replaced.
  ///
  /// ## Parameters
  ///
  /// - [playlists]: List of playlists to save
  ///
  /// ## Example
  ///
  /// ```dart
  /// await dataSource.savePlaylists([playlist1, playlist2]);
  /// ```
  ///
  /// ## Throws
  ///
  /// [StorageException] if batch save fails.
  Future<void> savePlaylists(List<Playlist> playlists) async {
    _ensureInitialized();

    if (playlists.isEmpty) {
      _logger.d('No playlists to save');
      return;
    }

    try {
      // Create map of id -> Playlist for batch put
      final entries = <String, Playlist>{};
      for (final playlist in playlists) {
        entries[playlist.id] = playlist;
      }

      await _playlistBox.putAll(entries);

      _logger.i('Saved ${playlists.length} playlists in batch');
    } on Exception catch (e) {
      _logger.e('Failed to save playlists batch', error: e);
      throw StorageException('Failed to save playlists', e);
    }
  }

  // ---------------------------------------------------------------------------
  // Read Operations
  // ---------------------------------------------------------------------------

  /// Retrieves a single playlist by ID.
  ///
  /// Returns `null` if no playlist with the given ID exists.
  ///
  /// ## Parameters
  ///
  /// - [id]: The unique ID of the playlist
  ///
  /// ## Example
  ///
  /// ```dart
  /// final playlist = await dataSource.getPlaylist('abc-123');
  /// if (playlist != null) {
  ///   print('Found: ${playlist.name}');
  /// }
  /// ```
  Future<Playlist?> getPlaylist(String id) async {
    _ensureInitialized();

    try {
      final playlist = _playlistBox.get(id);

      if (playlist != null) {
        _logger.d('Retrieved playlist: ${playlist.name}');
      } else {
        _logger.d('Playlist not found: $id');
      }

      return playlist;
    } on Exception catch (e) {
      _logger.e('Failed to get playlist', error: e);
      throw StorageException('Failed to retrieve playlist', e);
    }
  }

  /// Retrieves all playlists.
  ///
  /// Returns playlists sorted by date modified (most recent first).
  ///
  /// ## Example
  ///
  /// ```dart
  /// final allPlaylists = await dataSource.getAllPlaylists();
  /// print('Total playlists: ${allPlaylists.length}');
  /// ```
  Future<List<Playlist>> getAllPlaylists() async {
    _ensureInitialized();

    try {
      final playlists = _playlistBox.values.toList()
        ..sort((a, b) => b.dateModified.compareTo(a.dateModified));

      _logger.d('Retrieved ${playlists.length} playlists');

      return playlists;
    } on Exception catch (e) {
      _logger.e('Failed to get all playlists', error: e);
      throw StorageException('Failed to retrieve playlists', e);
    }
  }

  /// Retrieves recently created playlists.
  ///
  /// Returns playlists sorted by `dateCreated` in descending order.
  ///
  /// ## Parameters
  ///
  /// - [limit]: Maximum number of playlists to return (default: 10)
  ///
  /// ## Example
  ///
  /// ```dart
  /// final recent = await dataSource.getRecentPlaylists(limit: 5);
  /// ```
  Future<List<Playlist>> getRecentPlaylists({int limit = 10}) async {
    _ensureInitialized();

    try {
      final playlists = _playlistBox.values.toList()
        ..sort((a, b) => b.dateCreated.compareTo(a.dateCreated));

      final result = playlists.take(limit).toList();

      _logger.d('Retrieved ${result.length} recent playlists');

      return result;
    } on Exception catch (e) {
      _logger.e('Failed to get recent playlists', error: e);
      throw StorageException('Failed to retrieve recent playlists', e);
    }
  }

  /// Searches playlists by name.
  ///
  /// Performs case-insensitive substring matching on name field.
  ///
  /// ## Parameters
  ///
  /// - [query]: Search query string
  ///
  /// ## Example
  ///
  /// ```dart
  /// final results = await dataSource.searchPlaylists('relax');
  /// ```
  Future<List<Playlist>> searchPlaylists(String query) async {
    _ensureInitialized();

    if (query.trim().isEmpty) {
      return getAllPlaylists();
    }

    try {
      final lowerQuery = query.toLowerCase();

      final results = _playlistBox.values.where((playlist) {
        final nameMatch = playlist.name.toLowerCase().contains(lowerQuery);
        final descMatch =
            playlist.description?.toLowerCase().contains(lowerQuery) ?? false;

        return nameMatch || descMatch;
      }).toList();

      _logger.d('Search "$query" found ${results.length} playlists');

      return results;
    } on Exception catch (e) {
      _logger.e('Failed to search playlists', error: e);
      throw StorageException('Failed to search playlists', e);
    }
  }

  /// Gets the total number of playlists.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final count = await dataSource.getPlaylistCount();
  /// print('You have $count playlists');
  /// ```
  Future<int> getPlaylistCount() async {
    _ensureInitialized();

    try {
      final count = _playlistBox.length;

      _logger.d('Playlist count: $count');

      return count;
    } on Exception catch (e) {
      _logger.e('Failed to get playlist count', error: e);
      return 0;
    }
  }

  /// Gets playlists that contain a specific track.
  ///
  /// ## Parameters
  ///
  /// - [trackId]: The audio file ID to search for
  ///
  /// ## Example
  ///
  /// ```dart
  /// final playlists = await dataSource.getPlaylistsContainingTrack(trackId);
  /// print('Track is in ${playlists.length} playlists');
  /// ```
  Future<List<Playlist>> getPlaylistsContainingTrack(String trackId) async {
    _ensureInitialized();

    try {
      final playlists =
          _playlistBox.values.where((p) => p.trackIds.contains(trackId)).toList();

      _logger.d('Found ${playlists.length} playlists containing track $trackId');

      return playlists;
    } on Exception catch (e) {
      _logger.e('Failed to get playlists containing track', error: e);
      throw StorageException('Failed to retrieve playlists', e);
    }
  }

  // ---------------------------------------------------------------------------
  // Update Operations
  // ---------------------------------------------------------------------------

  /// Updates an existing playlist.
  ///
  /// Replaces the stored playlist with the provided instance. The playlist ID
  /// must match an existing entry.
  ///
  /// ## Parameters
  ///
  /// - [playlist]: Updated playlist instance
  ///
  /// ## Example
  ///
  /// ```dart
  /// final updated = playlist.copyWith(name: 'New Name');
  /// await dataSource.updatePlaylist(updated);
  /// ```
  ///
  /// ## Throws
  ///
  /// [StorageException] if update fails or playlist doesn't exist.
  Future<void> updatePlaylist(Playlist playlist) async {
    _ensureInitialized();

    try {
      // Verify playlist exists
      if (!_playlistBox.containsKey(playlist.id)) {
        throw StorageException(
          'Cannot update non-existent playlist: ${playlist.id}',
        );
      }

      await _playlistBox.put(playlist.id, playlist);

      _logger.d('Updated playlist: ${playlist.name}');
    } on Exception catch (e) {
      _logger.e('Failed to update playlist', error: e);
      throw StorageException('Failed to update playlist', e);
    }
  }

  /// Adds a track to a playlist.
  ///
  /// If the track is already in the playlist, it won't be added again.
  /// Updates the `dateModified` timestamp.
  ///
  /// ## Parameters
  ///
  /// - [playlistId]: Playlist ID
  /// - [trackId]: Audio file ID to add
  ///
  /// ## Returns
  ///
  /// The updated [Playlist] instance.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final updated = await dataSource.addTrackToPlaylist(playlistId, trackId);
  /// print('Playlist now has ${updated.trackIds.length} tracks');
  /// ```
  Future<Playlist> addTrackToPlaylist(String playlistId, String trackId) async {
    _ensureInitialized();

    try {
      final playlist = await getPlaylist(playlistId);

      if (playlist == null) {
        throw StorageException('Playlist not found: $playlistId');
      }

      // Check if track already exists
      if (playlist.trackIds.contains(trackId)) {
        _logger.d('Track already in playlist: $trackId');
        return playlist;
      }

      final updatedTrackIds = [...playlist.trackIds, trackId];
      final updated = playlist.copyWith(
        trackIds: updatedTrackIds,
        dateModified: DateTime.now(),
      );

      await _playlistBox.put(playlistId, updated);

      _logger.i(
        'Added track to playlist: ${updated.name} '
        '(${updated.trackIds.length} tracks)',
      );

      return updated;
    } on Exception catch (e) {
      _logger.e('Failed to add track to playlist', error: e);
      throw StorageException('Failed to add track to playlist', e);
    }
  }

  /// Removes a track from a playlist.
  ///
  /// Updates the `dateModified` timestamp.
  ///
  /// ## Parameters
  ///
  /// - [playlistId]: Playlist ID
  /// - [trackId]: Audio file ID to remove
  ///
  /// ## Returns
  ///
  /// The updated [Playlist] instance.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final updated = await dataSource.removeTrackFromPlaylist(playlistId, trackId);
  /// ```
  Future<Playlist> removeTrackFromPlaylist(
    String playlistId,
    String trackId,
  ) async {
    _ensureInitialized();

    try {
      final playlist = await getPlaylist(playlistId);

      if (playlist == null) {
        throw StorageException('Playlist not found: $playlistId');
      }

      final updatedTrackIds = playlist.trackIds.where((id) => id != trackId).toList();
      final updated = playlist.copyWith(
        trackIds: updatedTrackIds,
        dateModified: DateTime.now(),
      );

      await _playlistBox.put(playlistId, updated);

      _logger.i(
        'Removed track from playlist: ${updated.name} '
        '(${updated.trackIds.length} tracks remaining)',
      );

      return updated;
    } on Exception catch (e) {
      _logger.e('Failed to remove track from playlist', error: e);
      throw StorageException('Failed to remove track from playlist', e);
    }
  }

  /// Reorders tracks in a playlist.
  ///
  /// ## Parameters
  ///
  /// - [playlistId]: Playlist ID
  /// - [oldIndex]: Current index of track
  /// - [newIndex]: New index for track
  ///
  /// ## Returns
  ///
  /// The updated [Playlist] instance.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final updated = await dataSource.reorderTracks(playlistId, 0, 3);
  /// ```
  Future<Playlist> reorderTracks(
    String playlistId,
    int oldIndex,
    int newIndex,
  ) async {
    _ensureInitialized();

    try {
      final playlist = await getPlaylist(playlistId);

      if (playlist == null) {
        throw StorageException('Playlist not found: $playlistId');
      }

      final trackIds = List<String>.from(playlist.trackIds);

      // Perform reorder
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final trackId = trackIds.removeAt(oldIndex);
      trackIds.insert(newIndex, trackId);

      final updated = playlist.copyWith(
        trackIds: trackIds,
        dateModified: DateTime.now(),
      );

      await _playlistBox.put(playlistId, updated);

      _logger.d('Reordered tracks in playlist: ${updated.name}');

      return updated;
    } on Exception catch (e) {
      _logger.e('Failed to reorder tracks', error: e);
      throw StorageException('Failed to reorder tracks', e);
    }
  }

  // ---------------------------------------------------------------------------
  // Delete Operations
  // ---------------------------------------------------------------------------

  /// Deletes a single playlist.
  ///
  /// ## Parameters
  ///
  /// - [id]: Playlist ID to delete
  ///
  /// ## Example
  ///
  /// ```dart
  /// await dataSource.deletePlaylist(playlist.id);
  /// ```
  Future<void> deletePlaylist(String id) async {
    _ensureInitialized();

    try {
      await _playlistBox.delete(id);

      _logger.i('Deleted playlist: $id');
    } on Exception catch (e) {
      _logger.e('Failed to delete playlist', error: e);
      throw StorageException('Failed to delete playlist', e);
    }
  }

  /// Deletes multiple playlists in a batch operation.
  ///
  /// ## Parameters
  ///
  /// - [ids]: List of playlist IDs to delete
  ///
  /// ## Example
  ///
  /// ```dart
  /// await dataSource.deletePlaylists(['id1', 'id2', 'id3']);
  /// ```
  Future<void> deletePlaylists(List<String> ids) async {
    _ensureInitialized();

    if (ids.isEmpty) {
      return;
    }

    try {
      await _playlistBox.deleteAll(ids);

      _logger.i('Deleted ${ids.length} playlists');
    } on Exception catch (e) {
      _logger.e('Failed to delete playlists', error: e);
      throw StorageException('Failed to delete playlists', e);
    }
  }

  /// Clears all playlists.
  ///
  /// **WARNING**: This permanently deletes all playlists from storage.
  /// Use with caution!
  ///
  /// ## Example
  ///
  /// ```dart
  /// await dataSource.clearAllPlaylists();
  /// ```
  Future<void> clearAllPlaylists() async {
    _ensureInitialized();

    try {
      final count = _playlistBox.length;
      await _playlistBox.clear();

      _logger.w('Cleared all playlists ($count deleted)');
    } on Exception catch (e) {
      _logger.e('Failed to clear playlists', error: e);
      throw StorageException('Failed to clear playlists', e);
    }
  }

  // ---------------------------------------------------------------------------
  // Streams
  // ---------------------------------------------------------------------------

  /// Stream of playlist changes.
  ///
  /// Emits whenever playlists are added, updated, or deleted.
  /// Use this for reactive UI updates.
  ///
  /// ## Example
  ///
  /// ```dart
  /// dataSource.watchPlaylists().listen((playlists) {
  ///   print('Playlists updated: ${playlists.length}');
  /// });
  /// ```
  Stream<List<Playlist>> watchPlaylists() {
    _ensureInitialized();

    return _playlistBox.watch().map((_) {
      final playlists = _playlistBox.values.toList()
        ..sort((a, b) => b.dateModified.compareTo(a.dateModified));
      return playlists;
    });
  }

  /// Stream of a specific playlist.
  ///
  /// Emits whenever the playlist is updated.
  ///
  /// ## Parameters
  ///
  /// - [id]: Playlist ID to watch
  ///
  /// ## Example
  ///
  /// ```dart
  /// dataSource.watchPlaylist(playlistId).listen((playlist) {
  ///   print('Playlist updated: ${playlist?.name}');
  /// });
  /// ```
  Stream<Playlist?> watchPlaylist(String id) {
    _ensureInitialized();

    return _playlistBox.watch(key: id).map((_) => _playlistBox.get(id));
  }

  // ---------------------------------------------------------------------------
  // Helper Methods
  // ---------------------------------------------------------------------------

  /// Ensures the data source is initialized.
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw const StorageException(
        'HivePlaylistDataSource not initialized. Call init() first.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Disposal
  // ---------------------------------------------------------------------------

  /// Disposes the data source.
  ///
  /// Call during app shutdown or when data source is no longer needed.
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// void dispose() {
  ///   playlistDataSource.dispose();
  ///   super.dispose();
  /// }
  /// ```
  Future<void> dispose() async {
    if (!_isInitialized) {
      return;
    }

    try {
      _logger.i('Disposing HivePlaylistDataSource...');

      // DO NOT close Hive boxes on dispose!
      // Boxes should remain open for app lifetime to prevent
      // "Box has already been closed" errors during hot reload
      // and provider rebuilds.
      //
      // Hive boxes will be closed automatically when app terminates.

      _isInitialized = false;

      _logger.i('✓ HivePlaylistDataSource disposed (box kept open)');
    } on Exception catch (e) {
      _logger.e('Error during disposal', error: e);
      // Don't throw during cleanup
    }
  }
}
