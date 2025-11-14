/// SoulTune Now Playing Screen
///
/// Main playback screen showcasing the 432Hz healing frequency transformation.
/// Combines all player widgets into a beautiful, cohesive Material 3 interface.
///
/// ## Features
///
/// - Large album artwork with hero animation
/// - Track title and artist display
/// - Real-time seek bar with time display
/// - Player controls (play/pause, skip)
/// - Frequency selector (432Hz, 528Hz, 639Hz) ✨
/// - Beautiful gradient background
/// - Responsive layout for all screen sizes
/// - Smooth animations and transitions
///
/// ## Usage
///
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
/// );
/// ```
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soultune/features/player/presentation/providers/player_providers.dart';
import 'package:soultune/features/player/presentation/widgets/frequency_selector.dart';
import 'package:soultune/features/player/presentation/widgets/player_controls.dart';
import 'package:soultune/features/player/presentation/widgets/seek_bar.dart';

/// Now Playing screen - main playback interface.
///
/// Displays currently playing track with full player controls and
/// frequency transformation options.
class NowPlayingScreen extends ConsumerWidget {
  /// Creates a [NowPlayingScreen].
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFile = ref.watch(currentAudioFileProvider);
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Gradient background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerLow,
              colorScheme.surfaceContainerHigh,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              _buildAppBar(context, ref, currentFile?.title ?? 'SoulTune'),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Album art
                      _buildAlbumArt(
                        context,
                        currentFile?.albumArt,
                        currentFile?.title,
                      ),

                      const SizedBox(height: 32),

                      // Track info
                      _buildTrackInfo(
                        context,
                        currentFile?.title ?? 'No Track Playing',
                        currentFile?.artist ?? 'Unknown Artist',
                      ),

                      const SizedBox(height: 40),

                      // Seek bar
                      const SeekBar(),

                      const SizedBox(height: 32),

                      // Player controls
                      const PlayerControls(),

                      const SizedBox(height: 48),

                      // Frequency selector (THE STAR!)
                      const FrequencySelector(),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the app bar with back button and menu.
  Widget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    String title,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.keyboard_arrow_down),
            iconSize: 32,
            tooltip: 'Close',
          ),

          // Title
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Menu button
          IconButton(
            onPressed: () {
              // TODO: Show menu (add to favorites, share, etc.)
            },
            icon: const Icon(Icons.more_vert),
            tooltip: 'More options',
          ),
        ],
      ),
    );
  }

  /// Builds the album artwork section.
  Widget _buildAlbumArt(
    BuildContext context,
    String? albumArtPath,
    String? title,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Hero(
      tag: 'album_art_${title ?? "default"}',
      child: Container(
        width: 320,
        height: 320,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: albumArtPath != null && File(albumArtPath).existsSync()
              ? Image.file(
                  File(albumArtPath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholderArt(theme),
                )
              : _buildPlaceholderArt(theme),
        ),
      ),
    );
  }

  /// Builds placeholder album art.
  Widget _buildPlaceholderArt(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
            colorScheme.tertiaryContainer,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.music_note,
          size: 120,
          color: colorScheme.onPrimaryContainer.withOpacity(0.5),
        ),
      ),
    );
  }

  /// Builds track title and artist info.
  Widget _buildTrackInfo(
    BuildContext context,
    String title,
    String artist,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // Title
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Artist
          Text(
            artist,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
