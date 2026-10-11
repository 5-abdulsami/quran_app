import 'package:flutter/material.dart';

import '../../domain/models/app_settings.dart';

/// Colours with a Quran-specific meaning, kept distinct in every theme.
///
/// Mirrors the web app's design tokens: quoted source text sits on a warm,
/// bordered "paper" surface; the accent is a deep, desaturated green used for
/// links and focus, never as a large fill.
@immutable
class QuranColors extends ThemeExtension<QuranColors> {
  const QuranColors({
    required this.quranText,
    required this.sourceBackground,
    required this.sourceBorder,
    required this.marker,
    required this.highlight,
    required this.ornament,
  });

  /// Quranic text. Highest contrast in the theme.
  final Color quranText;

  /// Background of quoted source blocks (ayah detail, header basmalah).
  final Color sourceBackground;
  final Color sourceBorder;

  /// Juz / hizb / page markers: present but quiet.
  final Color marker;

  /// Briefly tints the ayah a reader just navigated to.
  final Color highlight;

  /// Ornamental framing (surah header, basmalah frame, medallions).
  final Color ornament;

  @override
  QuranColors copyWith({
    Color? quranText,
    Color? sourceBackground,
    Color? sourceBorder,
    Color? marker,
    Color? highlight,
    Color? ornament,
  }) => QuranColors(
    quranText: quranText ?? this.quranText,
    sourceBackground: sourceBackground ?? this.sourceBackground,
    sourceBorder: sourceBorder ?? this.sourceBorder,
    marker: marker ?? this.marker,
    highlight: highlight ?? this.highlight,
    ornament: ornament ?? this.ornament,
  );

  @override
  QuranColors lerp(QuranColors? other, double t) {
    if (other == null) return this;
    return QuranColors(
      quranText: Color.lerp(quranText, other.quranText, t)!,
      sourceBackground: Color.lerp(
        sourceBackground,
        other.sourceBackground,
        t,
      )!,
      sourceBorder: Color.lerp(sourceBorder, other.sourceBorder, t)!,
      marker: Color.lerp(marker, other.marker, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      ornament: Color.lerp(ornament, other.ornament, t)!,
    );
  }
}

/// Convenience accessor: `context.quranColors`.
extension QuranColorsContext on BuildContext {
  QuranColors get quranColors => Theme.of(this).extension<QuranColors>()!;
}

/// The palette for one theme. All text/background pairs meet WCAG AA (4.5:1).
class _Palette {
  const _Palette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.ink,
    required this.inkMuted,
    required this.outline,
    required this.accent,
    required this.onAccent,
    required this.accentContainer,
    required this.onAccentContainer,
    required this.error,
    required this.quran,
  });

  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color ink;
  final Color inkMuted;
  final Color outline;
  final Color accent;
  final Color onAccent;
  final Color accentContainer;
  final Color onAccentContainer;
  final Color error;
  final QuranColors quran;
}

const _light = _Palette(
  brightness: Brightness.light,
  background: Color(0xFFFBFAF6),
  surface: Color(0xFFFFFFFF),
  surfaceMuted: Color(0xFFF2F0EA),
  ink: Color(0xFF221F1A),
  inkMuted: Color(0xFF5C574F),
  outline: Color(0xFFD9D5CC),
  accent: Color(0xFF1F6650),
  onAccent: Color(0xFFFFFFFF),
  accentContainer: Color(0xFFDDEFE7),
  onAccentContainer: Color(0xFF0E3A2D),
  error: Color(0xFFA8322A),
  quran: QuranColors(
    quranText: Color(0xFF15120E),
    sourceBackground: Color(0xFFFCF9F1),
    sourceBorder: Color(0xFFE0D7C4),
    marker: Color(0xFF6E685E),
    highlight: Color(0x331F6650),
    ornament: Color(0xFFB08D4A),
  ),
);

const _dark = _Palette(
  brightness: Brightness.dark,
  background: Color(0xFF151412),
  surface: Color(0xFF1E1D1A),
  surfaceMuted: Color(0xFF282623),
  ink: Color(0xFFEDEBE6),
  inkMuted: Color(0xFFB4AFA6),
  outline: Color(0xFF3D3A35),
  accent: Color(0xFF7CC8AC),
  onAccent: Color(0xFF07241B),
  accentContainer: Color(0xFF1E3A30),
  onAccentContainer: Color(0xFFCDEBDD),
  error: Color(0xFFF0A49B),
  quran: QuranColors(
    quranText: Color(0xFFF3F1EC),
    sourceBackground: Color(0xFF221F1B),
    sourceBorder: Color(0xFF3B362E),
    marker: Color(0xFFA19B91),
    highlight: Color(0x337CC8AC),
    ornament: Color(0xFFC9A764),
  ),
);

const _sepia = _Palette(
  brightness: Brightness.light,
  background: Color(0xFFF4ECD8),
  surface: Color(0xFFFAF4E4),
  surfaceMuted: Color(0xFFECE2C9),
  ink: Color(0xFF3A2E1F),
  inkMuted: Color(0xFF65553F),
  outline: Color(0xFFD6C7A4),
  accent: Color(0xFF2F5E4C),
  onAccent: Color(0xFFFFFFFF),
  accentContainer: Color(0xFFDDE5CF),
  onAccentContainer: Color(0xFF1C3A2E),
  error: Color(0xFF9A2F24),
  quran: QuranColors(
    quranText: Color(0xFF2B2014),
    sourceBackground: Color(0xFFF8F0DC),
    sourceBorder: Color(0xFFD9C79F),
    marker: Color(0xFF6E5E46),
    highlight: Color(0x332F5E4C),
    ornament: Color(0xFF9C7A3C),
  ),
);

/// Builds the app's [ThemeData] for each [AppThemeMode].
abstract final class AppTheme {
  static ThemeData light() => _build(_light);
  static ThemeData dark() => _build(_dark);
  static ThemeData sepia() => _build(_sepia);

  static ThemeData _build(_Palette p) {
    final scheme = ColorScheme(
      brightness: p.brightness,
      primary: p.accent,
      onPrimary: p.onAccent,
      primaryContainer: p.accentContainer,
      onPrimaryContainer: p.onAccentContainer,
      secondary: p.accent,
      onSecondary: p.onAccent,
      secondaryContainer: p.accentContainer,
      onSecondaryContainer: p.onAccentContainer,
      tertiary: p.quran.ornament,
      onTertiary: p.onAccent,
      error: p.error,
      onError: p.surface,
      surface: p.background,
      onSurface: p.ink,
      onSurfaceVariant: p.inkMuted,
      surfaceContainerLowest: p.surface,
      surfaceContainerLow: p.surface,
      surfaceContainer: p.surface,
      surfaceContainerHigh: p.surfaceMuted,
      surfaceContainerHighest: p.surfaceMuted,
      outline: p.outline,
      outlineVariant: p.outline,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      extensions: [p.quran],
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: p.outline),
        ),
      ),
      dividerTheme: DividerThemeData(color: p.outline, space: 1, thickness: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: p.accentContainer,
        // A label never spills past its tab.
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => base.textTheme.labelMedium?.copyWith(
            overflow: TextOverflow.ellipsis,
            color: states.contains(WidgetState.selected) ? p.ink : p.inkMuted,
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide(color: p.outline),
        backgroundColor: p.surface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.outline),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      listTileTheme: const ListTileThemeData(minVerticalPadding: 12),
    );
  }

  /// The light-family theme for a mode (sepia replaces light when chosen).
  static ThemeData lightFor(AppThemeMode mode) =>
      mode == AppThemeMode.sepia ? sepia() : light();

  /// Maps the app's four-way choice onto Flutter's [ThemeMode].
  static ThemeMode themeModeFor(AppThemeMode mode) => switch (mode) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light || AppThemeMode.sepia => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };
}
