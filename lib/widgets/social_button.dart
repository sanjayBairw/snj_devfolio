import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import 'app_ui.dart';

/// Minimalist outlined icon button for social/profile links.
class SocialButton extends StatefulWidget {
  const SocialButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<SocialButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: _hovered
              ? (isDark ? kDarkSurface2 : kLightSurface2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(kRadiusMd),
          border: Border.all(
            color: _hovered
                ? kAccentViolet.withValues(alpha: 0.5)
                : appBorderColor(isDark),
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(kRadiusMd),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    size: 18,
                    color: _hovered ? kAccentViolet : appTextPrimary(isDark),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _hovered ? kAccentViolet : appTextPrimary(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
