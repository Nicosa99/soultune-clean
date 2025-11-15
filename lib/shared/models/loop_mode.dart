/// SoulTune Loop Mode
///
/// Defines playback loop behavior for tracks and playlists.
library;

/// Loop mode for playback.
///
/// Controls how the player behaves when a track finishes playing.
enum LoopMode {
  /// No looping - play once and stop.
  ///
  /// When the last track in the playlist finishes, playback stops.
  off,

  /// Loop single track - repeat current track indefinitely.
  ///
  /// When the track finishes, it restarts from the beginning.
  /// Ignores playlist progression.
  one,

  /// Loop all tracks - repeat entire playlist.
  ///
  /// When the last track finishes, playback continues from the first track.
  /// Creates an infinite loop through the playlist.
  all,
}

/// Extension methods for [LoopMode].
extension LoopModeExtension on LoopMode {
  /// Human-readable name for this loop mode.
  String get displayName {
    switch (this) {
      case LoopMode.off:
        return 'Off';
      case LoopMode.one:
        return 'Loop One';
      case LoopMode.all:
        return 'Loop All';
    }
  }

  /// Icon for this loop mode.
  String get iconName {
    switch (this) {
      case LoopMode.off:
        return 'repeat_off';
      case LoopMode.one:
        return 'repeat_one';
      case LoopMode.all:
        return 'repeat';
    }
  }

  /// Gets the next loop mode in the cycle.
  ///
  /// Cycles through: Off → All → One → Off
  LoopMode get next {
    switch (this) {
      case LoopMode.off:
        return LoopMode.all;
      case LoopMode.all:
        return LoopMode.one;
      case LoopMode.one:
        return LoopMode.off;
    }
  }
}
