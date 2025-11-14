/// SoulTune Player Repository
///
/// Business logic layer that coordinates audio playback, library management,
/// and data persistence. Serves as the single source of truth for the player
/// feature, orchestrating multiple services and data sources.
///
/// ## Responsibilities
///
/// - **Library Management**: Scan, import, and organize music files
/// - **Playback Control**: Play, pause, seek, frequency transformation
/// - **Data Persistence**: Save/load library state via Hive
/// - **Statistics Tracking**: Play counts, favorites, recently played
/// - **Error Handling**: Graceful degradation and user-friendly errors
///
/// ## Architecture
///
/// The repository follows Clean Architecture principles:
///
/// ```
/// Presentation Layer (UI/Widgets)
///        ↓
/// Repository (Business Logic) ← You are here
///        ↓
/// Data Sources & Services (Implementation)
/// ```
///
/// ## Dependencies
///
/// - [HiveAudioDataSource]: Local storage CRUD operations
/// - [FileSystemService]: Music file scanning
/// - [MetadataService]: ID3 tag extraction
/// - [AudioPlayerService]: Playback engine with 432Hz transformation
///
/// ## Usage
///
/// ```dart
/// final repository = PlayerRepository();
/// await repository.init();
///
/// // Scan and import library
/// await repository.scanAndImportLibrary(
///   onProgress: (current, total) {
///     print('Scanning: $current / $total');
///   },
/// );
///
/// // Play with 432Hz transformation
/// await repository.playAudioFile(
///   audioFile,
///   pitchShift: kPitch432Hz,
/// );
///
/// // Toggle favorite
/// await repository.toggleFavorite(audioFile.id);
/// ```
library;

import 'package:logger/logger.dart';
import 'package:soultune/features/player/data/datasources/hive_audio_datasource.dart';
import 'package:soultune/shared/exceptions/app_exceptions.dart';
import 'package:soultune/shared/models/audio_file.dart';
import 'package:soultune/shared/services/audio/audio_player_service.dart';
import 'package:soultune/shared/services/audio/metadata_service.dart';
import 'package:soultune/shared/services/file/file_system_service.dart';
import 'package:soultune/shared/services/file/permission_service.dart';

/// Repository for player feature business logic.
///
/// Coordinates multiple services to provide a unified API for audio playback
/// and library management. Handles error recovery and data consistency.
///
/// **Lifecycle**: Call [init] before use, [dispose] on cleanup.
class PlayerRepository {
  /// Creates a [PlayerRepository] instance.
  ///
  /// Optionally accepts custom implementations of dependencies for
  /// dependency injection (useful for testing).
  PlayerRepository({
    HiveAudioDataSource? dataSource,
    FileSystemService? fileSystemService,
    MetadataService? metadataService,
    AudioPlayerService? audioPlayerService,
    PermissionService? permissionService,
  })  : _dataSource = dataSource ?? HiveAudioDataSource(),
        _fileSystemService = fileSystemService ?? FileSystemService(),
        _metadataService = metadataService ?? MetadataService(),
        _audioPlayerService = audioPlayerService ?? AudioPlayerService(),
        _permissionService = permissionService ?? PermissionService() {
    _logger.d('PlayerRepository created');
  }

  /// Logger instance for debugging.
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Local storage data source.
  final HiveAudioDataSource _dataSource;

  /// File system scanning service.
  final FileSystemService _fileSystemService;

  /// Metadata extraction service.
  final MetadataService _metadataService;

  /// Audio playback service.
  final AudioPlayerService _audioPlayerService;

  /// Permission management service.
  final PermissionService _permissionService;

  /// Whether the repository has been initialized.
  bool _isInitialized = false;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Initializes the repository and all dependencies.
  ///
  /// Must be called before any operations. Initializes:
  /// - Hive data source
  /// - Audio player service
  ///
  /// ## Example
  ///
  /// ```dart
  /// final repository = PlayerRepository();
  /// await repository.init();
  /// ```
  ///
  /// ## Throws
  ///
  /// [AppException] if initialization fails.
  Future<void> init() async {
    if (_isInitialized) {
      _logger.w('PlayerRepository already initialized');
      return;
    }

    try {
      _logger.i('Initializing PlayerRepository...');

      // Initialize data source
      await _dataSource.init();

      // Initialize audio player
      await _audioPlayerService.init();

      _isInitialized = true;

      final librarySize = await _dataSource.getAudioFileCount();

      _logger.i(
        '✓ PlayerRepository initialized '
        '($librarySize files in library)',
      );
    } on Exception catch (e, stackTrace) {
      _logger.e(
        'Failed to initialize PlayerRepository',
        error: e,
        stackTrace: stackTrace,
      );

      throw AppException(
        'Failed to initialize player',
        e,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Library Management
  // ---------------------------------------------------------------------------

  /// Scans device storage and imports new music files to library.
  ///
  /// Performs complete library scan:
  /// 1. Requests storage permission (if needed)
  /// 2. Scans common music directories
  /// 3. Filters files already in library
  /// 4. Extracts metadata from new files
  /// 5. Saves to local database
  ///
  /// ## Parameters
  ///
  /// - [onProgress]: Optional callback `(current, total)` for scan progress
  /// - [extractAlbumArt]: Whether to extract album artwork (default: true)
  ///
  /// ## Returns
  ///
  /// Number of new files added to library.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final newFiles = await repository.scanAndImportLibrary(
  ///   onProgress: (current, total) {
  ///     print('Scanning: ${(current / total * 100).toInt()}%');
  ///   },
  /// );
  ///
  /// print('Added $newFiles new tracks');
  /// ```
  ///
  /// ## Throws
  ///
  /// - [PermissionException]: If storage permission denied
  /// - [FileException]: If music directories inaccessible
  Future<int> scanAndImportLibrary({
    void Function(int current, int total)? onProgress,
    bool extractAlbumArt = true,
  }) async {
    _ensureInitialized();

    try {
      _logger.i('Starting library scan and import...');

      // Scan file system
      final scannedFiles = await _fileSystemService.scanMusicLibrary(
        onProgress: onProgress,
        extractAlbumArt: extractAlbumArt,
      );

      if (scannedFiles.isEmpty) {
        _logger.w('No audio files found during scan');
        return 0;
      }

      // Get existing file paths to avoid duplicates
      final existingFiles = await _dataSource.getAllAudioFiles();
      final existingPaths = existingFiles.map((f) => f.filePath).toSet();

      // Filter new files only
      final newFiles = scannedFiles.where((file) {
        return !existingPaths.contains(file.filePath);
      }).toList();

      if (newFiles.isEmpty) {
        _logger.i('No new files to import (${scannedFiles.length} already in library)');
        return 0;
      }

      // Save new files to database
      await _dataSource.saveAudioFiles(newFiles);

      _logger.i(
        'Import complete: ${newFiles.length} new files added '
        '(${scannedFiles.length - newFiles.length} duplicates skipped)',
      );

      return newFiles.length;
    } on PermissionException {
      rethrow;
    } on Exception catch (e, stackTrace) {
      _logger.e(
        'Failed to scan and import library',
        error: e,
        stackTrace: stackTrace,
      );

      throw AppException(
        'Failed to scan music library',
        e,
      );
    }
  }

  /// Imports manually selected audio files.
  ///
  /// Opens file picker for user selection and imports chosen files.
  ///
  /// ## Parameters
  ///
  /// - [allowMultiple]: Allow selecting multiple files (default: true)
  /// - [extractAlbumArt]: Extract album artwork (default: true)
  ///
  /// ## Returns
  ///
  /// Number of files successfully imported.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final imported = await repository.importFiles();
  /// print('Imported $imported files');
  /// ```
  Future<int> importFiles({
    bool allowMultiple = true,
    bool extractAlbumArt = true,
  }) async {
    _ensureInitialized();

    try {
      _logger.i('Opening file picker for manual import...');

      final selectedFiles = await _fileSystemService.pickAudioFiles(
        allowMultiple: allowMultiple,
        extractAlbumArt: extractAlbumArt,
      );

      if (selectedFiles.isEmpty) {
        _logger.d('No files selected');
        return 0;
      }

      // Filter duplicates
      final existingFiles = await _dataSource.getAllAudioFiles();
      final existingPaths = existingFiles.map((f) => f.filePath).toSet();

      final newFiles = selectedFiles.where((file) {
        return !existingPaths.contains(file.filePath);
      }).toList();

      if (newFiles.isEmpty) {
        _logger.i('All selected files already in library');
        return 0;
      }

      // Save to database
      await _dataSource.saveAudioFiles(newFiles);

      _logger.i('Imported ${newFiles.length} files');

      return newFiles.length;
    } on Exception catch (e, stackTrace) {
      _logger.e(
        'Failed to import files',
        error: e,
        stackTrace: stackTrace,
      );

      throw AppException(
        'Failed to import audio files',
        e,
      );
    }
  }

  /// Removes an audio file from the library.
  ///
  /// **Note**: This only removes from the app's library database,
  /// not the actual file from device storage.
  ///
  /// ## Parameters
  ///
  /// - [id]: Audio file ID to remove
  ///
  /// ## Example
  ///
  /// ```dart
  /// await repository.removeFromLibrary(audioFile.id);
  /// ```
  Future<void> removeFromLibrary(String id) async {
    _ensureInitialized();

    try {
      await _dataSource.deleteAudioFile(id);

      _logger.i('Removed file from library: $id');
    } on Exception catch (e) {
      _logger.e('Failed to remove from library', error: e);
      throw AppException('Failed to remove from library', e);
    }
  }

  /// Clears the entire library.
  ///
  /// **WARNING**: Permanently removes all library data (not actual files).
  ///
  /// ## Example
  ///
  /// ```dart
  /// await repository.clearLibrary();
  /// ```
  Future<void> clearLibrary() async {
    _ensureInitialized();

    try {
      await _dataSource.clearLibrary();

      _logger.w('Library cleared');
    } on Exception catch (e) {
      _logger.e('Failed to clear library', error: e);
      throw AppException('Failed to clear library', e);
    }
  }

  // ---------------------------------------------------------------------------
  // Library Queries
  // ---------------------------------------------------------------------------

  /// Gets all audio files in the library.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final allFiles = await repository.getAllAudioFiles();
  /// ```
  Future<List<AudioFile>> getAllAudioFiles() async {
    _ensureInitialized();

    try {
      return await _dataSource.getAllAudioFiles();
    } on Exception catch (e) {
      _logger.e('Failed to get all audio files', error: e);
      throw AppException('Failed to load library', e);
    }
  }

  /// Gets a single audio file by ID.
  ///
  /// Returns `null` if not found.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final file = await repository.getAudioFile('abc-123');
  /// ```
  Future<AudioFile?> getAudioFile(String id) async {
    _ensureInitialized();

    try {
      return await _dataSource.getAudioFile(id);
    } on Exception catch (e) {
      _logger.e('Failed to get audio file', error: e);
      throw AppException('Failed to load audio file', e);
    }
  }

  /// Gets favorite audio files.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final favorites = await repository.getFavorites();
  /// ```
  Future<List<AudioFile>> getFavorites() async {
    _ensureInitialized();

    try {
      return await _dataSource.getFavorites();
    } on Exception catch (e) {
      _logger.e('Failed to get favorites', error: e);
      throw AppException('Failed to load favorites', e);
    }
  }

  /// Gets recently added audio files.
  ///
  /// ## Parameters
  ///
  /// - [limit]: Maximum number of files (default: 20)
  ///
  /// ## Example
  ///
  /// ```dart
  /// final recent = await repository.getRecentlyAdded(limit: 10);
  /// ```
  Future<List<AudioFile>> getRecentlyAdded({int limit = 20}) async {
    _ensureInitialized();

    try {
      return await _dataSource.getRecentlyAdded(limit: limit);
    } on Exception catch (e) {
      _logger.e('Failed to get recently added', error: e);
      throw AppException('Failed to load recently added', e);
    }
  }

  /// Gets most played audio files.
  ///
  /// ## Parameters
  ///
  /// - [limit]: Maximum number of files (default: 20)
  ///
  /// ## Example
  ///
  /// ```dart
  /// final popular = await repository.getMostPlayed(limit: 10);
  /// ```
  Future<List<AudioFile>> getMostPlayed({int limit = 20}) async {
    _ensureInitialized();

    try {
      return await _dataSource.getMostPlayed(limit: limit);
    } on Exception catch (e) {
      _logger.e('Failed to get most played', error: e);
      throw AppException('Failed to load most played', e);
    }
  }

  /// Searches audio files by title or artist.
  ///
  /// ## Parameters
  ///
  /// - [query]: Search query string
  ///
  /// ## Example
  ///
  /// ```dart
  /// final results = await repository.searchAudioFiles('meditation');
  /// ```
  Future<List<AudioFile>> searchAudioFiles(String query) async {
    _ensureInitialized();

    try {
      return await _dataSource.searchAudioFiles(query);
    } on Exception catch (e) {
      _logger.e('Failed to search audio files', error: e);
      throw AppException('Failed to search library', e);
    }
  }

  // ---------------------------------------------------------------------------
  // Playback Control
  // ---------------------------------------------------------------------------

  /// Plays an audio file with optional frequency transformation.
  ///
  /// ## Parameters
  ///
  /// - [audioFile]: The audio file to play
  /// - [pitchShift]: Semitone shift for frequency transformation (default: 0.0)
  ///   - Use constants: kPitch432Hz, kPitch528Hz, kPitch639Hz
  /// - [startPosition]: Optional starting position (default: beginning)
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Play with 432Hz transformation
  /// await repository.playAudioFile(
  ///   audioFile,
  ///   pitchShift: kPitch432Hz,
  /// );
  /// ```
  Future<void> playAudioFile(
    AudioFile audioFile, {
    double pitchShift = 0.0,
    Duration? startPosition,
  }) async {
    _ensureInitialized();

    try {
      await _audioPlayerService.play(audioFile, pitchShift, startPosition);

      _logger.i(
        'Playing: ${audioFile.title} '
        '(pitch: ${pitchShift.toStringAsFixed(3)} semitones)',
      );
    } on Exception catch (e, stackTrace) {
      _logger.e(
        'Failed to play audio file',
        error: e,
        stackTrace: stackTrace,
      );

      throw AudioException(
        'Failed to play audio file',
        e,
      );
    }
  }

  /// Pauses playback.
  ///
  /// ## Example
  ///
  /// ```dart
  /// await repository.pause();
  /// ```
  Future<void> pause() async {
    _ensureInitialized();

    try {
      await _audioPlayerService.pause();
    } on Exception catch (e) {
      _logger.e('Failed to pause', error: e);
      throw AudioException('Failed to pause playback', e);
    }
  }

  /// Resumes playback.
  ///
  /// ## Example
  ///
  /// ```dart
  /// await repository.resume();
  /// ```
  Future<void> resume() async {
    _ensureInitialized();

    try {
      await _audioPlayerService.play();
    } on Exception catch (e) {
      _logger.e('Failed to resume', error: e);
      throw AudioException('Failed to resume playback', e);
    }
  }

  /// Stops playback.
  ///
  /// ## Example
  ///
  /// ```dart
  /// await repository.stop();
  /// ```
  Future<void> stop() async {
    _ensureInitialized();

    try {
      await _audioPlayerService.stop();
    } on Exception catch (e) {
      _logger.e('Failed to stop', error: e);
      throw AudioException('Failed to stop playback', e);
    }
  }

  /// Seeks to a specific position.
  ///
  /// ## Parameters
  ///
  /// - [position]: Target position
  ///
  /// ## Example
  ///
  /// ```dart
  /// await repository.seek(Duration(minutes: 1));
  /// ```
  Future<void> seek(Duration position) async {
    _ensureInitialized();

    try {
      await _audioPlayerService.seek(position);
    } on Exception catch (e) {
      _logger.e('Failed to seek', error: e);
      throw AudioException('Failed to seek', e);
    }
  }

  /// Changes the pitch shift (frequency transformation) in real-time.
  ///
  /// ## Parameters
  ///
  /// - [semitones]: Pitch shift in semitones
  ///   - Use constants: kPitch432Hz, kPitch528Hz, kPitch639Hz
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Transform to 432Hz while playing
  /// await repository.setPitchShift(kPitch432Hz);
  /// ```
  Future<void> setPitchShift(double semitones) async {
    _ensureInitialized();

    try {
      await _audioPlayerService.setPitchShift(semitones);
    } on Exception catch (e) {
      _logger.e('Failed to set pitch shift', error: e);
      throw AudioException('Failed to change frequency', e);
    }
  }

  /// Sets playback speed.
  ///
  /// ## Parameters
  ///
  /// - [speed]: Speed multiplier (0.5 - 2.0)
  ///
  /// ## Example
  ///
  /// ```dart
  /// await repository.setSpeed(0.8); // Slow down for meditation
  /// ```
  Future<void> setSpeed(double speed) async {
    _ensureInitialized();

    try {
      await _audioPlayerService.setSpeed(speed);
    } on Exception catch (e) {
      _logger.e('Failed to set speed', error: e);
      throw AudioException('Failed to change speed', e);
    }
  }

  /// Sets volume.
  ///
  /// ## Parameters
  ///
  /// - [volume]: Volume level (0.0 - 1.0)
  ///
  /// ## Example
  ///
  /// ```dart
  /// await repository.setVolume(0.5);
  /// ```
  Future<void> setVolume(double volume) async {
    _ensureInitialized();

    try {
      await _audioPlayerService.setVolume(volume);
    } on Exception catch (e) {
      _logger.e('Failed to set volume', error: e);
      throw AudioException('Failed to set volume', e);
    }
  }

  // ---------------------------------------------------------------------------
  // User Actions
  // ---------------------------------------------------------------------------

  /// Toggles favorite status for an audio file.
  ///
  /// ## Parameters
  ///
  /// - [id]: Audio file ID
  ///
  /// ## Returns
  ///
  /// Updated audio file instance.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final updated = await repository.toggleFavorite(audioFile.id);
  /// ```
  Future<AudioFile> toggleFavorite(String id) async {
    _ensureInitialized();

    try {
      return await _dataSource.toggleFavorite(id);
    } on Exception catch (e) {
      _logger.e('Failed to toggle favorite', error: e);
      throw AppException('Failed to toggle favorite', e);
    }
  }

  /// Records a play event (increments play count, updates last played).
  ///
  /// Should be called when a track finishes or user plays >50% of duration.
  ///
  /// ## Parameters
  ///
  /// - [id]: Audio file ID
  ///
  /// ## Returns
  ///
  /// Updated audio file instance.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final updated = await repository.recordPlay(audioFile.id);
  /// ```
  Future<AudioFile> recordPlay(String id) async {
    _ensureInitialized();

    try {
      return await _dataSource.incrementPlayCount(id);
    } on Exception catch (e) {
      _logger.e('Failed to record play', error: e);
      throw AppException('Failed to record play', e);
    }
  }

  // ---------------------------------------------------------------------------
  // Getters & Streams
  // ---------------------------------------------------------------------------

  /// Whether audio is currently playing.
  bool get isPlaying => _audioPlayerService.isPlaying;

  /// Current playback position.
  Duration get position => _audioPlayerService.position;

  /// Total duration of current track.
  Duration? get duration => _audioPlayerService.duration;

  /// Currently playing audio file.
  AudioFile? get currentAudioFile => _audioPlayerService.currentAudioFile;

  /// Current pitch shift in semitones.
  double get currentPitchShift => _audioPlayerService.currentPitchShift;

  /// Current playback speed.
  double get currentSpeed => _audioPlayerService.currentSpeed;

  /// Stream of playback positions.
  Stream<Duration> get positionStream => _audioPlayerService.positionStream;

  /// Stream of duration changes.
  Stream<Duration?> get durationStream => _audioPlayerService.durationStream;

  /// Stream of playing state changes.
  Stream<bool> get playingStream => _audioPlayerService.playingStream;

  /// Stream of library changes.
  Stream<List<AudioFile>> get libraryStream => _dataSource.watchLibrary();

  // ---------------------------------------------------------------------------
  // Helper Methods
  // ---------------------------------------------------------------------------

  /// Ensures the repository is initialized.
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw const AppException(
        'PlayerRepository not initialized. Call init() first.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Disposal
  // ---------------------------------------------------------------------------

  /// Disposes the repository and all dependencies.
  ///
  /// Call during app shutdown.
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// void dispose() {
  ///   playerRepository.dispose();
  ///   super.dispose();
  /// }
  /// ```
  Future<void> dispose() async {
    if (!_isInitialized) {
      return;
    }

    try {
      _logger.i('Disposing PlayerRepository...');

      await _audioPlayerService.dispose();
      await _dataSource.dispose();

      _isInitialized = false;

      _logger.i('✓ PlayerRepository disposed');
    } on Exception catch (e) {
      _logger.e('Error during disposal', error: e);
      // Don't throw during cleanup
    }
  }
}
