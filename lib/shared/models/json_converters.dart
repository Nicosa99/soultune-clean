/// JSON converters for Freezed models.
///
/// Provides type converters for Duration and DateTime to enable
/// JSON serialization for Hive storage.
library;

import 'package:json_annotation/json_annotation.dart';

/// JSON converter for [Duration] type.
///
/// Stores duration as microseconds integer for compact storage.
class DurationConverter implements JsonConverter<Duration, int> {
  /// Creates a [DurationConverter].
  const DurationConverter();

  @override
  Duration fromJson(int json) => Duration(microseconds: json);

  @override
  int toJson(Duration object) => object.inMicroseconds;
}

/// JSON converter for [DateTime] type.
///
/// Stores DateTime as milliseconds since epoch.
class DateTimeConverter implements JsonConverter<DateTime, int> {
  /// Creates a [DateTimeConverter].
  const DateTimeConverter();

  @override
  DateTime fromJson(int json) => DateTime.fromMillisecondsSinceEpoch(json);

  @override
  int toJson(DateTime object) => object.millisecondsSinceEpoch;
}
