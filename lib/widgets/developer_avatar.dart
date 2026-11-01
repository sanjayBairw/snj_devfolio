import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';

/// Premium editorial developer avatar.
class DeveloperAvatar extends StatelessWidget {
  const DeveloperAvatar({
    super.key,
    this.radius = 48,
    this.assetPath = kProfileAssetPath,
    this.imageUrl = kAvatarUrl,
    this.showGlow = true,
    this.showStatusBadge = false,
  });

  final double radius;
  final String assetPath;
  final String imageUrl;
  final bool showGlow;
  final bool showStatusBadge;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                kAccentViolet.withValues(alpha: isDark ? 0.8 : 0.6),
                kAccentBlue.withValues(alpha: isDark ? 0.6 : 0.4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: showGlow
                ? [
                    BoxShadow(
                      color: kAccentViolet.withValues(alpha: isDark ? 0.35 : 0.2),
                      blurRadius: radius * 0.8,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: kAccentBlue.withValues(alpha: isDark ? 0.25 : 0.15),
                      blurRadius: radius * 0.5,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.all(2.5),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? kDarkSurface : Colors.white,
            ),
            padding: const EdgeInsets.all(2.5),
            child: ClipOval(
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallbackAvatar(isDark),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _fallbackAvatar(isDark);
                  },
                ),
              ),
            ),
          ),
        ),
        if (showStatusBadge)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: radius * 0.35,
              height: radius * 0.35,
              decoration: BoxDecoration(
                color: kEmeraldGreen,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? kDarkBackground : Colors.white,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: kEmeraldGreen.withValues(alpha: 0.6),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _fallbackAvatar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF1E1736), Color(0xFF131520)]
              : const [Color(0xFFEDE9FE), Color(0xFFDBEAFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          'SB',
          style: GoogleFonts.spaceGrotesk(
            fontSize: radius * 0.65,
            fontWeight: FontWeight.w800,
            color: isDark ? kAccentViolet : const Color(0xFF6D28D9),
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
