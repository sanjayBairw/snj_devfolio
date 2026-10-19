import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/developer_avatar.dart';
import '../services/resume_download_service.dart';

/// Screen 5 (Bottom Left) — About Me matching the reference screenshot.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
      children: [
        // App Bar Title Area
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'About Me',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : kLightTextPrimary,
              ),
            ),
            IconButton(
              tooltip: 'View Resume',
              icon: const Icon(Icons.description_rounded, color: kAccentViolet),
              onPressed: () => ResumeDownloadService.openResumePreview(context),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Glowing Avatar
        const Center(child: DeveloperAvatar(radius: 52)),
        const SizedBox(height: 18),

        // Name
        Center(
          child: Text(
            kDevName,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : kLightTextPrimary,
            ),
          ),
        ),
        const SizedBox(height: 4),

        // Role
        Center(
          child: Text(
            kDevRole,
            style: TextStyle(
              color: isDark ? kDarkTextSecondary : kLightTextSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Bio Paragraph
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? kDarkSurface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isDark ? Colors.white.withValues(alpha: 0.08) : kLightBorder,
            ),
          ),
          child: Text(
            kDevBio,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: isDark ? kDarkTextPrimary : kLightTextPrimary,
            ),
          ),
        ),

        const SizedBox(height: 28),

        // ── Skills Section (Screen 5 Reference) ─────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Skills',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : kLightTextPrimary,
              ),
            ),
            const Text(
              '8 Core Skills',
              style: TextStyle(
                color: kAccentViolet,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 2x4 Skill Grid matching reference screenshot
        const Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _SkillButton('Flutter'),
            _SkillButton('Dart'),
            _SkillButton('Firebase'),
            _SkillButton('Rest API'),
            _SkillButton('FastAPI'),
            _SkillButton('MongoDB'),
            _SkillButton('Node.js'),
            _SkillButton('Git'),
          ],
        ),

        const SizedBox(height: 32),

        // ── Education & Background ──────────────────────────────────────────
        Text(
          'Education',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : kLightTextPrimary,
          ),
        ),
        const SizedBox(height: 14),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? kDarkSurface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isDark ? Colors.white.withValues(alpha: 0.08) : kLightBorder,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: kVioletPurpleGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'B.Tech — Computer Science & Engineering',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : kLightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Guru Ghasidas Central University',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            isDark ? kDarkTextSecondary : kLightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Specialised in Mobile Systems, Algorithms, Distributed Databases & Cloud Computing.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: isDark ? kDarkTextMuted : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Resume Download Action (Bundled in assets/document)
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => ResumeDownloadService.openResumePreview(context),
            icon: const Icon(Icons.description_rounded),
            label: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'View Resume',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: kPrimaryPurple,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SkillButton extends StatelessWidget {
  const _SkillButton(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? kDarkSurface2 : kLightSurface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : kLightBorder,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? kDarkTextPrimary : kLightTextPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
