/// Download Scanner Service
///
/// Scans the device's Downloads folder for new audio files
/// and imports them into the library.
library;

import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:soultune/shared/models/audio_file.dart';
import 'package:uuid/uuid.dart';

/// Service for scanning Downloads folder and importing audio files.
class DownloadScannerService {
  /// Creates a [DownloadScannerService].
  DownloadScannerService() {
    _logger = Logger();
    _uuid = const Uuid();
  }

  late final Logger _logger;
  late final Uuid _uuid;

  /// Supported audio file extensions.
  static const _audioExtensions = [
    '.mp3',
    '.m4a',
    '.flac',
    '.wav',
    '.aac',
    '.ogg',
    '.opus',
    '.wma',
  ];

  /// Scans Downloads folder for new audio files.
  ///
  /// Returns list of newly imported audio file paths.
  Future<List<String>> scanAndImport() async {
    try {
      _logger.i('Starting Downloads folder scan...');

      // Get Downloads directory
      final downloadsDir = await _getDownloadsDirectory();
      if (downloadsDir == null) {
        _logger.w('Downloads directory not found');
        return [];
      }

      _logger.i('Scanning directory: ${downloadsDir.path}');

      // Get last scan timestamp
      final lastScanTime = await _getLastScanTime();
      _logger.i('Last scan: ${lastScanTime ?? 'never'}');

      // Find audio files
      final audioFiles = await _findAudioFiles(downloadsDir);
      _logger.i('Found ${audioFiles.length} audio files');

      // Filter new files (modified after last scan)
      final newFiles = audioFiles.where((file) {
        final modified = file.lastModifiedSync();
        final isNew = lastScanTime == null || modified.isAfter(lastScanTime);
        _logger.d('${file.path}: ${isNew ? 'NEW' : 'old'}');
        return isNew;
      }).toList();

      _logger.i('New files: ${newFiles.length}');

      // Import new files
      final importedPaths = <String>[];
      for (final file in newFiles) {
        try {
          final audioFile = await _createAudioFile(file);
          await _saveToHive(audioFile);
          importedPaths.add(path.basename(file.path));
          _logger.i('Imported: ${audioFile.title}');
        } catch (e) {
          _logger.e('Failed to import ${file.path}: $e');
        }
      }

      // Update last scan time
      await _updateLastScanTime();

      _logger.i('Import complete: ${importedPaths.length} files');
      return importedPaths;
    } catch (e) {
      _logger.e('Scan failed: $e');
      rethrow;
    }
  }

  /// Gets the Downloads directory.
  Future<Directory?> _getDownloadsDirectory() async {
    try {
      if (Platform.isAndroid) {
        // Android: /storage/emulated/0/Download
        final externalDir = Directory('/storage/emulated/0/Download');
        if (await externalDir.exists()) {
          return externalDir;
        }
      }

      // Fallback: try common paths
      final commonPaths = [
        '/storage/emulated/0/Downloads',
        '/sdcard/Download',
        '/sdcard/Downloads',
      ];

      for (final pathStr in commonPaths) {
        final dir = Directory(pathStr);
        if (await dir.exists()) {
          return dir;
        }
      }

      // Last resort: use external storage directory
      final externalStorage = await getExternalStorageDirectory();
      return externalStorage;
    } catch (e) {
      _logger.e('Failed to get downloads directory: $e');
      return null;
    }
  }

  /// Finds all audio files in directory (recursive).
  Future<List<File>> _findAudioFiles(Directory dir) async {
    final audioFiles = <File>[];

    try {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          final ext = path.extension(entity.path).toLowerCase();
          if (_audioExtensions.contains(ext)) {
            audioFiles.add(entity);
          }
        }
      }
    } catch (e) {
      _logger.e('Failed to scan directory: $e');
    }

    return audioFiles;
  }

  /// Creates AudioFile from File.
  Future<AudioFile> _createAudioFile(File file) async {
    final fileName = path.basenameWithoutExtension(file.path);
    // TODO: Get actual duration from metadata using audio_metadata package
    const duration = Duration.zero;

    return AudioFile(
      id: _uuid.v4(),
      filePath: file.path,
      title: fileName,
      artist: 'Unknown Artist',
      album: 'Downloads',
      duration: duration,
      dateAdded: DateTime.now(),
    );
  }

  /// Saves AudioFile to Hive.
  Future<void> _saveToHive(AudioFile audioFile) async {
    final box = await Hive.openBox<AudioFile>('audio_files');
    await box.put(audioFile.id, audioFile);
    _logger.i('Saved to Hive: ${audioFile.id}');
  }

  /// Gets last scan timestamp from Hive.
  Future<DateTime?> _getLastScanTime() async {
    try {
      final box = await Hive.openBox<dynamic>('download_scanner');
      final timestamp = box.get('last_scan_time') as int?;
      if (timestamp == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      _logger.e('Failed to get last scan time: $e');
      return null;
    }
  }

  /// Updates last scan timestamp in Hive.
  Future<void> _updateLastScanTime() async {
    try {
      final box = await Hive.openBox<dynamic>('download_scanner');
      await box.put('last_scan_time', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      _logger.e('Failed to update last scan time: $e');
    }
  }
}
