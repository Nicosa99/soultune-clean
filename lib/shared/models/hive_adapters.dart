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
///
///   runApp(MyApp());
/// }
/// ```
library;

import 'package:hive/hive.dart';
import 'package:soultune/shared/models/audio_file.dart';
import 'package:soultune/shared/models/frequency_setting.dart';
import 'package:soultune/shared/models/playlist.dart';

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
