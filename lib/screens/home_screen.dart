import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/project.dart';
import '../services/supabase_service.dart';
import '../widgets/developer_avatar.dart';
import '../widgets/project_card.dart';
import '../services/resume_download_service.dart';

/// Screen 2 — Home Screen matching the reference screenshot.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onNavigate});
  final ValueChanged<int> onNavigate;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Project> _featuredProjects = [];

  @override
  void initState() {
    super.initState();
    _loadFeatured();
  }

  Future<void> _loadFeatured() async {
    try {
      final remote = await ProjectService.fetchPublished();
      if (!mounted) return;
      if (remote.isNotEmpty) {
        setState(() {
          _featuredProjects = remote.where((p) => p.isFeatured).toList();
          if (_featuredProjects.isEmpty) {
            _featuredProjects = remote.take(2).toList();
          }
        });
        return;
      }
    } catch (_) {
      // Fallback to sample projects
    }
    if (!mounted) return;
    setState(() {
      _featuredProjects =
          kSampleProjects.where((p) => p.isFeatured).take(2).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      children: [
        // ── Top Profile Section ─────────────────────────────────────────────
        Center(
          child: Column(
            children: [
              // Circular glowing avatar
              const DeveloperAvatar(radius: 46),
              const SizedBox(height: 18),

              // Available for Opportunities Pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF064E3B).withValues(alpha: 0.5)
                      : const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? kEmeraldGreen.withValues(alpha: 0.4)
                        : kEmeraldGreen.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: kEmeraldGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kEmeraldGreen,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Available for Opportunities',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF34D399)
                              : const Color(0xFF065F46),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Name
              Text(
                kDevName,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white : kLightTextPrimary,
                ),
              ),
              const SizedBox(height: 6),

              // Role
              Text(
                kDevRole,
                style: TextStyle(
                  color: isDark ? kDarkTextSecondary : kLightTextSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // Quick skill chips
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _QuickPill('Flutter'),
                  _QuickPill('Dart'),
                  _QuickPill('Rest API'),
                  _QuickPill('Firebase'),
                  _QuickPill('FastAPI'),
                  _QuickPill('MongoDB'),
                ],
              ),
              const SizedBox(height: 24),

              // Headline: "Building apps that solve real problems."
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                    fontFamily: 'Roboto',
                    color: isDark ? Colors.white : kLightTextPrimary,
                  ),
                  children: const [
                    TextSpan(text: 'Building apps that\n'),
                    TextSpan(
                      text: 'solve real problems.',
                      style: TextStyle(color: kAccentViolet),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Primary Actions Row: View Projects & Download Resume
              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  // View Projects Button (Gradient)
                  Container(
                    decoration: BoxDecoration(
                      gradient: kVioletPurpleGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimaryPurple.withValues(alpha: 0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => widget.onNavigate(1),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 22, vertical: 14),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View Projects',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.north_east_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // View Resume Button (Bundled assets/document preview)
                  OutlinedButton.icon(
                    onPressed: () =>
                        ResumeDownloadService.openResumePreview(context),
                    icon: const Icon(Icons.description_rounded, size: 18),
                    label: const Text('View Resume'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // ── Featured Projects Header ────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Featured Projects',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : kLightTextPrimary,
              ),
            ),
            TextButton(
              onPressed: () => widget.onNavigate(1),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      color: kAccentViolet,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 15,
                    color: kAccentViolet,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Featured project cards preview
        ..._featuredProjects.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: ProjectCard(project: p),
          ),
        ),
      ],
    );
  }
}

class _QuickPill extends StatelessWidget {
  const _QuickPill(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? kDarkSurface2 : kLightSurface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : kLightBorder,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? kDarkTextPrimary : kLightTextPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
