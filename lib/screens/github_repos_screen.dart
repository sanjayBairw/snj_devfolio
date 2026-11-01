import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import '../models/github_repo.dart';
import '../services/github_service.dart';
import '../utils/url_utils.dart';
import '../widgets/app_ui.dart';

/// Screen 4 — GitHub Repositories & Open Source Showcase matching SNJ Devfolio 2.0.
class GithubReposScreen extends StatefulWidget {
  const GithubReposScreen({super.key});

  @override
  State<GithubReposScreen> createState() => _GithubReposScreenState();
}

class _GithubReposScreenState extends State<GithubReposScreen> {
  List<GithubRepo> _repos = [];
  List<GithubRepo> _filteredRepos = [];
  GithubUser? _user;
  bool _loading = true;
  String _searchQuery = '';
  String? _selectedLanguage;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    setState(() => _loading = true);
    try {
      final userFuture =
          GithubService.fetchUserProfile(forceRefresh: forceRefresh);
      final reposFuture =
          GithubService.fetchRepositories(forceRefresh: forceRefresh);

      final results = await Future.wait([userFuture, reposFuture]);
      if (!mounted) return;
      _user = results[0] as GithubUser;
      _repos = results[1] as List<GithubRepo>;
      _applyFilter();
    } catch (_) {
      // Handled inside service
    }
    if (mounted) setState(() => _loading = false);
  }

  void _applyFilter() {
    List<GithubRepo> list = List.from(_repos);

    if (_selectedLanguage != null) {
      list = list.where((r) => r.language == _selectedLanguage).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((r) {
        return r.name.toLowerCase().contains(q) ||
            r.description.toLowerCase().contains(q) ||
            r.language.toLowerCase().contains(q);
      }).toList();
    }

    _filteredRepos = list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GitHub Repositories',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Repositories',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _loadData(forceRefresh: true),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kAccentViolet))
          : RefreshIndicator(
              onRefresh: () => _loadData(forceRefresh: true),
              color: kAccentViolet,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
                children: [
                  // ── Profile Overview Hero Card ────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? kDarkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(kRadiusXl),
                      border: Border.all(color: appBorderColor(isDark)),
                      boxShadow: [
                        BoxShadow(
                          color: kAccentViolet.withValues(alpha: isDark ? 0.08 : 0.03),
                          blurRadius: 24,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: kAccentViolet.withValues(alpha: 0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  _user?.avatarUrl ?? kAvatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.code_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _user?.login ?? kGithubUsername,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: appTextPrimary(isDark),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'github.com/${_user?.login ?? kGithubUsername}',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 12,
                                      color: kAccentViolet,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Text(
                          _user?.bio ?? 'Open source developer & mobile engineer',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: appTextSecondary(isDark),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Stats Grid in JetBrains Mono & Space Grotesk
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? kDarkSurface2 : kLightSurface2,
                            borderRadius: BorderRadius.circular(kRadiusMd),
                            border: Border.all(color: appBorderColor(isDark)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _GithubMetric(
                                value: '${_user?.publicRepos ?? 15}',
                                label: 'REPOSITORIES',
                                isDark: isDark,
                              ),
                              Container(
                                height: 28,
                                width: 1,
                                color: appBorderColor(isDark),
                              ),
                              _GithubMetric(
                                value: '${_user?.followers ?? 250}',
                                label: 'FOLLOWERS',
                                isDark: isDark,
                              ),
                              Container(
                                height: 28,
                                width: 1,
                                color: appBorderColor(isDark),
                              ),
                              _GithubMetric(
                                value: '${_user?.following ?? 80}',
                                label: 'FOLLOWING',
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Search & Filter Controls ──────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          style: GoogleFonts.inter(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search repositories or topics...',
                            prefixIcon: const Icon(Icons.search_rounded, size: 20),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
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
                      ),
                      const SizedBox(width: 10),

                      // Language Menu
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? kDarkSurface2 : kLightSurface2,
                          borderRadius: BorderRadius.circular(kRadiusSm),
                          border: Border.all(
                            color: _selectedLanguage != null
                                ? kAccentViolet
                                : appBorderColor(isDark),
                          ),
                        ),
                        child: PopupMenuButton<String?>(
                          tooltip: 'Filter by Language',
                          icon: Icon(
                            Icons.tune_rounded,
                            size: 20,
                            color: _selectedLanguage != null
                                ? kAccentViolet
                                : appTextPrimary(isDark),
                          ),
                          onSelected: (lang) {
                            setState(() {
                              _selectedLanguage = lang;
                              _applyFilter();
                            });
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: null,
                              child: Text('All Languages'),
                            ),
                            const PopupMenuItem(
                              value: 'Dart',
                              child: Text('Dart'),
                            ),
                            const PopupMenuItem(
                              value: 'Python',
                              child: Text('Python'),
                            ),
                            const PopupMenuItem(
                              value: 'JavaScript',
                              child: Text('JavaScript'),
                            ),
                            const PopupMenuItem(
                              value: 'HTML',
                              child: Text('HTML'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Metadata counter in JetBrains Mono
                  Row(
                    children: [
                      Text(
                        'OPEN SOURCE ARCHIVE // ${_filteredRepos.length} REPOSITORIES',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: appTextMuted(isDark),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedLanguage != null || _searchQuery.isNotEmpty)
                        InkWell(
                          onTap: () {
                            setState(() {
                              _selectedLanguage = null;
                              _searchQuery = '';
                              _searchCtrl.clear();
                              _applyFilter();
                            });
                          },
                          child: Text(
                            'RESET',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: kAccentViolet,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Repositories List
                  if (_filteredRepos.isEmpty) ...[
                    EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No repositories found',
                      message: 'Try adjusting your search query or language filter.',
                      actionLabel: 'Reset Filters',
                      onAction: () {
                        setState(() {
                          _selectedLanguage = null;
                          _searchQuery = '';
                          _searchCtrl.clear();
                          _applyFilter();
                        });
                      },
                    ),
                  ] else ...[
                    ..._filteredRepos.map(
                      (repo) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _RepoCard(repo: repo, isDark: isDark),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _GithubMetric extends StatelessWidget {
  const _GithubMetric({
    required this.value,
    required this.label,
    required this.isDark,
  });

  final String value;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: appTextPrimary(isDark),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: appTextMuted(isDark),
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _RepoCard extends StatefulWidget {
  const _RepoCard({required this.repo, required this.isDark});
  final GithubRepo repo;
  final bool isDark;

  @override
  State<_RepoCard> createState() => _RepoCardState();
}

class _RepoCardState extends State<_RepoCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final repo = widget.repo;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: widget.isDark ? kDarkSurface : Colors.white,
          borderRadius: BorderRadius.circular(kRadiusMd),
          border: Border.all(
            color: _hovered
                ? kAccentViolet.withValues(alpha: 0.6)
                : appBorderColor(widget.isDark),
          ),
          boxShadow: [
            if (_hovered)
              BoxShadow(
                color: kAccentViolet.withValues(alpha: widget.isDark ? 0.12 : 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(kRadiusMd),
            onTap: () {
              if (repo.htmlUrl.isNotEmpty) {
                openLink(repo.htmlUrl);
              } else {
                _showRepoDetailsSheet(context);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: kAccentViolet.withValues(alpha: widget.isDark ? 0.16 : 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.code_rounded,
                      color: kAccentViolet,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          repo.name,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: appTextPrimary(widget.isDark),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          repo.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: appTextSecondary(widget.isDark),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getLanguageColor(repo.language),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              repo.language,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: appTextSecondary(widget.isDark),
                              ),
                            ),
                            const SizedBox(width: 16),

                            const Icon(Icons.star_outline_rounded,
                                size: 14, color: kAmberBadge),
                            const SizedBox(width: 4),
                            Text(
                              '${repo.stargazersCount}',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                color: appTextSecondary(widget.isDark),
                              ),
                            ),
                            const SizedBox(width: 14),

                            Icon(
                              Icons.fork_right_rounded,
                              size: 14,
                              color: appTextMuted(widget.isDark),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${repo.forksCount}',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                color: appTextSecondary(widget.isDark),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: _hovered ? kAccentViolet : appTextMuted(widget.isDark),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getLanguageColor(String lang) {
    switch (lang.toLowerCase()) {
      case 'dart':
        return const Color(0xFF00B4AB);
      case 'python':
        return const Color(0xFF3572A5);
      case 'javascript':
        return const Color(0xFFF1E05A);
      case 'html':
        return const Color(0xFFE34C26);
      default:
        return kAccentViolet;
    }
  }

  void _showRepoDetailsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: widget.isDark ? kDarkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kAccentViolet.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.code_rounded, color: kAccentViolet),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.repo.name,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: appTextPrimary(widget.isDark),
                        ),
                      ),
                      Text(
                        widget.repo.language,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: kAccentViolet,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.repo.description,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.5,
                color: appTextSecondary(widget.isDark),
              ),
            ),
            if (widget.repo.topics.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: widget.repo.topics
                    .map(
                      (t) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.isDark ? kDarkSurface2 : kLightSurface2,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#$t',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: appTextSecondary(widget.isDark),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
