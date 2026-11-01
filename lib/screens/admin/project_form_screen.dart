import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants.dart';
import '../../models/project.dart';
import '../../services/supabase_service.dart';
import '../../utils/url_utils.dart';
import '../../widgets/app_ui.dart';

/// Screen 6c — Project Creation & Modification Screen matching SNJ Devfolio 2.0.
class ProjectFormScreen extends StatefulWidget {
  const ProjectFormScreen({super.key, this.project});
  final Project? project;

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _techStack;
  late final TextEditingController _githubUrl;
  late final TextEditingController _demoUrl;
  late final TextEditingController _imageUrl;
  late final TextEditingController _displayOrder;
  late bool _isFeatured;
  late bool _isPublished;

  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _title = TextEditingController(text: p?.title ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _techStack = TextEditingController(text: p?.techStack ?? '');
    _githubUrl = TextEditingController(text: p?.githubUrl ?? '');
    _demoUrl = TextEditingController(text: p?.demoUrl ?? '');
    _imageUrl = TextEditingController(text: p?.imageUrl ?? '');
    _displayOrder =
        TextEditingController(text: (p?.displayOrder ?? 0).toString());
    _isFeatured = p?.isFeatured ?? false;
    _isPublished = p?.isPublished ?? true;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _techStack.dispose();
    _githubUrl.dispose();
    _demoUrl.dispose();
    _imageUrl.dispose();
    _displayOrder.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final draft = Project(
        id: widget.project?.id,
        title: _title.text.trim(),
        description: _description.text.trim(),
        techStack: _techStack.text.trim(),
        githubUrl: _githubUrl.text.trim(),
        demoUrl: _demoUrl.text.trim(),
        imageUrl: _imageUrl.text.trim(),
        isFeatured: _isFeatured,
        isPublished: _isPublished,
        displayOrder: int.tryParse(_displayOrder.text.trim()) ?? 0,
      );

      final saved = _isEditing
          ? await ProjectService.update(draft)
          : await ProjectService.insert(draft);

      if (!mounted) return;
      Navigator.of(context).pop(saved);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Project Record' : 'Create New Project',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'SAVE RECORD',
                      style: GoogleFonts.jetBrainsMono(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: kAccentViolet,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(kRadiusMd),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _error!,
                        style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 13),
                      ),
                    ),
                  ],

                  // ── General Information ─────────────────────────────────
                  const SectionHeader(
                    'General Specifications',
                    index: '01',
                    subtitle: 'Core product title and comprehensive summary',
                  ),
                  const SizedBox(height: 16),

                  _EditorialField(
                    controller: _title,
                    label: 'Project Title *',
                    hint: 'e.g. SignSpeak AI',
                    icon: Icons.title_rounded,
                    validator: (v) => v == null || v.trim().length < 2
                        ? 'Title must be at least 2 characters'
                        : null,
                  ),
                  _EditorialField(
                    controller: _description,
                    label: 'Description *',
                    hint: 'Explain the core functionality and problem it solves...',
                    icon: Icons.description_outlined,
                    maxLines: 4,
                    validator: (v) => v == null || v.trim().length < 10
                        ? 'Description must be at least 10 characters'
                        : null,
                  ),
                  _EditorialField(
                    controller: _techStack,
                    label: 'Tech Stack (comma or • separated)',
                    hint: 'Flutter • Dart • Supabase • REST API',
                    icon: Icons.code_rounded,
                  ),

                  const SizedBox(height: 28),

                  // ── URLs and Media ──────────────────────────────────────
                  const SectionHeader(
                    'Repositories & Deployments',
                    index: '02',
                    subtitle: 'Online links for code review and live demonstrations',
                  ),
                  const SizedBox(height: 16),

                  _EditorialField(
                    controller: _githubUrl,
                    label: 'GitHub Repository URL',
                    hint: 'https://github.com/username/project',
                    icon: Icons.link_rounded,
                    keyboardType: TextInputType.url,
                    validator: (v) => _urlValidator(v),
                  ),
                  _EditorialField(
                    controller: _demoUrl,
                    label: 'Live Demonstration URL',
                    hint: 'https://your-demo-domain.com',
                    icon: Icons.play_circle_outline,
                    keyboardType: TextInputType.url,
                    validator: (v) => _urlValidator(v),
                  ),
                  _EditorialField(
                    controller: _imageUrl,
                    label: 'Showcase Cover Image URL (optional)',
                    hint: 'https://.../cover.jpg',
                    icon: Icons.image_outlined,
                    keyboardType: TextInputType.url,
                    validator: (v) => _urlValidator(v),
                  ),

                  const SizedBox(height: 28),

                  // ── Status & Priority ───────────────────────────────────
                  const SectionHeader(
                    'Visibility & Ordering',
                    index: '03',
                    subtitle: 'Public visibility flags and display sequence priority',
                  ),
                  const SizedBox(height: 16),

                  _EditorialField(
                    controller: _displayOrder,
                    label: 'Display Sequence Order',
                    hint: '0 = Highest Priority',
                    icon: Icons.sort_rounded,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      if (int.tryParse(v) == null) return 'Must be a valid integer';
                      return null;
                    },
                  ),

                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? kDarkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(kRadiusMd),
                      border: Border.all(color: appBorderColor(isDark)),
                    ),
                    child: Column(
                      children: [
                        _ModernSwitchTile(
                          label: 'Publish Publicly',
                          subtitle: 'Instantly visible to all visitors in the public portfolio',
                          value: _isPublished,
                          isDark: isDark,
                          onChanged: (v) => setState(() => _isPublished = v),
                        ),
                        Divider(height: 24, color: appBorderColor(isDark)),
                        _ModernSwitchTile(
                          label: 'Featured Project',
                          subtitle: 'Showcase in hero showcase and highlight with a featured badge',
                          value: _isFeatured,
                          isDark: isDark,
                          onChanged: (v) => setState(() => _isFeatured = v),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: Text(_isEditing ? 'Update Project Record' : 'Publish New Project'),
                      style: FilledButton.styleFrom(
                        backgroundColor: kAccentViolet,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _urlValidator(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    if (!isValidUrl(v.trim())) return 'Enter a valid URL starting with http:// or https://';
    return null;
  }
}

class _EditorialField extends StatelessWidget {
  const _EditorialField({
    required this.controller,
    required this.label,
    this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 20),
          alignLabelWithHint: maxLines > 1,
        ),
        validator: validator,
      ),
    );
  }
}

class _ModernSwitchTile extends StatelessWidget {
  const _ModernSwitchTile({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: appTextPrimary(isDark),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: appTextSecondary(isDark),
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeTrackColor: kAccentViolet,
          activeThumbColor: Colors.white,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
