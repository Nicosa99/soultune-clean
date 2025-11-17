/// SoulTune Library Screen
///
/// Main library interface with tabbed navigation for Songs and Playlists.
/// Allows users to browse, search, and play music from their collection.
///
/// ## Features
///
/// - Tabbed interface (Songs, Playlists)
/// - List of all audio files with album art thumbnails
/// - Grid view of playlists with track counts
/// - Tap to play functionality
/// - Search bar for filtering
/// - Pull-to-refresh
/// - Scan for new music
/// - Create/manage playlists
/// - Empty state handling
/// - Beautiful Material 3 design
///
/// ## Usage
///
/// ```dart
/// LibraryScreen()
/// ```
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soultune/app/constants/frequencies.dart';
import 'package:soultune/features/player/presentation/providers/player_providers.dart';
import 'package:soultune/features/playlist/presentation/providers/playlist_providers.dart';
import 'package:soultune/features/playlist/presentation/screens/playlist_detail_screen.dart';
import 'package:soultune/features/playlist/presentation/widgets/add_to_playlist_dialog.dart';
import 'package:soultune/features/playlist/presentation/widgets/create_playlist_dialog.dart';
import 'package:soultune/shared/models/audio_file.dart';
import 'package:soultune/shared/models/playlist.dart';

/// Library screen displaying all audio files.
///
/// Main screen for browsing and selecting music to play.
class LibraryScreen extends ConsumerStatefulWidget {
  /// Creates a [LibraryScreen].
  const LibraryScreen({
    super.key,
    this.onNavigateToPlayer,
  });

  /// Callback to navigate to Now Playing screen.
  final VoidCallback? onNavigateToPlayer;

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  /// Tab controller for Songs and Playlists tabs.
  late TabController _tabController;

  /// Search query for filtering songs.
  String _songsSearchQuery = '';

  /// Search query for filtering playlists.
  String _playlistsSearchQuery = '';

  /// Whether a scan is in progress.
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Update UI when tab changes to show correct actions
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Library',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: _buildAppBarActions(context),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.music_note_outlined),
              text: 'Songs',
            ),
            Tab(
              icon: Icon(Icons.queue_music_outlined),
              text: 'Playlists',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSongsTab(context, theme, colorScheme),
          _buildPlaylistsTab(context, theme, colorScheme),
        ],
      ),
    );
  }

  /// Builds appropriate AppBar actions based on current tab.
  List<Widget> _buildAppBarActions(BuildContext context) {
    if (_tabController.index == 0) {
      // Songs tab actions
      return [
        IconButton(
          onPressed: () => _showSongsSearchDialog(context),
          icon: const Icon(Icons.search),
          tooltip: 'Search songs',
        ),
      ];
    } else {
      // Playlists tab actions
      return [
        IconButton(
          onPressed: () => _showCreatePlaylistDialog(context),
          icon: const Icon(Icons.add),
          tooltip: 'Create playlist',
        ),
        IconButton(
          onPressed: () => _showPlaylistsSearchDialog(context),
          icon: const Icon(Icons.search),
          tooltip: 'Search playlists',
        ),
      ];
    }
  }

  /// Builds the Songs tab content.
  Widget _buildSongsTab(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final libraryAsync = ref.watch(audioLibraryProvider);

    return libraryAsync.when(
      data: (files) {
        // Filter files based on search query
        final filteredFiles = _songsSearchQuery.isEmpty
            ? files
            : files.where((file) {
                final query = _songsSearchQuery.toLowerCase();
                final titleMatch = file.title.toLowerCase().contains(query);
                final artistMatch =
                    file.artist?.toLowerCase().contains(query) ?? false;
                return titleMatch || artistMatch;
              }).toList();

        if (filteredFiles.isEmpty && _songsSearchQuery.isNotEmpty) {
          return _buildEmptySearch(context);
        }

        if (filteredFiles.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(audioLibraryProvider);
          },
          child: ListView.builder(
            itemCount: filteredFiles.length,
            padding: const EdgeInsets.only(bottom: 152),
            itemBuilder: (context, index) {
              final audioFile = filteredFiles[index];
              return _AudioFileTile(
                audioFile: audioFile,
                onTap: () => _playAudioFile(audioFile),
                onLongPress: () => _showAddToPlaylistDialog(audioFile),
              );
            },
          ),
        );
      },
      loading: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading library...',
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
              'Failed to load library',
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
    );
  }

  /// Builds the Playlists tab content.
  Widget _buildPlaylistsTab(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final playlistsAsync = ref.watch(allPlaylistsProvider);

    return playlistsAsync.when(
      data: (playlists) {
        // Filter playlists based on search query
        final filteredPlaylists = _playlistsSearchQuery.isEmpty
            ? playlists
            : playlists.where((playlist) {
                final query = _playlistsSearchQuery.toLowerCase();
                final nameMatch = playlist.name.toLowerCase().contains(query);
                final descMatch =
                    playlist.description?.toLowerCase().contains(query) ??
                        false;
                return nameMatch || descMatch;
              }).toList();

        if (filteredPlaylists.isEmpty && _playlistsSearchQuery.isNotEmpty) {
          return _buildEmptyPlaylistSearch(context);
        }

        if (filteredPlaylists.isEmpty) {
          return _buildEmptyPlaylistsState(context);
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
    );
  }

  /// Builds the playlist grid.
  Widget _buildPlaylistGrid(BuildContext context, List<Playlist> playlists) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 152),
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

  /// Builds empty state when no files in library.
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
              size: 120,
              color: colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Music Found',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap "Scan for Music" to find audio files on your device',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _scanForMusic(),
              icon: const Icon(Icons.refresh),
              label: const Text('Scan for Music'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds empty search results state for songs.
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
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No results for "$_songsSearchQuery"',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds empty search results state for playlists.
  Widget _buildEmptyPlaylistSearch(BuildContext context) {
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

  /// Builds empty state when no playlists exist.
  Widget _buildEmptyPlaylistsState(BuildContext context) {
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
              'Create your first playlist to organize your favorite healing '
              'frequencies',
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

  /// Shows search dialog for songs.
  void _showSongsSearchDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Songs'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter title or artist...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              _songsSearchQuery = value;
            });
          },
          onSubmitted: (_) {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _songsSearchQuery = '';
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  /// Shows search dialog for playlists.
  void _showPlaylistsSearchDialog(BuildContext context) {
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
              _playlistsSearchQuery = value;
            });
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _playlistsSearchQuery = '';
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

  /// Shows create playlist dialog.
  void _showCreatePlaylistDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const CreatePlaylistDialog(),
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

  /// Scans device for music files.
  Future<void> _scanForMusic() async {
    setState(() {
      _isScanning = true;
    });

    try {
      final messenger = ScaffoldMessenger.of(context);

      // Show progress dialog
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const _ScanProgressDialog(),
      );

      // Start scan
      final newFilesCount = await ref.read(scanLibraryActionProvider)();

      // Close progress dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // Show result
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            newFilesCount > 0
                ? 'Added $newFilesCount new tracks'
                : 'No new tracks found',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scan failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  /// Plays an audio file and navigates to Now Playing screen.
  Future<void> _playAudioFile(AudioFile audioFile) async {
    try {
      // Get all files from library
      final libraryAsync = ref.read(audioLibraryProvider);
      final allFiles = libraryAsync.value ?? [];

      // Get current pitch shift (frequency setting)
      final currentPitch = ref.read(currentPitchShiftProvider);

      // Find the index of the clicked file
      final index = allFiles.indexWhere((file) => file.id == audioFile.id);

      if (index == -1 || allFiles.isEmpty) {
        // Fallback to single file play if not found
        await ref.read(playAudioProvider.notifier).play(
              audioFile,
              pitchShift: currentPitch,
            );
      } else {
        // Play with entire library as playlist
        final playWithPlaylist = ref.read(playWithPlaylistProvider);
        await playWithPlaylist(allFiles, index, pitchShift: currentPitch);
      }

      // Navigate to Now Playing tab (using callback from HomeScreen)
      widget.onNavigateToPlayer?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to play: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Shows add to playlist dialog.
  void _showAddToPlaylistDialog(AudioFile audioFile) {
    showDialog<void>(
      context: context,
      builder: (context) => AddToPlaylistDialog(track: audioFile),
    );
  }
}

/// Scan progress dialog.
class _ScanProgressDialog extends StatelessWidget {
  const _ScanProgressDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Scanning for music...',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a minute',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Audio file list tile.
class _AudioFileTile extends StatelessWidget {
  const _AudioFileTile({
    required this.audioFile,
    required this.onTap,
    this.onLongPress,
  });

  final AudioFile audioFile;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      leading: _buildAlbumArt(colorScheme),
      title: Text(
        audioFile.title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            audioFile.artist ?? 'Unknown Artist',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            audioFile.formattedDuration,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
      trailing: Icon(
        Icons.play_circle_outline,
        size: 32,
        color: colorScheme.primary,
      ),
    );
  }

  /// Builds album art thumbnail or placeholder.
  Widget _buildAlbumArt(ColorScheme colorScheme) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: colorScheme.surfaceContainerHighest,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: audioFile.albumArt != null &&
                File(audioFile.albumArt!).existsSync()
            ? Image.file(
                File(audioFile.albumArt!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(colorScheme),
              )
            : _buildPlaceholder(colorScheme),
      ),
    );
  }

  /// Builds placeholder icon.
  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Icon(
      Icons.music_note,
      size: 32,
      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
    );
  }
}

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
                '${playlist.trackIds.length} '
                '${playlist.trackIds.length == 1 ? 'track' : 'tracks'}',
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
