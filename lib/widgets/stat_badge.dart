import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import 'app_ui.dart';

/// Minimalist Swiss metric badge component.
class StatBadge extends StatelessWidget {
  const StatBadge({
    super.key,
    required this.value,
    required this.label,
    this.tag,
  });

  final String value;
  final String label;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? kDarkSurface : Colors.white,
        borderRadius: BorderRadius.circular(kRadiusMd),
        border: Border.all(color: appBorderColor(isDark)),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tag != null) ...[
            Text(
              tag!.toUpperCase(),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: kAccentViolet,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: appTextPrimary(isDark),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: appTextSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }
}
