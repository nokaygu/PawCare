import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

@immutable
class PawThemeExtension extends ThemeExtension<PawThemeExtension> {
  final Color background;
  final Color shellBackdrop;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color tertiaryFixed;
  final Color accentWarm;
  final Color accentBeige;
  final Color success;
  final Color successContainer;
  final Color warningBg;
  final Color warningText;
  final Color starGold;
  final Color glassBadge;
  final Color modalBarrier;
  final Color heroGradientBottom;
  final Color galleryBadgeScrim;
  final Color pureWhite;
  final Color transparent;
  final Color mapParkGreen;
  final Color mapSeaBlue;
  final Color mapSeaText;
  final List<BoxShadow> cardShadow;
  final List<BoxShadow> floatingShadow;
  final List<BoxShadow> shellShadow;
  final List<BoxShadow> navBarShadow;

  const PawThemeExtension({
    required this.background,
    required this.shellBackdrop,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.tertiaryFixed,
    required this.accentWarm,
    required this.accentBeige,
    required this.success,
    required this.successContainer,
    required this.warningBg,
    required this.warningText,
    required this.starGold,
    required this.glassBadge,
    required this.modalBarrier,
    required this.heroGradientBottom,
    required this.galleryBadgeScrim,
    required this.pureWhite,
    required this.transparent,
    required this.mapParkGreen,
    required this.mapSeaBlue,
    required this.mapSeaText,
    required this.cardShadow,
    required this.floatingShadow,
    required this.shellShadow,
    required this.navBarShadow,
  });

  static const PawThemeExtension light = PawThemeExtension(
    background: AppColors.background,
    shellBackdrop: AppColors.shellBackdropLight,
    surfaceContainerLowest: AppColors.surfaceContainerLowest,
    surfaceContainerLow: AppColors.surfaceContainerLow,
    surfaceContainer: AppColors.surfaceContainer,
    surfaceContainerHigh: AppColors.surfaceContainerHigh,
    tertiaryFixed: AppColors.tertiaryFixed,
    accentWarm: AppColors.accentWarm,
    accentBeige: AppColors.accentBeige,
    success: AppColors.success,
    successContainer: AppColors.successContainer,
    warningBg: AppColors.warningBgLight,
    warningText: AppColors.warningTextLight,
    starGold: AppColors.starGold,
    glassBadge: AppColors.glassBadgeLight,
    modalBarrier: AppColors.modalBarrier,
    heroGradientBottom: AppColors.heroGradientBottom,
    galleryBadgeScrim: AppColors.galleryBadgeScrim,
    pureWhite: AppColors.pureWhite,
    transparent: AppColors.transparent,
    mapParkGreen: AppColors.mapParkGreenLight,
    mapSeaBlue: AppColors.mapSeaBlueLight,
    mapSeaText: AppColors.mapSeaTextLight,
    cardShadow: AppColors.cardShadowLight,
    floatingShadow: AppColors.floatingShadowLight,
    shellShadow: AppColors.shellShadow,
    navBarShadow: AppColors.navBarShadow,
  );

  static const PawThemeExtension dark = PawThemeExtension(
    background: AppColors.darkBackground,
    shellBackdrop: AppColors.darkShellBackdrop,
    surfaceContainerLowest: AppColors.darkSurfaceContainerLowest,
    surfaceContainerLow: AppColors.darkSurfaceContainerLow,
    surfaceContainer: AppColors.darkSurfaceContainer,
    surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
    tertiaryFixed: AppColors.darkTertiaryFixed,
    accentWarm: AppColors.accentWarm,
    accentBeige: AppColors.accentBeige,
    success: AppColors.darkSuccess,
    successContainer: AppColors.darkSuccessContainer,
    warningBg: AppColors.darkWarningBg,
    warningText: AppColors.darkWarningText,
    starGold: AppColors.starGold,
    glassBadge: AppColors.darkGlassBadge,
    modalBarrier: AppColors.modalBarrier,
    heroGradientBottom: AppColors.heroGradientBottom,
    galleryBadgeScrim: AppColors.galleryBadgeScrim,
    pureWhite: AppColors.pureWhite,
    transparent: AppColors.transparent,
    mapParkGreen: AppColors.darkMapParkGreen,
    mapSeaBlue: AppColors.darkMapSeaBlue,
    mapSeaText: AppColors.darkMapSeaText,
    cardShadow: AppColors.cardShadowDark,
    floatingShadow: AppColors.floatingShadowDark,
    shellShadow: AppColors.shellShadow,
    navBarShadow: AppColors.navBarShadow,
  );

  @override
  PawThemeExtension copyWith({
    Color? background,
    Color? shellBackdrop,
    Color? surfaceContainerLowest,
    Color? surfaceContainerLow,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? tertiaryFixed,
    Color? accentWarm,
    Color? accentBeige,
    Color? success,
    Color? successContainer,
    Color? warningBg,
    Color? warningText,
    Color? starGold,
    Color? glassBadge,
    Color? modalBarrier,
    Color? heroGradientBottom,
    Color? galleryBadgeScrim,
    Color? pureWhite,
    Color? transparent,
    Color? mapParkGreen,
    Color? mapSeaBlue,
    Color? mapSeaText,
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? floatingShadow,
    List<BoxShadow>? shellShadow,
    List<BoxShadow>? navBarShadow,
  }) {
    return PawThemeExtension(
      background: background ?? this.background,
      shellBackdrop: shellBackdrop ?? this.shellBackdrop,
      surfaceContainerLowest:
          surfaceContainerLowest ?? this.surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      tertiaryFixed: tertiaryFixed ?? this.tertiaryFixed,
      accentWarm: accentWarm ?? this.accentWarm,
      accentBeige: accentBeige ?? this.accentBeige,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      warningBg: warningBg ?? this.warningBg,
      warningText: warningText ?? this.warningText,
      starGold: starGold ?? this.starGold,
      glassBadge: glassBadge ?? this.glassBadge,
      modalBarrier: modalBarrier ?? this.modalBarrier,
      heroGradientBottom: heroGradientBottom ?? this.heroGradientBottom,
      galleryBadgeScrim: galleryBadgeScrim ?? this.galleryBadgeScrim,
      pureWhite: pureWhite ?? this.pureWhite,
      transparent: transparent ?? this.transparent,
      mapParkGreen: mapParkGreen ?? this.mapParkGreen,
      mapSeaBlue: mapSeaBlue ?? this.mapSeaBlue,
      mapSeaText: mapSeaText ?? this.mapSeaText,
      cardShadow: cardShadow ?? this.cardShadow,
      floatingShadow: floatingShadow ?? this.floatingShadow,
      shellShadow: shellShadow ?? this.shellShadow,
      navBarShadow: navBarShadow ?? this.navBarShadow,
    );
  }

  @override
  PawThemeExtension lerp(ThemeExtension<PawThemeExtension>? other, double t) {
    if (other is! PawThemeExtension) return this;
    return PawThemeExtension(
      background: Color.lerp(background, other.background, t)!,
      shellBackdrop: Color.lerp(shellBackdrop, other.shellBackdrop, t)!,
      surfaceContainerLowest: Color.lerp(
        surfaceContainerLowest,
        other.surfaceContainerLowest,
        t,
      )!,
      surfaceContainerLow: Color.lerp(
        surfaceContainerLow,
        other.surfaceContainerLow,
        t,
      )!,
      surfaceContainer: Color.lerp(
        surfaceContainer,
        other.surfaceContainer,
        t,
      )!,
      surfaceContainerHigh: Color.lerp(
        surfaceContainerHigh,
        other.surfaceContainerHigh,
        t,
      )!,
      tertiaryFixed: Color.lerp(tertiaryFixed, other.tertiaryFixed, t)!,
      accentWarm: Color.lerp(accentWarm, other.accentWarm, t)!,
      accentBeige: Color.lerp(accentBeige, other.accentBeige, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      warningText: Color.lerp(warningText, other.warningText, t)!,
      starGold: Color.lerp(starGold, other.starGold, t)!,
      glassBadge: Color.lerp(glassBadge, other.glassBadge, t)!,
      modalBarrier: Color.lerp(modalBarrier, other.modalBarrier, t)!,
      heroGradientBottom: Color.lerp(
        heroGradientBottom,
        other.heroGradientBottom,
        t,
      )!,
      galleryBadgeScrim: Color.lerp(
        galleryBadgeScrim,
        other.galleryBadgeScrim,
        t,
      )!,
      pureWhite: Color.lerp(pureWhite, other.pureWhite, t)!,
      transparent: Color.lerp(transparent, other.transparent, t)!,
      mapParkGreen: Color.lerp(mapParkGreen, other.mapParkGreen, t)!,
      mapSeaBlue: Color.lerp(mapSeaBlue, other.mapSeaBlue, t)!,
      mapSeaText: Color.lerp(mapSeaText, other.mapSeaText, t)!,
      cardShadow: cardShadow,
      floatingShadow: floatingShadow,
      shellShadow: shellShadow,
      navBarShadow: navBarShadow,
    );
  }
}

class AppTheme {
  const AppTheme._();

  static final ThemeData lightTheme = _buildLightTheme();
  static final ThemeData darkTheme = _buildDarkTheme();

  static ThemeData _buildLightTheme() {
    final textTheme = AppTypography.buildTextTheme(
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
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
        outlineVariant: AppColors.outlineVariant,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
      ),
      extensions: const <ThemeExtension<dynamic>>[PawThemeExtension.light],
    );
  }

  static ThemeData _buildDarkTheme() {
    final textTheme = AppTypography.buildTextTheme(
      onSurface: AppColors.darkOnSurface,
      onSurfaceVariant: AppColors.darkOnSurfaceVariant,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkOnPrimary,
        primaryContainer: AppColors.darkPrimaryContainer,
        onPrimaryContainer: AppColors.darkOnPrimaryContainer,
        secondary: AppColors.darkSecondary,
        onSecondary: AppColors.darkOnSecondary,
        secondaryContainer: AppColors.darkSecondaryContainer,
        onSecondaryContainer: AppColors.darkOnSecondaryContainer,
        tertiary: AppColors.darkTertiary,
        onTertiary: AppColors.darkOnTertiary,
        tertiaryContainer: AppColors.darkTertiaryContainer,
        onTertiaryContainer: AppColors.darkTertiaryContainer,
        error: AppColors.darkError,
        onError: AppColors.darkOnError,
        errorContainer: AppColors.darkErrorContainer,
        onErrorContainer: AppColors.darkOnErrorContainer,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        onSurfaceVariant: AppColors.darkOnSurfaceVariant,
        outline: AppColors.darkOutline,
        outlineVariant: AppColors.darkOutlineVariant,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkOnSurface,
        elevation: 0,
      ),
      extensions: const <ThemeExtension<dynamic>>[PawThemeExtension.dark],
    );
  }
}

extension PawThemeBuildContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  PawThemeExtension get pawTheme =>
      Theme.of(this).extension<PawThemeExtension>() ?? PawThemeExtension.light;
  TextTheme get pawTextTheme => Theme.of(this).textTheme;
}
