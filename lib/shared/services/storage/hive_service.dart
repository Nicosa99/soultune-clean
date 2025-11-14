/// SoulTune Hive Storage Service
///
/// Provides centralized management of Hive local database operations.
/// Implements singleton pattern to ensure single source of truth for
/// storage operations throughout the application lifecycle.
///
/// ## Features
///
/// - Thread-safe singleton initialization
/// - Automatic storage path resolution
/// - Type-safe box access
/// - Adapter registration management
/// - Graceful error handling
/// - Resource cleanup
///
/// ## Usage
///
/// ```dart
/// // Initialize during app startup
/// await HiveService.instance.init();
///
/// // Access boxes through the service
/// final audioBox = HiveService.instance.getBox<AudioFile>('audio_files');
///
/// // Cleanup during app shutdown
/// await HiveService.instance.close();
/// ```
library;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soultune/shared/exceptions/app_exceptions.dart';

/// Manages Hive local database initialization, box access, and lifecycle.
///
/// This service follows the singleton pattern to ensure consistent database
/// state across the application. It handles:
///
/// - Platform-specific storage path configuration
/// - Type adapter registration for custom models
/// - Box opening and caching
/// - Error handling and recovery
/// - Resource disposal
///
/// **Thread Safety**: This class uses a singleton pattern but is not
/// inherently thread-safe. Ensure initialization completes before accessing
/// boxes from multiple isolates.
class HiveService {
  // Private constructor for singleton pattern
  HiveService._internal();

  /// Singleton instance of [HiveService].
  ///
  /// Access this instance throughout the application to interact with
  /// Hive storage.
  static final HiveService instance = HiveService._internal();

  /// Logger instance for debugging and error tracking.
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

  /// Whether Hive has been successfully initialized.
  bool _isInitialized = false;

  /// Getter to check initialization status.
  ///
  /// Use this before attempting to access boxes to prevent errors.
  bool get isInitialized => _isInitialized;

  /// Cache of opened boxes for reuse.
  ///
  /// Prevents redundant box opening operations and maintains references
  /// to active boxes for efficient access.
  final Map<String, Box<dynamic>> _openBoxes = {};

  /// Initializes Hive with proper storage path and adapters.
  ///
  /// This method must be called during app startup before accessing any
  /// Hive boxes. It performs the following:
  ///
  /// 1. Determines platform-specific storage directory
  /// 2. Initializes Hive with the storage path
  /// 3. Registers all required type adapters
  ///
  /// ## Error Handling
  ///
  /// Throws [StorageException] if:
  /// - Storage directory cannot be accessed
  /// - Hive initialization fails
  /// - Adapter registration fails
  ///
  /// ## Example
  ///
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///
  ///   try {
  ///     await HiveService.instance.init();
  ///   } on StorageException catch (e) {
  ///     // Handle initialization failure
  ///     print('Storage init failed: ${e.message}');
  ///     return;
  ///   }
  ///
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// ## Platform Notes
  ///
  /// - **Android**: Uses `getApplicationDocumentsDirectory()`
  /// - **iOS**: Uses `getApplicationDocumentsDirectory()`
  /// - **Desktop**: Uses `getApplicationSupportDirectory()`
  /// - **Web**: Uses browser storage (handled by Hive automatically)
  Future<void> init() async {
    if (_isInitialized) {
      _logger.w('HiveService already initialized. Skipping...');
      return;
    }

    try {
      _logger.i('Initializing HiveService...');

      // Get platform-specific storage directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final hivePath = '${appDocDir.path}/soultune_db';

      _logger.d('Hive storage path: $hivePath');

      // Initialize Hive with Flutter support
      await Hive.initFlutter(hivePath);

      // Register type adapters here
      // Note: Adapters will be registered as models are created
      // Example: Hive.registerAdapter(AudioFileAdapter());
      _registerAdapters();

      _isInitialized = true;
      _logger.i('✓ HiveService initialized successfully');
    } on Exception catch (e, stackTrace) {
      _logger.e(
        'Failed to initialize HiveService',
        error: e,
        stackTrace: stackTrace,
      );
      throw StorageException(
        'Failed to initialize local storage',
        e,
      );
    }
  }

  /// Registers all Hive type adapters for custom data models.
  ///
  /// Type adapters must be registered before opening boxes containing
  /// custom types. This method is called automatically during [init].
  ///
  /// **Important**: Each adapter must have a unique `typeId` to avoid
  /// conflicts. TypeIds are defined in the model classes.
  ///
  /// ## Adapter Registration Pattern
  ///
  /// ```dart
  /// if (!Hive.isAdapterRegistered(AudioFileAdapter().typeId)) {
  ///   Hive.registerAdapter(AudioFileAdapter());
  /// }
  /// ```
  void _registerAdapters() {
    _logger.d('Registering Hive type adapters...');

    // Type adapters will be registered here as models are implemented
    // Phase 1.3 will add:
    // - AudioFile adapter
    // - Playlist adapter
    // - FrequencySetting adapter (if stored locally)

    // Example pattern:
    // if (!Hive.isAdapterRegistered(1)) {
    //   Hive.registerAdapter(AudioFileAdapter());
    //   _logger.d('Registered AudioFileAdapter (typeId: 1)');
    // }

    _logger.d('Type adapter registration complete');
  }

  /// Opens or retrieves a typed Hive box.
  ///
  /// If the box is already open, returns the cached instance.
  /// Otherwise, opens the box and caches it for future access.
  ///
  /// ## Type Safety
  ///
  /// The generic type [T] ensures compile-time type safety:
  ///
  /// ```dart
  /// // Type-safe box access
  /// final Box<AudioFile> audioBox = service.getBox<AudioFile>('audio_files');
  /// final AudioFile file = audioBox.getAt(0); // No cast needed
  /// ```
  ///
  /// ## Parameters
  ///
  /// - [boxName]: Unique identifier for the box. Use consistent naming:
  ///   - `audio_files` - Stores [AudioFile] objects
  ///   - `playlists` - Stores [Playlist] objects
  ///   - `settings` - Stores app settings
  ///
  /// ## Error Handling
  ///
  /// Throws [StorageException] if:
  /// - Hive is not initialized (call [init] first)
  /// - Box cannot be opened (corruption, permission issues)
  /// - Type adapter not registered for [T]
  ///
  /// ## Example
  ///
  /// ```dart
  /// try {
  ///   final audioBox = HiveService.instance.getBox<AudioFile>('audio_files');
  ///   final files = audioBox.values.toList();
  /// } on StorageException catch (e) {
  ///   // Handle error
  /// }
  /// ```
  Box<T> getBox<T>(String boxName) {
    if (!_isInitialized) {
      throw const StorageException(
        'HiveService not initialized. Call init() first.',
      );
    }

    try {
      // Check cache first
      if (_openBoxes.containsKey(boxName)) {
        _logger.d('Retrieved cached box: $boxName');
        return _openBoxes[boxName]! as Box<T>;
      }

      // Box must be opened asynchronously, but this method is synchronous
      // for convenience. Boxes should be pre-opened during app initialization.
      // If a box is not found in cache, it means it wasn't opened properly.
      throw StorageException(
        'Box "$boxName" not found. Use openBox() during initialization.',
      );
    } on Exception catch (e) {
      _logger.e('Failed to get box: $boxName', error: e);
      throw StorageException(
        'Failed to access storage box: $boxName',
        e,
      );
    }
  }

  /// Opens a Hive box asynchronously and caches it.
  ///
  /// This method should be called during app initialization to prepare
  /// all required boxes for use. Once opened, boxes can be accessed
  /// synchronously via [getBox].
  ///
  /// ## Parameters
  ///
  /// - [boxName]: Unique identifier for the box
  /// - [lazy]: If true, opens box in lazy mode (values loaded on demand)
  ///
  /// ## Error Handling
  ///
  /// Throws [StorageException] if box cannot be opened.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // During app initialization
  /// await HiveService.instance.openBox<AudioFile>('audio_files');
  /// await HiveService.instance.openBox<Playlist>('playlists');
  ///
  /// // Later, access synchronously
  /// final audioBox = HiveService.instance.getBox<AudioFile>('audio_files');
  /// ```
  Future<Box<T>> openBox<T>(
    String boxName, {
    bool lazy = false,
  }) async {
    if (!_isInitialized) {
      throw const StorageException(
        'HiveService not initialized. Call init() first.',
      );
    }

    try {
      // Check if already open
      if (_openBoxes.containsKey(boxName)) {
        _logger.d('Box "$boxName" already open');
        return _openBoxes[boxName]! as Box<T>;
      }

      _logger.d('Opening box: $boxName (lazy: $lazy)');

      final Box<T> box = lazy
          ? await Hive.openLazyBox<T>(boxName)
          : await Hive.openBox<T>(boxName);

      // Cache the box
      _openBoxes[boxName] = box;

      _logger.i('✓ Opened box: $boxName (${box.length} items)');

      return box;
    } on Exception catch (e, stackTrace) {
      _logger.e(
        'Failed to open box: $boxName',
        error: e,
        stackTrace: stackTrace,
      );
      throw StorageException(
        'Failed to open storage box: $boxName',
        e,
      );
    }
  }

  /// Closes a specific box and removes it from cache.
  ///
  /// Use this to free resources for boxes that are no longer needed.
  /// In most cases, you should use [close] to clean up all boxes during
  /// app shutdown instead.
  ///
  /// ## Parameters
  ///
  /// - [boxName]: Name of the box to close
  ///
  /// ## Example
  ///
  /// ```dart
  /// await HiveService.instance.closeBox('temp_cache');
  /// ```
  Future<void> closeBox(String boxName) async {
    try {
      if (_openBoxes.containsKey(boxName)) {
        await _openBoxes[boxName]?.close();
        _openBoxes.remove(boxName);
        _logger.d('Closed box: $boxName');
      }
    } on Exception catch (e) {
      _logger.e('Failed to close box: $boxName', error: e);
      // Don't throw - closing is best effort during cleanup
    }
  }

  /// Closes all open Hive boxes and performs cleanup.
  ///
  /// Call this method during app shutdown to ensure proper resource
  /// disposal and data persistence.
  ///
  /// **Important**: After calling this method, you must call [init] again
  /// before accessing any boxes.
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// void dispose() {
  ///   HiveService.instance.close();
  ///   super.dispose();
  /// }
  /// ```
  Future<void> close() async {
    try {
      _logger.i('Closing HiveService...');

      // Close all cached boxes
      for (final entry in _openBoxes.entries) {
        try {
          await entry.value.close();
          _logger.d('Closed box: ${entry.key}');
        } on Exception catch (e) {
          _logger.w('Failed to close box ${entry.key}: $e');
        }
      }

      _openBoxes.clear();

      // Close Hive completely
      await Hive.close();

      _isInitialized = false;
      _logger.i('✓ HiveService closed successfully');
    } on Exception catch (e) {
      _logger.e('Error during HiveService closure', error: e);
      // Don't throw during cleanup - log and continue
    }
  }

  /// Deletes a box from storage permanently.
  ///
  /// **Warning**: This operation cannot be undone. All data in the box
  /// will be lost.
  ///
  /// The box will be closed if currently open before deletion.
  ///
  /// ## Parameters
  ///
  /// - [boxName]: Name of the box to delete
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Clear all cached data
  /// await HiveService.instance.deleteBox('cache');
  /// ```
  Future<void> deleteBox(String boxName) async {
    try {
      _logger.w('Deleting box: $boxName');

      // Close box if open
      await closeBox(boxName);

      // Delete from storage
      await Hive.deleteBoxFromDisk(boxName);

      _logger.i('✓ Deleted box: $boxName');
    } on Exception catch (e, stackTrace) {
      _logger.e(
        'Failed to delete box: $boxName',
        error: e,
        stackTrace: stackTrace,
      );
      throw StorageException(
        'Failed to delete storage box: $boxName',
        e,
      );
    }
  }

  /// Compacts a box to reclaim disk space.
  ///
  /// Over time, Hive boxes can accumulate unused space from deleted entries.
  /// Compaction reorganizes the data to optimize storage.
  ///
  /// **Note**: This operation can be slow for large boxes. Consider running
  /// it in a background isolate or during idle time.
  ///
  /// ## Parameters
  ///
  /// - [boxName]: Name of the box to compact
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Optimize storage after bulk deletions
  /// await HiveService.instance.compactBox('audio_files');
  /// ```
  Future<void> compactBox(String boxName) async {
    try {
      if (_openBoxes.containsKey(boxName)) {
        _logger.d('Compacting box: $boxName');
        await _openBoxes[boxName]?.compact();
        _logger.i('✓ Compacted box: $boxName');
      }
    } on Exception catch (e, stackTrace) {
      _logger.e(
        'Failed to compact box: $boxName',
        error: e,
        stackTrace: stackTrace,
      );
      throw StorageException(
        'Failed to compact storage box: $boxName',
        e,
      );
    }
  }
}
