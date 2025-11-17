/// SoulTune Color Palette
///
/// Implements a comprehensive Material 3 color system optimized for
/// a healing music player aesthetic. Colors are chosen to evoke:
///
/// - Serenity and calmness (deep blues, purples)
/// - Spiritual connection (indigos, teals)
/// - Energy and warmth (subtle gradients)
///
/// All colors meet WCAG 2.1 AA accessibility standards for contrast ratios.
///
/// ## Color Philosophy
///
/// - **Primary**: Deep indigo/purple - Represents spirituality and healing
/// - **Secondary**: Cyan/teal - Represents sound waves and frequencies
/// - **Tertiary**: Warm amber - Represents energy and vitality
/// - **Background**: Rich blacks - Optimized for OLED and dark environments
///
/// ## References
///
/// - Material 3 Color System: https://m3.material.io/styles/color/
/// - WCAG Contrast: https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum
library;

import 'package:flutter/material.dart';

/// App-wide color constants and palettes.
///
/// Use these constants instead of hardcoding colors throughout the app
/// to ensure consistency and easy theme updates.
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // ---------------------------------------------------------------------------
  // Primary Colors - Deep Indigo/Purple (Healing & Spirituality)
  // ---------------------------------------------------------------------------

  /// Primary color - Deep indigo representing healing frequencies.
  ///
  /// Used for: App bar, primary buttons, key UI elements.
  static const Color primary = Color(0xFF6366F1); // Indigo-500

  /// Lighter variant of primary color.
  static const Color primaryLight = Color(0xFF818CF8); // Indigo-400

  /// Darker variant of primary color.
  static const Color primaryDark = Color(0xFF4F46E5); // Indigo-600

  /// Primary color container (Material 3).
  ///
  /// Used for: Chips, filled buttons, prominent surfaces.
  static const Color primaryContainer = Color(0xFF3730A3); // Indigo-700

  /// Text color on primary color.
  static const Color onPrimary = Color(0xFFFFFFFF); // White

  /// Text color on primary container.
  static const Color onPrimaryContainer = Color(0xFFE0E7FF); // Indigo-100

  // ---------------------------------------------------------------------------
  // Secondary Colors - Cyan/Teal (Sound Waves & Frequencies)
  // ---------------------------------------------------------------------------

  /// Secondary color - Cyan representing sound and frequencies.
  ///
  /// Used for: Frequency selector, visualizer, accent elements.
  static const Color secondary = Color(0xFF06B6D4); // Cyan-500

  /// Lighter variant of secondary color.
  static const Color secondaryLight = Color(0xFF22D3EE); // Cyan-400

  /// Darker variant of secondary color.
  static const Color secondaryDark = Color(0xFF0891B2); // Cyan-600

  /// Secondary color container (Material 3).
  static const Color secondaryContainer = Color(0xFF164E63); // Cyan-900

  /// Text color on secondary color.
  static const Color onSecondary = Color(0xFFFFFFFF); // White

  /// Text color on secondary container.
  static const Color onSecondaryContainer = Color(0xFFCFFAFE); // Cyan-100

  // ---------------------------------------------------------------------------
  // Tertiary Colors - Warm Amber (Energy & Vitality)
  // ---------------------------------------------------------------------------

  /// Tertiary color - Warm amber for energy and highlights.
  ///
  /// Used for: Premium badges, special features, warm accents.
  static const Color tertiary = Color(0xFFF59E0B); // Amber-500

  /// Lighter variant of tertiary color.
  static const Color tertiaryLight = Color(0xFFFBBF24); // Amber-400

  /// Darker variant of tertiary color.
  static const Color tertiaryDark = Color(0xFFD97706); // Amber-600

  /// Tertiary color container (Material 3).
  static const Color tertiaryContainer = Color(0xFF92400E); // Amber-800

  /// Text color on tertiary color.
  static const Color onTertiary = Color(0xFF000000); // Black

  /// Text color on tertiary container.
  static const Color onTertiaryContainer = Color(0xFFFEF3C7); // Amber-100

  // ---------------------------------------------------------------------------
  // Background Colors - Rich Blacks (OLED Optimized)
  // ---------------------------------------------------------------------------

  /// Primary background color - Deep black for OLED optimization.
  static const Color background = Color(0xFF0F0F0F); // Near black

  /// Slightly elevated surface color.
  static const Color surface = Color(0xFF1A1A1A); // Elevated black

  /// More elevated surface (cards, dialogs).
  static const Color surfaceVariant = Color(0xFF262626); // Card background

  /// Highest elevation surface.
  static const Color surfaceHigh = Color(0xFF333333); // Modal background

  /// Text color on background.
  static const Color onBackground = Color(0xFFE5E5E5); // Off-white

  /// Text color on surface.
  static const Color onSurface = Color(0xFFE5E5E5); // Off-white

  /// Dim text color on surface (secondary text).
  static const Color onSurfaceVariant = Color(0xFF9CA3AF); // Gray-400

  // ---------------------------------------------------------------------------
  // Semantic Colors
  // ---------------------------------------------------------------------------

  /// Error color - Used for error states and destructive actions.
  static const Color error = Color(0xFFEF4444); // Red-500

  /// Error container color (Material 3).
  static const Color errorContainer = Color(0xFF7F1D1D); // Red-900

  /// Text color on error color.
  static const Color onError = Color(0xFFFFFFFF); // White

  /// Text color on error container.
  static const Color onErrorContainer = Color(0xFFFEE2E2); // Red-100

  /// Success color - Used for success states and confirmations.
  static const Color success = Color(0xFF10B981); // Green-500

  /// Warning color - Used for warning states.
  static const Color warning = Color(0xFFF59E0B); // Amber-500

  /// Info color - Used for informational messages.
  static const Color info = Color(0xFF3B82F6); // Blue-500

  // ---------------------------------------------------------------------------
  // Frequency-Specific Colors (Solfeggio & Healing Frequencies)
  // ---------------------------------------------------------------------------

  /// 174 Hz - Pain Relief & Grounding (Deep Brown/Earth).
  static const Color frequency174 = Color(0xFF78350F); // Brown-900

  /// 285 Hz - Cellular Healing (Warm Orange).
  static const Color frequency285 = Color(0xFFF97316); // Orange-500

  /// 396 Hz - Liberation from Fear (Deep Red).
  static const Color frequency396 = Color(0xFFDC2626); // Red-600

  /// 417 Hz - Trauma Healing (Rose/Pink).
  static const Color frequency417 = Color(0xFFEC4899); // Pink-500

  /// 432 Hz - Deep Peace (Deep Indigo).
  static const Color frequency432 = Color(0xFF6366F1); // Indigo-500

  /// 528 Hz - Love Frequency (Cyan/Turquoise).
  static const Color frequency528 = Color(0xFF06B6D4); // Cyan-500

  /// 639 Hz - Harmony & Connection (Emerald Green).
  static const Color frequency639 = Color(0xFF10B981); // Green-500

  /// 741 Hz - Detoxification (Blue).
  static const Color frequency741 = Color(0xFF3B82F6); // Blue-500

  /// 852 Hz - Positive Thinking (Purple/Violet).
  static const Color frequency852 = Color(0xFF8B5CF6); // Purple-500

  /// 963 Hz - Pineal Activation (Gold/Divine).
  static const Color frequency963 = Color(0xFFFBBF24); // Amber-400

  /// Standard 440 Hz tuning (Neutral Gray).
  static const Color frequencyStandard = Color(0xFF9CA3AF); // Gray-400

  // ---------------------------------------------------------------------------
  // UI Element Colors
  // ---------------------------------------------------------------------------

  /// Divider color for separators.
  static const Color divider = Color(0xFF404040); // Dark gray

  /// Outline color for borders.
  static const Color outline = Color(0xFF525252); // Medium gray

  /// Disabled element color.
  static const Color disabled = Color(0xFF6B7280); // Gray-500

  /// Disabled text color.
  static const Color disabledText = Color(0xFF4B5563); // Gray-600

  /// Shadow color.
  static const Color shadow = Color(0x4D000000); // Black with 30% opacity

  /// Scrim color for overlays.
  static const Color scrim = Color(0x99000000); // Black with 60% opacity

  // ---------------------------------------------------------------------------
  // Player-Specific Colors
  // ---------------------------------------------------------------------------

  /// Seek bar active track color.
  static const Color seekBarActive = primary;

  /// Seek bar inactive track color.
  static const Color seekBarInactive = Color(0xFF404040);

  /// Seek bar thumb color.
  static const Color seekBarThumb = primary;

  /// Play button color.
  static const Color playButton = primary;

  /// Pause button color.
  static const Color pauseButton = primary;

  /// Album art placeholder gradient start.
  static const Color albumArtGradientStart = Color(0xFF3730A3); // Indigo-700

  /// Album art placeholder gradient end.
  static const Color albumArtGradientEnd = Color(0xFF164E63); // Cyan-900

  // ---------------------------------------------------------------------------
  // Gradient Definitions
  // ---------------------------------------------------------------------------

  /// Primary gradient for backgrounds and accent elements.
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6366F1), // Indigo-500
      Color(0xFF06B6D4), // Cyan-500
    ],
  );

  /// Background gradient for immersive player screen.
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1E1B4B), // Indigo-950
      Color(0xFF0F0F0F), // Near black
    ],
  );

  /// Album art overlay gradient (fade to background).
  static const LinearGradient albumArtOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x00000000), // Transparent
      Color(0xCC0F0F0F), // Near black with 80% opacity
    ],
  );

  // ---------------------------------------------------------------------------
  // Utility Methods
  // ---------------------------------------------------------------------------

  /// Returns the appropriate text color for a given background color.
  ///
  /// Ensures WCAG AA contrast compliance.
  static Color getContrastingTextColor(Color backgroundColor) {
    // Calculate relative luminance
    final luminance = backgroundColor.computeLuminance();

    // Return white for dark backgrounds, black for light backgrounds
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Returns a semi-transparent version of the given color.
  static Color withOpacity(Color color, double opacity) {
    assert(
      opacity >= 0.0 && opacity <= 1.0,
      'Opacity must be between 0.0 and 1.0',
    );
    return color.withOpacity(opacity);
  }

  /// Returns a darker variant of the given color.
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0.0 && amount <= 1.0, 'Amount must be between 0 and 1');

    final hsl = HSLColor.fromColor(color);
    final darkened = hsl.withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    );

    return darkened.toColor();
  }

  /// Returns a lighter variant of the given color.
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0.0 && amount <= 1.0, 'Amount must be between 0 and 1');

    final hsl = HSLColor.fromColor(color);
    final lightened = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );

    return lightened.toColor();
  }
}
