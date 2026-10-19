import 'package:flutter/material.dart';
import '../constants.dart';

/// Small pill badge for a technology name.
class SkillChip extends StatelessWidget {
  const SkillChip(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? kPanel2 : const Color(0xFFE8F4F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: .07)
              : const Color(0xFFB2D8E8),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? const Color(0xFFD5E3F5) : const Color(0xFF1A6B8A),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
