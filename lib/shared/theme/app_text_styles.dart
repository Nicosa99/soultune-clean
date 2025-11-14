/// SoulTune Typography System
///
/// Implements Material 3 typography scale with customizations for optimal
/// readability in a music player interface. The type system emphasizes:
///
/// - Clear hierarchy for music metadata (artist, album, track)
/// - Legibility in dark mode environments
/// - Smooth scaling across device sizes
/// - Accessibility compliance
///
/// ## Type Scale
///
/// Material 3 defines 5 categories with 3 sizes each:
/// - **Display**: Large, high-impact text (headings, titles)
/// - **Headline**: Medium to large text (section headers)
/// - **Title**: Medium text (card titles, list headers)
/// - **Body**: Default text (paragraphs, descriptions)
/// - **Label**: Small text (buttons, captions)
///
/// ## Font Stack
///
/// Currently uses system fonts. Future versions may include:
/// - Inter for headings (clean, modern)
/// - SF Pro / Roboto for body (platform-native)
///
/// ## References
///
/// - Material 3 Type Scale: https://m3.material.io/styles/typography/
/// - Flutter TextStyle: https://api.flutter.dev/flutter/painting/TextStyle-class.html
library;

import 'package:flutter/material.dart';
import 'package:soultune/shared/theme/app_colors.dart';

/// Typography constants and text styles for the application.
///
/// All text styles follow Material 3 design guidelines with customizations
/// for SoulTune's dark theme and music player aesthetic.
class AppTextStyles {
  AppTextStyles._(); // Private constructor to prevent instantiation

  // ---------------------------------------------------------------------------
  // Font Families
  // ---------------------------------------------------------------------------

  /// Default sans-serif font family (system font).
  ///
  /// Falls back to platform defaults:
  /// - iOS/macOS: SF Pro
  /// - Android: Roboto
  /// - Windows: Segoe UI
  static const String defaultFontFamily = '';

  /// Monospace font for technical displays (duration, timestamps).
  static const String monospaceFontFamily = 'monospace';

  // ---------------------------------------------------------------------------
  // Display Styles (Large, high-impact text)
  // ---------------------------------------------------------------------------

  /// Display Large - 57sp
  ///
  /// Usage: Rarely used, very large headings
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    height: 1.12,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    color: AppColors.onBackground,
  );

  /// Display Medium - 45sp
  ///
  /// Usage: Large section headers, splash screens
  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    height: 1.16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );

  /// Display Small - 36sp
  ///
  /// Usage: Now Playing track title (prominent)
  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    height: 1.22,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );

  // ---------------------------------------------------------------------------
  // Headline Styles (Medium to large text)
  // ---------------------------------------------------------------------------

  /// Headline Large - 32sp
  ///
  /// Usage: Screen titles, main headers
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    height: 1.25,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );

  /// Headline Medium - 28sp
  ///
  /// Usage: Section headers in settings, library
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    height: 1.29,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );

  /// Headline Small - 24sp
  ///
  /// Usage: Card headers, dialog titles
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    height: 1.33,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );

  // ---------------------------------------------------------------------------
  // Title Styles (Medium text for list items and cards)
  // ---------------------------------------------------------------------------

  /// Title Large - 22sp
  ///
  /// Usage: Now Playing track title (alternative to display)
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    height: 1.27,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );

  /// Title Medium - 16sp
  ///
  /// Usage: List item titles, track names in library
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    color: AppColors.onBackground,
  );

  /// Title Small - 14sp
  ///
  /// Usage: Small card titles, secondary headers
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.onBackground,
  );

  // ---------------------------------------------------------------------------
  // Body Styles (Default paragraph and description text)
  // ---------------------------------------------------------------------------

  /// Body Large - 16sp
  ///
  /// Usage: Primary body text, descriptions
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: AppColors.onBackground,
  );

  /// Body Medium - 14sp
  ///
  /// Usage: Artist names, album names, secondary info
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: AppColors.onSurfaceVariant,
  );

  /// Body Small - 12sp
  ///
  /// Usage: Tertiary information, metadata
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.onSurfaceVariant,
  );

  // ---------------------------------------------------------------------------
  // Label Styles (Small text for buttons, captions, badges)
  // ---------------------------------------------------------------------------

  /// Label Large - 14sp
  ///
  /// Usage: Button text, tab labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.onBackground,
  );

  /// Label Medium - 12sp
  ///
  /// Usage: Frequency labels, filter chips
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.onBackground,
  );

  /// Label Small - 11sp
  ///
  /// Usage: Timestamps, tiny labels
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    height: 1.45,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.onSurfaceVariant,
  );

  // ---------------------------------------------------------------------------
  // Custom Styles for SoulTune
  // ---------------------------------------------------------------------------

  /// Now Playing - Track Title
  ///
  /// Large, bold text for the currently playing track name.
  /// Optimized for quick readability at a glance.
  static const TextStyle nowPlayingTitle = TextStyle(
    fontSize: 28,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.onBackground,
  );

  /// Now Playing - Artist Name
  ///
  /// Medium text for artist name below track title.
  static const TextStyle nowPlayingArtist = TextStyle(
    fontSize: 18,
    height: 1.4,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    color: AppColors.onSurfaceVariant,
  );

  /// Now Playing - Album Name
  ///
  /// Small text for album name.
  static const TextStyle nowPlayingAlbum = TextStyle(
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: AppColors.onSurfaceVariant,
  );

  /// Duration / Timestamp (e.g., "2:34" or "5:12")
  ///
  /// Monospace font for consistent width and alignment.
  static const TextStyle duration = TextStyle(
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    fontFamily: monospaceFontFamily,
    fontFeatures: [FontFeature.tabularFigures()],
    color: AppColors.onSurfaceVariant,
  );

  /// Frequency Label (e.g., "432 Hz")
  ///
  /// Bold, prominent label for frequency indicators.
  static const TextStyle frequencyLabel = TextStyle(
    fontSize: 16,
    height: 1.4,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.primary,
  );

  /// Frequency Description
  ///
  /// Smaller text for frequency explanations.
  static const TextStyle frequencyDescription = TextStyle(
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.onSurfaceVariant,
  );

  /// List Item - Track Title
  ///
  /// Used in library lists for track names.
  static const TextStyle listItemTitle = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    color: AppColors.onSurface,
  );

  /// List Item - Subtitle (Artist/Album)
  ///
  /// Secondary text in list items.
  static const TextStyle listItemSubtitle = TextStyle(
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: AppColors.onSurfaceVariant,
  );

  /// Button Text - Primary
  ///
  /// Text for primary action buttons.
  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.onPrimary,
  );

  /// Button Text - Secondary
  ///
  /// Text for secondary/outline buttons.
  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.primary,
  );

  /// Premium Badge
  ///
  /// Text for "Premium" badges on locked features.
  static const TextStyle premiumBadge = TextStyle(
    fontSize: 10,
    height: 1.4,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: AppColors.tertiary,
  );

  /// Empty State Title
  ///
  /// Large text for empty state messages.
  static const TextStyle emptyStateTitle = TextStyle(
    fontSize: 20,
    height: 1.4,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    color: AppColors.onSurfaceVariant,
  );

  /// Empty State Description
  ///
  /// Body text for empty state explanations.
  static const TextStyle emptyStateDescription = TextStyle(
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: AppColors.onSurfaceVariant,
  );

  // ---------------------------------------------------------------------------
  // Utility Methods
  // ---------------------------------------------------------------------------

  /// Creates a text style with a specific color.
  ///
  /// Useful for applying semantic colors to base styles.
  static TextStyle withColor(TextStyle style, Color color) =>
      style.copyWith(color: color);

  /// Creates a bold variant of the given text style.
  static TextStyle bold(TextStyle style) =>
      style.copyWith(fontWeight: FontWeight.w700);

  /// Creates a semi-bold variant of the given text style.
  static TextStyle semiBold(TextStyle style) =>
      style.copyWith(fontWeight: FontWeight.w600);

  /// Creates a medium variant of the given text style.
  static TextStyle medium(TextStyle style) =>
      style.copyWith(fontWeight: FontWeight.w500);

  /// Creates an italic variant of the given text style.
  static TextStyle italic(TextStyle style) =>
      style.copyWith(fontStyle: FontStyle.italic);

  /// Creates a text style with custom opacity.
  static TextStyle withOpacity(TextStyle style, double opacity) =>
      style.copyWith(color: style.color?.withOpacity(opacity));
}
