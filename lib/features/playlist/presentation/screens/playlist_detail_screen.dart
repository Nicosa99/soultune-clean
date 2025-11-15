/// SoulTune Playlist Detail Screen
///
/// Displays all tracks in a playlist with play and management options.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soultune/app/constants/frequencies.dart';
import 'package:soultune/features/player/presentation/providers/player_providers.dart';
import 'package:soultune/features/playlist/presentation/providers/playlist_providers.dart';
import 'package:soultune/shared/models/audio_file.dart';

/// Playlist detail screen showing all tracks.
class PlaylistDetailScreen extends ConsumerWidget {
  /// Creates a [PlaylistDetailScreen].
  const PlaylistDetailScreen({
    super.key,
    required this.playlistId,
    this.onNavigateToPlayer,
  });

  /// The playlist ID to display.
  final String playlistId;

  /// Callback to navigate to Now Playing screen.
  final VoidCallback? onNavigateToPlayer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistAsync = ref.watch(playlistProvider(playlistId));
    final libraryAsync = ref.watch(audioLibraryProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: playlistAsync.when(
        data: (playlist) {
          if (playlist == null) {
            return _buildNotFound(context);
          }

          return libraryAsync.when(
            data: (allFiles) {
              // Get tracks that exist in library
              final tracks = playlist.trackIds
                  .map((id) => allFiles.firstWhere(
                        (file) => file.id == id,
                        orElse: () => null as AudioFile,
                      ))
                  .where((file) => file != null)
                  .cast<AudioFile>()
                  .toList();

              return CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar.large(
                    title: Text(playlist.name),
                    actions: [
                      // Edit playlist
                      IconButton(
                        onPressed: () => _showEditDialog(context, ref, playlist.id, playlist.name, playlist.description),
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit playlist',
                      ),
                      // Delete playlist
                      IconButton(
                        onPressed: () => _confirmDelete(context, ref, playlist.id, playlist.name),
                        icon: const Icon(Icons.delete),
                        tooltip: 'Delete playlist',
                      ),
                    ],
                  ),

                  // Playlist info
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (playlist.description != null)
                            Text(
                              playlist.description!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            '${tracks.length} ${tracks.length == 1 ? 'track' : 'tracks'}',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                          if (tracks.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: () => _playPlaylist(ref, tracks),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Play All'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Track list
                  if (tracks.isEmpty)
                    SliverFillRemaining(
                      child: _buildEmptyState(context),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final track = tracks[index];
                          return _TrackListTile(
                            track: track,
                            playlistId: playlistId,
                            onTap: () => _playTrack(ref, tracks, index),
                          );
                        },
                        childCount: tracks.length,
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error loading tracks: $error'),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading playlist: $error'),
        ),
      ),
    );
  }

  /// Builds not found state.
  Widget _buildNotFound(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Playlist Not Found',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds empty state.
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_music_outlined,
              size: 80,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No tracks in this playlist',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add tracks from your library',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Plays all tracks in playlist.
  Future<void> _playPlaylist(WidgetRef ref, List<AudioFile> tracks) async {
    if (tracks.isEmpty) return;

    try {
      final playWithPlaylist = ref.read(playWithPlaylistProvider);
      await playWithPlaylist(tracks, 0);

      // Navigate to Now Playing screen
      onNavigateToPlayer?.call();
    } catch (e) {
      // Error handled by provider
    }
  }

  /// Plays a specific track.
  Future<void> _playTrack(
    WidgetRef ref,
    List<AudioFile> tracks,
    int index,
  ) async {
    try {
      final playWithPlaylist = ref.read(playWithPlaylistProvider);
      await playWithPlaylist(tracks, index);

      // Navigate to Now Playing screen
      onNavigateToPlayer?.call();
    } catch (e) {
      // Error handled by provider
    }
  }

  /// Shows edit dialog.
  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    String playlistId,
    String currentName,
    String? currentDescription,
  ) {
    final nameController = TextEditingController(text: currentName);
    final descController = TextEditingController(text: currentDescription ?? '');

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Playlist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              try {
                final updateMetadata = ref.read(updatePlaylistMetadataProvider);
                await updateMetadata(
                  playlistId: playlistId,
                  name: name,
                  description: descController.text.trim().isEmpty
                      ? null
                      : descController.text.trim(),
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Playlist updated')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Confirms playlist deletion.
  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String playlistId,
    String playlistName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Playlist?'),
        content: Text(
          'Are you sure you want to delete "$playlistName"? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final deletePlaylist = ref.read(deletePlaylistProvider);
        await deletePlaylist(playlistId: playlistId);

        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Deleted "$playlistName"')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}

// -----------------------------------------------------------------------------
// Track List Tile
// -----------------------------------------------------------------------------

class _TrackListTile extends ConsumerWidget {
  const _TrackListTile({
    required this.track,
    required this.playlistId,
    required this.onTap,
  });

  final AudioFile track;
  final String playlistId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentFile = ref.watch(currentAudioFileProvider);
    final isPlaying = currentFile?.id == track.id;

    return ListTile(
      leading: _buildAlbumArt(context, track, isPlaying),
      title: Text(
        track.title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: isPlaying ? FontWeight.w600 : FontWeight.normal,
          color: isPlaying ? colorScheme.primary : null,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: track.artist != null
          ? Text(
              track.artist!,
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: IconButton(
        icon: const Icon(Icons.remove_circle_outline),
        tooltip: 'Remove from playlist',
        onPressed: () => _removeFromPlaylist(context, ref),
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }

  Widget _buildAlbumArt(BuildContext context, AudioFile track, bool isPlaying) {
    final colorScheme = Theme.of(context).colorScheme;

    if (track.albumArt != null && File(track.albumArt!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.file(
          File(track.albumArt!),
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultIcon(context, isPlaying);
          },
        ),
      );
    }

    return _buildDefaultIcon(context, isPlaying);
  }

  Widget _buildDefaultIcon(BuildContext context, bool isPlaying) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isPlaying
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        isPlaying ? Icons.play_arrow : Icons.music_note,
        color: isPlaying
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurfaceVariant,
      ),
    );
  }

  Future<void> _removeFromPlaylist(BuildContext context, WidgetRef ref) async {
    try {
      final removeTrack = ref.read(removeTrackFromPlaylistProvider);
      await removeTrack(playlistId: playlistId, trackId: track.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed "${track.title}" from playlist'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
