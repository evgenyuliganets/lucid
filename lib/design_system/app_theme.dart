import 'package:flutter/material.dart';

ThemeData buildAppTheme(Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF6750A4),
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

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.surfaceAccent,
    required this.textMuted,
    required this.success,
    required this.warning,
  });

  factory AppColors.fromColorScheme(ColorScheme colors) {
    return AppColors(
      surfaceAccent: colors.primaryContainer,
      textMuted: colors.onSurfaceVariant,
      success: colors.brightness == Brightness.light
          ? const Color(0xFF2E7D32)
          : const Color(0xFF81C784),
      warning: colors.brightness == Brightness.light
          ? const Color(0xFF8A4F00)
          : const Color(0xFFFFB74D),
    );
  }

  final Color surfaceAccent;
  final Color textMuted;
  final Color success;
  final Color warning;

  @override
  AppColors copyWith({
    Color? surfaceAccent,
    Color? textMuted,
    Color? success,
    Color? warning,
  }) {
    return AppColors(
      surfaceAccent: surfaceAccent ?? this.surfaceAccent,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      warning: warning ?? this.warning,
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
    );
  }
}

extension AppThemeContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
