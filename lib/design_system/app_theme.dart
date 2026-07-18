import 'package:flutter/material.dart';

/// Lucid's theme: a calm night palette, the same seed in light and dark.
ThemeData buildAppTheme(Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF5B4FCF),
    brightness: brightness,
  );

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    extensions: [AppColors.fromColorScheme(colorScheme)],
    cardTheme: const CardThemeData(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
    ),
  );
}

/// Semantic colours the Material scheme has no role for.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.surfaceAccent,
    required this.textMuted,
    required this.success,
    required this.warning,
    required this.stageAwake,
    required this.stageRem,
    required this.stageLight,
    required this.stageDeep,
  });

  factory AppColors.fromColorScheme(ColorScheme colors) {
    final light = colors.brightness == Brightness.light;
    return AppColors(
      surfaceAccent: colors.primaryContainer,
      textMuted: colors.onSurfaceVariant,
      success: light ? const Color(0xFF2E7D32) : const Color(0xFF81C784),
      warning: light ? const Color(0xFF8A4F00) : const Color(0xFFFFB74D),
      stageAwake: light ? const Color(0xFFE8833A) : const Color(0xFFFFB27A),
      stageRem: light ? const Color(0xFF0091A7) : const Color(0xFF5FD4E6),
      stageLight: light ? const Color(0xFF6E8FE8) : const Color(0xFF9DB5FF),
      stageDeep: light ? const Color(0xFF3B2C8F) : const Color(0xFF6F5FE0),
    );
  }

  final Color surfaceAccent;
  final Color textMuted;
  final Color success;
  final Color warning;

  /// Hypnogram and stage legend colours.
  final Color stageAwake;
  final Color stageRem;
  final Color stageLight;
  final Color stageDeep;

  @override
  AppColors copyWith({
    Color? surfaceAccent,
    Color? textMuted,
    Color? success,
    Color? warning,
    Color? stageAwake,
    Color? stageRem,
    Color? stageLight,
    Color? stageDeep,
  }) {
    return AppColors(
      surfaceAccent: surfaceAccent ?? this.surfaceAccent,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      stageAwake: stageAwake ?? this.stageAwake,
      stageRem: stageRem ?? this.stageRem,
      stageLight: stageLight ?? this.stageLight,
      stageDeep: stageDeep ?? this.stageDeep,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      surfaceAccent: Color.lerp(surfaceAccent, other.surfaceAccent, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      stageAwake: Color.lerp(stageAwake, other.stageAwake, t)!,
      stageRem: Color.lerp(stageRem, other.stageRem, t)!,
      stageLight: Color.lerp(stageLight, other.stageLight, t)!,
      stageDeep: Color.lerp(stageDeep, other.stageDeep, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
