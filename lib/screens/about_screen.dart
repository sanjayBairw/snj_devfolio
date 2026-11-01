import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import '../services/resume_download_service.dart';
import '../utils/url_utils.dart';
import '../widgets/app_ui.dart';
import '../widgets/developer_avatar.dart';

/// Screen 5 — Editorial About & Skills with timeline matching SNJ Devfolio 2.0.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
      children: [
        // ── Title Header ────────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '03 // BIOGRAPHY & CAPABILITIES',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: kAccentViolet,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'About Me',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      color: appTextPrimary(isDark),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'View Resume',
              icon: const Icon(Icons.description_rounded, color: kAccentViolet),
              onPressed: () => ResumeDownloadService.openResumePreview(context),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // ── Editorial Biography Card ────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? kDarkSurface : Colors.white,
            borderRadius: BorderRadius.circular(kRadiusXl),
            border: Border.all(color: appBorderColor(isDark)),
            boxShadow: [
              BoxShadow(
                color: kAccentViolet.withValues(alpha: isDark ? 0.08 : 0.03),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const DeveloperAvatar(radius: 40, showStatusBadge: true),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kDevName,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: appTextPrimary(isDark),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          kDevRole,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            color: kAccentViolet,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Social shortcuts
                        Row(
                          children: [
                            _MiniSocialLink(
                              tooltip: 'GitHub',
                              icon: Icons.code_rounded,
                              onTap: () => openLink(kGithubUrl),
                            ),
                            const SizedBox(width: 8),
                            _MiniSocialLink(
                              tooltip: 'LinkedIn',
                              icon: Icons.work_rounded,
                              onTap: () => openLink(kLinkedinUrl),
                            ),
                            const SizedBox(width: 8),
                            _MiniSocialLink(
                              tooltip: 'X (Twitter)',
                              icon: Icons.alternate_email_rounded,
                              onTap: () => openLink(kXUrl),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Philosophy Statement
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? kDarkSurface2 : kLightSurface2,
                  borderRadius: BorderRadius.circular(kRadiusSm),
                  border: const Border(
                    left: BorderSide(color: kAccentViolet, width: 3),
                  ),
                ),
                child: Text(
                  '“Building apps that solve real problems through clean architecture, high visual polish, and performance-driven engineering.”',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                    color: appTextPrimary(isDark),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Narrative
              Text(
                kDevBio,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.65,
                  color: appTextSecondary(isDark),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // ── Skills & Technical Ecosystem ───────────────────────────────────
        SectionHeader(
          'My Skills',
          index: '01',
          subtitle: 'Specialized toolkit and architectural competencies',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: kAccentViolet.withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(kRadiusXs),
            ),
            child: Text(
              '${kAllSkills.length} SPECIALIZED',
              style: GoogleFonts.jetBrainsMono(
                color: kAccentViolet,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Grouped Skills with interactive elements (NO percentage bars)
        for (final entry in kSkillGroups.entries) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? kDarkSurface : Colors.white,
              borderRadius: BorderRadius.circular(kRadiusMd),
              border: Border.all(color: appBorderColor(isDark)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getGroupIcon(entry.key),
                      size: 16,
                      color: kAccentViolet,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.key.toUpperCase(),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: appTextPrimary(isDark),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${entry.value.length} Tools',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: appTextMuted(isDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in entry.value)
                      _InteractiveSkillBadge(
                        label: s,
                        isDark: isDark,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 32),

        // ── Education & Engineering Journey Timeline ───────────────────────
        const SectionHeader(
          'Education',
          index: '02',
          subtitle: 'Formal computer science education and specialization',
        ),
        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: isDark ? kDarkSurface : Colors.white,
            borderRadius: BorderRadius.circular(kRadiusLg),
            border: Border.all(color: appBorderColor(isDark)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TimelineEntry(
                period: 'CURRENT // DEGREE',
                title: 'B.Tech — Computer Science & Engineering',
                institution: 'Guru Ghasidas Central University',
                description:
                    'In-depth study of mobile distributed systems, algorithms, cloud computing, and advanced software architecture. Hands-on focus in production-grade Flutter development.',
                isDark: isDark,
                isLast: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // View Full Resume CTA
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => ResumeDownloadService.openResumePreview(context),
            icon: const Icon(Icons.description_rounded, size: 18),
            label: const Text('View Resume'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getGroupIcon(String group) {
    switch (group.toLowerCase()) {
      case 'mobile':
        return Icons.phone_android_rounded;
      case 'backend':
        return Icons.dns_rounded;
      case 'tools':
        return Icons.construction_rounded;
      default:
        return Icons.layers_rounded;
    }
  }
}

class _InteractiveSkillBadge extends StatefulWidget {
  const _InteractiveSkillBadge({
    required this.label,
    required this.isDark,
  });

  final String label;
  final bool isDark;

  @override
  State<_InteractiveSkillBadge> createState() => _InteractiveSkillBadgeState();
}

class _InteractiveSkillBadgeState extends State<_InteractiveSkillBadge> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _hovered
              ? (widget.isDark
                  ? kAccentViolet.withValues(alpha: 0.22)
                  : const Color(0xFFEDE9FE))
              : (widget.isDark ? kDarkSurface2 : kLightSurface2),
          borderRadius: BorderRadius.circular(kRadiusSm),
          border: Border.all(
            color: _hovered
                ? kAccentViolet
                : appBorderColor(widget.isDark),
            width: _hovered ? 1.4 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: _hovered ? kAccentViolet : kAccentBlue,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: _hovered ? FontWeight.w700 : FontWeight.w600,
                color: _hovered
                    ? (widget.isDark ? Colors.white : kAccentViolet)
                    : appTextPrimary(widget.isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.period,
    required this.title,
    required this.institution,
    required this.description,
    required this.isDark,
    this.isLast = false,
  });

  final String period;
  final String title;
  final String institution;
  final String description;
  final bool isDark;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline node
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: kAccentViolet,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? kDarkSurface : Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: kAccentViolet.withValues(alpha: 0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 80,
                color: appBorderColor(isDark),
              ),
          ],
        ),
        const SizedBox(width: 18),

        // Timeline body
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                period,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: kAccentViolet,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: appTextPrimary(isDark),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                institution,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: appTextSecondary(isDark),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.5,
                  color: appTextMuted(isDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniSocialLink extends StatelessWidget {
  const _MiniSocialLink({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: isDark ? kDarkSurface2 : kLightSurface2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: appBorderColor(isDark)),
      ),
      child: IconButton(
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 16, color: appTextSecondary(isDark)),
        onPressed: onTap,
      ),
    );
  }
}
