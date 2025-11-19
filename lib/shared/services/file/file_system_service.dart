/// SoulTune FileSystem Service
///
/// Manages music library scanning and file selection for the audio player.
/// Scans common music directories on Android/iOS and allows manual file
/// selection via file picker.
///
/// ## Scanning Strategy
///
/// - **Android**: Scans `/storage/emulated/0/Music`, `/Download`
/// - **iOS**: Uses `getApplicationDocumentsDirectory()` and Music library
/// - **Manual Selection**: file_picker for user-selected files/folders
///
/// ## Supported Formats
///
/// - MP3, FLAC, M4A, AAC, OGG, WAV
///
/// ## Features
///
/// - Permission checking before scan
/// - Recursive directory traversal
/// - Duplicate detection (by file path)
/// - Progress callbacks for UI updates
/// - Batch metadata extraction
/// - Error recovery (skip corrupted files)
///
/// ## Usage
///
/// ```dart
/// final fileSystemService = FileSystemService();
///
/// // Scan entire music library
/// final files = await fileSystemService.scanMusicLibrary(
///   onProgress: (current, total) {
///     print('Scanning: $current / $total');
///   },
/// );
///
/// // Pick files manually
/// final selectedFiles = await fileSystemService.pickAudioFiles();
/// ```
library;

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soultune/shared/exceptions/app_exceptions.dart';
import 'package:soultune/shared/models/audio_file.dart';
import 'package:soultune/shared/services/audio/metadata_service.dart';
import 'package:soultune/shared/services/file/permission_service.dart';

/// Service for scanning and managing music files on the device.
///
/// Provides methods to scan standard music directories, manually select
/// files, and extract metadata from discovered audio files.
///
/// **Thread Safety**: This service is safe to use from the main isolate,
/// but for large libraries, consider running scans in a background isolate
/// to prevent UI blocking.
class FileSystemService {
  /// Creates a [FileSystemService] instance.
  ///
  /// Optionally accepts custom [PermissionService] and [MetadataService]
  /// instances for dependency injection (useful for testing).
  FileSystemService({
    PermissionService? permissionService,
    MetadataService? metadataService,
  })  : _permissionService = permissionService ?? PermissionService(),
        _metadataService = metadataService ?? MetadataService() {
    _logger.d('FileSystemService initialized');
  }

  /// Logger instance for debugging and error tracking.
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Permission service for storage access checks.
  final PermissionService _permissionService;

  /// Metadata service for extracting ID3 tags.
  final MetadataService _metadataService;

  /// Supported audio file extensions.
  static const List<String> supportedExtensions = [
    '.mp3',
    '.flac',
    '.m4a',
    '.aac',
    '.ogg',
    '.wav',
  ];

  /// Common music directories on Android.
  ///
  /// Includes multiple download paths for compatibility with different
  /// Android versions and device configurations:
  /// - Standard Music directory
  /// - Download/Downloads folders (both singular and plural)
  /// - /sdcard symlink paths (common on many devices)
  static const List<String> androidMusicDirs = [
    '/storage/emulated/0/Music',
    '/storage/emulated/0/Download',
    '/storage/emulated/0/Downloads',
    '/sdcard/Music',
    '/sdcard/Download',
    '/sdcard/Downloads',
  ];

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Scans the device's music library and extracts metadata.
  ///
  /// This method performs a complete scan of common music directories,
  /// discovers all supported audio files, and extracts their metadata.
  ///
  /// ## Process
  ///
  /// 1. Checks storage permission (requests if needed)
  /// 2. Scans platform-specific music directories
  /// 3. Filters supported audio formats
  /// 4. Extracts metadata for each file
  /// 5. Returns list of [AudioFile] objects
  ///
  /// ## Parameters
  ///
  /// - [onProgress]: Optional callback for progress updates.
  ///   Called with `(currentFile, totalFiles)` as files are processed.
  /// - [extractAlbumArt]: Whether to extract album artwork (default: true).
  ///   Set to `false` for faster scans if artwork isn't needed immediately.
  ///
  /// ## Returns
  ///
  /// List of successfully scanned [AudioFile] objects. Corrupted or
  /// inaccessible files are logged and skipped.
  ///
  /// ## Throws
  ///
  /// - [PermissionException]: If storage permission is denied
  /// - [FileException]: If music directories are inaccessible
  ///
  /// ## Example
  ///
  /// ```dart
  /// try {
  ///   final files = await fileSystemService.scanMusicLibrary(
  ///     onProgress: (current, total) {
  ///       final percent = (current / total * 100).toStringAsFixed(0);
  ///       print('Scanning: $percent% ($current/$total)');
  ///     },
  ///   );
  ///
  ///   print('Found ${files.length} audio files');
  /// } on PermissionException catch (e) {
  ///   if (e.isPermanentlyDenied) {
  ///     // Guide user to settings
  ///   }
  /// }
  /// ```
  Future<List<AudioFile>> scanMusicLibrary({
    void Function(int current, int total)? onProgress,
    bool extractAlbumArt = true,
  }) async {
    try {
      _logger.i('Starting music library scan...');

      // Check/request permission
      await _ensurePermission();

      // Find all audio files
      final audioPaths = await _findAudioFiles();

      _logger.i('Found ${audioPaths.length} audio files');

      if (audioPaths.isEmpty) {
        _logger.w('No audio files found in music directories');
        return [];
      }

      // Extract metadata for all files
      final audioFiles = <AudioFile>[];
      var processed = 0;

      for (final filePath in audioPaths) {
        try {
          final audioFile = await _metadataService.extractMetadata(
            filePath,
            extractAlbumArt: extractAlbumArt,
          );

          audioFiles.add(audioFile);
        } on Exception catch (e) {
          _logger.w('Skipping file due to error: $filePath ($e)');
          // Continue processing remaining files
        }

        processed++;
        onProgress?.call(processed, audioPaths.length);
      }

      _logger.i(
        'Library scan complete: ${audioFiles.length}/${audioPaths.length} succeeded',
      );

      return audioFiles;
    } on PermissionException {
      rethrow;
    } on Exception catch (e, stackTrace) {
      _logger.e(
        'Failed to scan music library',
        error: e,
        stackTrace: stackTrace,
      );

      throw FileException(
        'Failed to scan music library',
        e,
      );
    }
  }

  /// Opens file picker for manual audio file selection.
  ///
  /// Allows users to manually select one or more audio files from anywhere
  /// on the device. Useful for adding files outside standard music directories.
  ///
  /// ## Parameters
  ///
  /// - [allowMultiple]: Whether to allow selecting multiple files (default: true)
  /// - [extractAlbumArt]: Whether to extract album artwork (default: true)
  ///
  /// ## Returns
  ///
  /// List of selected [AudioFile] objects, or empty list if cancelled.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final selectedFiles = await fileSystemService.pickAudioFiles();
  ///
  /// if (selectedFiles.isNotEmpty) {
  ///   print('User selected ${selectedFiles.length} files');
  ///   // Add to library...
  /// }
  /// ```
  Future<List<AudioFile>> pickAudioFiles({
    bool allowMultiple = true,
    bool extractAlbumArt = true,
  }) async {
    try {
      _logger.i('Opening file picker...');

      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: allowMultiple,
        allowCompression: false,
      );

      if (result == null || result.files.isEmpty) {
        _logger.d('File picker cancelled');
        return [];
      }

      _logger.i('User selected ${result.files.length} files');

      // Extract metadata from selected files
      final audioFiles = <AudioFile>[];

      for (final file in result.files) {
        if (file.path == null) {
          _logger.w('Skipping file with null path: ${file.name}');
          continue;
        }

        try {
          // Validate extension
          if (!_isSupportedAudioFile(file.path!)) {
            _logger.w('Skipping unsupported file: ${file.path}');
            continue;
          }

          final audioFile = await _metadataService.extractMetadata(
            file.path!,
            extractAlbumArt: extractAlbumArt,
          );

          audioFiles.add(audioFile);
        } on Exception catch (e) {
          _logger.w('Failed to process file ${file.path}: $e');
          // Continue processing remaining files
        }
      }

      _logger.i('Successfully processed ${audioFiles.length} files');

      return audioFiles;
    } on Exception catch (e, stackTrace) {
      _logger.e(
        'Failed to pick audio files',
        error: e,
        stackTrace: stackTrace,
      );

      throw FileException(
        'Failed to select audio files',
        e,
      );
    }
  }

  /// Opens folder picker and scans selected directory.
  ///
  /// Allows users to select a folder and recursively scan it for audio files.
  /// Useful for importing entire album folders or custom music directories.
  ///
  /// ## Parameters
  ///
  /// - [onProgress]: Optional progress callback `(current, total)`
  /// - [extractAlbumArt]: Whether to extract album artwork (default: true)
  ///
  /// ## Returns
  ///
  /// List of [AudioFile] objects found in selected folder, or empty if cancelled.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final files = await fileSystemService.pickFolder(
  ///   onProgress: (current, total) {
  ///     print('Processing: $current / $total');
  ///   },
  /// );
  /// ```
  Future<List<AudioFile>> pickFolder({
    void Function(int current, int total)? onProgress,
    bool extractAlbumArt = true,
  }) async {
    try {
      _logger.i('Opening folder picker...');

      final directoryPath = await FilePicker.platform.getDirectoryPath();

      if (directoryPath == null) {
        _logger.d('Folder picker cancelled');
        return [];
      }

      _logger.i('User selected folder: $directoryPath');

      // Scan selected directory
      final directory = Directory(directoryPath);

      if (!await directory.exists()) {
        throw FileException('Selected directory does not exist');
      }

      final audioPaths = await _scanDirectory(directory);

      _logger.i('Found ${audioPaths.length} audio files in folder');

      if (audioPaths.isEmpty) {
        return [];
      }

      // Extract metadata
      final audioFiles = <AudioFile>[];
      var processed = 0;

      for (final filePath in audioPaths) {
        try {
          final audioFile = await _metadataService.extractMetadata(
            filePath,
            extractAlbumArt: extractAlbumArt,
          );

          audioFiles.add(audioFile);
        } on Exception catch (e) {
          _logger.w('Skipping file due to error: $filePath ($e)');
        }

        processed++;
        onProgress?.call(processed, audioPaths.length);
      }

      _logger.i(
        'Folder scan complete: ${audioFiles.length}/${audioPaths.length} succeeded',
      );

      return audioFiles;
    } on Exception catch (e, stackTrace) {
      _logger.e(
        'Failed to pick folder',
        error: e,
        stackTrace: stackTrace,
      );

      throw FileException(
        'Failed to scan selected folder',
        e,
      );
    }
  }

  /// Validates that a file exists and is a supported audio format.
  ///
  /// ## Parameters
  ///
  /// - [filePath]: Path to the file to validate
  ///
  /// ## Returns
  ///
  /// `true` if file exists and has supported extension, `false` otherwise.
  ///
  /// ## Example
  ///
  /// ```dart
  /// if (await fileSystemService.validateAudioFile('/path/to/song.mp3')) {
  ///   // File is valid, proceed with playback
  /// }
  /// ```
  Future<bool> validateAudioFile(String filePath) async {
    try {
      // Check extension
      if (!_isSupportedAudioFile(filePath)) {
        _logger.d('File has unsupported extension: $filePath');
        return false;
      }

      // Check existence
      final file = File(filePath);
      final exists = await file.exists();

      if (!exists) {
        _logger.d('File does not exist: $filePath');
        return false;
      }

      _logger.d('File validated: $filePath');
      return true;
    } on Exception catch (e) {
      _logger.e('Failed to validate file: $filePath', error: e);
      return false;
    }
  }

  /// Gets the total number of audio files in music directories.
  ///
  /// Lightweight scan that only counts files without extracting metadata.
  /// Useful for displaying library size or estimating scan duration.
  ///
  /// ## Returns
  ///
  /// Number of supported audio files found.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final count = await fileSystemService.getAudioFileCount();
  /// print('Your library contains $count songs');
  /// ```
  Future<int> getAudioFileCount() async {
    try {
      await _ensurePermission();

      final audioPaths = await _findAudioFiles();

      _logger.d('Audio file count: ${audioPaths.length}');

      return audioPaths.length;
    } on Exception catch (e) {
      _logger.e('Failed to count audio files', error: e);
      return 0;
    }
  }

  // ---------------------------------------------------------------------------
  // Helper Methods
  // ---------------------------------------------------------------------------

  /// Ensures storage permission is granted, requests if needed.
  Future<void> _ensurePermission() async {
    final hasPermission = await _permissionService.hasStoragePermission();

    if (!hasPermission) {
      _logger.w('Storage permission not granted, requesting...');

      final granted = await _permissionService.requestStoragePermission();

      if (!granted) {
        throw const PermissionException(
          'Storage permission is required to scan your music library',
        );
      }
    }

    _logger.d('Storage permission granted');
  }

  /// Finds all audio files in standard music directories.
  ///
  /// Returns list of absolute file paths.
  Future<List<String>> _findAudioFiles() async {
    final audioPaths = <String>[];

    if (Platform.isAndroid) {
      // Also scan external storage directories if available
      try {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          final externalDownloads = Directory(
            '${externalDir.path}/../../Download',
          ).absolute;
          if (await externalDownloads.exists()) {
            final paths = await _scanDirectory(externalDownloads);
            audioPaths.addAll(paths);
            _logger.i(
              'Found ${paths.length} files in external downloads: ${externalDownloads.path}',
            );
          }
        }
      } catch (e) {
        _logger.w('Could not access external storage directory: $e');
      }

      // Scan Android music directories
      for (final dirPath in androidMusicDirs) {
        final directory = Directory(dirPath);

        if (await directory.exists()) {
          _logger.d('Scanning directory: $dirPath');

          final paths = await _scanDirectory(directory);
          audioPaths.addAll(paths);

          if (paths.isNotEmpty) {
            _logger.i('Found ${paths.length} audio files in $dirPath');
          } else {
            _logger.d('No audio files found in $dirPath');
          }
        } else {
          _logger.d('Directory does not exist or not accessible: $dirPath');
        }
      }
    } else if (Platform.isIOS) {
      // Scan iOS documents directory
      // Note: iOS doesn't provide direct access to Music app library
      // without MusicKit. For MVP, we scan app's documents directory.
      final documentsDir = await getApplicationDocumentsDirectory();

      _logger.d('Scanning iOS documents: ${documentsDir.path}');

      final paths = await _scanDirectory(documentsDir);
      audioPaths.addAll(paths);

      _logger.d('Found ${paths.length} files in documents');
    }

    // Remove duplicates (in case of symlinks or multiple paths to same file)
    final uniquePaths = audioPaths.toSet().toList();

    _logger.i(
      'Total unique audio files found: ${uniquePaths.length} '
      '(${audioPaths.length - uniquePaths.length} duplicates removed)',
    );

    return uniquePaths;
  }

  /// Recursively scans a directory for audio files.
  ///
  /// Returns list of absolute file paths.
  Future<List<String>> _scanDirectory(Directory directory) async {
    final audioPaths = <String>[];

    try {
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          if (_isSupportedAudioFile(entity.path)) {
            audioPaths.add(entity.path);
          }
        }
      }
    } on FileSystemException catch (e) {
      _logger.w('Error scanning directory ${directory.path}: $e');
      // Continue - some directories may be inaccessible
    }

    return audioPaths;
  }

  /// Checks if a file path has a supported audio extension.
  bool _isSupportedAudioFile(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    final supported = supportedExtensions.contains('.$extension');

    return supported;
  }
}
