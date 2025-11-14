/// SoulTune Player Controls Widget
///
/// Material 3 playback controls for the audio player.
/// Provides play/pause, skip, and playback control buttons.
///
/// ## Features
///
/// - Large centered play/pause button with smooth animation
/// - Skip forward/backward buttons (10 seconds)
/// - Material 3 filled tonal button design
/// - Haptic feedback on button press
/// - Responsive sizing for different screens
/// - Accessibility support
///
/// ## Usage
///
/// ```dart
/// PlayerControls()
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soultune/features/player/presentation/providers/player_providers.dart';

/// Player controls widget with play/pause and skip buttons.
///
/// Automatically updates based on playback state using Riverpod.
class PlayerControls extends ConsumerWidget {
  /// Creates a [PlayerControls] widget.
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(isPlayingProvider);
    final currentFile = ref.watch(currentAudioFileProvider);
    

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Disable controls if no audio file loaded
    final hasAudio = currentFile != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Skip backward button (10 seconds)
        IconButton(
          onPressed: hasAudio
              ? () {
                  HapticFeedback.lightImpact();
                  _skipBackward(ref);
                }
              : null,
          icon: const Icon(Icons.replay_10),
          iconSize: 32,
          tooltip: 'Skip backward 10 seconds',
        ),

        const SizedBox(width: 16),

        // Play/Pause button (large, centered)
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasAudio
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            boxShadow: hasAudio
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: hasAudio
                  ? () async {
                      HapticFeedback.mediumImpact();
                      await ref.read(togglePlayPauseProvider)();
                    }
                  : null,
              borderRadius: BorderRadius.circular(36),
              child: Center(
                child: AnimatedSwitcher(
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
                    size: 40,
                    color: hasAudio
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Skip forward button (10 seconds)
        IconButton(
          onPressed: hasAudio
              ? () {
                  HapticFeedback.lightImpact();
                  _skipForward(ref);
                }
              : null,
          icon: const Icon(Icons.forward_10),
          iconSize: 32,
          tooltip: 'Skip forward 10 seconds',
        ),
      ],
    );
  }

  /// Skips backward 10 seconds.
  void _skipBackward(WidgetRef ref) {
    final repository = ref.read(playerRepositoryProvider).value;
    if (repository == null) return;

    final currentPosition = repository.position;
    final newPosition = Duration(
      milliseconds: (currentPosition.inMilliseconds - 10000).clamp(0, double.infinity).toInt(),
    );

    ref.read(seekToProvider)(newPosition);
  }

  /// Skips forward 10 seconds.
  void _skipForward(WidgetRef ref) {
    final repository = ref.read(playerRepositoryProvider).value;
    if (repository == null) return;

    final currentPosition = repository.position;
    final duration = repository.duration ?? Duration.zero;
    final newPosition = Duration(
      milliseconds: (currentPosition.inMilliseconds + 10000)
          .clamp(0, duration.inMilliseconds)
          .toInt(),
    );

    ref.read(seekToProvider)(newPosition);
  }
}
