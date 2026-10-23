import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTypography {
  static TextStyle get display => GoogleFonts.nunitoSans(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 44 / 36,
    color: AppColors.onSurface,
    letterSpacing: -0.5,
  );

  static TextStyle get headlineHero => GoogleFonts.nunitoSans(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    color: AppColors.onSurface,
    letterSpacing: -0.3,
  );

  static TextStyle get headlineScreen => GoogleFonts.nunitoSans(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 34 / 26,
    color: AppColors.onSurface,
    letterSpacing: -0.2,
  );

  static TextStyle get headlineSection => GoogleFonts.nunitoSans(
    fontSize: 19,
    fontWeight: FontWeight.w600,
    height: 26 / 19,
    color: AppColors.onSurface,
  );

  static TextStyle get titleCard => GoogleFonts.nunitoSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 22 / 16,
    color: AppColors.onSurface,
  );

  static TextStyle get bodyDefault => GoogleFonts.nunitoSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle get bodyMedium => GoogleFonts.nunitoSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    color: AppColors.onSurface,
  );

  static TextStyle get caption => GoogleFonts.nunitoSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle get labelTag => GoogleFonts.nunitoSans(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 14 / 11,
    color: AppColors.onSurface,
    letterSpacing: 0.3,
  );
}
