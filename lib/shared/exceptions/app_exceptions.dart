/// SoulTune Custom Exceptions
///
/// Provides a comprehensive, type-safe exception hierarchy for robust error
/// handling across the application. Each exception type represents a specific
/// failure domain and includes contextual information for debugging and user
/// feedback.
///
/// Usage:
/// ```dart
/// try {
///   await audioPlayer.play(file);
/// } on AudioException catch (e) {
///   logger.e('Audio playback failed: ${e.message}', error: e.cause);
///   // Show user-friendly error
/// }
/// ```
library;

/// Base exception class for all SoulTune application errors.
///
/// All custom exceptions should extend this class to maintain a consistent
/// error handling interface across the application.
abstract class AppException implements Exception {
  /// Creates an [AppException] with an error message and optional cause.
  const AppException(
    this.message, [
    this.cause,
  ]);

  /// Human-readable error description.
  final String message;

  /// Optional underlying error that caused this exception.
  final Object? cause;

  @override
  String toString() => 'AppException: $message${cause != null ? '\nCaused by: $cause' : ''}';
}

/// Exception thrown when audio playback or processing operations fail.
///
/// This includes failures in:
/// - Loading audio files
/// - Playback control (play, pause, seek)
/// - Pitch shifting / frequency transformation
/// - Audio session management
///
/// Example:
/// ```dart
/// throw AudioException(
///   'Failed to apply 432Hz pitch shift',
///   originalError,
/// );
/// ```
class AudioException extends AppException {
  /// Creates an [AudioException] with a message and optional cause.
  const AudioException(
    super.message, [
    super.cause,
  ]);

  @override
  String toString() => 'AudioException: $message${cause != null ? '\nCaused by: $cause' : ''}';
}

/// Exception thrown when file system operations fail.
///
/// This includes:
/// - File not found errors
/// - Permission denied errors
/// - Invalid file format
/// - Corrupted file data
/// - I/O errors during file scanning
///
/// Example:
/// ```dart
/// throw FileException(
///   'Audio file not found: /path/to/song.mp3',
///   FileSystemException('No such file'),
/// );
/// ```
class FileException extends AppException {
  /// Creates a [FileException] with a message and optional cause.
  const FileException(
    super.message, [
    super.cause,
  ]);

  @override
  String toString() => 'FileException: $message${cause != null ? '\nCaused by: $cause' : ''}';
}

/// Exception thrown when local storage (Hive) operations fail.
///
/// This includes:
/// - Database initialization failures
/// - Read/Write operation errors
/// - Data corruption
/// - Schema migration failures
/// - Box access errors
///
/// Example:
/// ```dart
/// throw StorageException(
///   'Failed to save audio file metadata to Hive',
///   HiveError('Box not open'),
/// );
/// ```
class StorageException extends AppException {
  /// Creates a [StorageException] with a message and optional cause.
  const StorageException(
    super.message, [
    super.cause,
  ]);

  @override
  String toString() => 'StorageException: $message${cause != null ? '\nCaused by: $cause' : ''}';
}

/// Exception thrown when permission requests are denied or fail.
///
/// This includes:
/// - Storage permission denied
/// - Audio recording permission denied (future)
/// - Notification permission denied (future)
/// - Permission permanently denied
///
/// Example:
/// ```dart
/// if (!granted) {
///   throw const PermissionException(
///     'Storage permission required to access music files',
///   );
/// }
/// ```
class PermissionException extends AppException {
  /// Whether the permission was permanently denied by the user.
  ///
  /// When true, the app should guide users to app settings to grant permission.
  final bool isPermanentlyDenied;

  /// Creates a [PermissionException] with a message and optional cause.
  const PermissionException(
    super.message, [
    super.cause,
    this.isPermanentlyDenied = false,
  ]);

  /// Creates a [PermissionException] for permanently denied permissions.
  const PermissionException.permanentlyDenied(
    String message, [
    Object? cause,
  ])  : isPermanentlyDenied = true,
        super(message, cause);

  @override
  String toString() => 'PermissionException: $message'
      '${isPermanentlyDenied ? ' (permanently denied)' : ''}'
      '${cause != null ? '\nCaused by: $cause' : ''}';
}

/// Exception thrown when metadata extraction fails.
///
/// This includes:
/// - Missing or corrupted ID3 tags
/// - Unsupported metadata format
/// - Album art extraction failures
/// - Duration calculation errors
///
/// Example:
/// ```dart
/// throw MetadataException(
///   'Failed to extract metadata from file: corrupted ID3 tags',
///   FormatException('Invalid tag format'),
/// );
/// ```
class MetadataException extends AppException {
  /// Creates a [MetadataException] with a message and optional cause.
  const MetadataException(
    super.message, [
    super.cause,
  ]);

  @override
  String toString() => 'MetadataException: $message${cause != null ? '\nCaused by: $cause' : ''}';
}

/// Exception thrown for network-related errors (future cloud features).
///
/// Reserved for Phase 3 cloud sync functionality.
/// Included here for forward compatibility.
class NetworkException extends AppException {
  /// Creates a [NetworkException] with a message and optional cause.
  const NetworkException(
    super.message, [
    super.cause,
  ]);

  @override
  String toString() => 'NetworkException: $message${cause != null ? '\nCaused by: $cause' : ''}';
}

/// Exception thrown when an unexpected error occurs.
///
/// Use this as a last resort when the error doesn't fit any specific category.
/// Always prefer more specific exception types when possible.
///
/// Example:
/// ```dart
/// try {
///   // some operation
/// } catch (e) {
///   throw UnknownException(
///     'An unexpected error occurred during audio processing',
///     e,
///   );
/// }
/// ```
class UnknownException extends AppException {
  /// Creates an [UnknownException] with a message and optional cause.
  const UnknownException(
    super.message, [
    super.cause,
  ]);

  @override
  String toString() => 'UnknownException: $message${cause != null ? '\nCaused by: $cause' : ''}';
}
