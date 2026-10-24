import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // ===========================================================================
  // LIGHT THEME (Stitch Original Palette)
  // ===========================================================================
  static const Color surface = Color(0xFFFBF9F3);
  static const Color background = Color(0xFFF7F5EF);
  static const Color shellBackdropLight = Color(0xFFEFECE5);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF5F3ED);
  static const Color surfaceContainer = Color(0xFFF0EEE8);
  static const Color surfaceContainerHigh = Color(0xFFEAE8E2);

  static const Color onSurface = Color(0xFF1B1C18);
  static const Color onSurfaceVariant = Color(0xFF434843);

  static const Color outline = Color(0xFF737872);
  static const Color outlineVariant = Color(0xFFC3C8C1);

  // Primary (Deep Forest / Olive)
  static const Color primary = Color(0xFF1E3023);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF344638);
  static const Color onPrimaryContainer = Color(0xFF9FB3A1);

  // Secondary (Sage)
  static const Color secondary = Color(0xFF586156);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFDCE5D7);
  static const Color onSecondaryContainer = Color(0xFF394B3D);

  // Tertiary (Warm Sand / Amber)
  static const Color tertiary = Color(0xFF3B2811);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF533E25);
  static const Color onTertiaryContainer = Color(0xFFC7A98A);
  static const Color tertiaryFixed = Color(0xFFFEDDBB);
  static const Color accentWarm = Color(0xFFE9C9A8);
  static const Color accentBeige = Color(0xFFE9DCD2);

  // Error & Status
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color warningBgLight = Color(0xFFFFF2F2);
  static const Color warningTextLight = Color(0xFF701A1A);
  static const Color success = Color(0xFF2E6930);
  static const Color successContainer = Color(0xFFD8F3DC);
  static const Color starGold = Color(0xFFE5A823);

  // Demo Map Colors
  static const Color mapParkGreenLight = Color(0xFFD6E3D8);
  static const Color mapSeaBlueLight = Color(0xFFBCE0E8);
  static const Color mapSeaTextLight = Color(0xFF356A78);

  // Utility & Scrim Colors
  static const Color transparent = Color(0x00000000);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color modalBarrier = Color(0x73000000);
  static const Color heroGradientBottom = Color(0x73000000);
  static const Color galleryBadgeScrim = Color(0x99000000);
  static const Color glassBadgeLight = Color(0xE6FFFFFF);

  // ===========================================================================
  // DARK THEME (Khaki / Deep Forest Green — Pure Black #000000 is Forbidden!)
  // ===========================================================================
  static const Color darkBackground = Color(0xFF16241A);
  static const Color darkShellBackdrop = Color(0xFF111D14);
  static const Color darkSurface = Color(0xFF1E3023);
  static const Color darkSurfaceContainerLowest = Color(0xFF243628);
  static const Color darkSurfaceContainerLow = Color(0xFF2A3E2F);
  static const Color darkSurfaceContainer = Color(0xFF243628);
  static const Color darkSurfaceContainerHigh = Color(0xFF344638);
  static const Color darkPrimary = Color(0xFFDCE5D7);
  static const Color darkOnPrimary = Color(0xFF16241A);
  static const Color darkPrimaryContainer = Color(0xFF344638);
  static const Color darkOnPrimaryContainer = Color(0xFFDCE5D7);
  static const Color darkSecondary = Color(0xFF9FB3A1);
  static const Color darkOnSecondary = Color(0xFF16241A);
  static const Color darkSecondaryContainer = Color(0xFF344638);
  static const Color darkOnSecondaryContainer = Color(0xFFDCE5D7);
  static const Color darkTertiary = Color(0xFFE9C9A8);
  static const Color darkOnTertiary = Color(0xFF3B2811);
  static const Color darkTertiaryContainer = Color(0xFF533E25);
  static const Color darkTertiaryFixed = Color(0xFF3E3323);
  static const Color darkOnSurface = Color(0xFFEAE8E2);
  static const Color darkOnSurfaceVariant = Color(0xFF9FB3A1);
  static const Color darkOutline = Color(0xFF586D5B);
  static const Color darkOutlineVariant = Color(0xFF394B3D);
  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkOnError = Color(0xFF690005);
  static const Color darkErrorContainer = Color(0xFF5C1F1F);
  static const Color darkOnErrorContainer = Color(0xFFFFDAD6);
  static const Color darkWarningBg = Color(0xFF3B2020);
  static const Color darkWarningText = Color(0xFFFFDAD6);
  static const Color darkSuccess = Color(0xFF8CE99A);
  static const Color darkSuccessContainer = Color(0xFF1F4425);
  static const Color darkGlassBadge = Color(0xE6243628);
  static const Color darkMapParkGreen = Color(0xFF283D2D);
  static const Color darkMapSeaBlue = Color(0xFF1F3E47);
  static const Color darkMapSeaText = Color(0xFFA7D8E4);

  // Shadows
  static const List<BoxShadow> cardShadowLight = <BoxShadow>[
    BoxShadow(
      color: Color(0x0D344638),
      blurRadius: 20,
      offset: Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  static const List<BoxShadow> cardShadowDark = <BoxShadow>[
    BoxShadow(
      color: Color(0x330D1710),
      blurRadius: 20,
      offset: Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  static const List<BoxShadow> floatingShadowLight = <BoxShadow>[
    BoxShadow(
      color: Color(0x14292F29),
      blurRadius: 30,
      offset: Offset(0, 10),
      spreadRadius: -4,
    ),
  ];

  static const List<BoxShadow> floatingShadowDark = <BoxShadow>[
    BoxShadow(
      color: Color(0x4D0D1710),
      blurRadius: 30,
      offset: Offset(0, 10),
      spreadRadius: -4,
    ),
  ];

  static const List<BoxShadow> shellShadow = <BoxShadow>[
    BoxShadow(color: Color(0x1A16241A), blurRadius: 32, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> navBarShadow = <BoxShadow>[
    BoxShadow(color: Color(0x0A16241A), blurRadius: 16, offset: Offset(0, -4)),
  ];
}
