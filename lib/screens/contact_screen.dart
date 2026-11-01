import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../utils/url_utils.dart';
import '../widgets/app_ui.dart';

final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Screen 8 — Refined Contact experience matching SNJ Devfolio 2.0.
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
    _toast('Email address copied to clipboard: $kContactEmail');
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

    final subject = Uri.encodeComponent('Project Inquiry from $name');
    final body = Uri.encodeComponent(
      'Client / Collaborator: $name\nEmail: $email\n\n$message',
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
          ? 'Opening default email application…'
          : 'Email app not detected. Message details copied to clipboard.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final directChannels = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChannelCard(
          icon: Icons.email_rounded,
          title: 'Email Me',
          subtitle: kContactEmail,
          onTap: _emailDirect,
          onLongPress: _copyEmail,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _ChannelCard(
          icon: Icons.work_rounded,
          title: 'LinkedIn',
          subtitle: 'linkedin.com/in/sanjay-buhadiya',
          onTap: () => openLink(kLinkedinUrl),
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _ChannelCard(
          icon: Icons.code_rounded,
          title: 'GitHub',
          subtitle: 'github.com/$kGithubUsername',
          onTap: () => openLink(kGithubUrl),
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _ChannelCard(
          icon: Icons.alternate_email_rounded,
          title: 'X (Twitter)',
          subtitle: '@snj_142005',
          onTap: () => openLink(kXUrl),
          isDark: isDark,
        ),
        const SizedBox(height: 18),

        // Availability note
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? kDarkSurface2 : kLightSurface2,
            borderRadius: BorderRadius.circular(kRadiusMd),
            border: Border.all(color: appBorderColor(isDark)),
          ),
          child: Row(
            children: [
              const PulsingDot(color: kEmeraldGreen, size: 8),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Typically responds within 24 hours. Open to remote contracts & full-time roles.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: appTextSecondary(isDark),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final messageForm = Container(
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transmit a Message',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: appTextPrimary(isDark),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Fill out the form below to initiate communication directly.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: appTextSecondary(isDark),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameCtrl,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              style: GoogleFonts.inter(fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Your name',
                prefixIcon: Icon(Icons.person_outline, size: 20),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter your name' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              style: GoogleFonts.inter(fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Your email',
                prefixIcon: Icon(Icons.alternate_email, size: 20),
              ),
              validator: (v) => v != null && _emailPattern.hasMatch(v.trim())
                  ? null
                  : 'Enter a valid email',
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _msgCtrl,
              maxLines: 4,
              maxLength: 1000,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Message',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.chat_bubble_outline, size: 20),
              ),
              validator: (v) => v == null || v.trim().length < 5
                  ? 'Write a short message'
                  : null,
            ),
            const SizedBox(height: 16),
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
                    : const Icon(Icons.send_rounded, size: 16),
                label: Text(
                  _sending ? 'Opening Email Client…' : 'Open email to send',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
      children: [
        // Title & Copy Action
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '04 // DIRECT COMMUNICATION',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: kAccentViolet,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Let\'s Connect!',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      color: appTextPrimary(isDark),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Copy Email Address',
              icon: const Icon(Icons.copy_rounded, color: kAccentViolet),
              onPressed: _copyEmail,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Large Editorial Introductory Statement
        RichText(
          text: TextSpan(
            style: GoogleFonts.spaceGrotesk(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
              height: 1.15,
              color: appTextPrimary(isDark),
            ),
            children: const [
              TextSpan(text: 'Let\'s build something\n'),
              TextSpan(
                text: 'remarkable together.',
                style: TextStyle(color: kAccentViolet),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Have a product concept in mind, an opportunity, or looking for a specialized Flutter developer? Reach out through any channel below.',
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 1.55,
            color: appTextSecondary(isDark),
          ),
        ),
        const SizedBox(height: 32),

        // Asymmetrical layout on wide screens
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 760) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: directChannels),
                  const SizedBox(width: 24),
                  Expanded(flex: 5, child: messageForm),
                ],
              );
            }
            return Column(
              children: [
                directChannels,
                const SizedBox(height: 24),
                messageForm,
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ChannelCard extends StatefulWidget {
  const _ChannelCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.onLongPress,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isDark;

  @override
  State<_ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends State<_ChannelCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
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
                color: kAccentViolet.withValues(alpha: widget.isDark ? 0.15 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(kRadiusMd),
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: kAccentViolet.withValues(alpha: widget.isDark ? 0.16 : 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon, color: kAccentViolet, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: appTextPrimary(widget.isDark),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: appTextSecondary(widget.isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 16,
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
}
