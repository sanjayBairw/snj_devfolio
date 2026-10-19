import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/project.dart';
import '../services/supabase_service.dart';
import '../widgets/project_card.dart';

/// Screen 3 — My Projects screen matching the reference screenshot.
class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<Project> _allProjects = [];
  List<Project> _filteredProjects = [];
  bool _loading = true;
  String? _error;
  bool _usingFallback = false;
  String _selectedFilter = 'All';
  String _searchQuery = '';
  bool _isSearchOpen = false;
  final TextEditingController _searchCtrl = TextEditingController();

  final List<String> _filters = ['All', 'Featured', 'GitHub', 'Supabase'];

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
    try {
      final remote = await ProjectService.fetchPublished();
      if (!mounted) return;
      if (remote.isEmpty) {
        _allProjects = kSampleProjects;
        _usingFallback = true;
      } else {
        _allProjects = remote;
        _usingFallback = false;
      }
    } catch (e) {
      if (!mounted) return;
      _allProjects = kSampleProjects;
      _usingFallback = true;
      _error = e.toString();
    }
    _applyFilter();
    setState(() => _loading = false);
  }

  void _applyFilter() {
    List<Project> list = List.from(_allProjects);

    // Apply category filter
    if (_selectedFilter == 'Featured') {
      list = list.where((p) => p.isFeatured).toList();
    } else if (_selectedFilter == 'GitHub') {
      list = list.where((p) => p.githubUrl.trim().isNotEmpty).toList();
    } else if (_selectedFilter == 'Supabase') {
      list = list.where((p) => p.techStack.toLowerCase().contains('supabase')).toList();
    }

    // Apply search query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) {
        return p.title.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.techStack.toLowerCase().contains(q);
      }).toList();
    }

    _filteredProjects = list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: kAccentViolet,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: kAccentViolet,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
        children: [
          // Header + Search Row
          Row(
            children: [
              Expanded(
                child: Text(
                  'My Projects',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : kLightTextPrimary,
                  ),
                ),
              ),
              IconButton(
                tooltip: _isSearchOpen ? 'Close Search' : 'Search Projects',
                icon: Icon(
                  _isSearchOpen ? Icons.close_rounded : Icons.search_rounded,
                  color: isDark ? Colors.white : kLightTextPrimary,
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

          // Search Field when toggled
          if (_isSearchOpen) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _searchCtrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search by title, tech stack, or description...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
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
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                  _applyFilter();
                });
              },
            ),
          ],

          const SizedBox(height: 14),

          // Horizontal Filter Chips (Screen 3 Reference)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                        _applyFilter();
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isSelected ? kVioletPurpleGradient : null,
                        color: isSelected
                            ? null
                            : (isDark ? kDarkSurface : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : kLightBorder),
                        ),
                        boxShadow: isSelected
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
                        filter,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? kDarkTextSecondary : kLightTextSecondary),
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 18),

          // Fallback notice banner if remote DB is empty
          if (_usingFallback) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? kPrimaryPurple.withValues(alpha: 0.1)
                    : const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: kAccentViolet.withValues(alpha: 0.3),
                ),
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
                      _error != null
                          ? 'Showing curated sample projects (database connection pending).'
                          : 'Curated projects loaded. Changes in admin panel reflect instantly.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? kDarkTextSecondary : kLightTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Projects List
          if (_filteredProjects.isEmpty) ...[
            const SizedBox(height: 40),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_list_off_rounded,
                    size: 48,
                    color: isDark ? kDarkTextMuted : Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No projects match "$_searchQuery"',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'All';
                        _searchQuery = '';
                        _searchCtrl.clear();
                        _applyFilter();
                      });
                    },
                    child: const Text('Reset filters'),
                  ),
                ],
              ),
            ),
          ] else ...[
            ..._filteredProjects.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: ProjectCard(project: p),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
