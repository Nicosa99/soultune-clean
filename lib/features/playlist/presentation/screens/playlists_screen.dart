/// SoulTune Playlists Screen
///
/// Main playlists interface displaying all user-created playlists.
/// Allows users to browse, create, and manage their playlists.
///
/// ## Features
///
/// - Grid view of all playlists with track counts
/// - Tap to view playlist details
/// - Create new playlist button
/// - Search playlists
/// - Delete playlists (long press)
/// - Empty state when no playlists
/// - Beautiful Material 3 design
///
/// ## Usage
///
/// ```dart
/// PlaylistsScreen()
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soultune/features/playlist/presentation/providers/playlist_providers.dart';
import 'package:soultune/features/playlist/presentation/screens/playlist_detail_screen.dart';
import 'package:soultune/features/playlist/presentation/widgets/create_playlist_dialog.dart';
import 'package:soultune/shared/models/playlist.dart';

/// Playlists screen displaying all user playlists.
///
/// Main screen for managing playlist collections.
class PlaylistsScreen extends ConsumerStatefulWidget {
  /// Creates a [PlaylistsScreen].
  const PlaylistsScreen({
    super.key,
    this.onNavigateToPlayer,
  });

  /// Callback to navigate to Now Playing screen.
  final VoidCallback? onNavigateToPlayer;

  @override
  ConsumerState<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends ConsumerState<PlaylistsScreen> {
  /// Search query for filtering playlists.
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final playlistsAsync = ref.watch(allPlaylistsProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Playlists',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          // Create playlist button
          IconButton(
            onPressed: () => _showCreatePlaylistDialog(context),
            icon: const Icon(Icons.add),
            tooltip: 'Create playlist',
          ),
          // Search button
          IconButton(
            onPressed: () {
              _showSearchDialog(context);
            },
            icon: const Icon(Icons.search),
            tooltip: 'Search playlists',
          ),
        ],
      ),
      body: playlistsAsync.when(
        data: (playlists) {
          // Filter playlists based on search query
          final filteredPlaylists = _searchQuery.isEmpty
              ? playlists
              : playlists.where((playlist) {
                  final query = _searchQuery.toLowerCase();
                  final nameMatch = playlist.name.toLowerCase().contains(query);
                  final descMatch =
                      playlist.description?.toLowerCase().contains(query) ??
                          false;
                  return nameMatch || descMatch;
                }).toList();

          if (filteredPlaylists.isEmpty && _searchQuery.isNotEmpty) {
            return _buildEmptySearch(context);
          }

          if (filteredPlaylists.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildPlaylistGrid(context, filteredPlaylists);
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading playlists...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        error: (error, stack) => Center(
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
                'Failed to load playlists',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the playlist grid.
  Widget _buildPlaylistGrid(BuildContext context, List<Playlist> playlists) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          return _PlaylistCard(
            playlist: playlist,
            onTap: () => _navigateToPlaylistDetail(context, playlist),
            onDelete: () => _confirmDeletePlaylist(context, playlist),
          );
        },
      ),
    );
  }

  /// Builds empty state when no playlists exist.
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
              Icons.queue_music,
              size: 120,
              color: colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Playlists Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first playlist to organize your favorite healing frequencies',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _showCreatePlaylistDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Playlist'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds empty search state.
  Widget _buildEmptySearch(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No playlists found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows create playlist dialog.
  void _showCreatePlaylistDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const CreatePlaylistDialog(),
    );
  }

  /// Shows search dialog.
  void _showSearchDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Playlists'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter playlist name...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Navigates to playlist detail screen.
  void _navigateToPlaylistDetail(BuildContext context, Playlist playlist) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistDetailScreen(
          playlistId: playlist.id,
          onNavigateToPlayer: widget.onNavigateToPlayer,
        ),
      ),
    );
  }

  /// Confirms playlist deletion.
  Future<void> _confirmDeletePlaylist(
    BuildContext context,
    Playlist playlist,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Playlist?'),
        content: Text(
          'Are you sure you want to delete "${playlist.name}"? '
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

    if (confirmed == true && mounted) {
      try {
        await ref.read(deletePlaylistProvider)(playlistId: playlist.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted "${playlist.name}"'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete playlist: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}

// -----------------------------------------------------------------------------
// Playlist Card Widget
// -----------------------------------------------------------------------------

/// Card widget for displaying a single playlist.
class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({
    required this.playlist,
    required this.onTap,
    required this.onDelete,
  });

  final Playlist playlist;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onDelete,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Playlist icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.queue_music,
                  size: 32,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),

              const Spacer(),

              // Playlist name
              Text(
                playlist.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Track count
              Text(
                '${playlist.trackIds.length} ${playlist.trackIds.length == 1 ? 'track' : 'tracks'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
