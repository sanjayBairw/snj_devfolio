import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/project.dart';
import '../screens/project_details_screen.dart';
import '../utils/url_utils.dart';

/// Premium project card matching Screen 3 of the reference design.
class ProjectCard extends StatefulWidget {
  const ProjectCard({
    super.key,
    required this.project,
    this.isAdminView = false,
    this.onEdit,
    this.onDelete,
    this.onTogglePublish,
  });

  final Project project;
  final bool isAdminView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTogglePublish;

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = widget.project;

    final tags = p.techStack
        .split('•')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    void openDetails() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProjectDetailsScreen(project: p),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: _hovered
            ? (Matrix4.identity()..translateByDouble(0.0, -3.0, 0.0, 1.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: isDark ? kDarkSurface : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _hovered
                ? kAccentViolet.withValues(alpha: 0.5)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : kLightBorder),
            width: _hovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? kPrimaryPurple.withValues(alpha: isDark ? 0.25 : 0.15)
                  : Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: _hovered ? 24 : 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: openDetails,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header: Icon + Title + Featured / Status Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Icon Container
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _getIconBackgroundColor(p.title, isDark),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getIconBorderColor(p.title),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _getIconGlowColor(p.title),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Icon(
                          _getProjectIcon(p.title),
                          color: _getIconForegroundColor(p.title),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Title and Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    p.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? Colors.white : kLightTextPrimary,
                                    ),
                                  ),
                                ),
                                if (p.isFeatured) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: kPrimaryPurple.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: kAccentViolet.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star_rounded,
                                          size: 13,
                                          color: kAccentViolet,
                                        ),
                                        SizedBox(width: 3),
                                        Text(
                                          'Featured',
                                          style: TextStyle(
                                            color: kAccentViolet,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                if (widget.isAdminView) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: p.isPublished
                                          ? kEmeraldGreen.withValues(alpha: 0.15)
                                          : Colors.orange.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      p.isPublished ? 'Live' : 'Draft',
                                      style: TextStyle(
                                        color: p.isPublished
                                            ? kEmeraldGreen
                                            : Colors.orange,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              p.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? kDarkTextSecondary : kLightTextSecondary,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Tech stack pill tags
                  if (tags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags.map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? kDarkSurface2 : kLightSurface2,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : kLightBorder,
                            ),
                          ),
                          child: Text(
                            t,
                            style: TextStyle(
                              color: isDark ? kDarkTextSecondary : kLightTextSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 16),

                  // Action buttons row
                  Row(
                    children: [
                      // View Project Button (Gradient Pill)
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: kVioletPurpleGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: kPrimaryPurple.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: openDetails,
                              child: const Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'View Project',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Icon(
                                          Icons.north_east_rounded,
                                          size: 15,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // GitHub Button (Dark Round Button)
                      if (p.githubUrl.trim().isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? kDarkSurface2 : kLightSurface2,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : kLightBorder,
                            ),
                          ),
                          child: IconButton(
                            tooltip: 'View GitHub Repository',
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.code_rounded,
                              size: 19,
                              color: isDark ? Colors.white : kLightTextPrimary,
                            ),
                            onPressed: () => openLink(p.githubUrl),
                          ),
                        ),
                      ],

                      // Admin controls
                      if (widget.isAdminView) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Edit',
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: widget.onEdit,
                        ),
                        IconButton(
                          tooltip: p.isPublished ? 'Unpublish' : 'Publish',
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            p.isPublished
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                          ),
                          onPressed: widget.onTogglePublish,
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.delete_outline,
                              size: 18, color: Colors.redAccent),
                          onPressed: widget.onDelete,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getProjectIcon(String title) {
    if (title.contains('SignSpeak') || title.contains('Sign')) {
      return Icons.pan_tool_alt_rounded;
    } else if (title.contains('Devfolio') || title.contains('portfolio')) {
      return Icons.code_rounded;
    } else if (title.contains('Nutrition') || title.contains('Coach')) {
      return Icons.favorite_rounded;
    } else if (title.contains('Video') || title.contains('Forensic')) {
      return Icons.video_settings_rounded;
    }
    return Icons.terminal_rounded;
  }

  Color _getIconBackgroundColor(String title, bool isDark) {
    if (title.contains('SignSpeak')) {
      return const Color(0xFF2E1065);
    } else if (title.contains('Devfolio')) {
      return const Color(0xFF1E3A8A);
    } else if (title.contains('Nutrition')) {
      return const Color(0xFF064E3B);
    }
    return isDark ? kDarkSurface2 : const Color(0xFFE2E8F0);
  }

  Color _getIconBorderColor(String title) {
    if (title.contains('SignSpeak')) {
      return kAccentViolet.withValues(alpha: 0.5);
    } else if (title.contains('Devfolio')) {
      return kElectricBlue.withValues(alpha: 0.5);
    } else if (title.contains('Nutrition')) {
      return kCyanAccent.withValues(alpha: 0.5);
    }
    return Colors.white.withValues(alpha: 0.1);
  }

  Color _getIconGlowColor(String title) {
    if (title.contains('SignSpeak')) {
      return kPrimaryPurple.withValues(alpha: 0.3);
    } else if (title.contains('Devfolio')) {
      return kElectricBlue.withValues(alpha: 0.3);
    } else if (title.contains('Nutrition')) {
      return kCyanAccent.withValues(alpha: 0.2);
    }
    return Colors.transparent;
  }

  Color _getIconForegroundColor(String title) {
    if (title.contains('SignSpeak')) {
      return kAccentViolet;
    } else if (title.contains('Devfolio')) {
      return kElectricBlue;
    } else if (title.contains('Nutrition')) {
      return kCyanAccent;
    }
    return Colors.white;
  }
}
