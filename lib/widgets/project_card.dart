import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import '../models/project.dart';
import '../screens/project_details_screen.dart';
import '../utils/url_utils.dart';
import 'app_ui.dart';

/// Editorial project showcase card matching SNJ Devfolio 2.0.
class ProjectCard extends StatefulWidget {
  const ProjectCard({
    super.key,
    required this.project,
    this.index,
    this.isAdminView = false,
    this.onEdit,
    this.onDelete,
    this.onTogglePublish,
  });

  final Project project;
  final int? index;
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
        .split(RegExp(r'[,|•]'))
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

    final accentColor = _getProjectAccentColor(p.title);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: _hovered
            ? (Matrix4.identity()..translateByDouble(0.0, -4.0, 0.0, 1.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: isDark ? kDarkSurface : Colors.white,
          borderRadius: BorderRadius.circular(kRadiusLg),
          border: Border.all(
            color: _hovered
                ? accentColor.withValues(alpha: 0.6)
                : appBorderColor(isDark),
            width: _hovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            if (isDark)
              BoxShadow(
                color: _hovered
                    ? accentColor.withValues(alpha: 0.22)
                    : Colors.black.withValues(alpha: 0.35),
                blurRadius: _hovered ? 28 : 12,
                offset: Offset(0, _hovered ? 10 : 4),
              )
            else
              BoxShadow(
                color: _hovered
                    ? accentColor.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: _hovered ? 24 : 10,
                offset: Offset(0, _hovered ? 8 : 2),
              ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(kRadiusLg),
            onTap: openDetails,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Metadata & Index Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Project Index Number
                      if (widget.index != null)
                        Text(
                          '${(widget.index! + 1).toString().padLeft(2, '0')} //',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                            letterSpacing: 1.0,
                          ),
                        ),

                      const Spacer(),

                      // Featured Badge
                      if (p.isFeatured) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: kAccentViolet.withValues(alpha: isDark ? 0.2 : 0.12),
                            borderRadius: BorderRadius.circular(kRadiusXs),
                            border: Border.all(
                              color: kAccentViolet.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 13,
                                color: kAccentViolet,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'FEATURED',
                                style: GoogleFonts.jetBrainsMono(
                                  color: kAccentViolet,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Admin status
                      if (widget.isAdminView) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: p.isPublished
                                ? kEmeraldGreen.withValues(alpha: 0.15)
                                : Colors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            p.isPublished ? 'LIVE' : 'DRAFT',
                            style: GoogleFonts.jetBrainsMono(
                              color: p.isPublished
                                  ? kEmeraldGreen
                                  : Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Header: Icon + Title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Custom Styled Project Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: isDark ? 0.16 : 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: accentColor.withValues(alpha: isDark ? 0.4 : 0.3),
                            width: 1.2,
                          ),
                        ),
                        child: Icon(
                          _getProjectIcon(p.title),
                          color: accentColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Title
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                                color: appTextPrimary(isDark),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: appTextSecondary(isDark),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Technology Tags
                  if (tags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags.take(5).map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? kDarkSurface2 : kLightSurface2,
                            borderRadius: BorderRadius.circular(kRadiusXs),
                            border: Border.all(
                              color: appBorderColor(isDark),
                            ),
                          ),
                          child: Text(
                            t,
                            style: GoogleFonts.jetBrainsMono(
                              color: isDark ? kDarkTextSecondary : kLightTextSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 18),

                  // Actions Row: Explore Case Study + GitHub + Admin controls
                  Row(
                    children: [
                      // View Case Study Button
                      Expanded(
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: isDark ? kDarkSurface2 : kLightSurface2,
                            borderRadius: BorderRadius.circular(kRadiusSm),
                            border: Border.all(
                              color: _hovered
                                  ? accentColor.withValues(alpha: 0.6)
                                  : appBorderColor(isDark),
                            ),
                          ),
                          child: Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(kRadiusSm),
                              onTap: openDetails,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Case Study',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          color: _hovered ? accentColor : appTextPrimary(isDark),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    AnimatedSlide(
                                      duration: const Duration(milliseconds: 180),
                                      offset: _hovered ? const Offset(0.2, -0.2) : Offset.zero,
                                      child: Icon(
                                        Icons.north_east_rounded,
                                        size: 14,
                                        color: _hovered ? accentColor : appTextSecondary(isDark),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // GitHub repository button
                      if (p.githubUrl.trim().isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isDark ? kDarkSurface2 : kLightSurface2,
                            borderRadius: BorderRadius.circular(kRadiusSm),
                            border: Border.all(
                              color: appBorderColor(isDark),
                            ),
                          ),
                          child: IconButton(
                            tooltip: 'Source Code',
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.code_rounded,
                              size: 19,
                              color: appTextPrimary(isDark),
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
                          constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: widget.onEdit,
                        ),
                        IconButton(
                          tooltip: p.isPublished ? 'Unpublish' : 'Publish',
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
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
                          constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
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

  Color _getProjectAccentColor(String title) {
    if (title.contains('SignSpeak')) {
      return kAccentViolet;
    } else if (title.contains('Devfolio')) {
      return kAccentBlue;
    } else if (title.contains('Nutrition')) {
      return kEmeraldGreen;
    } else if (title.contains('Video')) {
      return kCyanAccent;
    }
    return kAccentViolet;
  }
}
