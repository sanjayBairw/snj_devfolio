import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models/project.dart';
import '../../services/supabase_service.dart';
import '../../utils/url_utils.dart';

/// Add or edit a single portfolio project.
/// Pass [project] to edit; leave null to create a new one.
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit project' : 'Add project'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null)
                    _ErrorBanner(message: _error!),

                  _Field(
                    controller: _title,
                    label: 'Project title *',
                    icon: Icons.title_rounded,
                    validator: (v) => v == null || v.trim().length < 2
                        ? 'Title must be at least 2 characters'
                        : null,
                  ),
                  _Field(
                    controller: _description,
                    label: 'Description *',
                    icon: Icons.description_outlined,
                    maxLines: 4,
                    validator: (v) => v == null || v.trim().length < 10
                        ? 'Description must be at least 10 characters'
                        : null,
                  ),
                  _Field(
                    controller: _techStack,
                    label: 'Tech stack  (use • as separator)',
                    hint: 'Flutter • Dart • Firebase',
                    icon: Icons.code_rounded,
                  ),
                  _Field(
                    controller: _githubUrl,
                    label: 'GitHub URL',
                    hint: 'https://github.com/...',
                    icon: Icons.link_rounded,
                    keyboardType: TextInputType.url,
                    validator: (v) => _urlValidator(v),
                  ),
                  _Field(
                    controller: _demoUrl,
                    label: 'Live demo URL',
                    hint: 'https://...',
                    icon: Icons.play_circle_outline,
                    keyboardType: TextInputType.url,
                    validator: (v) => _urlValidator(v),
                  ),
                  _Field(
                    controller: _imageUrl,
                    label: 'Image URL  (optional)',
                    hint: 'https://...jpg or .png',
                    icon: Icons.image_outlined,
                    keyboardType: TextInputType.url,
                    validator: (v) => _urlValidator(v),
                  ),
                  _Field(
                    controller: _displayOrder,
                    label: 'Display order',
                    hint: '0 = first',
                    icon: Icons.sort_rounded,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      if (int.tryParse(v) == null) return 'Enter a number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  _SwitchRow(
                    label: 'Published',
                    subtitle: 'Visible in the public portfolio',
                    value: _isPublished,
                    onChanged: (v) => setState(() => _isPublished = v),
                  ),
                  _SwitchRow(
                    label: 'Featured',
                    subtitle: 'Highlighted with a ★ badge',
                    value: _isFeatured,
                    onChanged: (v) => setState(() => _isFeatured = v),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: const Icon(Icons.save_outlined),
                      label: Text(_isEditing ? 'Save changes' : 'Create project'),
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
    if (v == null || v.trim().isEmpty) return null; // optional
    if (!isValidUrl(v.trim())) return 'Enter a valid https:// URL';
    return null;
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
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
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          alignLabelWithHint: maxLines > 1,
        ),
        validator: validator,
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle,
          style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? kMuted
                  : const Color(0xFF546E7A),
              fontSize: 12)),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: .3)),
      ),
      child: Text(message,
          style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
    );
  }
}
