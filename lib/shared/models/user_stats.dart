/// User Statistics Model
///
/// Tracks gamification stats including sessions, hours, streaks, and level.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'user_stats.freezed.dart';
part 'user_stats.g.dart';

/// User statistics for gamification.
///
/// Tracks:
/// - Total sessions and hours
/// - Current streak and longest streak
/// - Level and XP progress
/// - Unlocked achievements
@freezed
class UserStats with _$UserStats {
  /// Creates a [UserStats].
  @HiveType(typeId: 10, adapterName: 'UserStatsImplAdapter')
  const factory UserStats({
    /// Total completed sessions.
    @HiveField(0) @Default(0) int totalSessions,

    /// Total hours of practice.
    @HiveField(1) @Default(0) int totalHours,

    /// Current daily streak.
    @HiveField(2) @Default(0) int currentStreak,

    /// Longest streak ever achieved.
    @HiveField(3) @Default(0) int longestStreak,

    /// Current level (starts at 1).
    @HiveField(4) @Default(1) int level,

    /// Current XP points.
    @HiveField(5) @Default(0) int xpCurrent,

    /// List of unlocked achievement IDs.
    @HiveField(6) @Default([]) List<String> unlockedAchievements,

    /// Last session date (for streak tracking).
    @HiveField(7) DateTime? lastSessionDate,
  }) = _UserStats;

  /// Private constructor for adding custom getters.
  const UserStats._();

  /// Creates a [UserStats] from JSON.
  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);

  /// XP required for next level.
  ///
  /// Formula: level * 100
  int get xpRequired => level * 100;

  /// Progress towards next level (0.0 to 1.0).
  double get levelProgress => xpCurrent / xpRequired;
}
