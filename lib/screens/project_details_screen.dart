import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/project.dart';
import '../utils/url_utils.dart';

/// Full-fidelity project details screen.
class ProjectDetailsScreen extends StatelessWidget {
  const ProjectDetailsScreen({super.key, required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tags = project.techStack
        .split('•')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          project.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Banner / Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? kDarkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : kLightBorder,
                    ),
                    gradient: isDark
                        ? const LinearGradient(
                            colors: [Color(0xFF131D35), Color(0xFF0F172A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryPurple.withValues(alpha: isDark ? 0.15 : 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: kVioletPurpleGradient,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: kPrimaryPurple.withValues(alpha: 0.3),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: Icon(
                              _getProjectIcon(project.title),
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project.title,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : kLightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    if (project.isFeatured)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: kPrimaryPurple.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: kAccentViolet.withValues(alpha: 0.4),
                                          ),
                                        ),
                                        child: const Text(
                                          '★ Featured Project',
                                          style: TextStyle(
                                            color: kAccentViolet,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: kEmeraldGreen.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Verified',
                                        style: TextStyle(
                                          color: kEmeraldGreen,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        project.description,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: isDark ? kDarkTextSecondary : kLightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Optional Project Image
                if (project.imageUrl.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      project.imageUrl,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ],

                // Key Features Section
                if (project.features.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  const Text(
                    'Key Highlights & Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...project.features.map(
                    (feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? kDarkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : kLightBorder,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: kPrimaryPurple.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: kAccentViolet,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                feature,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.45,
                                  color: isDark ? kDarkTextPrimary : kLightTextPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                // Technologies Used
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Technologies & Tools',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? kDarkSurface2 : kLightSurface2,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? kAccentViolet.withValues(alpha: 0.25)
                                : kLightBorder,
                          ),
                        ),
                        child: Text(
                          t,
                          style: TextStyle(
                            color: isDark ? kAccentViolet : kPrimaryPurple,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 32),

                // Primary Actions (Clean, robust layout without overflow)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final hasGithub = project.githubUrl.trim().isNotEmpty;
                    final hasDemo = project.demoUrl.trim().isNotEmpty;

                    if (!hasGithub && !hasDemo) {
                      return const SizedBox.shrink();
                    }

                    final githubButton = FilledButton.icon(
                      onPressed: () => openLink(project.githubUrl),
                      icon: const Icon(Icons.code_rounded),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('View on GitHub'),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: kPrimaryPurple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 16),
                      ),
                    );

                    final demoButton = OutlinedButton.icon(
                      onPressed: () => openLink(project.demoUrl),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Live Demo'),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 16),
                      ),
                    );

                    final isMobile = constraints.maxWidth < 480;

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

  IconData _getProjectIcon(String title) {
    if (title.contains('SignSpeak') || title.contains('Sign')) {
      return Icons.pan_tool_alt_rounded;
    } else if (title.contains('Devfolio') || title.contains('Portfolio')) {
      return Icons.code_rounded;
    } else if (title.contains('Nutrition') || title.contains('Coach')) {
      return Icons.favorite_rounded;
    } else if (title.contains('Video') || title.contains('Forensic')) {
      return Icons.video_settings_rounded;
    }
    return Icons.terminal_rounded;
  }
}
