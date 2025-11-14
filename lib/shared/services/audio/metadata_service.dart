/// SoulTune Metadata Service
///
/// Extracts audio metadata (ID3 tags, duration, album art) from local music
/// files using the `audiotags` package. Creates complete [AudioFile] models
/// with all available metadata.
///
/// ## Supported Formats
///
/// - **MP3**: ID3v1, ID3v2 (most common)
/// - **FLAC**: Vorbis Comments
/// - **M4A/AAC**: MP4 metadata
/// - **OGG**: Vorbis Comments
/// - **WAV**: RIFF INFO chunks (limited)
///
/// ## Features
///
/// - Automatic format detection
/// - Graceful fallback for missing metadata (uses filename)
/// - Album art extraction and caching
/// - Duration calculation
/// - Error recovery for corrupted files
///
/// ## Usage
///
/// ```dart
/// final metadataService = MetadataService();
///
/// try {
///   final audioFile = await metadataService.extractMetadata(
///     '/storage/music/song.mp3',
///   );
///
///   print('Title: ${audioFile.title}');
///   print('Artist: ${audioFile.displayArtist}');
///   print('Duration: ${audioFile.formattedDuration}');
/// } on MetadataException catch (e) {
///   print('Failed to extract metadata: ${e.message}');
/// }
/// ```
library;

import 'dart:io';

import 'package:audiotags/audiotags.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soultune/shared/exceptions/app_exceptions.dart';
import 'package:soultune/shared/models/audio_file.dart';
import 'package:uuid/uuid.dart';

/// Service for extracting metadata from audio files.
///
/// Uses the `audiotags` package to read ID3 tags and other metadata formats.
/// Handles missing or corrupted metadata gracefully with intelligent fallbacks.
class MetadataService {
  /// Creates a [MetadataService] instance.
  MetadataService() {
    _logger.d('MetadataService initialized');
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

  /// UUID generator for creating unique audio file IDs.
  final Uuid _uuid = const Uuid();

  /// Extracts complete metadata from an audio file and returns [AudioFile].
  ///
  /// Reads all available metadata tags (title, artist, album, etc.) and
  /// creates a complete [AudioFile] model. If metadata is missing or
  /// corrupted, uses intelligent fallbacks:
  ///
  /// - **Missing title**: Uses filename without extension
  /// - **Missing artist**: Returns null (displays "Unknown Artist" in UI)
  /// - **Missing album**: Returns null (displays "Unknown Album" in UI)
  /// - **Missing duration**: Throws error (duration is required)
  ///
  /// ## Parameters
  ///
  /// - [filePath]: Absolute path to the audio file
  /// - [extractAlbumArt]: Whether to extract and cache album artwork (default: true)
  ///
  /// ## Returns
  ///
  /// Complete [AudioFile] model with all extracted metadata.
  ///
  /// ## Throws
  ///
  /// - [MetadataException]: If file cannot be read or is not a valid audio file
  /// - [FileException]: If file doesn't exist or is inaccessible
  ///
  /// ## Example
  ///
  /// ```dart
  /// final audioFile = await metadataService.extractMetadata(
  ///   '/storage/emulated/0/Music/meditation.mp3',
  /// );
  ///
  /// // Access metadata
  /// print('Playing: ${audioFile.title}');
  /// print('By: ${audioFile.displayArtist}');
  /// print('Duration: ${audioFile.formattedDuration}');
  ///
  /// // Check for album art
  /// if (audioFile.hasAlbumArt) {
  ///   loadImage(audioFile.albumArt!);
  /// }
  /// ```
  Future<AudioFile> extractMetadata(
    String filePath, {
    bool extractAlbumArt = true,
  }) async {
    try {
      _logger.d('Extracting metadata from: $filePath');

      // Validate file existence
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileException('Audio file not found: $filePath');
      }

      // Read metadata using audiotags
      final tag = await AudioTags.read(filePath);

      if (tag == null) {
        throw MetadataException(
          'Failed to read metadata from file: $filePath',
        );
      }

      // Extract basic metadata with fallbacks
      final title = tag.title?.trim() ?? _getFileNameWithoutExtension(filePath);
      final artist = tag.trackArtist?.trim();
      final album = tag.album?.trim();
      final genre = tag.genre?.trim();
      final year = tag.year;
      final trackNumber = tag.trackNumber;

      // Extract duration (required field)
      final durationMs = tag.duration;
      if (durationMs == null || durationMs <= 0) {
        throw MetadataException(
          'Invalid or missing duration in file: $filePath',
        );
      }
      final duration = Duration(milliseconds: durationMs);

      // Extract and cache album art if requested
      String? albumArtPath;
      if (extractAlbumArt) {
        albumArtPath = await _extractAlbumArt(filePath, tag);
      }

      // Create AudioFile model
      final audioFile = AudioFile(
        id: _uuid.v4(),
        filePath: filePath,
        title: title,
        artist: artist,
        album: album,
        albumArt: albumArtPath,
        genre: genre,
        year: year,
        trackNumber: trackNumber,
        duration: duration,
        dateAdded: DateTime.now(),
      );

      _logger.i(
        'Extracted metadata: "$title" by ${artist ?? 'Unknown'} '
        '(${duration.inSeconds}s)',
      );

      return audioFile;
    } on FileException {
      rethrow;
    } on MetadataException {
      rethrow;
    } on Exception catch (e, stackTrace) {
      _logger.e(
        'Failed to extract metadata',
        error: e,
        stackTrace: stackTrace,
      );

      throw MetadataException(
        'Failed to extract metadata from file: $filePath',
        e,
      );
    }
  }

  /// Extracts album artwork from audio file and saves to cache.
  ///
  /// Returns the cached file path if album art exists, null otherwise.
  Future<String?> _extractAlbumArt(String filePath, Tag tag) async {
    try {
      // Check if album art exists
      final pictures = tag.pictures;
      if (pictures.isEmpty) {
        _logger.d('No album art found in: $filePath');
        return null;
      }

      final picture = pictures.first;
      final imageData = picture.bytes;

      if (imageData.isEmpty) {
        _logger.d('Empty album art data in: $filePath');
        return null;
      }

      // Generate cache filename
      final cacheDir = await getTemporaryDirectory();
      final albumArtDir = Directory('${cacheDir.path}/album_art');

      // Create album art directory if needed
      if (!await albumArtDir.exists()) {
        await albumArtDir.create(recursive: true);
      }

      // Use UUID for cache filename to avoid conflicts
      final cacheFileName = '${_uuid.v4()}.jpg';
      final cachePath = '${albumArtDir.path}/$cacheFileName';

      // Write image data to cache
      final cacheFile = File(cachePath);
      await cacheFile.writeAsBytes(imageData);

      _logger.d('Cached album art to: $cachePath (${imageData.length} bytes)');

      return cachePath;
    } on Exception catch (e) {
      _logger.w('Failed to extract album art: $e');
      // Non-critical error - return null instead of throwing
      return null;
    }
  }

  /// Extracts filename without extension from file path.
  ///
  /// Used as fallback title when ID3 tags are missing.
  ///
  /// Examples:
  /// - `/music/song.mp3` → `song`
  /// - `/music/track 01 - artist.flac` → `track 01 - artist`
  String _getFileNameWithoutExtension(String filePath) {
    final fileName = filePath.split('/').last;
    final lastDot = fileName.lastIndexOf('.');

    if (lastDot > 0) {
      return fileName.substring(0, lastDot);
    }

    return fileName;
  }

  /// Batch extracts metadata from multiple files.
  ///
  /// Processes files sequentially to avoid memory issues. Returns a list
  /// of successfully extracted [AudioFile] objects. Failed extractions
  /// are logged but don't stop the batch process.
  ///
  /// ## Parameters
  ///
  /// - [filePaths]: List of absolute file paths to process
  /// - [onProgress]: Optional callback for progress updates (0.0 to 1.0)
  /// - [extractAlbumArt]: Whether to extract album artwork (default: true)
  ///
  /// ## Returns
  ///
  /// List of successfully extracted [AudioFile] objects.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final files = await metadataService.extractMetadataBatch(
  ///   filePaths,
  ///   onProgress: (progress) {
  ///     print('Progress: ${(progress * 100).toStringAsFixed(0)}%');
  ///   },
  /// );
  ///
  /// print('Successfully extracted ${files.length} of ${filePaths.length}');
  /// ```
  Future<List<AudioFile>> extractMetadataBatch(
    List<String> filePaths, {
    void Function(double progress)? onProgress,
    bool extractAlbumArt = true,
  }) async {
    _logger.i('Batch extracting metadata from ${filePaths.length} files...');

    final results = <AudioFile>[];
    var processed = 0;

    for (final filePath in filePaths) {
      try {
        final audioFile = await extractMetadata(
          filePath,
          extractAlbumArt: extractAlbumArt,
        );

        results.add(audioFile);
      } on Exception catch (e) {
        _logger.w('Skipping file due to error: $filePath ($e)');
        // Continue processing remaining files
      }

      processed++;
      onProgress?.call(processed / filePaths.length);
    }

    _logger.i(
      'Batch extraction complete: ${results.length}/${filePaths.length} succeeded',
    );

    return results;
  }

  /// Validates that a file is a supported audio format.
  ///
  /// Checks file extension against supported formats.
  ///
  /// ## Supported Extensions
  ///
  /// - `.mp3` - MPEG Audio Layer 3
  /// - `.flac` - Free Lossless Audio Codec
  /// - `.m4a` - MPEG-4 Audio
  /// - `.aac` - Advanced Audio Coding
  /// - `.ogg` - Ogg Vorbis
  /// - `.wav` - Waveform Audio File
  ///
  /// ## Example
  ///
  /// ```dart
  /// if (metadataService.isSupportedAudioFile('/music/song.mp3')) {
  ///   // Process audio file
  /// }
  /// ```
  bool isSupportedAudioFile(String filePath) {
    const supportedExtensions = [
      '.mp3',
      '.flac',
      '.m4a',
      '.aac',
      '.ogg',
      '.wav',
    ];

    final extension = filePath.toLowerCase().split('.').last;
    final supported = supportedExtensions.contains('.$extension');

    _logger.d('File $filePath supported: $supported');

    return supported;
  }

  /// Clears cached album artwork to free disk space.
  ///
  /// Deletes all cached album art images. Use sparingly as this will
  /// require re-extraction on next access.
  ///
  /// ## Returns
  ///
  /// Number of files deleted, or -1 if cache directory doesn't exist.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Clear cache during app cleanup or settings
  /// final deleted = await metadataService.clearAlbumArtCache();
  /// print('Cleared $deleted cached album art files');
  /// ```
  Future<int> clearAlbumArtCache() async {
    try {
      _logger.i('Clearing album art cache...');

      final cacheDir = await getTemporaryDirectory();
      final albumArtDir = Directory('${cacheDir.path}/album_art');

      if (!await albumArtDir.exists()) {
        _logger.d('Album art cache directory does not exist');
        return 0;
      }

      final files = await albumArtDir.list().toList();
      var deleted = 0;

      for (final file in files) {
        if (file is File) {
          await file.delete();
          deleted++;
        }
      }

      _logger.i('Deleted $deleted cached album art files');

      return deleted;
    } on Exception catch (e, stackTrace) {
      _logger.e(
        'Failed to clear album art cache',
        error: e,
        stackTrace: stackTrace,
      );

      return -1;
    }
  }

  /// Gets the total size of cached album artwork in bytes.
  ///
  /// Useful for displaying cache size in app settings.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final cacheSize = await metadataService.getAlbumArtCacheSize();
  /// final sizeMB = (cacheSize / 1024 / 1024).toStringAsFixed(2);
  /// print('Album art cache: $sizeMB MB');
  /// ```
  Future<int> getAlbumArtCacheSize() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final albumArtDir = Directory('${cacheDir.path}/album_art');

      if (!await albumArtDir.exists()) {
        return 0;
      }

      final files = await albumArtDir.list().toList();
      var totalSize = 0;

      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          totalSize += stat.size;
        }
      }

      _logger.d('Album art cache size: $totalSize bytes');

      return totalSize;
    } on Exception catch (e) {
      _logger.e('Failed to get album art cache size', error: e);
      return 0;
    }
  }
}
