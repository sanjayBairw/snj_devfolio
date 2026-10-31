import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/resume_download_service.dart';
import '../utils/url_utils.dart';
import '../widgets/app_ui.dart';
import '../widgets/developer_avatar.dart';

/// Screen 5 — About Me.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
      children: [
        ScreenTitle(
          'About Me',
          actions: [
            IconButton(
              tooltip: 'View Resume',
              icon: const Icon(Icons.description_rounded, color: kAccentViolet),
              onPressed: () => ResumeDownloadService.openResumePreview(context),
            ),
          ],
        ),
        const SizedBox(height: 16),

        const Center(child: DeveloperAvatar(radius: 52)),
        const SizedBox(height: 18),
        Center(
          child: Text(
            kDevName,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: appTextPrimary(isDark),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            kDevRole,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: appTextSecondary(isDark),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Social shortcuts
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialButton(
              tooltip: 'GitHub',
              icon: Icons.code_rounded,
              onTap: () => openLink(kGithubUrl),
            ),
            _SocialButton(
              tooltip: 'LinkedIn',
              icon: Icons.work_rounded,
              onTap: () => openLink(kLinkedinUrl),
            ),
            _SocialButton(
              tooltip: 'X (Twitter)',
              icon: Icons.alternate_email_rounded,
              onTap: () => openLink(kXUrl),
            ),
          ],
        ),
        const SizedBox(height: 14),

        AppCard(
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

        // ── Skills, grouped by area ─────────────────────────────────────────
        SectionHeader(
          'My Skills',
          trailing: Text(
            '${kAllSkills.length} Core Skills',
            style: const TextStyle(
              color: kAccentViolet,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 14),

        for (final entry in kSkillGroups.entries) ...[
          Text(
            entry.key,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: appTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [for (final s in entry.value) TagPill(s, large: true)],
          ),
          const SizedBox(height: 16),
        ],

        const SizedBox(height: 12),

        // ── Education ───────────────────────────────────────────────────────
        const SectionHeader('Education'),
        const SizedBox(height: 14),

        AppCard(
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
                        color: appTextPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Guru Ghasidas Central University',
                      style: TextStyle(
                        fontSize: 13,
                        color: appTextSecondary(isDark),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Specialised in Mobile Systems, Algorithms, Distributed Databases & Cloud Computing.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: appTextMuted(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => ResumeDownloadService.openResumePreview(context),
            icon: const Icon(Icons.description_rounded),
            label: const Text('View Resume'),
            style: FilledButton.styleFrom(
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

class _SocialButton extends StatelessWidget {
  const _SocialButton({
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
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: appTextSecondary(isDark)),
    );
  }
}
