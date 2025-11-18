/// SoulTune Library Screen
///
/// Main library interface displaying all audio files.
/// Allows users to browse, search, and play music from their collection.
///
/// ## Features
///
/// - Tabbed interface: Songs, Folders, Favorites
/// - List of all audio files with album art thumbnails
/// - Folder-based browsing for organized music
/// - Favorites section for quick access
/// - Tap to play functionality
/// - Search bar for filtering
/// - Pull-to-refresh
/// - Floating action button to scan for new music
/// - Empty state when no files
/// - Loading state during scan
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
import 'package:soultune/features/playlist/presentation/widgets/add_to_playlist_dialog.dart';
import 'package:soultune/features/playlist/presentation/widgets/create_playlist_dialog.dart';
import 'package:soultune/shared/models/audio_file.dart';
import 'package:soultune/shared/models/playlist.dart';

/// Library screen displaying all audio files.
///
/// Main screen for browsing and selecting music to play.
/// Features tabbed navigation: Songs, Folders, Favorites.
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
  /// Search query for filtering files.
  String _searchQuery = '';

  /// Whether a scan is in progress.
  bool _isScanning = false;

  /// Tab controller for Songs/Folders/Artists/Favorites tabs.
  late TabController _tabController;

  /// Current folder path for folder navigation (null = root).
  String? _currentFolderPath;

  /// Current artist for artist navigation (null = all artists).
  String? _currentArtist;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
        actions: [
          // Search button
          IconButton(
            onPressed: () {
              _showSearchDialog(context);
            },
            icon: const Icon(Icons.search),
            tooltip: 'Search',
          ),
          // Scan button
          IconButton(
            onPressed: _scanForMusic,
            icon: const Icon(Icons.refresh),
            tooltip: 'Scan for Music',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, // Allow scrolling for 5 tabs
          tabAlignment: TabAlignment.start, // Align tabs to the left
          tabs: const [
            Tab(
              icon: Icon(Icons.music_note),
              text: 'Songs',
            ),
            Tab(
              icon: Icon(Icons.folder),
              text: 'Folders',
            ),
            Tab(
              icon: Icon(Icons.person),
              text: 'Artists',
            ),
            Tab(
              icon: Icon(Icons.queue_music),
              text: 'Playlists',
            ),
            Tab(
              icon: Icon(Icons.favorite),
              text: 'Favorites',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Songs Tab
          _buildSongsTab(),

          // Folders Tab
          _buildFoldersTab(),

          // Artists Tab
          _buildArtistsTab(),

          // Playlists Tab
          _buildPlaylistsTab(),

          // Favorites Tab
          _buildFavoritesTab(),
        ],
      ),
    );
  }

  /// Builds the Songs tab content.
  Widget _buildSongsTab() {
    final libraryAsync = ref.watch(audioLibraryProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return libraryAsync.when(
      data: (files) {
        // Filter files based on search query
        final filteredFiles = _searchQuery.isEmpty
            ? files
            : files.where((file) {
                final query = _searchQuery.toLowerCase();
                final titleMatch = file.title.toLowerCase().contains(query);
                final artistMatch =
                    file.artist?.toLowerCase().contains(query) ?? false;
                return titleMatch || artistMatch;
              }).toList();

        if (filteredFiles.isEmpty && _searchQuery.isNotEmpty) {
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
            padding: const EdgeInsets.only(
                bottom: 152), // Nav bar (80) + Mini player (72)
            itemBuilder: (context, index) {
              final audioFile = filteredFiles[index];
              return _AudioFileTile(
                audioFile: audioFile,
                onTap: () => _playAudioFile(audioFile),
                onLongPress: () => _showAddToPlaylistDialog(audioFile),
                onFavoriteToggle: () => _toggleFavorite(audioFile),
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

  /// Builds the Folders tab content.
  Widget _buildFoldersTab() {
    final libraryAsync = ref.watch(audioLibraryProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return libraryAsync.when(
      data: (files) {
        if (files.isEmpty) {
          return _buildEmptyState(context);
        }

        // Group files by folder
        final folderMap = <String, List<AudioFile>>{};
        for (final file in files) {
          final folderPath = _getFolderPath(file.filePath);
          folderMap.putIfAbsent(folderPath, () => []).add(file);
        }

        // If we're in a specific folder, show its contents
        if (_currentFolderPath != null) {
          final folderFiles = folderMap[_currentFolderPath] ?? [];
          return Column(
            children: [
              // Back button
              ListTile(
                leading: const Icon(Icons.arrow_back),
                title: Text(
                  'Back to Folders',
                  style: theme.textTheme.titleMedium,
                ),
                onTap: () {
                  setState(() {
                    _currentFolderPath = null;
                  });
                },
              ),
              const Divider(),
              // Folder contents
              Expanded(
                child: ListView.builder(
                  itemCount: folderFiles.length,
                  padding: const EdgeInsets.only(bottom: 152),
                  itemBuilder: (context, index) {
                    final audioFile = folderFiles[index];
                    return _AudioFileTile(
                      audioFile: audioFile,
                      onTap: () => _playAudioFile(audioFile),
                      onLongPress: () => _showAddToPlaylistDialog(audioFile),
                      onFavoriteToggle: () => _toggleFavorite(audioFile),
                    );
                  },
                ),
              ),
            ],
          );
        }

        // Show folder list
        final folders = folderMap.keys.toList()..sort();

        return ListView.builder(
          itemCount: folders.length,
          padding: const EdgeInsets.only(bottom: 152),
          itemBuilder: (context, index) {
            final folderPath = folders[index];
            final folderName = _getFolderName(folderPath);
            final fileCount = folderMap[folderPath]?.length ?? 0;

            return ListTile(
              leading: Icon(
                Icons.folder,
                size: 40,
                color: colorScheme.primary,
              ),
              title: Text(
                folderName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '$fileCount ${fileCount == 1 ? 'song' : 'songs'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                setState(() {
                  _currentFolderPath = folderPath;
                });
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  /// Builds the Artists tab content.
  Widget _buildArtistsTab() {
    final libraryAsync = ref.watch(audioLibraryProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return libraryAsync.when(
      data: (files) {
        if (files.isEmpty) {
          return _buildEmptyState(context);
        }

        // Group files by artist
        final artistMap = <String, List<AudioFile>>{};
        for (final file in files) {
          final artistName = file.artist ?? 'Unknown Artist';
          artistMap.putIfAbsent(artistName, () => []).add(file);
        }

        // If we're viewing a specific artist, show their songs
        if (_currentArtist != null) {
          final artistFiles = artistMap[_currentArtist] ?? [];
          return Column(
            children: [
              // Back button
              ListTile(
                leading: const Icon(Icons.arrow_back),
                title: Text(
                  'Back to Artists',
                  style: theme.textTheme.titleMedium,
                ),
                onTap: () {
                  setState(() {
                    _currentArtist = null;
                  });
                },
              ),
              const Divider(),
              // Artist's songs
              Expanded(
                child: ListView.builder(
                  itemCount: artistFiles.length,
                  padding: const EdgeInsets.only(bottom: 152),
                  itemBuilder: (context, index) {
                    final audioFile = artistFiles[index];
                    return _AudioFileTile(
                      audioFile: audioFile,
                      onTap: () => _playAudioFile(audioFile),
                      onFavoriteToggle: () => _toggleFavorite(audioFile),
                    );
                  },
                ),
              ),
            ],
          );
        }

        // Show artist list
        final artists = artistMap.keys.toList()..sort();

        return ListView.builder(
          itemCount: artists.length,
          padding: const EdgeInsets.only(bottom: 152),
          itemBuilder: (context, index) {
            final artistName = artists[index];
            final songCount = artistMap[artistName]?.length ?? 0;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              title: Text(
                artistName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '$songCount ${songCount == 1 ? 'song' : 'songs'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                setState(() {
                  _currentArtist = artistName;
                });
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  /// Builds the Favorites tab content.
  Widget _buildFavoritesTab() {
    final libraryAsync = ref.watch(audioLibraryProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return libraryAsync.when(
      data: (files) {
        // Filter only favorites
        final favoriteFiles =
            files.where((file) => file.isFavorite).toList();

        if (favoriteFiles.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Favorites Yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Long-press a song and add to favorites',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: favoriteFiles.length,
          padding: const EdgeInsets.only(bottom: 152),
          itemBuilder: (context, index) {
            final audioFile = favoriteFiles[index];
            return _AudioFileTile(
              audioFile: audioFile,
              onTap: () => _playAudioFile(audioFile),
              onLongPress: () => _showAddToPlaylistDialog(audioFile),
              onFavoriteToggle: () => _toggleFavorite(audioFile),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  /// Builds the Playlists tab content.
  Widget _buildPlaylistsTab() {
    final playlistsAsync = ref.watch(playlistsStreamProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return playlistsAsync.when(
      data: (playlists) {
        if (playlists.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.queue_music_outlined,
                    size: 80,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Playlists Yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a playlist to organize your music',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _showCreatePlaylistDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Playlist'),
                  ),
                ],
              ),
            ),
          );
        }

        return Stack(
          children: [
            ListView.builder(
              itemCount: playlists.length,
              padding: const EdgeInsets.only(bottom: 152),
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return _PlaylistTile(
                  playlist: playlist,
                  onTap: () => _showPlaylistDetail(playlist),
                  onDelete: () => _deletePlaylist(playlist),
                );
              },
            ),
            // Floating action button
            Positioned(
              right: 16,
              bottom: 160,
              child: FloatingActionButton(
                onPressed: _showCreatePlaylistDialog,
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  /// Shows create playlist dialog.
  void _showCreatePlaylistDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => const CreatePlaylistDialog(),
    );
  }

  /// Shows playlist detail (tracks in playlist).
  void _showPlaylistDetail(Playlist playlist) {
    // Show a bottom sheet with playlist tracks
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _PlaylistDetailSheet(
          playlist: playlist,
          scrollController: scrollController,
          onPlayTrack: _playAudioFile,
        ),
      ),
    );
  }

  /// Deletes a playlist.
  Future<void> _deletePlaylist(Playlist playlist) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Playlist?'),
        content: Text('Are you sure you want to delete "${playlist.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
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
              content: Text('Failed to delete: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  /// Gets the folder path from a file path.
  String _getFolderPath(String filePath) {
    final lastSlash = filePath.lastIndexOf('/');
    if (lastSlash == -1) return '/';
    return filePath.substring(0, lastSlash);
  }

  /// Gets the folder display name from a folder path.
  String _getFolderName(String folderPath) {
    final parts = folderPath.split('/');
    // Return the last meaningful part
    for (var i = parts.length - 1; i >= 0; i--) {
      if (parts[i].isNotEmpty) {
        return parts[i];
      }
    }
    return 'Root';
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

  /// Builds empty search results state.
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
              'No results for "$_searchQuery"',
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

  /// Shows search dialog.
  void _showSearchDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Library'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter title or artist...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
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
                _searchQuery = '';
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
      // Ensure PlayerRepository is initialized first
      // This prevents the "first click does nothing" bug
      final repository = await ref.read(playerRepositoryProvider.future);

      // Get current pitch shift (frequency setting)
      final currentPitch = ref.read(currentPitchShiftProvider);

      // Get all files directly from repository (more reliable than StreamProvider)
      final allFiles = await repository.getAllAudioFiles();

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

  /// Toggles favorite status for an audio file.
  Future<void> _toggleFavorite(AudioFile audioFile) async {
    try {
      await ref.read(toggleFavoriteActionProvider)(audioFile.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              audioFile.isFavorite
                  ? 'Removed from favorites'
                  : 'Added to favorites',
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorite: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
    this.onFavoriteToggle,
    this.showFavoriteIcon = false,
  });

  final AudioFile audioFile;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onFavoriteToggle;
  final bool showFavoriteIcon;

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
      trailing: onFavoriteToggle != null
          ? IconButton(
              onPressed: onFavoriteToggle,
              icon: Icon(
                audioFile.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: audioFile.isFavorite
                    ? colorScheme.error
                    : colorScheme.onSurfaceVariant,
              ),
              tooltip: audioFile.isFavorite
                  ? 'Remove from favorites'
                  : 'Add to favorites',
            )
          : showFavoriteIcon
              ? Icon(
                  Icons.favorite,
                  size: 24,
                  color: colorScheme.error,
                )
              : null,
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

/// Playlist list tile.
class _PlaylistTile extends StatelessWidget {
  const _PlaylistTile({
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

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.queue_music,
          size: 28,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(
        playlist.name,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${playlist.trackIds.length} '
        '${playlist.trackIds.length == 1 ? 'song' : 'songs'}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: IconButton(
        onPressed: onDelete,
        icon: Icon(
          Icons.delete_outline,
          color: colorScheme.error,
        ),
        tooltip: 'Delete playlist',
      ),
    );
  }
}

/// Playlist detail bottom sheet.
class _PlaylistDetailSheet extends ConsumerWidget {
  const _PlaylistDetailSheet({
    required this.playlist,
    required this.scrollController,
    required this.onPlayTrack,
  });

  final Playlist playlist;
  final ScrollController scrollController;
  final Future<void> Function(AudioFile) onPlayTrack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final libraryAsync = ref.watch(audioLibraryProvider);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.queue_music,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${playlist.trackIds.length} songs',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Track list
          Expanded(
            child: libraryAsync.when(
              data: (allFiles) {
                if (playlist.trackIds.isEmpty) {
                  return Center(
                    child: Text(
                      'No songs in this playlist',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                // Get tracks in playlist order
                final tracks = <AudioFile>[];
                for (final trackId in playlist.trackIds) {
                  final track = allFiles.firstWhere(
                    (f) => f.id == trackId,
                    orElse: () => allFiles.first,
                  );
                  if (allFiles.any((f) => f.id == trackId)) {
                    tracks.add(track);
                  }
                }

                return ListView.builder(
                  controller: scrollController,
                  itemCount: tracks.length,
                  itemBuilder: (context, index) {
                    final track = tracks[index];
                    return _AudioFileTile(
                      audioFile: track,
                      onTap: () {
                        Navigator.pop(context);
                        onPlayTrack(track);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
