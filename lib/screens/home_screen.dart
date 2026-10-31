import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/project.dart';
import '../services/resume_download_service.dart';
import '../services/supabase_service.dart';
import '../widgets/app_ui.dart';
import '../widgets/developer_avatar.dart';
import '../widgets/project_card.dart';

/// Screen 2 — Home Screen.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onNavigate});
  final ValueChanged<int> onNavigate;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Project> _featuredProjects = [];
  int _totalProjects = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFeatured();
  }

  Future<void> _loadFeatured() async {
    List<Project> source;
    try {
      final remote = await ProjectService.fetchPublished();
      source = remote.isNotEmpty ? remote : kSampleProjects;
    } catch (_) {
      // Fall back to the bundled sample projects.
      source = kSampleProjects;
    }
    if (!mounted) return;

    var featured = source.where((p) => p.isFeatured).toList();
    if (featured.isEmpty) featured = source.take(2).toList();

    setState(() {
      _totalProjects = source.length;
      _featuredProjects = featured.take(3).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: _loadFeatured,
      color: kAccentViolet,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
        children: [
          // ── Hero (the one animated moment on this screen) ────────────────
          Center(
            child: Column(
              children: [
                const FadeSlideIn(
                  index: 0,
                  child: DeveloperAvatar(radius: 46),
                ),
                const SizedBox(height: 18),
                FadeSlideIn(index: 1, child: _AvailabilityPill(isDark: isDark)),
                const SizedBox(height: 14),
                FadeSlideIn(
                  index: 2,
                  child: Column(
                    children: [
                      Text(
                        kDevName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: appTextPrimary(isDark),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        kDevRole,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: appTextSecondary(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FadeSlideIn(
                  index: 3,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final skill in kAllSkills.take(6)) TagPill(skill),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FadeSlideIn(
                  index: 4,
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.35,
                        color: appTextPrimary(isDark),
                      ),
                      children: const [
                        TextSpan(text: 'Building apps that\n'),
                        TextSpan(
                          text: 'solve real problems.',
                          style: TextStyle(color: kAccentViolet),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                FadeSlideIn(
                  index: 5,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      GradientButton(
                        label: 'View Projects',
                        icon: Icons.north_east_rounded,
                        onPressed: () => widget.onNavigate(1),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            ResumeDownloadService.openResumePreview(context),
                        icon: const Icon(Icons.description_rounded, size: 18),
                        label: const Text('View Resume'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Quick stats (computed from real data, nothing hard-coded) ────
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  value: _loading ? '–' : '$_totalProjects',
                  label: 'Projects',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  value: '${kAllSkills.length}',
                  label: 'Core skills',
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Featured Projects ────────────────────────────────────────────
          SectionHeader(
            'Featured Projects',
            trailing: TextButton(
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
          ),
          const SizedBox(height: 14),

          if (_loading) ...[
            const ProjectCardSkeleton(),
            const SizedBox(height: 14),
            const ProjectCardSkeleton(),
          ] else
            for (final p in _featuredProjects)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: ProjectCard(project: p),
              ),
        ],
      ),
    );
  }
}

class _AvailabilityPill extends StatelessWidget {
  const _AvailabilityPill({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF064E3B).withValues(alpha: 0.5)
            : const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: kEmeraldGreen.withValues(alpha: isDark ? 0.4 : 0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PulsingDot(),
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
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: kAccentViolet,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: appTextSecondary(isDark)),
          ),
        ],
      ),
    );
  }
}
