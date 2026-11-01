import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';

// ─── App Typography System (Space Grotesk • Inter • JetBrains Mono) ────────────
class AppTypography {
  AppTypography._();

  /// Space Grotesk — Display large headlines & hero text
  static TextStyle displayLarge(
    BuildContext context, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize ?? 44,
      fontWeight: fontWeight ?? FontWeight.w800,
      color: color ?? appTextPrimary(isDark),
      letterSpacing: letterSpacing ?? -1.2,
      height: height ?? 1.08,
    );
  }

  /// Space Grotesk — Section and card titles
  static TextStyle displayMedium(
    BuildContext context, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize ?? 28,
      fontWeight: fontWeight ?? FontWeight.w800,
      color: color ?? appTextPrimary(isDark),
      letterSpacing: letterSpacing ?? -0.8,
      height: height ?? 1.15,
    );
  }

  /// Space Grotesk — Small titles & modal headers
  static TextStyle displaySmall(
    BuildContext context, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize ?? 20,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color ?? appTextPrimary(isDark),
      letterSpacing: letterSpacing ?? -0.4,
      height: height ?? 1.25,
    );
  }

  /// Inter — Body editorial paragraphs
  static TextStyle body(
    BuildContext context, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.inter(
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color ?? appTextSecondary(isDark),
      letterSpacing: letterSpacing ?? 0.0,
      height: height ?? 1.55,
    );
  }

  /// Inter — UI labels, buttons, controls
  static TextStyle label(
    BuildContext context, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.inter(
      fontSize: fontSize ?? 13,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color ?? appTextPrimary(isDark),
      letterSpacing: letterSpacing ?? 0.1,
    );
  }

  /// JetBrains Mono — Technical labels, stats, metadata chips, code tags
  static TextStyle mono(
    BuildContext context, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize ?? 12,
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color ?? appTextSecondary(isDark),
      letterSpacing: letterSpacing ?? 0.4,
    );
  }

  /// JetBrains Mono — Badge / category indicator (uppercase, tracked)
  static TextStyle monoBadge(
    BuildContext context, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize ?? 11,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color ?? kAccentViolet,
      letterSpacing: 1.2,
    );
  }
}

// ─── Color Helpers ─────────────────────────────────────────────────────────────
Color appBorderColor(bool isDark) => isDark ? kDarkBorder : kLightBorder;
Color appTextPrimary(bool isDark) => isDark ? kDarkTextPrimary : kLightTextPrimary;
Color appTextSecondary(bool isDark) => isDark ? kDarkTextSecondary : kLightTextSecondary;
Color appTextMuted(bool isDark) => isDark ? kDarkTextMuted : kLightTextMuted;
Color appSurfaceColor(bool isDark) => isDark ? kDarkSurface : kLightSurface;
Color appSurface2Color(bool isDark) => isDark ? kDarkSurface2 : kLightSurface2;

// ─── Architectural Card Component ─────────────────────────────────────────────
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = kRadiusLg,
    this.onTap,
    this.onLongPress,
    this.color,
    this.border,
    this.enableHover = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final BoxBorder? border;
  final bool enableHover;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isInteractive = widget.onTap != null;
    final isHovering = widget.enableHover && isInteractive && _hovered;

    return MouseRegion(
      onEnter: isInteractive ? (_) => setState(() => _hovered = true) : null,
      onExit: isInteractive ? (_) => setState(() => _hovered = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: isHovering
            ? (Matrix4.identity()..translateByDouble(0.0, -3.0, 0.0, 1.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: widget.color ?? (isDark ? kDarkSurface : kLightSurface),
          borderRadius: BorderRadius.circular(widget.radius),
          border: widget.border ??
              Border.all(
                color: isHovering
                    ? kAccentViolet.withValues(alpha: 0.5)
                    : appBorderColor(isDark),
                width: isHovering ? 1.4 : 1.0,
              ),
          boxShadow: [
            if (isDark)
              BoxShadow(
                color: isHovering
                    ? kAccentViolet.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.35),
                blurRadius: isHovering ? 24 : 12,
                offset: Offset(0, isHovering ? 8 : 4),
              )
            else
              BoxShadow(
                color: isHovering
                    ? kAccentViolet.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: isHovering ? 20 : 10,
                offset: Offset(0, isHovering ? 6 : 2),
              ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(widget.radius),
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
  }
}

// ─── Screen Title Component ───────────────────────────────────────────────────
class ScreenTitle extends StatelessWidget {
  const ScreenTitle(
    this.title, {
    super.key,
    this.indexPrefix,
    this.actions = const [],
  });

  final String title;
  final String? indexPrefix;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (indexPrefix != null) ...[
                  Text(
                    indexPrefix!,
                    style: AppTypography.monoBadge(context, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  title,
                  style: AppTypography.displayMedium(
                    context,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: appTextPrimary(isDark),
                  ),
                ),
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

// ─── Editorial Section Header ─────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    super.key,
    this.index,
    this.trailing,
    this.subtitle,
  });

  final String title;
  final String? index;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            if (index != null) ...[
              Text(
                '$index //',
                style: AppTypography.monoBadge(
                  context,
                  color: isDark ? kAccentBlue : kAccentViolet,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                title,
                style: AppTypography.displaySmall(
                  context,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: appTextPrimary(isDark),
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: AppTypography.body(context, fontSize: 13),
          ),
        ],
      ],
    );
  }
}

// ─── Technical Tag Pill ───────────────────────────────────────────────────────
class TagPill extends StatelessWidget {
  const TagPill(
    this.label, {
    super.key,
    this.large = false,
    this.icon,
    this.color,
    this.active = false,
  });

  final String label;
  final bool large;
  final IconData? icon;
  final Color? color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = color ?? (isDark ? kAccentViolet : const Color(0xFF6D28D9));

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 11,
        vertical: large ? 8 : 5,
      ),
      decoration: BoxDecoration(
        color: active
            ? accent.withValues(alpha: isDark ? 0.2 : 0.12)
            : (isDark ? kDarkSurface2 : kLightSurface2),
        borderRadius: BorderRadius.circular(kRadiusSm),
        border: Border.all(
          color: active
              ? accent.withValues(alpha: 0.6)
              : appBorderColor(isDark),
          width: active ? 1.2 : 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: large ? 15 : 13, color: accent),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: large ? 12 : 11,
              fontWeight: active ? FontWeight.w700 : FontWeight.w600,
              color: active ? accent : appTextPrimary(isDark),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Primary Editorial Gradient Button ────────────────────────────────────────
class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.gradient,
    this.padding,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: _hovered
            ? (Matrix4.identity()..translateByDouble(0.0, -1.5, 0.0, 1.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          gradient: widget.gradient ?? kVioletBlueGradient,
          borderRadius: BorderRadius.circular(kRadiusMd),
          boxShadow: [
            BoxShadow(
              color: kAccentViolet.withValues(alpha: _hovered ? 0.45 : 0.3),
              blurRadius: _hovered ? 18 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(kRadiusMd),
            onTap: widget.onPressed,
            child: Padding(
              padding: widget.padding ??
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.label,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (widget.icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(widget.icon, size: 16, color: Colors.white),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Pulsing Live Status Dot ──────────────────────────────────────────────────
class PulsingDot extends StatefulWidget {
  const PulsingDot({super.key, this.color = kEmeraldGreen, this.size = 8});

  final Color color;
  final double size;

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.35 + 0.45 * _c.value),
              blurRadius: 4 + 7 * _c.value,
              spreadRadius: 1 + 2 * _c.value,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Live Availability Badge ──────────────────────────────────────────────────
class AvailabilityBadge extends StatelessWidget {
  const AvailabilityBadge({super.key, this.text = 'AVAILABLE FOR OPPORTUNITIES'});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF064E3B).withValues(alpha: 0.35)
            : const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: kEmeraldGreen.withValues(alpha: isDark ? 0.4 : 0.6),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PulsingDot(color: kEmeraldGreen, size: 8),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.jetBrainsMono(
              color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Subtle Entrance Animation ────────────────────────────────────────────────
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = 18,
  });

  final Widget child;
  final int index;
  final double offset;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return child;
    final step = index > 8 ? 8 : index;
    final delayMs = step * 60;
    final totalMs = 450 + delayMs;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: totalMs),
      curve: Interval(delayMs / totalMs, 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * offset),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

// ─── Shimmering / Pulsing Loading Skeletons ────────────────────────────────────
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = kRadiusSm,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final a = isDark ? kDarkSurface2 : kLightSurface2;
    final b = isDark ? kDarkSurface3 : kLightSurface3;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(a, b, Curves.easeInOut.transform(_c.value)),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

class ProjectCardSkeleton extends StatelessWidget {
  const ProjectCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBox(height: 48, width: 48, radius: 14),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(height: 18, width: 180),
                    SizedBox(height: 6),
                    SkeletonBox(height: 12, width: 120),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SkeletonBox(height: 12),
          SizedBox(height: 8),
          SkeletonBox(height: 12, width: 240),
          SizedBox(height: 16),
          Row(
            children: [
              SkeletonBox(height: 26, width: 72, radius: 8),
              SizedBox(width: 8),
              SkeletonBox(height: 26, width: 80, radius: 8),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Editorial Empty State ────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark ? kDarkSurface2 : kLightSurface2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: appBorderColor(isDark)),
              ),
              child: Icon(icon, size: 28, color: appTextMuted(isDark)),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.displaySmall(
                context,
                fontSize: 18,
                color: appTextPrimary(isDark),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: AppTypography.body(context, fontSize: 13),
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
