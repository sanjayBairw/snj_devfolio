import 'package:flutter/material.dart';
import '../constants.dart';
import 'portfolio_shell.dart';

/// Animated splash screen matching the reference design.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
    Future.delayed(const Duration(milliseconds: 1600), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const PortfolioShell(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
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
          // Background ambient neon wave painter
          Positioned.fill(
            child: CustomPaint(
              painter: _WaveRibbonPainter(),
            ),
          ),

          // Central branding
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Glowing Neon Icon Container
                      Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1224),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: kAccentViolet.withValues(alpha: 0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimaryPurple.withValues(alpha: 0.35),
                              blurRadius: 40,
                              spreadRadius: 8,
                            ),
                            BoxShadow(
                              color: kElectricBlue.withValues(alpha: 0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              'assets/logo/Neon SNJ Devfolio Logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // SNJ Devfolio Title
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'SNJ ',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: 'Devfolio',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: kAccentViolet,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Tagline
                      const Text(
                        kDevTagline,
                        style: TextStyle(
                          color: kDarkTextSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 70),

                      // Subtitle
                      const Text(
                        kDevSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kDarkTextMuted,
                          fontSize: 13,
                          height: 1.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom loading indicator matching screenshot
          Positioned(
            left: 48,
            right: 48,
            bottom: 48,
            child: AnimatedBuilder(
              animation: _controller,
              child: const Text(
                'Loading your portfolio...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kDarkTextMuted,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              builder: (context, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 3,
                      width: 140,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 140 * _progressAnimation.value,
                          decoration: BoxDecoration(
                            gradient: kPurpleBlueGradient,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: kAccentViolet.withValues(alpha: 0.6),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    child!,
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

/// Custom painter for the neon wavy ribbons shown in the reference splash screen.
class _WaveRibbonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x337C3AED),
          Color(0x1A3B82F6),
          Colors.transparent,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.15);
    path1.cubicTo(
      size.width * 0.45,
      size.height * 0.05,
      size.width * 0.7,
      size.height * 0.35,
      size.width,
      size.height * 0.28,
    );
    canvas.drawPath(path1, paint1);

    final paint2 = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x223B82F6),
          Color(0x33A855F7),
          Colors.transparent,
        ],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.85);
    path2.cubicTo(
      size.width * 0.35,
      size.height * 0.72,
      size.width * 0.6,
      size.height * 0.95,
      size.width,
      size.height * 0.78,
    );
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
