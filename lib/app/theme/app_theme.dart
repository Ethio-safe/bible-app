import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/reader_settings/domain/reader_style.dart';

/// Brand colours shared by every theme variant.
class AppColors {
  AppColors._();

  /// Signature red used for the active "Today" tab, red-letter text, badges.
  static const accent = Color(0xFFE5484D);

  // Dark (default) palette — pure black canvas with charcoal cards.
  static const black = Color(0xFF000000);
  static const card = Color(0xFF1C1C1E);
  static const cardHigh = Color(0xFF2C2C2E);
  static const divider = Color(0xFF2A2A2C);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF9A9A9E);
  static const toggleOn = Color(0xFF2F6FED);
}

/// App-wide Material 3 theme. The default look is a pure-black, high-contrast
/// reading theme; light and sepia variants are kept for people who prefer them.
class AppTheme {
  AppTheme._();

  static ThemeData light() => _buildLight();
  static ThemeData dark() => _buildDark();

  /// Warm off-white paper tone, light brightness.
  static ThemeData sepia() {
    final base = _buildLight();
    const paper = Color(0xFFF4ECD8);
    const ink = Color(0xFF3B2F22);
    final scheme = base.colorScheme.copyWith(
      surface: paper,
      onSurface: ink,
      surfaceContainerLowest: const Color(0xFFFBF6E9),
      surfaceContainerLow: const Color(0xFFF7F0DE),
      surfaceContainer: const Color(0xFFEFE5CC),
      surfaceContainerHigh: const Color(0xFFE8DCBF),
      surfaceContainerHighest: const Color(0xFFE0D3B2),
      onSurfaceVariant: const Color(0xFF6B5B45),
      outlineVariant: const Color(0xFFD5C7A5),
    );
    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: paper,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: paper,
        foregroundColor: ink,
      ),
      textTheme: base.textTheme.apply(bodyColor: ink, displayColor: ink),
    );
  }

  static ThemeData forReaderTheme(ReaderTheme t) => switch (t) {
    ReaderTheme.system => light(),
    ReaderTheme.light => light(),
    ReaderTheme.sepia => sepia(),
    ReaderTheme.dark => dark(),
  };

  // ── Dark ──────────────────────────────────────────────────────────────────

  static ThemeData _buildDark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.textPrimary,
      onPrimary: AppColors.black,
      primaryContainer: AppColors.card,
      onPrimaryContainer: AppColors.textPrimary,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.cardHigh,
      onSecondaryContainer: AppColors.textPrimary,
      tertiary: AppColors.toggleOn,
      onTertiary: Colors.white,
      error: AppColors.accent,
      onError: Colors.white,
      errorContainer: Color(0xFF3A1416),
      onErrorContainer: Color(0xFFFFB4AB),
      surface: AppColors.black,
      onSurface: AppColors.textPrimary,
      surfaceContainerLowest: AppColors.black,
      surfaceContainerLow: Color(0xFF121214),
      surfaceContainer: AppColors.card,
      surfaceContainerHigh: AppColors.cardHigh,
      surfaceContainerHighest: Color(0xFF3A3A3C),
      onSurfaceVariant: AppColors.textSecondary,
      outline: Color(0xFF5A5A5E),
      outlineVariant: AppColors.divider,
      inverseSurface: Color(0xFFE6E6E6),
      onInverseSurface: AppColors.black,
      inversePrimary: AppColors.black,
      shadow: Colors.black,
      scrim: Colors.black,
      surfaceTint: Colors.transparent,
    );
    return _apply(ThemeData(colorScheme: scheme, useMaterial3: true), scheme);
  }

  // ── Light ─────────────────────────────────────────────────────────────────

  static ThemeData _buildLight() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF292724),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE9E4DC),
      onPrimaryContainer: Color(0xFF292724),
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFF3DDD8),
      onSecondaryContainer: Color(0xFF3A1815),
      tertiary: AppColors.toggleOn,
      onTertiary: Colors.white,
      error: AppColors.accent,
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: Color(0xFFFAF8F5),
      onSurface: Color(0xFF292724),
      surfaceContainerLowest: Color(0xFFFFFCF9),
      surfaceContainerLow: Color(0xFFF7F3EF),
      surfaceContainer: Color(0xFFF0ECE7),
      surfaceContainerHigh: Color(0xFFE9E4DE),
      surfaceContainerHighest: Color(0xFFE0DAD3),
      onSurfaceVariant: Color(0xFF6E6861),
      outline: Color(0xFFA9A19A),
      outlineVariant: Color(0xFFDCD5CE),
      inverseSurface: Color(0xFF292724),
      onInverseSurface: Colors.white,
      inversePrimary: Colors.white,
      shadow: Colors.black,
      scrim: Colors.black,
      surfaceTint: Colors.transparent,
    );
    return _apply(ThemeData(colorScheme: scheme, useMaterial3: true), scheme);
  }

  // ── Shared component styling ──────────────────────────────────────────────

  static ThemeData _apply(ThemeData base, ColorScheme scheme) {
    final textTheme = GoogleFonts.interTextTheme(
      base.textTheme,
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: scheme.surface,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
            size: 26,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall!.copyWith(
            fontSize: 11.5,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        iconColor: scheme.onSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Colors.white
              : scheme.onSurfaceVariant,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.toggleOn
              : scheme.surfaceContainerHigh,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        thumbIcon: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? const Icon(Icons.check, size: 16, color: AppColors.toggleOn)
              : null,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.onSurface,
        unselectedLabelColor: scheme.onSurfaceVariant,
        indicatorColor: AppColors.accent,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainer,
        selectedColor: scheme.onSurface,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        labelStyle: textTheme.labelLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.onSurface,
          foregroundColor: scheme.surface,
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
      ),
    );
  }
}

/// Builds reader text styles from the user's [ReaderStyle].
class ReaderTypography {
  ReaderTypography._();

  static TextStyle body(BuildContext context, ReaderStyle style) {
    final scheme = Theme.of(context).colorScheme;
    return GoogleFonts.getFont(
      style.font.googleFontName,
      fontSize: style.fontSize,
      height: style.lineHeight,
      color: scheme.onSurface,
    );
  }

  /// Small, muted superscript verse numbers.
  static TextStyle verseNumber(BuildContext context, ReaderStyle style) {
    final scheme = Theme.of(context).colorScheme;
    return GoogleFonts.inter(
      fontSize: (style.fontSize * 0.5).clamp(8, 14),
      fontWeight: FontWeight.w500,
      color: scheme.onSurfaceVariant,
      fontFeatures: const [FontFeature.superscripts()],
    );
  }

  /// Large chapter number shown above the text.
  static TextStyle chapterNumber(BuildContext context) => GoogleFonts.lora(
    fontSize: 64,
    fontWeight: FontWeight.w700,
    height: 1,
    color: Theme.of(context).colorScheme.onSurface,
  );

  /// Book name shown above the chapter number.
  static TextStyle bookName(BuildContext context) => GoogleFonts.lora(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );

  /// Serif verse text used on Home cards.
  static TextStyle quote(BuildContext context, {double size = 22}) =>
      GoogleFonts.lora(
        fontSize: size,
        height: 1.35,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      );
}
