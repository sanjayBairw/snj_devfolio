import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../utils/url_utils.dart';

/// Screen 8 — Contact Screen matching the reference screenshot with direct form.
class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  void _copyEmail() {
    Clipboard.setData(const ClipboardData(text: kContactEmail));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email copied to clipboard: $kContactEmail'),
        backgroundColor: kPrimaryPurple,
      ),
    );
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final subject =
        Uri.encodeComponent('Portfolio Contact from ${_nameCtrl.text.trim()}');
    final body = Uri.encodeComponent(
      'Name: ${_nameCtrl.text.trim()}\n'
      'Email: ${_emailCtrl.text.trim()}\n\n'
      '${_msgCtrl.text.trim()}',
    );
    final uri = Uri.parse('mailto:$kContactEmail?subject=$subject&body=$body');

    if (!await launchUrl(uri)) {
      Clipboard.setData(ClipboardData(
        text:
            'From: ${_nameCtrl.text.trim()} (${_emailCtrl.text.trim()})\n${_msgCtrl.text.trim()}',
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('No email app found. Message copied to clipboard instead.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
      children: [
        // App Bar Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Contact Me',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : kLightTextPrimary,
              ),
            ),
            IconButton(
              tooltip: 'Copy Email',
              icon: const Icon(Icons.copy_rounded, color: kAccentViolet),
              onPressed: _copyEmail,
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Header Title & Subtitle (Screen 8 Reference)
        Text(
          'Let\'s Connect!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : kLightTextPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Have a project in mind or want to collaborate? Feel free to reach out.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? kDarkTextSecondary : kLightTextSecondary,
            height: 1.45,
          ),
        ),

        const SizedBox(height: 24),

        // ── Illustrated Envelope Card (Screen 8 Reference) ──────────────────
        Center(
          child: Container(
            width: 140,
            height: 96,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E1065), Color(0xFF1E1B4B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: kAccentViolet.withValues(alpha: 0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryPurple.withValues(alpha: 0.35),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ShaderMask(
              shaderCallback: (bounds) => kVioletPurpleGradient
                  .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              child: const Icon(
                Icons.mark_email_unread_rounded,
                size: 52,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 26),

        // ── Contact Option Cards (Screen 8 Reference) ───────────────────────
        _ContactOptionCard(
          icon: Icons.email_rounded,
          title: 'Email Me',
          subtitle: kContactEmail,
          isDark: isDark,
          onTap: () async {
            final uri = Uri.parse('mailto:$kContactEmail');
            if (!await launchUrl(uri)) {
              _copyEmail();
            }
          },
          onLongPress: _copyEmail,
        ),
        const SizedBox(height: 10),

        _ContactOptionCard(
          icon: Icons.work_rounded,
          title: 'LinkedIn',
          subtitle: 'Connect with me',
          isDark: isDark,
          onTap: () => openLink(kLinkedinUrl),
        ),
        const SizedBox(height: 10),

        _ContactOptionCard(
          icon: Icons.code_rounded,
          title: 'GitHub',
          subtitle: 'github.com/sanjayBairw',
          isDark: isDark,
          onTap: () => openLink(kGithubUrl),
        ),
        const SizedBox(height: 10),

        _ContactOptionCard(
          icon: Icons.alternate_email_rounded,
          title: 'X (Twitter)',
          subtitle: '@snj_142005',
          isDark: isDark,
          onTap: () => openLink(kXUrl),
        ),

        const SizedBox(height: 28),

        // ── Direct Contact Form ─────────────────────────────────────────────
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
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send a Direct Message',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : kLightTextPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Your name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Your email',
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                  validator: (v) {
                    if (v == null || !v.contains('@')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _msgCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.chat_bubble_outline),
                  ),
                  validator: (v) => v == null || v.trim().length < 5
                      ? 'Write a short message'
                      : null,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Open email to send'),
                    style: FilledButton.styleFrom(
                      backgroundColor: kPrimaryPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactOptionCard extends StatelessWidget {
  const _ContactOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
    this.onLongPress,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? kDarkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : kLightBorder,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          onLongPress: onLongPress,
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: kPrimaryPurple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: kAccentViolet, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : kLightTextPrimary,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? kDarkTextSecondary : kLightTextSecondary,
            ),
          ),
          trailing: Icon(
            Icons.arrow_outward_rounded,
            size: 18,
            color: isDark ? kDarkTextMuted : Colors.grey,
          ),
        ),
      ),
    );
  }
}
