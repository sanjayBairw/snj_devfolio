import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models/project.dart';
import '../../services/supabase_service.dart';
import 'project_form_screen.dart';

/// Screen 6 — Admin Panel matching the reference screenshot.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<Project> _projects = [];
  bool _loading = true;
  String? _error;
  bool _showProjectList = false;

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
                : 'Project unpublished (draft).',
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
        title: const Text('Delete project?'),
        content: Text(
            'This will permanently delete "${p.title}". This cannot be undone.'),
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
        SnackBar(content: Text('"${p.title}" deleted.')),
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

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.shield_outlined, color: kAccentViolet),
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: _signOut,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kAccentViolet))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
              children: [
                if (_error != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_off_rounded, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Supabase connection note: $_error',
                            style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                          ),
                        ),
                        TextButton(
                          onPressed: _load,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Hero Secure Card (Screen 6 Reference) ─────────────────
                Container(
                  padding: const EdgeInsets.all(22),
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
                            colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: kPrimaryPurple.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          color: kAccentViolet,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Secure Access Only',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : kLightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage your projects remotely',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? kDarkTextSecondary : kLightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // View All Projects Button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            setState(() => _showProjectList = !_showProjectList);
                          },
                          icon: Icon(
                            _showProjectList
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                          ),
                          label: Text(
                            _showProjectList
                                ? 'Hide Projects List'
                                : 'View All Projects (${_projects.length}) →',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: kPrimaryPurple,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Quick Actions Grid (Screen 6 Reference) ───────────────
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : kLightTextPrimary,
                  ),
                ),
                const SizedBox(height: 14),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _ActionCard(
                      icon: Icons.add_rounded,
                      title: 'Add Project',
                      isDark: isDark,
                      onTap: _addProject,
                    ),
                    _ActionCard(
                      icon: Icons.edit_note_rounded,
                      title: 'Edit Projects',
                      isDark: isDark,
                      onTap: () {
                        setState(() => _showProjectList = true);
                      },
                    ),
                    _ActionCard(
                      icon: Icons.format_list_bulleted_rounded,
                      title: 'Manage Content',
                      isDark: isDark,
                      onTap: () {
                        setState(() => _showProjectList = true);
                      },
                    ),

                    _ActionCard(
                      icon: Icons.bar_chart_rounded,
                      title: 'View Analytics',
                      isDark: isDark,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Total remote projects: ${_projects.length} • Supabase RLS Active',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Admin Status Card (Screen 6 Reference) ────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? kDarkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : kLightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Status',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? kDarkTextSecondary : kLightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: kEmeraldGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Authenticated',
                            style: TextStyle(
                              color: kEmeraldGreen,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Signed in as admin (${kAdminUserId.substring(0, 8)}...)',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? kDarkTextMuted : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Detailed Project List Section ─────────────────────────
                if (_showProjectList) ...[
                  const SizedBox(height: 28),
                  Text(
                    'Projects (${_projects.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : kLightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_projects.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text('No projects yet. Tap Add Project above.'),
                      ),
                    )
                  else
                    ...List.generate(_projects.length, (i) {
                      final p = _projects[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(
                            p.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            p.techStack.isNotEmpty ? p.techStack : p.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  p.isPublished
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 19,
                                ),
                                onPressed: () => _togglePublish(p, i),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.edit_outlined, size: 19),
                                onPressed: () => _editProject(p, i),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.delete_outline,
                                    size: 19, color: Colors.redAccent),
                                onPressed: () => _deleteProject(p, i),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ],
            ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool isDark;
  final VoidCallback onTap;

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
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kPrimaryPurple.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: kAccentViolet, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : kLightTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
