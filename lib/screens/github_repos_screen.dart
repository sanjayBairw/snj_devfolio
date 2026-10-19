import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/github_repo.dart';
import '../services/github_service.dart';
import '../utils/url_utils.dart';

/// Screen 4 — GitHub Repositories matching the reference screenshot.
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
        title: const Text('GitHub Repositories'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
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
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                children: [
                  // ── Profile Overview Card (Screen 4 Reference) ────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? kDarkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(22),
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
                    ),
                    child: Column(
                      children: [
                        // Avatar + Name + Handle
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF1E293B),
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
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _user?.login ?? kGithubUsername,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? Colors.white : kLightTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '@${_user?.login ?? kGithubUsername}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? kDarkTextSecondary : kLightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Bio
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _user?.bio ?? 'Open source contributor & developer',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? kDarkTextSecondary : kLightTextSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _UserMetric(
                              value: '${_user?.publicRepos ?? 15}',
                              label: 'Repos',
                              isDark: isDark,
                            ),
                            _UserMetric(
                              value: '${_user?.followers ?? 250}',
                              label: 'Followers',
                              isDark: isDark,
                            ),
                            _UserMetric(
                              value: '${_user?.following ?? 80}',
                              label: 'Following',
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ── Search & Filter Input ─────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            hintText: 'Search repositories...',
                            prefixIcon: const Icon(Icons.search_rounded, size: 20),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
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

                      // Language Filter Menu
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? kDarkSurface2 : kLightSurface2,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _selectedLanguage != null
                                ? kAccentViolet
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : kLightBorder),
                          ),
                        ),
                        child: PopupMenuButton<String?>(
                          tooltip: 'Filter by Language',
                          icon: Icon(
                            Icons.tune_rounded,
                            color: _selectedLanguage != null
                                ? kAccentViolet
                                : (isDark ? Colors.white : kLightTextPrimary),
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
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Repositories List ─────────────────────────────────────
                  if (_filteredRepos.isEmpty) ...[
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: isDark ? kDarkTextMuted : Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No repositories found',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : kLightTextPrimary,
                            ),
                          ),
                        ],
                      ),
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

class _UserMetric extends StatelessWidget {
  const _UserMetric({
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : kLightTextPrimary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? kDarkTextSecondary : kLightTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _RepoCard extends StatelessWidget {
  const _RepoCard({required this.repo, required this.isDark});
  final GithubRepo repo;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? kDarkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : kLightBorder,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            if (repo.htmlUrl.isNotEmpty) {
              openLink(repo.htmlUrl);
            } else {
              _showRepoDetailsSheet(context);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Repo Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: kElectricBlue.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Icon(
                    Icons.code_rounded,
                    color: kElectricBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),

                // Repo Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        repo.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : kLightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        repo.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? kDarkTextSecondary : kLightTextSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Language Dot
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
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? kDarkTextSecondary : kLightTextSecondary,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Stars
                            const Icon(Icons.star_outline_rounded,
                                size: 15, color: kAmberBadge),
                            const SizedBox(width: 4),
                            Text(
                              '${repo.stargazersCount}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? kDarkTextSecondary : kLightTextSecondary,
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Forks
                            Icon(
                              Icons.fork_right_rounded,
                              size: 15,
                              color: isDark ? kDarkTextMuted : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${repo.forksCount}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? kDarkTextSecondary : kLightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? kDarkTextMuted : Colors.grey,
                ),
              ],
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
      backgroundColor: isDark ? kDarkSurface : Colors.white,
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
                    color: kPrimaryPurple.withValues(alpha: 0.15),
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
                        repo.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : kLightTextPrimary,
                        ),
                      ),
                      Text(
                        repo.language,
                        style: const TextStyle(
                          fontSize: 12,
                          color: kAccentViolet,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              repo.description,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? kDarkTextSecondary : kLightTextSecondary,
              ),
            ),
            if (repo.topics.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: repo.topics
                    .map(
                      (t) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? kDarkSurface2 : kLightSurface2,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#$t',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? kDarkTextSecondary
                                : kLightTextSecondary,
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
                style: FilledButton.styleFrom(
                  backgroundColor: kPrimaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
