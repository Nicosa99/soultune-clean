/// SoulTune Mini Player Widget
///
/// Compact persistent player bar shown at bottom of screen (above nav bar).
/// Provides quick access to playback controls and current track info.
///
/// ## Features
///
/// - Shows currently playing track + artist
/// - Play/pause button
/// - Album artwork thumbnail
/// - Tap to expand to full Now Playing screen
/// - Smooth slide-up animation
/// - Material 3 design
/// - Hero animation for album art
///
/// ## Usage
///
/// ```dart
/// MiniPlayer(
///   onTap: () => _showNowPlayingModal(),
/// )
/// ```
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soultune/features/player/presentation/providers/player_providers.dart';

/// Mini player widget for persistent playback control.
///
/// Displays at bottom of screen (above navigation bar) when audio is playing.
/// Tapping expands to full Now Playing screen via modal.
class MiniPlayer extends ConsumerWidget {
  /// Creates a [MiniPlayer].
  const MiniPlayer({
    super.key,
    required this.onTap,
  });

  /// Callback when mini player is tapped (expand to full player).
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFile = ref.watch(currentAudioFileProvider);
    final isPlayingAsync = ref.watch(isPlayingProvider);
    final pitchShift = ref.watch(currentPitchShiftProvider);

    // Don't show if no audio playing
    if (currentFile == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPlaying = isPlayingAsync.valueOrNull ?? false;

    return Material(
      elevation: 8,
      shadowColor: colorScheme.shadow.withOpacity(0.4),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant,
              width: 1,
            ),
          ),
        ),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Album art with Hero animation
                Hero(
                  tag: 'album_art_${currentFile.id}',
                  child: _buildAlbumArt(context, currentFile),
                ),

                const SizedBox(width: 12),

                // Track info (title + artist)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Track title
                      Text(
                        currentFile.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 2),

                      // Artist + Frequency badge
                      Row(
                        children: [
                          // Artist name
                          Flexible(
                            child: Text(
                              currentFile.artist ?? 'Unknown Artist',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Frequency indicator
                          if (pitchShift != 0.0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getFrequencyLabel(pitchShift),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Play/Pause button
                IconButton(
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    await ref.read(togglePlayPauseProvider)();
                  },
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      key: ValueKey<bool>(isPlaying),
                      size: 32,
                    ),
                  ),
                  iconSize: 32,
                  color: colorScheme.primary,
                  tooltip: isPlaying ? 'Pause' : 'Play',
                ),

                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds album art thumbnail.
  Widget _buildAlbumArt(BuildContext context, currentFile) {
    final colorScheme = Theme.of(context).colorScheme;

    if (currentFile.albumArt != null &&
        File(currentFile.albumArt!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          File(currentFile.albumArt!),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAlbumArt(context);
          },
        ),
      );
    }

    return _buildDefaultAlbumArt(context);
  }

  /// Builds default album art icon.
  Widget _buildDefaultAlbumArt(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        Icons.music_note,
        size: 28,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }

  /// Gets frequency label from pitch shift value.
  String _getFrequencyLabel(double pitchShift) {
    if ((pitchShift - (-0.31767)).abs() < 0.01) {
      return '432Hz';
    } else if ((pitchShift - 0.37851).abs() < 0.01) {
      return '528Hz';
    } else if ((pitchShift - 0.69877).abs() < 0.01) {
      return '639Hz';
    }
    return '440Hz';
  }
}
