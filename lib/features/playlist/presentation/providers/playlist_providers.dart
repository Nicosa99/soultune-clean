/// SoulTune Playlist Providers
///
/// Riverpod providers for playlist state management and business logic.
/// Provides reactive access to playlists, CRUD operations, and track management.
///
/// ## Provider Types
///
/// - **Data Source**: Singleton HivePlaylistDataSource
/// - **State Providers**: Current playlist, all playlists, track associations
/// - **Action Providers**: Create, update, delete, add/remove tracks
/// - **Stream Providers**: Reactive playlist updates
///
/// ## Usage
///
/// ```dart
/// // Watch all playlists
/// final playlists = ref.watch(allPlaylistsProvider);
///
/// // Create new playlist
/// await ref.read(createPlaylistProvider)(name: 'My Playlist');
///
/// // Add track to playlist
/// await ref.read(addTrackToPlaylistProvider)(playlistId, trackId);
/// ```
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soultune/features/playlist/data/datasources/hive_playlist_datasource.dart';
import 'package:soultune/shared/models/playlist.dart';
import 'package:uuid/uuid.dart';

part 'playlist_providers.g.dart';

// -----------------------------------------------------------------------------
// Data Source Provider
// -----------------------------------------------------------------------------

/// Provides singleton HivePlaylistDataSource instance.
///
/// Automatically initializes the datasource on first access.
@riverpod
Future<HivePlaylistDataSource> playlistDataSource(
  PlaylistDataSourceRef ref,
) async {
  final dataSource = HivePlaylistDataSource();
  await dataSource.init();

  // Cleanup on provider dispose
  ref.onDispose(() async {
    await dataSource.dispose();
  });

  return dataSource;
}

// -----------------------------------------------------------------------------
// Read Providers
// -----------------------------------------------------------------------------

/// Provides all playlists sorted by date modified.
///
/// Automatically updates when playlists change in Hive.
@riverpod
Future<List<Playlist>> allPlaylists(AllPlaylistsRef ref) async {
  final dataSource = await ref.watch(playlistDataSourceProvider.future);
  return dataSource.getAllPlaylists();
}

/// Provides stream of all playlists for reactive updates.
@riverpod
Stream<List<Playlist>> playlistsStream(PlaylistsStreamRef ref) async* {
  final dataSource = await ref.watch(playlistDataSourceProvider.future);

  // Yield initial value first to avoid loading loop
  yield await dataSource.getAllPlaylists();

  // Then yield updates as they come
  yield* dataSource.watchPlaylists();
}

/// Provides a specific playlist by ID.
///
/// Returns null if playlist not found.
@riverpod
Future<Playlist?> playlist(PlaylistRef ref, String playlistId) async {
  final dataSource = await ref.watch(playlistDataSourceProvider.future);
  return dataSource.getPlaylist(playlistId);
}

/// Provides stream of a specific playlist for reactive updates.
@riverpod
Stream<Playlist?> playlistStream(
  PlaylistStreamRef ref,
  String playlistId,
) async* {
  final dataSource = await ref.watch(playlistDataSourceProvider.future);
  yield* dataSource.watchPlaylist(playlistId);
}

/// Provides playlists that contain a specific track.
@riverpod
Future<List<Playlist>> playlistsContainingTrack(
  PlaylistsContainingTrackRef ref,
  String trackId,
) async {
  final dataSource = await ref.watch(playlistDataSourceProvider.future);
  return dataSource.getPlaylistsContainingTrack(trackId);
}

/// Provides total playlist count.
@riverpod
Future<int> playlistCount(PlaylistCountRef ref) async {
  final dataSource = await ref.watch(playlistDataSourceProvider.future);
  return dataSource.getPlaylistCount();
}

/// Provides search results for playlists.
///
/// Pass empty string to get all playlists.
@riverpod
Future<List<Playlist>> searchPlaylists(
  SearchPlaylistsRef ref,
  String query,
) async {
  final dataSource = await ref.watch(playlistDataSourceProvider.future);
  return dataSource.searchPlaylists(query);
}

// -----------------------------------------------------------------------------
// Create Providers
// -----------------------------------------------------------------------------

/// Provides function to create a new playlist.
///
/// Returns the created playlist.
///
/// ## Example
///
/// ```dart
/// final createPlaylist = ref.read(createPlaylistProvider);
/// final playlist = await createPlaylist(
///   name: 'My Relaxation Mix',
///   description: 'Calming tracks for meditation',
/// );
/// ```
@riverpod
Future<Playlist> Function({
  required String name,
  String? description,
  List<String>? initialTrackIds,
}) createPlaylist(CreatePlaylistRef ref) {
  return ({
    required String name,
    String? description,
    List<String>? initialTrackIds,
  }) async {
    final dataSource = await ref.read(playlistDataSourceProvider.future);

    final playlist = Playlist(
      id: const Uuid().v4(),
      name: name,
      trackIds: initialTrackIds ?? [],
      dateCreated: DateTime.now(),
      dateModified: DateTime.now(),
      description: description,
    );

    await dataSource.savePlaylist(playlist);

    // Invalidate to trigger refresh
    ref.invalidate(allPlaylistsProvider);
    ref.invalidate(playlistCountProvider);

    return playlist;
  };
}

// -----------------------------------------------------------------------------
// Update Providers
// -----------------------------------------------------------------------------

/// Provides function to update playlist metadata (name, description).
///
/// ## Example
///
/// ```dart
/// final updatePlaylist = ref.read(updatePlaylistMetadataProvider);
/// await updatePlaylist(
///   playlistId: playlist.id,
///   name: 'New Name',
///   description: 'Updated description',
/// );
/// ```
@riverpod
Future<void> Function({
  required String playlistId,
  String? name,
  String? description,
}) updatePlaylistMetadata(UpdatePlaylistMetadataRef ref) {
  return ({
    required String playlistId,
    String? name,
    String? description,
  }) async {
    final dataSource = await ref.read(playlistDataSourceProvider.future);
    final playlist = await dataSource.getPlaylist(playlistId);

    if (playlist == null) {
      throw Exception('Playlist not found: $playlistId');
    }

    final updated = playlist.copyWith(
      name: name ?? playlist.name,
      description: description,
      dateModified: DateTime.now(),
    );

    await dataSource.updatePlaylist(updated);

    // Invalidate to trigger refresh
    ref.invalidate(allPlaylistsProvider);
    ref.invalidate(playlistProvider(playlistId));
  };
}

/// Provides function to add a track to a playlist.
///
/// ## Example
///
/// ```dart
/// final addTrack = ref.read(addTrackToPlaylistProvider);
/// await addTrack(playlistId: playlist.id, trackId: audioFile.id);
/// ```
@riverpod
Future<void> Function({
  required String playlistId,
  required String trackId,
}) addTrackToPlaylist(AddTrackToPlaylistRef ref) {
  return ({
    required String playlistId,
    required String trackId,
  }) async {
    final dataSource = await ref.read(playlistDataSourceProvider.future);
    await dataSource.addTrackToPlaylist(playlistId, trackId);

    // Invalidate to trigger refresh
    ref.invalidate(allPlaylistsProvider);
    ref.invalidate(playlistProvider(playlistId));
    ref.invalidate(playlistsContainingTrackProvider(trackId));
  };
}

/// Provides function to remove a track from a playlist.
///
/// ## Example
///
/// ```dart
/// final removeTrack = ref.read(removeTrackFromPlaylistProvider);
/// await removeTrack(playlistId: playlist.id, trackId: audioFile.id);
/// ```
@riverpod
Future<void> Function({
  required String playlistId,
  required String trackId,
}) removeTrackFromPlaylist(RemoveTrackFromPlaylistRef ref) {
  return ({
    required String playlistId,
    required String trackId,
  }) async {
    final dataSource = await ref.read(playlistDataSourceProvider.future);
    await dataSource.removeTrackFromPlaylist(playlistId, trackId);

    // Invalidate to trigger refresh
    ref.invalidate(allPlaylistsProvider);
    ref.invalidate(playlistProvider(playlistId));
    ref.invalidate(playlistsContainingTrackProvider(trackId));
  };
}

/// Provides function to reorder tracks in a playlist.
///
/// ## Example
///
/// ```dart
/// final reorder = ref.read(reorderPlaylistTracksProvider);
/// await reorder(playlistId: playlist.id, oldIndex: 0, newIndex: 3);
/// ```
@riverpod
Future<void> Function({
  required String playlistId,
  required int oldIndex,
  required int newIndex,
}) reorderPlaylistTracks(ReorderPlaylistTracksRef ref) {
  return ({
    required String playlistId,
    required int oldIndex,
    required int newIndex,
  }) async {
    final dataSource = await ref.read(playlistDataSourceProvider.future);
    await dataSource.reorderTracks(playlistId, oldIndex, newIndex);

    // Invalidate to trigger refresh
    ref.invalidate(playlistProvider(playlistId));
  };
}

// -----------------------------------------------------------------------------
// Delete Providers
// -----------------------------------------------------------------------------

/// Provides function to delete a playlist.
///
/// ## Example
///
/// ```dart
/// final deletePlaylist = ref.read(deletePlaylistProvider);
/// await deletePlaylist(playlistId: playlist.id);
/// ```
@riverpod
Future<void> Function({required String playlistId}) deletePlaylist(
  DeletePlaylistRef ref,
) {
  return ({required String playlistId}) async {
    final dataSource = await ref.read(playlistDataSourceProvider.future);
    await dataSource.deletePlaylist(playlistId);

    // Invalidate to trigger refresh
    ref.invalidate(allPlaylistsProvider);
    ref.invalidate(playlistCountProvider);
  };
}

/// Provides function to delete multiple playlists.
///
/// ## Example
///
/// ```dart
/// final deletePlaylists = ref.read(deletePlaylistsProvider);
/// await deletePlaylists(playlistIds: [id1, id2, id3]);
/// ```
@riverpod
Future<void> Function({required List<String> playlistIds}) deletePlaylists(
  DeletePlaylistsRef ref,
) {
  return ({required List<String> playlistIds}) async {
    final dataSource = await ref.read(playlistDataSourceProvider.future);
    await dataSource.deletePlaylists(playlistIds);

    // Invalidate to trigger refresh
    ref.invalidate(allPlaylistsProvider);
    ref.invalidate(playlistCountProvider);
  };
}
