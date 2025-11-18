/// Hive TypeAdapters for SoulTune Models
///
/// Manual TypeAdapter implementations for storing Freezed models in Hive.
/// These adapters leverage the existing JSON serialization from Freezed
/// for clean, maintainable code without code-generation conflicts.
///
/// ## Type IDs
///
/// - 0: FrequencySetting
/// - 1: AudioFile
/// - 2: Playlist
/// - 3: FrequencyPreset
/// - 10: UserStats
/// - 11: GatewayProgress
/// - 12: JournalEntry
///
/// ## Usage
///
/// Register all adapters during app initialization:
///
/// ```dart
/// void main() async {
///   await Hive.initFlutter();
///
///   // Register adapters
///   Hive.registerAdapter(FrequencySettingAdapter());
///   Hive.registerAdapter(AudioFileAdapter());
///   Hive.registerAdapter(PlaylistAdapter());
///   Hive.registerAdapter(FrequencyPresetAdapter());
///
///   runApp(MyApp());
/// }
/// ```
library;

import 'package:hive/hive.dart';
import 'package:soultune/features/generator/data/models/frequency_preset.dart';
import 'package:soultune/shared/models/audio_file.dart';
import 'package:soultune/shared/models/frequency_setting.dart';
import 'package:soultune/shared/models/gateway_progress.dart';
import 'package:soultune/shared/models/journal_entry.dart';
import 'package:soultune/shared/models/playlist.dart';
import 'package:soultune/shared/models/user_stats.dart';

// -----------------------------------------------------------------------------
// FrequencySetting TypeAdapter (TypeId: 0)
// -----------------------------------------------------------------------------

/// Hive TypeAdapter for [FrequencySetting].
///
/// Serializes FrequencySetting objects to/from JSON for Hive storage.
/// Uses the auto-generated toJson/fromJson methods from Freezed.
class FrequencySettingAdapter extends TypeAdapter<FrequencySetting> {
  @override
  final int typeId = 0;

  @override
  FrequencySetting read(BinaryReader reader) {
    final json = reader.readMap().cast<String, dynamic>();
    return FrequencySetting.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, FrequencySetting obj) {
    writer.writeMap(obj.toJson());
  }
}

// -----------------------------------------------------------------------------
// AudioFile TypeAdapter (TypeId: 1)
// -----------------------------------------------------------------------------

/// Hive TypeAdapter for [AudioFile].
///
/// Serializes AudioFile objects to/from JSON for Hive storage.
/// Uses the auto-generated toJson/fromJson methods from Freezed.
class AudioFileAdapter extends TypeAdapter<AudioFile> {
  @override
  final int typeId = 1;

  @override
  AudioFile read(BinaryReader reader) {
    final json = reader.readMap().cast<String, dynamic>();
    return AudioFile.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, AudioFile obj) {
    writer.writeMap(obj.toJson());
  }
}

// -----------------------------------------------------------------------------
// Playlist TypeAdapter (TypeId: 2)
// -----------------------------------------------------------------------------

/// Hive TypeAdapter for [Playlist].
///
/// Serializes Playlist objects to/from JSON for Hive storage.
/// Uses the auto-generated toJson/fromJson methods from Freezed.
class PlaylistAdapter extends TypeAdapter<Playlist> {
  @override
  final int typeId = 2;

  @override
  Playlist read(BinaryReader reader) {
    final json = reader.readMap().cast<String, dynamic>();
    return Playlist.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, Playlist obj) {
    writer.writeMap(obj.toJson());
  }
}

// -----------------------------------------------------------------------------
// FrequencyPreset TypeAdapter (TypeId: 3)
// -----------------------------------------------------------------------------

/// Hive TypeAdapter for [FrequencyPreset].
///
/// Serializes FrequencyPreset objects to/from JSON for Hive storage.
/// Uses the auto-generated toJson/fromJson methods from Freezed.
class FrequencyPresetAdapter extends TypeAdapter<FrequencyPreset> {
  @override
  final int typeId = 3;

  @override
  FrequencyPreset read(BinaryReader reader) {
    final json = reader.readMap().cast<String, dynamic>();
    return FrequencyPreset.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, FrequencyPreset obj) {
    writer.writeMap(obj.toJson());
  }
}

// -----------------------------------------------------------------------------
// UserStats TypeAdapter (TypeId: 10)
// -----------------------------------------------------------------------------

/// Hive TypeAdapter for [UserStats].
///
/// Serializes UserStats objects to/from JSON for Hive storage.
/// Uses the auto-generated toJson/fromJson methods from Freezed.
class UserStatsAdapter extends TypeAdapter<UserStats> {
  @override
  final int typeId = 10;

  @override
  UserStats read(BinaryReader reader) {
    final json = reader.readMap().cast<String, dynamic>();
    return UserStats.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, UserStats obj) {
    writer.writeMap(obj.toJson());
  }
}

// -----------------------------------------------------------------------------
// GatewayProgress TypeAdapter (TypeId: 11)
// -----------------------------------------------------------------------------

/// Hive TypeAdapter for [GatewayProgress].
///
/// Serializes GatewayProgress objects to/from JSON for Hive storage.
/// Uses the auto-generated toJson/fromJson methods from Freezed.
class GatewayProgressAdapter extends TypeAdapter<GatewayProgress> {
  @override
  final int typeId = 11;

  @override
  GatewayProgress read(BinaryReader reader) {
    final json = reader.readMap().cast<String, dynamic>();
    return GatewayProgress.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, GatewayProgress obj) {
    writer.writeMap(obj.toJson());
  }
}

// -----------------------------------------------------------------------------
// JournalEntry TypeAdapter (TypeId: 12)
// -----------------------------------------------------------------------------

/// Hive TypeAdapter for [JournalEntry].
///
/// Serializes JournalEntry objects to/from JSON for Hive storage.
/// Uses the auto-generated toJson/fromJson methods from Freezed.
class JournalEntryAdapter extends TypeAdapter<JournalEntry> {
  @override
  final int typeId = 12;

  @override
  JournalEntry read(BinaryReader reader) {
    final json = reader.readMap().cast<String, dynamic>();
    return JournalEntry.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, JournalEntry obj) {
    writer.writeMap(obj.toJson());
  }
}
