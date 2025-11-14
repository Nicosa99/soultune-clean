/// SoulTune Hive Audio Data Source
///
/// Low-level CRUD operations for AudioFile persistence using Hive.
/// Manages local storage of audio library metadata, favorites, and
/// playback statistics.
///
/// ## Storage Strategy
///
/// - **Box Name**: `audio_files`
/// - **Key Format**: AudioFile.id (UUID v4)
/// - **Value Type**: AudioFile (via manual TypeAdapter)
/// - **Storage Location**: App documents directory
///
/// ## Data Operations
///
/// - **Create**: Add new audio files to library
/// - **Read**: Query by ID, favorites, recently added, most played
/// - **Update**: Modify metadata, play counts, favorite status
/// - **Delete**: Remove files from library
///
/// ## Features
///
/// - Batch operations for performance
/// - Reactive streams for real-time updates
/// - Indexing by play count and date added
/// - Favorites filtering
/// - Search by title/artist
///
/// ## Usage
///
/// ```dart
/// final dataSource = HiveAudioDataSource();
/// await dataSource.init();
///
/// // Save audio file
/// await dataSource.saveAudioFile(audioFile);
///
/// // Get all files
/// final allFiles = await dataSource.getAllAudioFiles();
///
/// // Get favorites
/// final favorites = await dataSource.getFavorites();
///
/// // Update play count
/// await dataSource.incrementPlayCount(audioFile.id);
/// ```
library;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:soultune/shared/exceptions/app_exceptions.dart';
import 'package:soultune/shared/models/audio_file.dart';
import 'package:soultune/shared/services/storage/hive_service.dart';

/// Data source for AudioFile persistence using Hive.
///
/// Provides type-safe CRUD operations and query methods for managing
/// the local music library. All operations are asynchronous and return
/// Futures for proper async/await handling.
///
/// **Lifecycle**: Call [init] before any operations, [dispose] on cleanup.
class HiveAudioDataSource {
  /// Creates a [HiveAudioDataSource] instance.
  ///
  /// Optionally accepts custom [HiveService] for dependency injection.
  HiveAudioDataSource({HiveService? hiveService})
      : _hiveService = hiveService ?? HiveService.instance {
    _logger.d('HiveAudioDataSource created');
  }

  /// Logger instance for debugging.
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

  /// Hive service for box management.
  final HiveService _hiveService;

  /// Box name for audio files storage.
  static const String _boxName = 'audio_files';

  /// The Hive box containing AudioFile objects.
  late Box<AudioFile> _audioBox;

  /// Whether the data source has been initialized.
  bool _isInitialized = false;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Initializes the data source and opens the Hive box.
  ///
  /// Must be called before any CRUD operations. Opens or creates the
  /// `audio_files` box and prepares it for use.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final dataSource = HiveAudioDataSource();
  /// await dataSource.init();
  /// ```
  ///
  /// ## Throws
  ///
  /// [StorageException] if box cannot be opened.
  Future<void> init() async {
    if (_isInitialized) {
      _logger.w('HiveAudioDataSource already initialized');
      return;
    }

    try {
      _logger.i('Initializing HiveAudioDataSource...');

      // Ensure HiveService is initialized
      await _hiveService.init();

      // Open audio files box
      _audioBox = await _hiveService.openBox<AudioFile>(_boxName);

      _isInitialized = true;

      _logger.i(
        '✓ HiveAudioDataSource initialized '
        '(${_audioBox.length} files in library)',
      );
    } on Exception catch (e, stackTrace) {
      _logger.e(
        'Failed to initialize HiveAudioDataSource',
        error: e,
        stackTrace: stackTrace,
      );

      throw StorageException(
        'Failed to initialize audio database',
        e,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Create Operations
  // ---------------------------------------------------------------------------

  /// Saves a single audio file to the library.
  ///
  /// If a file with the same ID already exists, it will be replaced.
  ///
  /// ## Parameters
  ///
  /// - [audioFile]: The audio file to save
  ///
  /// ## Example
  ///
  /// ```dart
  /// await dataSource.saveAudioFile(audioFile);
  /// ```
  ///
  /// ## Throws
  ///
  /// [StorageException] if save operation fails.
  Future<void> saveAudioFile(AudioFile audioFile) async {
    _ensureInitialized();

    try {
      await _audioBox.put(audioFile.id, audioFile);

      _logger.d('Saved audio file: ${audioFile.title} (${audioFile.id})');
    } on Exception catch (e) {
      _logger.e('Failed to save audio file', error: e);
      throw StorageException('Failed to save audio file', e);
    }
  }

  /// Saves multiple audio files in a batch operation.
  ///
  /// More efficient than calling [saveAudioFile] multiple times.
  /// Existing files with matching IDs will be replaced.
  ///
  /// ## Parameters
  ///
  /// - [audioFiles]: List of audio files to save
  ///
  /// ## Example
  ///
  /// ```dart
  /// await dataSource.saveAudioFiles(scannedFiles);
  /// ```
  ///
  /// ## Throws
  ///
  /// [StorageException] if batch save fails.
  Future<void> saveAudioFiles(List<AudioFile> audioFiles) async {
    _ensureInitialized();

    if (audioFiles.isEmpty) {
      _logger.d('No files to save');
      return;
    }

    try {
      // Create map of id -> AudioFile for batch put
      final entries = <String, AudioFile>{};
      for (final file in audioFiles) {
        entries[file.id] = file;
      }

      await _audioBox.putAll(entries);

      _logger.i('Saved ${audioFiles.length} audio files in batch');
    } on Exception catch (e) {
      _logger.e('Failed to save audio files batch', error: e);
      throw StorageException('Failed to save audio files', e);
    }
  }

  // ---------------------------------------------------------------------------
  // Read Operations
  // ---------------------------------------------------------------------------

  /// Retrieves a single audio file by ID.
  ///
  /// Returns `null` if no file with the given ID exists.
  ///
  /// ## Parameters
  ///
  /// - [id]: The unique ID of the audio file
  ///
  /// ## Example
  ///
  /// ```dart
  /// final file = await dataSource.getAudioFile('abc-123');
  /// if (file != null) {
  ///   print('Found: ${file.title}');
  /// }
  /// ```
  Future<AudioFile?> getAudioFile(String id) async {
    _ensureInitialized();

    try {
      final audioFile = _audioBox.get(id);

      if (audioFile != null) {
        _logger.d('Retrieved audio file: ${audioFile.title}');
      } else {
        _logger.d('Audio file not found: $id');
      }

      return audioFile;
    } on Exception catch (e) {
      _logger.e('Failed to get audio file', error: e);
      throw StorageException('Failed to retrieve audio file', e);
    }
  }

  /// Retrieves all audio files in the library.
  ///
  /// Returns files in insertion order (same as Hive storage order).
  /// For sorted results, use specific query methods.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final allFiles = await dataSource.getAllAudioFiles();
  /// print('Library size: ${allFiles.length}');
  /// ```
  Future<List<AudioFile>> getAllAudioFiles() async {
    _ensureInitialized();

    try {
      final files = _audioBox.values.toList();

      _logger.d('Retrieved ${files.length} audio files');

      return files;
    } on Exception catch (e) {
      _logger.e('Failed to get all audio files', error: e);
      throw StorageException('Failed to retrieve audio library', e);
    }
  }

  /// Retrieves favorite audio files.
  ///
  /// Returns only files where `isFavorite == true`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final favorites = await dataSource.getFavorites();
  /// ```
  Future<List<AudioFile>> getFavorites() async {
    _ensureInitialized();

    try {
      final favorites = _audioBox.values
          .where((file) => file.isFavorite)
          .toList();

      _logger.d('Retrieved ${favorites.length} favorites');

      return favorites;
    } on Exception catch (e) {
      _logger.e('Failed to get favorites', error: e);
      throw StorageException('Failed to retrieve favorites', e);
    }
  }

  /// Retrieves recently added audio files.
  ///
  /// Returns files sorted by `dateAdded` in descending order (newest first).
  ///
  /// ## Parameters
  ///
  /// - [limit]: Maximum number of files to return (default: 20)
  ///
  /// ## Example
  ///
  /// ```dart
  /// final recent = await dataSource.getRecentlyAdded(limit: 10);
  /// ```
  Future<List<AudioFile>> getRecentlyAdded({int limit = 20}) async {
    _ensureInitialized();

    try {
      final files = _audioBox.values.toList()
        ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

      final result = files.take(limit).toList();

      _logger.d('Retrieved ${result.length} recently added files');

      return result;
    } on Exception catch (e) {
      _logger.e('Failed to get recently added', error: e);
      throw StorageException('Failed to retrieve recently added files', e);
    }
  }

  /// Retrieves most played audio files.
  ///
  /// Returns files sorted by `playCount` in descending order (most played first).
  ///
  /// ## Parameters
  ///
  /// - [limit]: Maximum number of files to return (default: 20)
  ///
  /// ## Example
  ///
  /// ```dart
  /// final popular = await dataSource.getMostPlayed(limit: 10);
  /// ```
  Future<List<AudioFile>> getMostPlayed({int limit = 20}) async {
    _ensureInitialized();

    try {
      final files = _audioBox.values.toList()
        ..sort((a, b) => b.playCount.compareTo(a.playCount));

      final result = files.take(limit).toList();

      _logger.d('Retrieved ${result.length} most played files');

      return result;
    } on Exception catch (e) {
      _logger.e('Failed to get most played', error: e);
      throw StorageException('Failed to retrieve most played files', e);
    }
  }

  /// Searches audio files by title or artist.
  ///
  /// Performs case-insensitive substring matching on title and artist fields.
  ///
  /// ## Parameters
  ///
  /// - [query]: Search query string
  ///
  /// ## Example
  ///
  /// ```dart
  /// final results = await dataSource.searchAudioFiles('meditation');
  /// ```
  Future<List<AudioFile>> searchAudioFiles(String query) async {
    _ensureInitialized();

    if (query.trim().isEmpty) {
      return getAllAudioFiles();
    }

    try {
      final lowerQuery = query.toLowerCase();

      final results = _audioBox.values.where((file) {
        final titleMatch = file.title.toLowerCase().contains(lowerQuery);
        final artistMatch = file.artist?.toLowerCase().contains(lowerQuery) ?? false;

        return titleMatch || artistMatch;
      }).toList();

      _logger.d('Search "$query" found ${results.length} results');

      return results;
    } on Exception catch (e) {
      _logger.e('Failed to search audio files', error: e);
      throw StorageException('Failed to search audio files', e);
    }
  }

  /// Gets the total number of audio files in the library.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final count = await dataSource.getAudioFileCount();
  /// print('Library contains $count tracks');
  /// ```
  Future<int> getAudioFileCount() async {
    _ensureInitialized();

    try {
      final count = _audioBox.length;

      _logger.d('Audio file count: $count');

      return count;
    } on Exception catch (e) {
      _logger.e('Failed to get audio file count', error: e);
      return 0;
    }
  }

  // ---------------------------------------------------------------------------
  // Update Operations
  // ---------------------------------------------------------------------------

  /// Updates an existing audio file.
  ///
  /// Replaces the stored file with the provided instance. The file ID
  /// must match an existing entry.
  ///
  /// ## Parameters
  ///
  /// - [audioFile]: Updated audio file instance
  ///
  /// ## Example
  ///
  /// ```dart
  /// final updated = audioFile.copyWith(isFavorite: true);
  /// await dataSource.updateAudioFile(updated);
  /// ```
  ///
  /// ## Throws
  ///
  /// [StorageException] if update fails or file doesn't exist.
  Future<void> updateAudioFile(AudioFile audioFile) async {
    _ensureInitialized();

    try {
      // Verify file exists
      if (!_audioBox.containsKey(audioFile.id)) {
        throw StorageException(
          'Cannot update non-existent file: ${audioFile.id}',
        );
      }

      await _audioBox.put(audioFile.id, audioFile);

      _logger.d('Updated audio file: ${audioFile.title}');
    } on Exception catch (e) {
      _logger.e('Failed to update audio file', error: e);
      throw StorageException('Failed to update audio file', e);
    }
  }

  /// Toggles favorite status for an audio file.
  ///
  /// ## Parameters
  ///
  /// - [id]: Audio file ID
  ///
  /// ## Returns
  ///
  /// The updated [AudioFile] instance.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final updated = await dataSource.toggleFavorite(audioFile.id);
  /// print('Is favorite: ${updated.isFavorite}');
  /// ```
  Future<AudioFile> toggleFavorite(String id) async {
    _ensureInitialized();

    try {
      final audioFile = await getAudioFile(id);

      if (audioFile == null) {
        throw StorageException('Audio file not found: $id');
      }

      final updated = audioFile.copyWith(isFavorite: !audioFile.isFavorite);
      await _audioBox.put(id, updated);

      _logger.i(
        'Toggled favorite: ${updated.title} '
        '(${updated.isFavorite ? "added" : "removed"})',
      );

      return updated;
    } on Exception catch (e) {
      _logger.e('Failed to toggle favorite', error: e);
      throw StorageException('Failed to toggle favorite', e);
    }
  }

  /// Increments play count and updates last played timestamp.
  ///
  /// ## Parameters
  ///
  /// - [id]: Audio file ID
  ///
  /// ## Returns
  ///
  /// The updated [AudioFile] instance.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final updated = await dataSource.incrementPlayCount(audioFile.id);
  /// print('Play count: ${updated.playCount}');
  /// ```
  Future<AudioFile> incrementPlayCount(String id) async {
    _ensureInitialized();

    try {
      final audioFile = await getAudioFile(id);

      if (audioFile == null) {
        throw StorageException('Audio file not found: $id');
      }

      final updated = audioFile.recordPlay();
      await _audioBox.put(id, updated);

      _logger.d(
        'Incremented play count: ${updated.title} '
        '(${updated.playCount} plays)',
      );

      return updated;
    } on Exception catch (e) {
      _logger.e('Failed to increment play count', error: e);
      throw StorageException('Failed to update play count', e);
    }
  }

  // ---------------------------------------------------------------------------
  // Delete Operations
  // ---------------------------------------------------------------------------

  /// Deletes a single audio file from the library.
  ///
  /// ## Parameters
  ///
  /// - [id]: Audio file ID to delete
  ///
  /// ## Example
  ///
  /// ```dart
  /// await dataSource.deleteAudioFile(audioFile.id);
  /// ```
  Future<void> deleteAudioFile(String id) async {
    _ensureInitialized();

    try {
      await _audioBox.delete(id);

      _logger.i('Deleted audio file: $id');
    } on Exception catch (e) {
      _logger.e('Failed to delete audio file', error: e);
      throw StorageException('Failed to delete audio file', e);
    }
  }

  /// Deletes multiple audio files in a batch operation.
  ///
  /// ## Parameters
  ///
  /// - [ids]: List of audio file IDs to delete
  ///
  /// ## Example
  ///
  /// ```dart
  /// await dataSource.deleteAudioFiles(['id1', 'id2', 'id3']);
  /// ```
  Future<void> deleteAudioFiles(List<String> ids) async {
    _ensureInitialized();

    if (ids.isEmpty) {
      return;
    }

    try {
      await _audioBox.deleteAll(ids);

      _logger.i('Deleted ${ids.length} audio files');
    } on Exception catch (e) {
      _logger.e('Failed to delete audio files', error: e);
      throw StorageException('Failed to delete audio files', e);
    }
  }

  /// Clears the entire audio library.
  ///
  /// **WARNING**: This permanently deletes all audio files from storage.
  /// Use with caution!
  ///
  /// ## Example
  ///
  /// ```dart
  /// await dataSource.clearLibrary();
  /// ```
  Future<void> clearLibrary() async {
    _ensureInitialized();

    try {
      final count = _audioBox.length;
      await _audioBox.clear();

      _logger.w('Cleared entire library ($count files deleted)');
    } on Exception catch (e) {
      _logger.e('Failed to clear library', error: e);
      throw StorageException('Failed to clear library', e);
    }
  }

  // ---------------------------------------------------------------------------
  // Streams
  // ---------------------------------------------------------------------------

  /// Stream of library changes.
  ///
  /// Emits whenever files are added, updated, or deleted.
  /// Use this for reactive UI updates.
  ///
  /// ## Example
  ///
  /// ```dart
  /// dataSource.watchLibrary().listen((files) {
  ///   print('Library updated: ${files.length} files');
  /// });
  /// ```
  Stream<List<AudioFile>> watchLibrary() {
    _ensureInitialized();

    return _audioBox.watch().map((_) => _audioBox.values.toList());
  }

  /// Stream of a specific audio file.
  ///
  /// Emits whenever the file is updated.
  ///
  /// ## Parameters
  ///
  /// - [id]: Audio file ID to watch
  ///
  /// ## Example
  ///
  /// ```dart
  /// dataSource.watchAudioFile(audioFile.id).listen((file) {
  ///   print('File updated: ${file?.title}');
  /// });
  /// ```
  Stream<AudioFile?> watchAudioFile(String id) {
    _ensureInitialized();

    return _audioBox.watch(key: id).map((_) => _audioBox.get(id));
  }

  // ---------------------------------------------------------------------------
  // Helper Methods
  // ---------------------------------------------------------------------------

  /// Ensures the data source is initialized.
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw const StorageException(
        'HiveAudioDataSource not initialized. Call init() first.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Disposal
  // ---------------------------------------------------------------------------

  /// Disposes the data source and closes the box.
  ///
  /// Call during app shutdown or when data source is no longer needed.
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// void dispose() {
  ///   audioDataSource.dispose();
  ///   super.dispose();
  /// }
  /// ```
  Future<void> dispose() async {
    if (!_isInitialized) {
      return;
    }

    try {
      _logger.i('Disposing HiveAudioDataSource...');

      // DO NOT close Hive boxes on dispose!
      // Boxes should remain open for app lifetime to prevent
      // "Box has already been closed" errors during hot reload
      // and provider rebuilds.
      //
      // Hive boxes will be closed automatically when app terminates.
      // await _hiveService.closeBox(_boxName); // ← REMOVED

      _isInitialized = false;

      _logger.i('✓ HiveAudioDataSource disposed (box kept open)');
    } on Exception catch (e) {
      _logger.e('Error during disposal', error: e);
      // Don't throw during cleanup
    }
  }
}
