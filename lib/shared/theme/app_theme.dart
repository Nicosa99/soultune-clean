/// SoulTune Theme Configuration
///
/// Implements a complete Material 3 theme optimized for a healing music
/// player experience. The theme system provides:
///
/// - Dark theme as primary (OLED-optimized for energy efficiency)
/// - Optional light theme for accessibility
/// - Consistent component styling
/// - Smooth animations and transitions
/// - Accessibility compliance
///
/// ## Theme Philosophy
///
/// The dark theme creates an immersive, cinema-like environment that:
/// - Reduces eye strain during extended listening sessions
/// - Emphasizes album art and visual elements
/// - Saves battery on OLED devices
/// - Provides a calming, meditative atmosphere
///
/// ## Usage
///
/// ```dart
/// MaterialApp(
///   theme: AppTheme.lightTheme, // Optional
///   darkTheme: AppTheme.darkTheme, // Primary
///   themeMode: ThemeMode.dark, // Default to dark
/// );
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soultune/shared/theme/app_colors.dart';
import 'package:soultune/shared/theme/app_text_styles.dart';

/// Application theme configuration and builder.
///
/// Provides pre-configured Material 3 themes with custom styling
/// for SoulTune components.
class AppTheme {
  AppTheme._(); // Private constructor to prevent instantiation

  // ---------------------------------------------------------------------------
  // Theme Configurations
  // ---------------------------------------------------------------------------

  /// Dark theme - Primary theme for SoulTune.
  ///
  /// Optimized for OLED displays, reducing eye strain and creating
  /// an immersive music listening experience.
  static ThemeData get darkTheme {
    return ThemeData(
      // Material 3
      useMaterial3: true,

      // Brightness
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: _darkColorScheme,

      // Typography
      textTheme: _textTheme,

      // App Bar Theme
      appBarTheme: _darkAppBarTheme,

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: _darkBottomNavigationBarTheme,

      // Navigation Bar Theme (Material 3)
      navigationBarTheme: _darkNavigationBarTheme,

      // Card Theme
      cardTheme: _cardTheme,

      // Elevated Button Theme
      elevatedButtonTheme: _elevatedButtonTheme,

      // Text Button Theme
      textButtonTheme: _textButtonTheme,

      // Outlined Button Theme
      outlinedButtonTheme: _outlinedButtonTheme,

      // Icon Button Theme
      iconButtonTheme: _iconButtonTheme,

      // Floating Action Button Theme
      floatingActionButtonTheme: _fabTheme,

      // Chip Theme
      chipTheme: _chipTheme,

      // Slider Theme
      sliderTheme: _sliderTheme,

      // List Tile Theme
      listTileTheme: _listTileTheme,

      // Divider Theme
      dividerTheme: _dividerTheme,

      // Dialog Theme
      dialogTheme: _dialogTheme,

      // Bottom Sheet Theme
      bottomSheetTheme: _bottomSheetTheme,

      // Snackbar Theme
      snackBarTheme: _snackBarTheme,

      // Input Decoration Theme
      inputDecorationTheme: _inputDecorationTheme,

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.onSurface,
        size: 24,
      ),

      // Primary Icon Theme
      primaryIconTheme: const IconThemeData(
        color: AppColors.onPrimary,
        size: 24,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: AppColors.background,

      // Canvas Color
      canvasColor: AppColors.background,

      // Disable default transitions for better performance
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // Splash and Highlight Colors
      splashColor: AppColors.primary.withOpacity(0.12),
      highlightColor: AppColors.primary.withOpacity(0.08),

      // Focus Color
      focusColor: AppColors.primary.withOpacity(0.12),

      // Hover Color
      hoverColor: AppColors.onSurface.withOpacity(0.08),
    );
  }

  /// Light theme - Optional alternative for accessibility.
  ///
  /// Provides high contrast for use in bright environments.
  static ThemeData get lightTheme {
    return ThemeData(
      // Material 3
      useMaterial3: true,

      // Brightness
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: _lightColorScheme,

      // Typography
      textTheme: _textTheme.apply(
        bodyColor: Colors.black87,
        displayColor: Colors.black87,
      ),

      // Other theme properties would be configured similarly to dark theme
      // but with light mode colors. For MVP, we focus on dark theme.
      scaffoldBackgroundColor: Colors.white,
      canvasColor: Colors.white,
    );
  }

  // ---------------------------------------------------------------------------
  // Color Schemes
  // ---------------------------------------------------------------------------

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.onTertiary,
    tertiaryContainer: AppColors.tertiaryContainer,
    onTertiaryContainer: AppColors.onTertiaryContainer,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.outline,
    shadow: AppColors.shadow,
    scrim: AppColors.scrim,
    inverseSurface: Color(0xFFEEEEEE), // grey[200]
    onInverseSurface: Color(0xFF212121), // grey[900]
    inversePrimary: AppColors.primaryLight,
  );

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.secondaryLight,
    onSecondaryContainer: AppColors.secondaryDark,
    tertiary: AppColors.tertiary,
    onTertiary: Colors.black,
    tertiaryContainer: AppColors.tertiaryLight,
    onTertiaryContainer: AppColors.tertiaryDark,
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: Color(0xFFFFCDD2), // red[100]
    onErrorContainer: Color(0xFFB71C1C), // red[900]
    surface: Colors.white,
    onSurface: Color(0xDD000000), // black87
    onSurfaceVariant: Color(0xFF616161), // grey[700]
    outline: Color(0xFFBDBDBD), // grey[400]
    shadow: Color(0x42000000), // black26
    scrim: Color(0x8A000000), // black54
    inverseSurface: Color(0xFF424242), // grey[800]
    onInverseSurface: Colors.white,
    inversePrimary: AppColors.primary,
  );

  // ---------------------------------------------------------------------------
  // Typography
  // ---------------------------------------------------------------------------

  static final TextTheme _textTheme = TextTheme(
    displayLarge: AppTextStyles.displayLarge,
    displayMedium: AppTextStyles.displayMedium,
    displaySmall: AppTextStyles.displaySmall,
    headlineLarge: AppTextStyles.headlineLarge,
    headlineMedium: AppTextStyles.headlineMedium,
    headlineSmall: AppTextStyles.headlineSmall,
    titleLarge: AppTextStyles.titleLarge,
    titleMedium: AppTextStyles.titleMedium,
    titleSmall: AppTextStyles.titleSmall,
    bodyLarge: AppTextStyles.bodyLarge,
    bodyMedium: AppTextStyles.bodyMedium,
    bodySmall: AppTextStyles.bodySmall,
    labelLarge: AppTextStyles.labelLarge,
    labelMedium: AppTextStyles.labelMedium,
    labelSmall: AppTextStyles.labelSmall,
  );

  // ---------------------------------------------------------------------------
  // Component Themes
  // ---------------------------------------------------------------------------

  static const AppBarTheme _darkAppBarTheme = AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.onSurface,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: AppTextStyles.titleLarge,
    iconTheme: IconThemeData(color: AppColors.onSurface),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  static final BottomNavigationBarThemeData _darkBottomNavigationBarTheme =
      BottomNavigationBarThemeData(
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.onSurfaceVariant,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
    selectedLabelStyle: AppTextStyles.labelMedium,
    unselectedLabelStyle: AppTextStyles.labelSmall,
  );

  static final NavigationBarThemeData _darkNavigationBarTheme =
      NavigationBarThemeData(
    backgroundColor: AppColors.surface,
    indicatorColor: AppColors.primaryContainer,
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppTextStyles.labelMedium.copyWith(color: AppColors.primary);
      }
      return AppTextStyles.labelSmall.copyWith(
        color: AppColors.onSurfaceVariant,
      );
    }),
  );

  static const CardThemeData _cardTheme = CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    clipBehavior: Clip.antiAlias,
    margin: EdgeInsets.all(8),
  );

  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: AppTextStyles.buttonPrimary,
    ),
  );

  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: AppTextStyles.buttonSecondary,
    ),
  );

  static final OutlinedButtonThemeData _outlinedButtonTheme =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.outline, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: AppTextStyles.buttonSecondary,
    ),
  );

  static final IconButtonThemeData _iconButtonTheme = IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: AppColors.onSurface,
      iconSize: 24,
      padding: const EdgeInsets.all(12),
    ),
  );

  static const FloatingActionButtonThemeData _fabTheme =
      FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.onPrimary,
    elevation: 6,
    shape: CircleBorder(),
  );

  static final ChipThemeData _chipTheme = ChipThemeData(
    backgroundColor: AppColors.surfaceVariant,
    selectedColor: AppColors.primaryContainer,
    labelStyle: AppTextStyles.labelMedium,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static const SliderThemeData _sliderTheme = SliderThemeData(
    activeTrackColor: AppColors.primary,
    inactiveTrackColor: AppColors.seekBarInactive,
    thumbColor: AppColors.primary,
    overlayColor: Color(0x1F6366F1), // Primary with 12% opacity
    trackHeight: 4,
    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
    overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
  );

  static const ListTileThemeData _listTileTheme = ListTileThemeData(
    tileColor: Colors.transparent,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    iconColor: AppColors.onSurface,
    textColor: AppColors.onSurface,
    dense: false,
  );

  static const DividerThemeData _dividerTheme = DividerThemeData(
    color: AppColors.divider,
    thickness: 1,
    space: 1,
  );

  static const DialogThemeData _dialogTheme = DialogThemeData(
    elevation: 24,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(28)),
    ),
  );

  static const BottomSheetThemeData _bottomSheetTheme = BottomSheetThemeData(
    backgroundColor: AppColors.surfaceHigh,
    elevation: 16,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    clipBehavior: Clip.antiAlias,
  );

  static final SnackBarThemeData _snackBarTheme = SnackBarThemeData(
    backgroundColor: AppColors.surfaceHigh,
    contentTextStyle: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.onSurface,
    ),
    actionTextColor: AppColors.primary,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  static final InputDecorationTheme _inputDecorationTheme =
      InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceVariant,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    hintStyle: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.onSurfaceVariant,
    ),
    labelStyle: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.onSurfaceVariant,
    ),
  );

  // ---------------------------------------------------------------------------
  // System UI Overlay Styles
  // ---------------------------------------------------------------------------

  /// System overlay style for dark theme (light status bar icons).
  static const SystemUiOverlayStyle darkSystemOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  /// System overlay style for light theme (dark status bar icons).
  static const SystemUiOverlayStyle lightSystemOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  /// Apply system overlay style for full-screen immersive mode.
  ///
  /// Use this for Now Playing screen to hide system UI elements.
  static void setImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );
    SystemChrome.setSystemUIOverlayStyle(darkSystemOverlay);
  }

  /// Restore default system overlay style.
  static void setDefaultMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setSystemUIOverlayStyle(darkSystemOverlay);
  }
}
