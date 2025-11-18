/// Gateway Protocol Progress Model
///
/// Tracks user progress through the 8-week Gateway Program.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'gateway_progress.freezed.dart';
part 'gateway_progress.g.dart';

/// Gateway protocol progress tracking.
///
/// 8-week program structure:
/// - Week 1-2: Focus 10 (Body Asleep, Mind Awake)
/// - Week 3-4: Focus 12 (Expanded Awareness)
/// - Week 5-6: Focus 15 (No Time)
/// - Week 7-8: Focus 21 (Other Energy Systems)
@freezed
class GatewayProgress with _$GatewayProgress {
  /// Creates a [GatewayProgress].
  @HiveType(typeId: 11, adapterName: 'GatewayProgressImplAdapter')
  const factory GatewayProgress({
    /// Week 1-2 sessions completed (Focus 10).
    @HiveField(0) @Default(0) int week1Sessions,

    /// Week 3-4 sessions completed (Focus 12).
    @HiveField(1) @Default(0) int week3Sessions,

    /// Week 5-6 sessions completed (Focus 15).
    @HiveField(2) @Default(0) int week5Sessions,

    /// Week 7-8 sessions completed (Focus 21).
    @HiveField(3) @Default(0) int week7Sessions,

    /// Current week (1-8).
    @HiveField(4) @Default(1) int currentWeek,

    /// Whether the program is active.
    @HiveField(5) @Default(false) bool isActive,

    /// Program start date.
    @HiveField(6) DateTime? startedAt,

    /// Program completion date.
    @HiveField(7) DateTime? completedAt,
  }) = _GatewayProgress;

  /// Private constructor for adding custom getters.
  const GatewayProgress._();

  /// Creates a [GatewayProgress] from JSON.
  factory GatewayProgress.fromJson(Map<String, dynamic> json) =>
      _$GatewayProgressFromJson(json);

  /// Total sessions completed across all phases.
  int get totalSessions =>
      week1Sessions + week3Sessions + week5Sessions + week7Sessions;

  /// Overall progress (0.0 to 1.0).
  ///
  /// Based on 56 total sessions (14 per phase).
  double get overallProgress => totalSessions / 56.0;

  /// Current phase name.
  String get currentPhase {
    if (currentWeek <= 2) return 'Focus 10 - Body Asleep';
    if (currentWeek <= 4) return 'Focus 12 - Expanded Awareness';
    if (currentWeek <= 6) return 'Focus 15 - No Time';
    return 'Focus 21 - Gateway State';
  }

  /// Sessions for current week.
  int get currentWeekSessions {
    if (currentWeek <= 2) return week1Sessions;
    if (currentWeek <= 4) return week3Sessions;
    if (currentWeek <= 6) return week5Sessions;
    return week7Sessions;
  }

  /// Whether current phase is completed.
  bool get currentPhaseCompleted => currentWeekSessions >= 14;
}
