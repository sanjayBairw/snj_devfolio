import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants.dart';
import '../../models/project.dart';
import '../../services/supabase_service.dart';
import '../../widgets/app_ui.dart';
import 'project_form_screen.dart';

/// Screen 6 — Admin Console matching SNJ Devfolio 2.0 specifications.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<Project> _projects = [];
  bool _loading = true;
  String? _error;
  bool _showProjectList = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final projects = await ProjectService.fetchAll();
      if (!mounted) return;
      setState(() {
        _projects = projects;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _addProject() async {
    final created = await Navigator.of(context).push<Project>(
      MaterialPageRoute(builder: (_) => const ProjectFormScreen()),
    );
    if (created != null) {
      setState(() => _projects.add(created));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${created.title}" created successfully!')),
      );
    }
  }

  Future<void> _editProject(Project p, int index) async {
    final updated = await Navigator.of(context).push<Project>(
      MaterialPageRoute(builder: (_) => ProjectFormScreen(project: p)),
    );
    if (updated != null) {
      setState(() => _projects[index] = updated);
    }
  }

  Future<void> _togglePublish(Project p, int index) async {
    try {
      final updated = await ProjectService.update(
        p.copyWith(isPublished: !p.isPublished),
      );
      setState(() => _projects[index] = updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updated.isPublished
                ? 'Project published publicly.'
                : 'Project unpublished (saved as draft).',
          ),
        ),
      );
    } catch (e) {
      _showError('Failed to update: $e');
    }
  }

  Future<void> _deleteProject(Project p, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Delete project?',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will permanently delete "${p.title}" from Supabase database. This action cannot be undone.',
          style: GoogleFonts.inter(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ProjectService.delete(p.id!);
      setState(() => _projects.removeAt(index));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${p.title}" permanently deleted.')),
      );
    } catch (e) {
      _showError('Failed to delete: $e');
    }
  }

  Future<void> _signOut() async {
    await AuthService.signOut();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final publishedCount = _projects.where((p) => p.isPublished).length;
    final draftCount = _projects.length - publishedCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Console',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: _signOut,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kAccentViolet))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
              children: [
                if (_error != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(kRadiusMd),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_off_rounded, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Database Notice: $_error',
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.redAccent),
                          ),
                        ),
                        TextButton(
                          onPressed: _load,
                          child: const Text('RETRY'),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Security & Status Banner ──────────────────────────────
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: isDark ? kDarkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(kRadiusXl),
                    border: Border.all(color: appBorderColor(isDark)),
                    boxShadow: [
                      BoxShadow(
                        color: kAccentViolet.withValues(alpha: isDark ? 0.08 : 0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: kAccentViolet.withValues(alpha: isDark ? 0.16 : 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.lock_rounded, color: kAccentViolet, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Authenticated Session',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: appTextPrimary(isDark),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: kEmeraldGreen.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(kRadiusXs),
                                  ),
                                  child: Text(
                                    'RLS ACTIVE',
                                    style: GoogleFonts.jetBrainsMono(
                                      color: kEmeraldGreen,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Connected to Supabase project • Admin ID: ${kAdminUserId.substring(0, 8)}...',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                color: appTextMuted(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── KPI Summary Tiles ─────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _AdminKpiTile(
                        label: 'TOTAL PROJECTS',
                        value: '${_projects.length}',
                        color: kAccentViolet,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AdminKpiTile(
                        label: 'PUBLISHED (LIVE)',
                        value: '$publishedCount',
                        color: kEmeraldGreen,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AdminKpiTile(
                        label: 'DRAFT QUEUE',
                        value: '$draftCount',
                        color: Colors.amber,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ── Quick Actions ─────────────────────────────────────────
                const SectionHeader(
                  'Quick Management Actions',
                  index: '01',
                  subtitle: 'Create, organize and publish remote project records',
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        label: 'Create Project',
                        icon: Icons.add_rounded,
                        onPressed: _addProject,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() => _showProjectList = !_showProjectList);
                        },
                        icon: Icon(
                          _showProjectList ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 16,
                        ),
                        label: Text(
                          _showProjectList ? 'Hide List' : 'Show List (${_projects.length})',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ── High-Density Project Management List ──────────────────
                if (_showProjectList) ...[
                  SectionHeader(
                    'Repository Records (${_projects.length})',
                    index: '02',
                    subtitle: 'Toggle visibility, edit specifications or remove entries',
                  ),
                  const SizedBox(height: 14),

                  if (_projects.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: isDark ? kDarkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(kRadiusLg),
                        border: Border.all(color: appBorderColor(isDark)),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.inbox_rounded, size: 36, color: appTextMuted(isDark)),
                            const SizedBox(height: 12),
                            Text(
                              'No project records currently found in database.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: appTextSecondary(isDark),
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: _addProject,
                              child: const Text('Add First Project'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...List.generate(_projects.length, (i) {
                      final p = _projects[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? kDarkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(kRadiusMd),
                          border: Border.all(color: appBorderColor(isDark)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark ? kDarkSurface2 : kLightSurface2,
                                borderRadius: BorderRadius.circular(kRadiusSm),
                              ),
                              child: Text(
                                (i + 1).toString().padLeft(2, '0'),
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: kAccentViolet,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          p.title,
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: appTextPrimary(isDark),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: p.isPublished
                                              ? kEmeraldGreen.withValues(alpha: 0.15)
                                              : Colors.orange.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(kRadiusXs),
                                        ),
                                        child: Text(
                                          p.isPublished ? 'LIVE' : 'DRAFT',
                                          style: GoogleFonts.jetBrainsMono(
                                            color: p.isPublished ? kEmeraldGreen : Colors.orange,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    p.techStack.isNotEmpty ? p.techStack : p.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: appTextSecondary(isDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Actions
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: p.isPublished ? 'Unpublish' : 'Publish',
                                  visualDensity: VisualDensity.compact,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    p.isPublished
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 18,
                                    color: p.isPublished ? kEmeraldGreen : Colors.orange,
                                  ),
                                  onPressed: () => _togglePublish(p, i),
                                ),
                                IconButton(
                                  tooltip: 'Edit Project',
                                  visualDensity: VisualDensity.compact,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  onPressed: () => _editProject(p, i),
                                ),
                                IconButton(
                                  tooltip: 'Delete Project',
                                  visualDensity: VisualDensity.compact,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.delete_outline,
                                      size: 18, color: Colors.redAccent),
                                  onPressed: () => _deleteProject(p, i),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ],
            ),
    );
  }
}

class _AdminKpiTile extends StatelessWidget {
  const _AdminKpiTile({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  final String label;
  final String value;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? kDarkSurface : Colors.white,
        borderRadius: BorderRadius.circular(kRadiusMd),
        border: Border.all(color: appBorderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: appTextMuted(isDark),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
