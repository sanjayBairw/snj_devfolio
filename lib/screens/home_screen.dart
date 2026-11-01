import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import '../models/project.dart';
import '../services/resume_download_service.dart';
import '../services/supabase_service.dart';
import '../widgets/app_ui.dart';
import '../widgets/developer_avatar.dart';
import '../widgets/project_card.dart';

/// Screen 2 — Homepage with Awwwards-level typography & asymmetrical layout.
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
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
        children: [
          // ── Asymmetrical Typography-Driven Hero ──────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 600;
              if (wide) {
                return _buildDesktopHero(isDark);
              }
              return _buildMobileHero(isDark);
            },
          ),

          const SizedBox(height: 24),

          // ── Minimalist Swiss Metrics Bar ─────────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final fourCols = constraints.maxWidth >= 840;
              final twoCols = constraints.maxWidth >= 460 && !fourCols;

              if (fourCols) {
                return Row(
                  children: [
                    Expanded(
                      child: _SwissStatItem(
                        index: '01',
                        value: _loading ? '–' : '$_totalProjects',
                        label: 'Featured Projects',
                        sub: 'Shipped & Open Source',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _SwissStatItem(
                        index: '02',
                        value: '${kAllSkills.length}+',
                        label: 'Core Technologies',
                        sub: 'Mobile, Backend & Tools',
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: _SwissStatItem(
                        index: '03',
                        value: '100%',
                        label: 'Flutter & Dart Focus',
                        sub: 'Clean Architecture',
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: _SwissStatItem(
                        index: '04',
                        value: 'Global',
                        label: 'Remote Ready',
                        sub: 'Available Worldwide',
                      ),
                    ),
                  ],
                );
              }

              if (twoCols) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _SwissStatItem(
                            index: '01',
                            value: _loading ? '–' : '$_totalProjects',
                            label: 'Featured Projects',
                            sub: 'Shipped & Open Source',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SwissStatItem(
                            index: '02',
                            value: '${kAllSkills.length}+',
                            label: 'Core Technologies',
                            sub: 'Mobile, Backend & Tools',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Expanded(
                          child: _SwissStatItem(
                            index: '03',
                            value: '100%',
                            label: 'Flutter Focus',
                            sub: 'Clean Architecture',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _SwissStatItem(
                            index: '04',
                            value: 'Global',
                            label: 'Remote Ready',
                            sub: 'Available Worldwide',
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _SwissStatItem(
                    index: '01',
                    value: _loading ? '–' : '$_totalProjects',
                    label: 'Featured Projects',
                    sub: 'Shipped & Open Source',
                  ),
                  const SizedBox(height: 10),
                  _SwissStatItem(
                    index: '02',
                    value: '${kAllSkills.length}+',
                    label: 'Core Technologies',
                    sub: 'Mobile, Backend & Tools',
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 54),

          // ── Featured Projects Editorial Showcase ─────────────────────────
          SectionHeader(
            'Featured Case Studies',
            index: '01',
            subtitle: 'Selected case studies and mobile applications built with Flutter',
            trailing: TextButton(
              onPressed: () => widget.onNavigate(1),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All Projects',
                    style: GoogleFonts.inter(
                      color: kAccentViolet,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 15,
                    color: kAccentViolet,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (_loading) ...[
            const ProjectCardSkeleton(),
            const SizedBox(height: 16),
            const ProjectCardSkeleton(),
          ] else
            for (int i = 0; i < _featuredProjects.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ProjectCard(
                  project: _featuredProjects[i],
                  index: i,
                ),
              ),
        ],
      ),
    );
  }

  // ── Desktop Asymmetrical Hero ───────────────────────────────────────────────
  Widget _buildDesktopHero(bool isDark) {
    return FadeSlideIn(
      index: 0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Typography-driven statement & primary actions
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AvailabilityBadge(
                  text: 'Available for Opportunities',
                ),
                const SizedBox(height: 12),

                // Oversized Headline in Space Grotesk
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.0,
                      height: 1.1,
                      color: appTextPrimary(isDark),
                    ),
                    children: const [
                      TextSpan(text: 'Building apps that\n'),
                      TextSpan(
                        text: 'solve real problems.',
                        style: TextStyle(
                          color: kAccentViolet,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Editorial biography statement
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: Text(
                    'Hi, I\'m $kDevName. $kDevBio',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.5,
                      color: appTextSecondary(isDark),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Core Tech Stack Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final skill in kAllSkills.take(4))
                      TagPill(skill, large: false),
                  ],
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    GradientButton(
                      label: 'View Projects',
                      icon: Icons.north_east_rounded,
                      onPressed: () => widget.onNavigate(1),
                    ),
                    const SizedBox(width: 14),
                    OutlinedButton.icon(
                      onPressed: () =>
                          ResumeDownloadService.openResumePreview(context),
                      icon: const Icon(Icons.description_rounded, size: 18),
                      label: const Text('View Resume'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 40),

          // Right: Architectural profile presentation
          Expanded(
            flex: 4,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 360),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? kDarkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(kRadiusXl),
                  border: Border.all(color: appBorderColor(isDark)),
                  boxShadow: [
                    BoxShadow(
                      color: kAccentViolet.withValues(alpha: isDark ? 0.12 : 0.05),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const DeveloperAvatar(
                      radius: 40,
                      showStatusBadge: true,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      kDevName,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: appTextPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      kDevRole,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: kAccentViolet,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? kDarkSurface2 : kLightSurface2,
                        borderRadius: BorderRadius.circular(kRadiusSm),
                        border: Border.all(color: appBorderColor(isDark)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _QuickStatCell(
                            label: 'EXPERIENCE',
                            value: 'Production',
                            isDark: isDark,
                          ),
                          Container(
                            height: 24,
                            width: 1,
                            color: appBorderColor(isDark),
                          ),
                          _QuickStatCell(
                            label: 'CORE SPECIALTY',
                            value: 'Flutter & Dart',
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Mobile Hero ─────────────────────────────────────────────────────────────
  Widget _buildMobileHero(bool isDark) {
    return FadeSlideIn(
      index: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const DeveloperAvatar(radius: 32, showStatusBadge: true),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kDevName,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: appTextPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      kDevRolePipe,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: kAccentViolet,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          const AvailabilityBadge(
            text: 'Available for Opportunities',
          ),
          const SizedBox(height: 14),

          RichText(
            text: TextSpan(
              style: GoogleFonts.spaceGrotesk(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                height: 1.15,
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
          ),
          const SizedBox(height: 10),

          Text(
            kDevBio,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.5,
              color: appTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final skill in kAllSkills.take(6)) TagPill(skill),
            ],
          ),
          const SizedBox(height: 18),

          Wrap(
            spacing: 12,
            runSpacing: 10,
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
                    horizontal: 18,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SwissStatItem extends StatelessWidget {
  const _SwissStatItem({
    required this.index,
    required this.value,
    required this.label,
    required this.sub,
  });

  final String index;
  final String value;
  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
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
              Text(
                '$index //',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: kAccentViolet,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: appTextPrimary(isDark),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: appTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: appTextMuted(isDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatCell extends StatelessWidget {
  const _QuickStatCell({
    required this.label,
    required this.value,
    required this.isDark,
  });

  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: appTextMuted(isDark),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: appTextPrimary(isDark),
          ),
        ),
      ],
    );
  }
}
