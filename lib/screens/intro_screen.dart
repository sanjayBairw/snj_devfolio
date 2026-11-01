import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import 'portfolio_shell.dart';

/// Minimalist studio-level entrance screen for SNJ Devfolio 2.0.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 16.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.95, curve: Curves.easeInOutCubic),
      ),
    );

    _controller.forward();
    Future.delayed(const Duration(milliseconds: 1750), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const PortfolioShell(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBackground,
      body: Stack(
        children: [
          // Subtle architectural grid background
          Positioned.fill(
            child: CustomPaint(
              painter: _ArchitecturalGridPainter(),
            ),
          ),

          // Central Studio Identity
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Brand Mono Tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: kDarkSurface2,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: kDarkBorder,
                              ),
                            ),
                            child: Text(
                              'DIGITAL IDENTITY // 2.0',
                              style: GoogleFonts.jetBrainsMono(
                                color: kAccentViolet,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Brand Name in Space Grotesk
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'SNJ ',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1.0,
                                    color: kDarkTextPrimary,
                                  ),
                                ),
                                TextSpan(
                                  text: 'DEVFOLIO',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1.0,
                                    color: kAccentViolet,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Editorial Tagline
                          Text(
                            kDevHeadline.replaceAll('\n', ' • '),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: kDarkTextSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Text(
                            'Engineering & Design by $kDevName',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.jetBrainsMono(
                              color: kDarkTextMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom sleek progress track
          Positioned(
            left: 48,
            right: 48,
            bottom: 48,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 2,
                      width: 160,
                      decoration: BoxDecoration(
                        color: kDarkBorder,
                        borderRadius: BorderRadius.circular(1),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 160 * _progressAnimation.value,
                          decoration: BoxDecoration(
                            gradient: kVioletBlueGradient,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'CONNECTING // WORKSPACE',
                      style: GoogleFonts.jetBrainsMono(
                        color: kDarkTextMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Architectural minimal grid lines for the splash screen
class _ArchitecturalGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF141722)
      ..strokeWidth = 1.0;

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          kAccentViolet.withValues(alpha: 0.08),
          Colors.transparent,
        ],
        radius: 0.8,
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.5, size.height * 0.45),
        radius: size.width * 0.6,
      ));

    // Ambient radial glow
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.45),
      size.width * 0.6,
      glowPaint,
    );

    // Subtle crosslines
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
