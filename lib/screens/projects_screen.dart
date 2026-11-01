import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import '../models/project.dart';
import '../services/supabase_service.dart';
import '../widgets/app_ui.dart';
import '../widgets/project_card.dart';

enum _Sort { defaultOrder, featuredFirst, titleAZ }

/// Screen 3 — Editorial Projects Showcase matching SNJ Devfolio 2.0.
class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<Project> _allProjects = [];
  List<Project> _filteredProjects = [];
  List<String> _filters = const ['All', 'Featured', 'GitHub'];
  bool _loading = true;
  String? _error;
  bool _usingFallback = false;
  String _selectedFilter = 'All';
  String _searchQuery = '';
  bool _isSearchOpen = false;
  _Sort _sort = _Sort.defaultOrder;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    List<Project> projects;
    var fallback = false;
    String? error;
    try {
      final remote = await ProjectService.fetchPublished();
      if (remote.isEmpty) {
        projects = kSampleProjects;
        fallback = true;
      } else {
        projects = remote;
      }
    } catch (e) {
      projects = kSampleProjects;
      fallback = true;
      error = e.toString();
    }
    if (!mounted) return;

    setState(() {
      _allProjects = projects;
      _usingFallback = fallback;
      _error = error;
      _filters = ['All', 'Featured', 'GitHub', ..._topTechTags(projects)];
      if (!_filters.contains(_selectedFilter)) _selectedFilter = 'All';
      _applyFilter();
      _loading = false;
    });
  }

  static List<String> _techOf(Project p) => p.techStack
      .split(RegExp(r'[,|•]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  static List<String> _topTechTags(List<Project> projects) {
    final counts = <String, int>{};
    final display = <String, String>{};
    for (final p in projects) {
      for (final tech in _techOf(p)) {
        final key = tech.toLowerCase();
        counts[key] = (counts[key] ?? 0) + 1;
        display.putIfAbsent(key, () => tech);
      }
    }
    final keys = counts.keys.toList()
      ..sort((a, b) {
        final byCount = counts[b]!.compareTo(counts[a]!);
        return byCount != 0 ? byCount : a.compareTo(b);
      });
    return keys.take(4).map((k) => display[k]!).toList();
  }

  void _applyFilter() {
    var list = List<Project>.from(_allProjects);

    switch (_selectedFilter) {
      case 'All':
        break;
      case 'Featured':
        list = list.where((p) => p.isFeatured).toList();
      case 'GitHub':
        list = list.where((p) => p.githubUrl.trim().isNotEmpty).toList();
      default:
        final tech = _selectedFilter.toLowerCase();
        list = list
            .where((p) => _techOf(p).any((t) => t.toLowerCase() == tech))
            .toList();
    }

    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((p) {
        return p.title.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.techStack.toLowerCase().contains(q);
      }).toList();
    }

    switch (_sort) {
      case _Sort.defaultOrder:
        break;
      case _Sort.featuredFirst:
        list = [
          ...list.where((p) => p.isFeatured),
          ...list.where((p) => !p.isFeatured),
        ];
      case _Sort.titleAZ:
        list.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
    }

    _filteredProjects = list;
  }

  void _resetFilters() {
    setState(() {
      _selectedFilter = 'All';
      _searchQuery = '';
      _searchCtrl.clear();
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showSkeleton = _loading && _allProjects.isEmpty;

    return RefreshIndicator(
      onRefresh: _load,
      color: kAccentViolet,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
        children: [
          // ── Screen Title with Space Grotesk & Actions ─────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '02 // ARCHIVE & SHOWCASE',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: kAccentViolet,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'My Projects',
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
              PopupMenuButton<_Sort>(
                tooltip: 'Sort Order',
                initialValue: _sort,
                icon: Icon(Icons.sort_rounded, color: appTextPrimary(isDark)),
                onSelected: (value) => setState(() {
                  _sort = value;
                  _applyFilter();
                }),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: _Sort.defaultOrder,
                    child: Text('Default Order'),
                  ),
                  PopupMenuItem(
                    value: _Sort.featuredFirst,
                    child: Text('Featured First'),
                  ),
                  PopupMenuItem(
                    value: _Sort.titleAZ,
                    child: Text('Title A–Z'),
                  ),
                ],
              ),
              IconButton(
                tooltip: _isSearchOpen ? 'Close Search' : 'Search Projects',
                icon: Icon(
                  _isSearchOpen ? Icons.close_rounded : Icons.search_rounded,
                  color: appTextPrimary(isDark),
                ),
                onPressed: () {
                  setState(() {
                    _isSearchOpen = !_isSearchOpen;
                    if (!_isSearchOpen) {
                      _searchQuery = '';
                      _searchCtrl.clear();
                      _applyFilter();
                    }
                  });
                },
              ),
            ],
          ),

          if (_isSearchOpen) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _searchCtrl,
              autofocus: true,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search by title, tech stack, or description...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {
                            _searchQuery = '';
                            _applyFilter();
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (val) => setState(() {
                _searchQuery = val;
                _applyFilter();
              }),
            ),
          ],

          const SizedBox(height: 18),

          // ── Minimalist Filter Chips ──────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final filter in _filters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _EditorialFilterChip(
                      label: filter,
                      selected: _selectedFilter == filter,
                      isDark: isDark,
                      onTap: () => setState(() {
                        _selectedFilter = filter;
                        _applyFilter();
                      }),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Metadata line in JetBrains Mono
          if (!showSkeleton)
            Row(
              children: [
                Text(
                  'SHOWING ${_filteredProjects.length} OF ${_allProjects.length} DIGITAL PRODUCTS',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: appTextMuted(isDark),
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                if (_selectedFilter != 'All' || _searchQuery.isNotEmpty)
                  InkWell(
                    onTap: _resetFilters,
                    child: Text(
                      'CLEAR FILTERS',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: kAccentViolet,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
              ],
            ),

          const SizedBox(height: 16),

          // Fallback notice banner
          if (_usingFallback && !showSkeleton) ...[
            _FallbackBanner(
              isDark: isDark,
              hasError: _error != null,
              onRetry: _load,
            ),
            const SizedBox(height: 16),
          ],

          // Project List / Responsive Grid
          if (showSkeleton) ...[
            const ProjectCardSkeleton(),
            const SizedBox(height: 16),
            const ProjectCardSkeleton(),
            const SizedBox(height: 16),
            const ProjectCardSkeleton(),
          ] else if (_filteredProjects.isEmpty)
            EmptyState(
              icon: Icons.filter_list_off_rounded,
              title: _searchQuery.trim().isNotEmpty
                  ? 'No projects match "${_searchQuery.trim()}"'
                  : _selectedFilter != 'All'
                      ? 'No projects under "$_selectedFilter"'
                      : 'No projects yet',
              message: 'Try a different search or clear the filters.',
              actionLabel: 'Reset filters',
              onAction: _resetFilters,
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 16.0;
                final twoColumns = constraints.maxWidth >= 720;
                final cardWidth = twoColumns
                    ? (constraints.maxWidth - gap) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (int i = 0; i < _filteredProjects.length; i++)
                      SizedBox(
                        width: cardWidth,
                        child: ProjectCard(
                          project: _filteredProjects[i],
                          index: i,
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _EditorialFilterChip extends StatelessWidget {
  const _EditorialFilterChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(kRadiusSm),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? (isDark ? kAccentViolet.withValues(alpha: 0.22) : const Color(0xFFEDE9FE))
                : (isDark ? kDarkSurface : Colors.white),
            borderRadius: BorderRadius.circular(kRadiusSm),
            border: Border.all(
              color: selected ? kAccentViolet : appBorderColor(isDark),
              width: selected ? 1.4 : 1.0,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              color: selected
                  ? (isDark ? Colors.white : kAccentViolet)
                  : appTextSecondary(isDark),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _FallbackBanner extends StatelessWidget {
  const _FallbackBanner({
    required this.isDark,
    required this.hasError,
    required this.onRetry,
  });

  final bool isDark;
  final bool hasError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? kDarkSurface2 : const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(kRadiusMd),
        border: Border.all(color: kAccentViolet.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: kAccentViolet,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hasError
                  ? "Couldn't reach remote database. Showing verified local sample projects."
                  : 'No published remote projects found. Showing verified sample projects.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: appTextSecondary(isDark),
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'RETRY',
              style: GoogleFonts.jetBrainsMono(
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
