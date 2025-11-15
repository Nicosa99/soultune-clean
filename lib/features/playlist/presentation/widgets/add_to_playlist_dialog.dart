/// Add to Playlist Dialog Widget
///
/// Quick dialog for adding a track to one or more playlists.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soultune/features/playlist/presentation/providers/playlist_providers.dart';
import 'package:soultune/features/playlist/presentation/widgets/create_playlist_dialog.dart';
import 'package:soultune/shared/models/audio_file.dart';
import 'package:soultune/shared/models/playlist.dart';

/// Dialog for adding a track to playlists.
///
/// Shows all existing playlists with checkboxes and option to create new.
class AddToPlaylistDialog extends ConsumerStatefulWidget {
  /// Creates an [AddToPlaylistDialog].
  const AddToPlaylistDialog({
    super.key,
    required this.track,
  });

  /// The track to add to playlists.
  final AudioFile track;

  @override
  ConsumerState<AddToPlaylistDialog> createState() =>
      _AddToPlaylistDialogState();
}

class _AddToPlaylistDialogState extends ConsumerState<AddToPlaylistDialog> {
  final Set<String> _selectedPlaylistIds = {};
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final playlistsAsync = ref.watch(allPlaylistsProvider);
    final playlistsContainingTrackAsync =
        ref.watch(playlistsContainingTrackProvider(widget.track.id));

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Text('Add to Playlist'),
      content: SizedBox(
        width: double.maxFinite,
        child: playlistsAsync.when(
          data: (playlists) {
            return playlistsContainingTrackAsync.when(
              data: (containingPlaylists) {
                // Initialize selected playlists
                if (_selectedPlaylistIds.isEmpty) {
                  _selectedPlaylistIds.addAll(
                    containingPlaylists.map((p) => p.id),
                  );
                }

                if (playlists.isEmpty) {
                  return _buildEmptyState(context);
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Track info
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.music_note,
                        color: colorScheme.primary,
                      ),
                      title: Text(
                        widget.track.title,
                        style: theme.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: widget.track.artist != null
                          ? Text(
                              widget.track.artist!,
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                    ),

                    const Divider(),

                    // Playlist list
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: playlists.length,
                        itemBuilder: (context, index) {
                          final playlist = playlists[index];
                          final isSelected =
                              _selectedPlaylistIds.contains(playlist.id);

                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: _isProcessing
                                ? null
                                : (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedPlaylistIds.add(playlist.id);
                                      } else {
                                        _selectedPlaylistIds.remove(playlist.id);
                                      }
                                    });
                                  },
                            title: Text(playlist.name),
                            subtitle: Text(
                              '${playlist.trackIds.length} ${playlist.trackIds.length == 1 ? 'track' : 'tracks'}',
                            ),
                            secondary: Icon(
                              Icons.queue_music,
                              color: colorScheme.primary,
                            ),
                          );
                        },
                      ),
                    ),

                    const Divider(),

                    // Create new playlist button
                    TextButton.icon(
                      onPressed: _isProcessing
                          ? null
                          : () => _showCreatePlaylistDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Create New Playlist'),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Text('Error: $error'),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Text('Error: $error'),
        ),
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),

        // Save button
        FilledButton(
          onPressed: _isProcessing ? null : _saveChanges,
          child: _isProcessing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  /// Builds empty state when no playlists exist.
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.queue_music,
          size: 64,
          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
        const SizedBox(height: 16),
        Text(
          'No playlists yet',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Create your first playlist',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => _showCreatePlaylistDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Create Playlist'),
        ),
      ],
    );
  }

  /// Shows create playlist dialog.
  Future<void> _showCreatePlaylistDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => const CreatePlaylistDialog(),
    );

    // Refresh playlists after creation
    ref.invalidate(allPlaylistsProvider);
  }

  /// Saves changes to playlists.
  Future<void> _saveChanges() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Get current playlists containing this track
      final containingPlaylists =
          await ref.read(playlistsContainingTrackProvider(widget.track.id).future);
      final currentPlaylistIds = containingPlaylists.map((p) => p.id).toSet();

      // Determine which playlists to add to and remove from
      final toAdd = _selectedPlaylistIds.difference(currentPlaylistIds);
      final toRemove = currentPlaylistIds.difference(_selectedPlaylistIds);

      final addTrack = ref.read(addTrackToPlaylistProvider);
      final removeTrack = ref.read(removeTrackFromPlaylistProvider);

      // Add to new playlists
      for (final playlistId in toAdd) {
        await addTrack(
          playlistId: playlistId,
          trackId: widget.track.id,
        );
      }

      // Remove from unselected playlists
      for (final playlistId in toRemove) {
        await removeTrack(
          playlistId: playlistId,
          trackId: widget.track.id,
        );
      }

      if (mounted) {
        Navigator.pop(context);

        final message = toAdd.isEmpty && toRemove.isEmpty
            ? 'No changes made'
            : 'Updated playlists';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

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
