import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import '../models/project.dart';
import '../utils/url_utils.dart';
import '../widgets/app_ui.dart';

/// Screen 3b — Premium Digital Case Study details screen.
class ProjectDetailsScreen extends StatelessWidget {
  const ProjectDetailsScreen({super.key, required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tags = project.techStack
        .split(RegExp(r'[,|•]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          project.title,
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        actions: [
          if (project.githubUrl.isNotEmpty)
            IconButton(
              tooltip: 'View on GitHub',
              icon: const Icon(Icons.code_rounded),
              onPressed: () => openLink(project.githubUrl),
            ),
          if (project.demoUrl.isNotEmpty)
            IconButton(
              tooltip: 'Live Demo',
              icon: const Icon(Icons.open_in_new_rounded),
              onPressed: () => openLink(project.demoUrl),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Case Study Hero Banner ──────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: isDark ? kDarkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(kRadiusXl),
                    border: Border.all(color: appBorderColor(isDark)),
                    boxShadow: [
                      BoxShadow(
                        color: kAccentViolet.withValues(alpha: isDark ? 0.12 : 0.04),
                        blurRadius: 30,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top badges in JetBrains Mono
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? kDarkSurface2 : kLightSurface2,
                              borderRadius: BorderRadius.circular(kRadiusXs),
                              border: Border.all(color: appBorderColor(isDark)),
                            ),
                            child: Text(
                              'CASE STUDY // 01',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: kAccentViolet,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          if (project.isFeatured)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: kAccentViolet.withValues(alpha: isDark ? 0.2 : 0.12),
                                borderRadius: BorderRadius.circular(kRadiusXs),
                                border: Border.all(
                                  color: kAccentViolet.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                '★ Featured Project',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: kAccentViolet,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: kEmeraldGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(kRadiusXs),
                            ),
                            child: Text(
                              'Verified',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: kEmeraldGreen,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Case study title in Space Grotesk
                      Text(
                        project.title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.0,
                          color: appTextPrimary(isDark),
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Detailed description
                      Text(
                        project.description,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          height: 1.65,
                          color: appTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),

                // Optional project preview image
                if (project.imageUrl.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(kRadiusLg),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: appBorderColor(isDark)),
                      ),
                      child: Image.network(
                        project.imageUrl,
                        width: double.infinity,
                        height: 280,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // ── Highlights & Key Engineering Features ────────────────────
                if (project.features.isNotEmpty) ...[
                  const SectionHeader(
                    'Key Highlights & Features',
                    index: '01',
                    subtitle: 'Architecture details, specialized modules and implementation notes',
                  ),
                  const SizedBox(height: 16),
                  ...project.features.map(
                    (feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? kDarkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(kRadiusMd),
                          border: Border.all(color: appBorderColor(isDark)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: kAccentViolet.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: kAccentViolet,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                feature,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: appTextPrimary(isDark),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],

                // ── Technical Stack & Ecosystem ──────────────────────────────
                if (tags.isNotEmpty) ...[
                  const SectionHeader(
                    'Technical Stack & Ecosystem',
                    index: '02',
                    subtitle: 'Languages, frameworks and runtime technologies leveraged',
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? kDarkSurface2 : kLightSurface2,
                          borderRadius: BorderRadius.circular(kRadiusSm),
                          border: Border.all(color: appBorderColor(isDark)),
                        ),
                        child: Text(
                          t,
                          style: GoogleFonts.jetBrainsMono(
                            color: isDark ? kAccentViolet : const Color(0xFF6D28D9),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 36),
                ],

                // ── Primary Call to Actions ──────────────────────────────────
                LayoutBuilder(
                  builder: (context, constraints) {
                    final hasGithub = project.githubUrl.trim().isNotEmpty;
                    final hasDemo = project.demoUrl.trim().isNotEmpty;

                    if (!hasGithub && !hasDemo) {
                      return const SizedBox.shrink();
                    }

                    final githubButton = FilledButton.icon(
                      onPressed: () => openLink(project.githubUrl),
                      icon: const Icon(Icons.code_rounded, size: 18),
                      label: const Text('View Source Code on GitHub'),
                      style: FilledButton.styleFrom(
                        backgroundColor: kAccentViolet,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 16),
                      ),
                    );

                    final demoButton = OutlinedButton.icon(
                      onPressed: () => openLink(project.demoUrl),
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text('Launch Live Demonstration'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 16),
                      ),
                    );

                    final isMobile = constraints.maxWidth < 560;

                    if (hasGithub && hasDemo) {
                      if (isMobile) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            githubButton,
                            const SizedBox(height: 12),
                            demoButton,
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: githubButton),
                          const SizedBox(width: 14),
                          Expanded(child: demoButton),
                        ],
                      );
                    }

                    return SizedBox(
                      width: double.infinity,
                      child: hasGithub ? githubButton : demoButton,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
