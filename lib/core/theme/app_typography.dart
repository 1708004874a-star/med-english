import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  // Display — for hero word titles (DM Serif Display gives medical gravitas)
  static TextStyle get display => GoogleFonts.dmSerifDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  // Headline — section headers
  static TextStyle get headline => GoogleFonts.dmSerifDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  // Title — card titles, prominent list items
  static TextStyle get title => GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  // Subtitle — secondary labels
  static TextStyle get subtitle => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  // Body — primary reading text
  static TextStyle get body => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.6,
      );

  // Body small — secondary body text
  static TextStyle get bodySmall => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  // Caption — timestamps, metadata
  static TextStyle get caption => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
        height: 1.4,
      );

  // Label — tags, chips, small bold labels
  static TextStyle get label => GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: AppColors.textSecondary,
      );

  // IPA phonetics — monospace for pronunciation notation
  static TextStyle get ipa => GoogleFonts.spaceMono(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  // Button text
  static TextStyle get button => GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );
}
