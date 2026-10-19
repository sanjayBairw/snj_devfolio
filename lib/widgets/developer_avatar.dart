import 'package:flutter/material.dart';
import '../constants.dart';

/// Glowing developer avatar matching the reference design.
class DeveloperAvatar extends StatelessWidget {
  const DeveloperAvatar({
    super.key,
    this.radius = 48,
    this.assetPath = kProfileAssetPath,
    this.imageUrl = kAvatarUrl,
    this.showGlow = true,
  });

  final double radius;
  final String assetPath;
  final String imageUrl;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: kVioletPurpleGradient,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: kPrimaryPurple.withValues(alpha: 0.45),
                  blurRadius: radius * 0.7,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: kElectricBlue.withValues(alpha: 0.3),
                  blurRadius: radius * 0.5,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(3.0),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: kDarkSurface,
        ),
        padding: const EdgeInsets.all(2.5),
        child: ClipOval(
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallbackAvatar(),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _fallbackAvatar();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _fallbackAvatar() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF2E1065), Color(0xFF1E1B4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          'SB',
          style: TextStyle(
            fontSize: radius * 0.7,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
