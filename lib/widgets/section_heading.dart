import 'package:flutter/material.dart';
import '../constants.dart';

/// Labelled section divider used throughout the portfolio.
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
          title,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 11,
            color: isDark ? kAccent : const Color(0xFF1A6B8A),
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0D1B2A),
          ),
        ),
      ],
    );
  }
}
