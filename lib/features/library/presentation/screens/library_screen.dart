/// SoulTune Library Screen
///
/// Main library interface displaying all audio files.
/// Allows users to browse, search, and play music from their collection.
///
/// ## Features
///
/// - List of all audio files with album art thumbnails
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
import 'package:soultune/features/playlist/presentation/widgets/add_to_playlist_dialog.dart';
import 'package:soultune/shared/models/audio_file.dart';

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

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  /// Search query for filtering files.
  String _searchQuery = '';

  /// Whether a scan is in progress.
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    final libraryAsync = ref.watch(audioLibraryProvider);

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
        ],
      ),
      body: libraryAsync.when(
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
              padding: const EdgeInsets.only(bottom: 80),
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
      // Play with default 432Hz transformation
      await ref.read(playAudioProvider.notifier).play(
            audioFile,
            pitchShift: kPitch432Hz,
          );

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

  /// Shows add to playlist dialog.
  void _showAddToPlaylistDialog(AudioFile audioFile) {
    showDialog<void>(
      context: context,
      builder: (context) => AddToPlaylistDialog(track: audioFile),
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
