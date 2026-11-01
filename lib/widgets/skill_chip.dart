import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import 'app_ui.dart';

/// Technical skill badge with JetBrains Mono typography.
class SkillChip extends StatelessWidget {
  const SkillChip(this.label, {super.key, this.isPrimary = false});
  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: isPrimary
            ? kAccentViolet.withValues(alpha: isDark ? 0.2 : 0.12)
            : (isDark ? kDarkSurface2 : kLightSurface2),
        borderRadius: BorderRadius.circular(kRadiusSm),
        border: Border.all(
          color: isPrimary
              ? kAccentViolet.withValues(alpha: 0.5)
              : appBorderColor(isDark),
          width: isPrimary ? 1.2 : 1.0,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          color: isPrimary
              ? (isDark ? kAccentViolet : const Color(0xFF6D28D9))
              : appTextPrimary(isDark),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
