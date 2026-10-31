import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../utils/url_utils.dart';
import '../widgets/app_ui.dart';

final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Screen 8 — Contact.
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
  bool _sending = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _copyEmail() {
    Clipboard.setData(const ClipboardData(text: kContactEmail));
    _toast('Email copied: $kContactEmail');
  }

  Future<bool> _tryLaunch(Uri uri) async {
    try {
      return await launchUrl(uri);
    } catch (_) {
      return false;
    }
  }

  Future<void> _emailDirect() async {
    final ok = await _tryLaunch(Uri.parse('mailto:$kContactEmail'));
    if (!ok && mounted) _copyEmail();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final message = _msgCtrl.text.trim();

    final subject = Uri.encodeComponent('Portfolio contact from $name');
    final body = Uri.encodeComponent(
      'Name: $name\nEmail: $email\n\n$message',
    );
    final ok = await _tryLaunch(
      Uri.parse('mailto:$kContactEmail?subject=$subject&body=$body'),
    );

    if (!ok) {
      await Clipboard.setData(
        ClipboardData(text: 'From: $name ($email)\n$message'),
      );
    }
    if (!mounted) return;
    setState(() => _sending = false);
    _toast(
      ok
          ? 'Opening your email app…'
          : 'No email app found. Message copied to clipboard instead.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final options = Column(
      children: [
        _ContactOptionCard(
          icon: Icons.email_rounded,
          title: 'Email me',
          subtitle: kContactEmail,
          onTap: _emailDirect,
          onLongPress: _copyEmail,
        ),
        const SizedBox(height: 10),
        _ContactOptionCard(
          icon: Icons.work_rounded,
          title: 'LinkedIn',
          subtitle: 'Connect with me',
          onTap: () => openLink(kLinkedinUrl),
        ),
        const SizedBox(height: 10),
        _ContactOptionCard(
          icon: Icons.code_rounded,
          title: 'GitHub',
          subtitle: 'github.com/$kGithubUsername',
          onTap: () => openLink(kGithubUrl),
        ),
        const SizedBox(height: 10),
        _ContactOptionCard(
          icon: Icons.alternate_email_rounded,
          title: 'X (Twitter)',
          subtitle: '@snj_142005',
          onTap: () => openLink(kXUrl),
        ),
      ],
    );

    final form = AppCard(
      padding: const EdgeInsets.all(20),
      radius: 22,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send a message',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: appTextPrimary(isDark),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
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
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'Your email',
                prefixIcon: Icon(Icons.alternate_email),
              ),
              validator: (v) => v != null && _emailPattern.hasMatch(v.trim())
                  ? null
                  : 'Enter a valid email, like name@example.com',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _msgCtrl,
              maxLines: 4,
              maxLength: 1000,
              decoration: const InputDecoration(
                labelText: 'Message',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.chat_bubble_outline),
              ),
              validator: (v) => v == null || v.trim().length < 5
                  ? 'Write at least a short sentence'
                  : null,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _sending ? null : _send,
                icon: _sending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(_sending ? 'Opening email…' : 'Send via email app'),
              ),
            ),
          ],
        ),
      ),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
      children: [
        ScreenTitle(
          'Contact Me',
          actions: [
            IconButton(
              tooltip: 'Copy email',
              icon: const Icon(Icons.copy_rounded, color: kAccentViolet),
              onPressed: _copyEmail,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          "Let's connect",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: appTextPrimary(isDark),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Have a project in mind or want to collaborate? Reach out on any channel below.',
          style: TextStyle(
            fontSize: 13,
            color: appTextSecondary(isDark),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 24),

        // Side by side on wide screens, stacked on phones.
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 760) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: options),
                  const SizedBox(width: 20),
                  Expanded(child: form),
                ],
              );
            }
            return Column(
              children: [options, const SizedBox(height: 24), form],
            );
          },
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
    required this.onTap,
    this.onLongPress,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: kPrimaryPurple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: kAccentViolet, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: appTextPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: appTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_outward_rounded,
            size: 18,
            color: appTextMuted(isDark),
          ),
        ],
      ),
    );
  }
}
