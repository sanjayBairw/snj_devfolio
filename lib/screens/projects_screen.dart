import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/project.dart';
import '../services/supabase_service.dart';
import '../widgets/app_ui.dart';
import '../widgets/project_card.dart';

enum _Sort { defaultOrder, featuredFirst, titleAZ }

/// Screen 3 — My Projects.
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

  // ── Helpers ────────────────────────────────────────────────────────────────
  static List<String> _techOf(Project p) => p.techStack
      .split(RegExp(r'[,|•]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  /// The four most common technologies across all projects, so filters
  /// follow the real data instead of a hard-coded list.
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

  // ── UI ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showSkeleton = _loading && _allProjects.isEmpty;

    return RefreshIndicator(
      onRefresh: _load,
      color: kAccentViolet,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
        children: [
          ScreenTitle(
            'My Projects',
            actions: [
              PopupMenuButton<_Sort>(
                tooltip: 'Sort',
                initialValue: _sort,
                icon: Icon(Icons.sort_rounded, color: appTextPrimary(isDark)),
                onSelected: (value) => setState(() {
                  _sort = value;
                  _applyFilter();
                }),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: _Sort.defaultOrder,
                    child: Text('Default order'),
                  ),
                  PopupMenuItem(
                    value: _Sort.featuredFirst,
                    child: Text('Featured first'),
                  ),
                  PopupMenuItem(
                    value: _Sort.titleAZ,
                    child: Text('Title A–Z'),
                  ),
                ],
              ),
              IconButton(
                tooltip: _isSearchOpen ? 'Close search' : 'Search projects',
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
            const SizedBox(height: 10),
            TextField(
              controller: _searchCtrl,
              autofocus: true,
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

          const SizedBox(height: 14),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final filter in _filters)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _FilterChipButton(
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

          const SizedBox(height: 14),

          if (!showSkeleton)
            Text(
              '${_filteredProjects.length} of ${_allProjects.length} projects',
              style: TextStyle(fontSize: 12, color: appTextMuted(isDark)),
            ),

          const SizedBox(height: 10),

          // Fallback notice
          if (_usingFallback && !showSkeleton) ...[
            _FallbackBanner(
              isDark: isDark,
              hasError: _error != null,
              onRetry: _load,
            ),
            const SizedBox(height: 14),
          ],

          // Body
          if (showSkeleton) ...[
            const ProjectCardSkeleton(),
            const SizedBox(height: 14),
            const ProjectCardSkeleton(),
            const SizedBox(height: 14),
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
                const gap = 14.0;
                final twoColumns = constraints.maxWidth >= 720;
                final cardWidth = twoColumns
                    ? (constraints.maxWidth - gap) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final p in _filteredProjects)
                      SizedBox(width: cardWidth, child: ProjectCard(project: p)),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
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
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            gradient: selected ? kVioletPurpleGradient : null,
            color: selected ? null : (isDark ? kDarkSurface : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? Colors.transparent : appBorderColor(isDark),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: kPrimaryPurple.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : appTextSecondary(isDark),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? kPrimaryPurple.withValues(alpha: 0.1)
            : const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kAccentViolet.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: kAccentViolet,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hasError
                  ? "Couldn't reach the project database. Showing sample projects."
                  : 'No published projects yet. Showing sample projects.',
              style: TextStyle(fontSize: 12, color: appTextSecondary(isDark)),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
