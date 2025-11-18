/// Achievement Model
///
/// Defines unlockable achievements for gamification.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement.freezed.dart';
part 'achievement.g.dart';

/// Achievement category.
enum AchievementCategory {
  /// Gateway Protocol milestones.
  gateway,

  /// Frequency usage achievements.
  frequency,

  /// Time-based achievements.
  time,

  /// Special/rare achievements.
  special,
}

/// An unlockable achievement.
///
/// Achievements provide gamification and progression tracking.
@freezed
class Achievement with _$Achievement {
  /// Creates an [Achievement].
  const factory Achievement({
    /// Unique identifier.
    required String id,

    /// Display icon (emoji).
    required String icon,

    /// Achievement title.
    required String title,

    /// Achievement description.
    required String description,

    /// Achievement category.
    required AchievementCategory category,

    /// Required count to unlock (e.g., 10 sessions).
    @Default(1) int requiredCount,

    /// Current progress count.
    @Default(0) int currentCount,

    /// Whether this achievement is unlocked.
    @Default(false) bool isUnlocked,

    /// Unlock date.
    DateTime? unlockedAt,
  }) = _Achievement;

  /// Private constructor for adding custom getters.
  const Achievement._();

  /// Creates an [Achievement] from JSON.
  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);

  /// Progress percentage (0-100).
  int get progress =>
      ((currentCount / requiredCount) * 100).clamp(0, 100).toInt();
}

/// Predefined achievements.
class Achievements {
  /// Private constructor.
  Achievements._();

  // Gateway Protocol Achievements
  static final gatewayInitiate = Achievement(
    id: 'gateway_initiate',
    icon: '🎓',
    title: 'Gateway Initiate',
    description: 'Complete your first Focus 10 session',
    category: AchievementCategory.gateway,
    requiredCount: 1,
  );

  static final focus10Master = Achievement(
    id: 'focus10_master',
    icon: '😴',
    title: 'Focus 10 Master',
    description: 'Complete all Focus 10 sessions',
    category: AchievementCategory.gateway,
    requiredCount: 14,
  );

  static final focus12Explorer = Achievement(
    id: 'focus12_explorer',
    icon: '🌌',
    title: 'Expanded Awareness',
    description: 'Complete all Focus 12 sessions',
    category: AchievementCategory.gateway,
    requiredCount: 14,
  );

  static final focus15Traveler = Achievement(
    id: 'focus15_traveler',
    icon: '⏰',
    title: 'Beyond Time',
    description: 'Complete all Focus 15 sessions',
    category: AchievementCategory.gateway,
    requiredCount: 14,
  );

  static final focus21Adept = Achievement(
    id: 'focus21_adept',
    icon: '🌟',
    title: 'Gateway Adept',
    description: 'Complete all Focus 21 sessions',
    category: AchievementCategory.gateway,
    requiredCount: 14,
  );

  // Frequency Achievements
  static final frequencyNovice = Achievement(
    id: 'frequency_novice',
    icon: '⚡',
    title: 'Frequency Novice',
    description: 'Complete 5 sessions',
    category: AchievementCategory.frequency,
    requiredCount: 5,
  );

  static final frequencyJourneyman = Achievement(
    id: 'frequency_journeyman',
    icon: '🔮',
    title: 'Frequency Journeyman',
    description: 'Complete 25 sessions',
    category: AchievementCategory.frequency,
    requiredCount: 25,
  );

  static final frequencyMaster = Achievement(
    id: 'frequency_master',
    icon: '🧠',
    title: 'Frequency Master',
    description: 'Complete 100 sessions',
    category: AchievementCategory.frequency,
    requiredCount: 100,
  );

  // Time Achievements
  static final earlyBird = Achievement(
    id: 'early_bird',
    icon: '🐦',
    title: 'Early Bird',
    description: 'Complete a session before 6 AM',
    category: AchievementCategory.time,
    requiredCount: 1,
  );

  static final nightOwl = Achievement(
    id: 'night_owl',
    icon: '🦉',
    title: 'Night Owl',
    description: 'Complete a session at 3 AM',
    category: AchievementCategory.time,
    requiredCount: 1,
  );

  static final dedicated = Achievement(
    id: 'dedicated',
    icon: '🔥',
    title: 'Dedicated',
    description: 'Maintain a 7-day streak',
    category: AchievementCategory.time,
    requiredCount: 7,
  );

  static final unstoppable = Achievement(
    id: 'unstoppable',
    icon: '💪',
    title: 'Unstoppable',
    description: 'Maintain a 30-day streak',
    category: AchievementCategory.time,
    requiredCount: 30,
  );

  // Special Achievements
  static final obePioneer = Achievement(
    id: 'obe_pioneer',
    icon: '👁️',
    title: 'OBE Pioneer',
    description: 'Log your first OBE experience',
    category: AchievementCategory.special,
    requiredCount: 1,
  );

  static final lucidExplorer = Achievement(
    id: 'lucid_explorer',
    icon: '💭',
    title: 'Lucid Explorer',
    description: 'Log a lucid dream experience',
    category: AchievementCategory.special,
    requiredCount: 1,
  );

  static final thetaMaster = Achievement(
    id: 'theta_master',
    icon: '🌊',
    title: 'Theta Master',
    description: 'Complete 10 theta frequency sessions',
    category: AchievementCategory.special,
    requiredCount: 10,
  );

  /// All achievements.
  static final List<Achievement> all = [
    // Gateway
    gatewayInitiate,
    focus10Master,
    focus12Explorer,
    focus15Traveler,
    focus21Adept,
    // Frequency
    frequencyNovice,
    frequencyJourneyman,
    frequencyMaster,
    // Time
    earlyBird,
    nightOwl,
    dedicated,
    unstoppable,
    // Special
    obePioneer,
    lucidExplorer,
    thetaMaster,
  ];

  /// Get achievements by category.
  static List<Achievement> byCategory(AchievementCategory category) {
    return all.where((a) => a.category == category).toList();
  }
}
