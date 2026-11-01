import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import 'app_ui.dart';

/// Labelled section divider with Swiss typography.
class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.jetBrainsMono(
            fontWeight: FontWeight.w700,
            fontSize: 11,
            color: kAccentViolet,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: appTextPrimary(isDark),
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}
