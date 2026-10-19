import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';
import '../models/resume_data.dart';
import '../services/resume_parser_service.dart';
import '../utils/url_utils.dart';

/// Screen displaying structured details fetched from an uploaded resume.
class ResumeDetailsScreen extends StatefulWidget {
  const ResumeDetailsScreen({
    super.key,
    required this.resume,
    this.canApplyToProfile = true,
  });

  final ResumeData resume;
  final bool canApplyToProfile;

  @override
  State<ResumeDetailsScreen> createState() => _ResumeDetailsScreenState();
}

class _ResumeDetailsScreenState extends State<ResumeDetailsScreen>
    with SingleTickerProviderStateMixin {
  late ResumeData _currentResume;
  late TabController _tabController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _currentResume = widget.resume;
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickAnotherResume() async {
    setState(() => _isProcessing = true);
    try {
      final parsed = await ResumeParserService.pickAndParseResume();
      if (!mounted) return;
      if (parsed != null) {
        setState(() {
          _currentResume = parsed;
          _tabController.index = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully parsed "${parsed.fileName}"!'),
            backgroundColor: kEmeraldGreen,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = _currentResume;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Parsed Resume Details',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Copy Raw Text',
            icon: const Icon(Icons.copy_all_rounded),
            onPressed: () => _copyToClipboard(r.rawText, 'Resume text'),
          ),
          IconButton(
            tooltip: 'Upload Another',
            icon: const Icon(Icons.upload_file_rounded),
            onPressed: _isProcessing ? null : _pickAnotherResume,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: kAccentViolet),
                  SizedBox(height: 16),
                  Text('Analyzing and extracting resume details...'),
                ],
              ),
            )
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Header Card ───────────────────────────────
                              _buildHeaderCard(r, isDark),
                              const SizedBox(height: 16),

                              // ── Contact Pills Wrap ────────────────────────
                              _buildContactPills(r, isDark),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverTabBarDelegate(
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        indicatorColor: kAccentViolet,
                        labelColor: isDark ? Colors.white : kLightTextPrimary,
                        unselectedLabelColor:
                            isDark ? kDarkTextMuted : Colors.grey,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        tabs: [
                          Tab(text: 'Skills (${r.skills.length})'),
                          Tab(text: 'Experience (${r.experiences.length})'),
                          Tab(text: 'Education (${r.educations.length})'),
                          Tab(text: 'Projects (${r.projects.length})'),
                          const Tab(text: 'Raw Source'),
                        ],
                      ),
                      isDark: isDark,
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildSkillsTab(r, isDark),
                  _buildExperienceTab(r, isDark),
                  _buildEducationTab(r, isDark),
                  _buildProjectsTab(r, isDark),
                  _buildRawTextTab(r, isDark),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
        decoration: BoxDecoration(
          color: isDark ? kDarkSurface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : kLightBorder,
            ),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isProcessing ? null : _pickAnotherResume,
                  icon: const Icon(Icons.upload_file_rounded, size: 18),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Upload Different Resume'),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    _copyToClipboard(
                      '${r.fullName} • ${r.headline}\nEmail: ${r.email}\nPhone: ${r.phone}\nSkills: ${r.skills.join(', ')}\n\nSummary:\n${r.summary}',
                      'Parsed Profile Summary',
                    );
                  },
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Export Profile'),
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
      ),
    );
  }

  // ── Header Card ─────────────────────────────────────────────────────────────
  Widget _buildHeaderCard(ResumeData r, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? kDarkSurface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : kLightBorder,
        ),
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: kPrimaryPurple.withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 18,
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
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: kVioletPurpleGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryPurple.withValues(alpha: 0.35),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.badge_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            r.fullName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : kLightTextPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: kEmeraldGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Parsed',
                            style: TextStyle(
                              color: kEmeraldGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      r.headline,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? kAccentViolet : kPrimaryPurple,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            r.summary,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: isDark ? kDarkTextSecondary : kLightTextSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.insert_drive_file_outlined,
                size: 14,
                color: isDark ? kDarkTextMuted : Colors.grey,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${r.fileName} • ${(r.fileSizeBytes / 1024).toStringAsFixed(1)} KB',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? kDarkTextMuted : Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Contact Pills Wrap ──────────────────────────────────────────────────────
  Widget _buildContactPills(ResumeData r, bool isDark) {
    final pills = <Widget>[];

    if (r.email.isNotEmpty) {
      pills.add(_ContactPill(
        icon: Icons.email_outlined,
        label: r.email,
        onTap: () => openLink('mailto:${r.email}'),
        isDark: isDark,
      ));
    }
    if (r.phone.isNotEmpty) {
      pills.add(_ContactPill(
        icon: Icons.phone_outlined,
        label: r.phone,
        onTap: () => openLink('tel:${r.phone}'),
        isDark: isDark,
      ));
    }
    if (r.location.isNotEmpty) {
      pills.add(_ContactPill(
        icon: Icons.location_on_outlined,
        label: r.location,
        onTap: () {},
        isDark: isDark,
      ));
    }
    if (r.linkedinUrl.isNotEmpty) {
      pills.add(_ContactPill(
        icon: Icons.link_rounded,
        label: 'LinkedIn',
        onTap: () => openLink(r.linkedinUrl),
        isDark: isDark,
      ));
    }
    if (r.githubUrl.isNotEmpty) {
      pills.add(_ContactPill(
        icon: Icons.code_rounded,
        label: 'GitHub',
        onTap: () => openLink(r.githubUrl),
        isDark: isDark,
      ));
    }
    if (r.portfolioUrl.isNotEmpty) {
      pills.add(_ContactPill(
        icon: Icons.language_rounded,
        label: 'Portfolio',
        onTap: () => openLink(r.portfolioUrl),
        isDark: isDark,
      ));
    }

    if (pills.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: pills,
    );
  }

  // ── Tab 1: Skills ───────────────────────────────────────────────────────────
  Widget _buildSkillsTab(ResumeData r, bool isDark) {
    if (r.skills.isEmpty) {
      return _buildEmptyNotice('No matching technical skills identified.');
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Extracted Competencies',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : kLightTextPrimary,
              ),
            ),
            Text(
              '${r.skills.length} skills found',
              style: const TextStyle(
                fontSize: 12,
                color: kAccentViolet,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: r.skills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? kDarkSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? kAccentViolet.withValues(alpha: 0.3)
                      : kLightBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: kAccentViolet,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    skill,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : kLightTextPrimary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        if (r.certifications.isNotEmpty) ...[
          const SizedBox(height: 28),
          Text(
            'Certifications & Achievements',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : kLightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...r.certifications.map(
            (c) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? kDarkSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : kLightBorder,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_outlined,
                      color: kAccentViolet, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      c,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? kDarkTextPrimary : kLightTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Tab 2: Experience ───────────────────────────────────────────────────────
  Widget _buildExperienceTab(ResumeData r, bool isDark) {
    if (r.experiences.isEmpty) {
      return _buildEmptyNotice('No work experience section parsed.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: r.experiences.length,
      itemBuilder: (context, i) {
        final exp = r.experiences[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: kPrimaryPurple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.work_outline_rounded,
                      color: kAccentViolet,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exp.role,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : kLightTextPrimary,
                          ),
                        ),
                        if (exp.company.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            exp.company,
                            style: const TextStyle(
                              fontSize: 13,
                              color: kAccentViolet,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (exp.duration.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? kDarkSurface2 : kLightSurface2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        exp.duration,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? kDarkTextMuted : Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
              if (exp.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  exp.description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: isDark ? kDarkTextSecondary : kLightTextSecondary,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ── Tab 3: Education ────────────────────────────────────────────────────────
  Widget _buildEducationTab(ResumeData r, bool isDark) {
    if (r.educations.isEmpty) {
      return _buildEmptyNotice('No education records parsed.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: r.educations.length,
      itemBuilder: (context, i) {
        final edu = r.educations[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: kVioletPurpleGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      edu.degree,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : kLightTextPrimary,
                      ),
                    ),
                    if (edu.institution.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        edu.institution,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? kDarkTextSecondary
                              : kLightTextSecondary,
                        ),
                      ),
                    ],
                    if (edu.year.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        edu.year,
                        style: const TextStyle(
                          fontSize: 12,
                          color: kAccentViolet,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if (edu.details.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        edu.details,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: isDark ? kDarkTextMuted : Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Tab 4: Projects ─────────────────────────────────────────────────────────
  Widget _buildProjectsTab(ResumeData r, bool isDark) {
    if (r.projects.isEmpty) {
      return _buildEmptyNotice('No projects section found in this document.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: r.projects.length,
      itemBuilder: (context, i) {
        final prj = r.projects[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      prj.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : kLightTextPrimary,
                      ),
                    ),
                  ),
                  if (prj.link.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      tooltip: 'View Link',
                      onPressed: () => openLink(prj.link),
                    ),
                ],
              ),
              if (prj.techStack.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? kDarkSurface2 : kLightSurface2,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    prj.techStack,
                    style: const TextStyle(
                      fontSize: 11,
                      color: kAccentViolet,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              if (prj.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  prj.description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: isDark ? kDarkTextSecondary : kLightTextSecondary,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ── Tab 5: Raw Source ───────────────────────────────────────────────────────
  Widget _buildRawTextTab(ResumeData r, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Extracted Document Text',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : kLightTextPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: () => _copyToClipboard(r.rawText, 'Extracted text'),
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Copy'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? kDarkSurface2 : kLightSurface2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : kLightBorder,
            ),
          ),
          child: SelectableText(
            r.rawText,
            style: TextStyle(
              fontSize: 12,
              height: 1.6,
              fontFamily: 'monospace',
              color: isDark ? kDarkTextSecondary : kLightTextSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyNotice(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline_rounded,
                size: 40, color: kAccentViolet),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Contact Pill Widget ───────────────────────────────────────────────────────
class _ContactPill extends StatelessWidget {
  const _ContactPill({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? kDarkSurface2 : kLightSurface2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : kLightBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: kAccentViolet),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? kDarkTextPrimary : kLightTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sliver Persistent Tab Bar Delegate ────────────────────────────────────────
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this.tabBar, {required this.isDark});

  final TabBar tabBar;
  final bool isDark;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isDark ? kDarkBackground : kLightBackground,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
