import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app.dart';
import '../constants.dart';
import '../services/resume_download_service.dart';
import '../utils/url_utils.dart';
import '../widgets/app_ui.dart';
import '../widgets/developer_avatar.dart';
import 'github_repos_screen.dart';

/// Screen 7 — Settings & Preferences matching SNJ Devfolio 2.0.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _setMode(ThemeMode mode) {
    SNJDevfolioApp.of(context)?.setThemeMode(mode);
    setState(() {});
  }

  void _setAnimate(bool value) {
    SNJDevfolioApp.of(context)?.setAnimateTheme(value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final app = SNJDevfolioApp.of(context);
    final currentMode = app?.currentThemeMode ?? ThemeMode.dark;
    final animate = app?.animateTheme ?? true;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
        children: [
          // Profile tile
          AppCard(
            padding: const EdgeInsets.all(18),
            onTap: () => openLink(kGithubUrl),
            child: Row(
              children: [
                const DeveloperAvatar(radius: 28, showGlow: false),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kDevName,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: appTextPrimary(isDark),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'github.com/$kGithubUsername',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: kAccentViolet,
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
          ),

          const SizedBox(height: 32),

          // ── Appearance Section ──────────────────────────────────────────
          const SectionHeader(
            'Appearance',
            index: '01',
            subtitle: 'Configure color themes and cross-fade animations',
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _ThemeModeCard(
                  icon: Icons.computer_rounded,
                  label: 'System',
                  sub: 'OS Match',
                  isSelected: currentMode == ThemeMode.system,
                  isDark: isDark,
                  onTap: () => _setMode(ThemeMode.system),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ThemeModeCard(
                  icon: Icons.light_mode_outlined,
                  label: 'Light',
                  sub: 'Studio Pure',
                  isSelected: currentMode == ThemeMode.light,
                  isDark: isDark,
                  onTap: () => _setMode(ThemeMode.light),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ThemeModeCard(
                  icon: Icons.dark_mode_outlined,
                  label: 'Dark',
                  sub: 'Deep Space',
                  isSelected: currentMode == ThemeMode.dark,
                  isDark: isDark,
                  onTap: () => _setMode(ThemeMode.dark),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Animate theme switch
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? kDarkSurface : Colors.white,
              borderRadius: BorderRadius.circular(kRadiusMd),
              border: Border.all(color: appBorderColor(isDark)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smooth Theme Cross-Fade',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: appTextPrimary(isDark),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Interpolate colors smoothly when changing brightness',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: appTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: animate,
                  activeTrackColor: kAccentViolet,
                  activeThumbColor: Colors.white,
                  onChanged: _setAnimate,
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),

          // ── Shortcuts & Information ─────────────────────────────────────
          const SectionHeader(
            'App Information',
            index: '02',
            subtitle: 'Portfolio documentation and legal notices',
          ),
          const SizedBox(height: 16),

          _SettingsLinkTile(
            icon: Icons.description_rounded,
            title: 'Official Resume Document (PDF)',
            sub: 'A4 interactive preview with verified credentials',
            onTap: () => ResumeDownloadService.openResumePreview(context),
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _SettingsLinkTile(
            icon: Icons.code_rounded,
            title: 'GitHub Repositories Explorer',
            sub: 'Direct REST API integration with real-time stats',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GithubReposScreen()),
            ),
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _SettingsLinkTile(
            icon: Icons.share_rounded,
            title: 'Share Developer Portfolio',
            sub: 'Copy portfolio link and summary to clipboard',
            onTap: () {
              Clipboard.setData(
                const ClipboardData(
                  text: '$kDevName — Flutter Developer Portfolio\n'
                      'GitHub: $kGithubUrl\n'
                      'Email: $kContactEmail',
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Portfolio details copied to clipboard'),
                ),
              );
            },
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _SettingsLinkTile(
            icon: Icons.info_outline_rounded,
            title: 'Application Metadata',
            sub: 'Version $kAppVersion • Flutter 3.x & Supabase',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'SNJ Devfolio',
              applicationVersion: kAppVersion,
              applicationLegalese: '© 2026 $kDevName. All rights reserved.',
              children: [
                const SizedBox(height: 12),
                Text(
                  'SNJ Devfolio is an award-winning developer portfolio built with Flutter, Supabase and GitHub REST API.',
                  style: GoogleFonts.inter(fontSize: 13),
                ),
              ],
            ),
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _SettingsLinkTile(
            icon: Icons.security_rounded,
            title: 'Privacy Policy',
            sub: 'No third-party visitor tracking or unsolicited cookies',
            onTap: () => _showPolicyDialog(
              title: 'Privacy Policy',
              content:
                  'SNJ Devfolio respects your privacy. No personal visitor data, tracking cookies, or contact messages are stored on private servers without explicit consent.',
            ),
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _SettingsLinkTile(
            icon: Icons.gavel_rounded,
            title: 'Terms & Conditions',
            sub: 'Open source software licensing details',
            onTap: () => _showPolicyDialog(
              title: 'Terms & Conditions',
              content:
                  'All project code, design layouts, and showcase assets are properties of $kDevName or their respective open-source licenses.',
            ),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  void _showPolicyDialog({required String title, required String content}) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        content: Text(content, style: GoogleFonts.inter(fontSize: 13, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeCard extends StatelessWidget {
  const _ThemeModeCard({
    required this.icon,
    required this.label,
    required this.sub,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String sub;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(kRadiusMd),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? kAccentViolet.withValues(alpha: 0.18) : const Color(0xFFEDE9FE))
                : (isDark ? kDarkSurface : Colors.white),
            borderRadius: BorderRadius.circular(kRadiusMd),
            border: Border.all(
              color: isSelected ? kAccentViolet : appBorderColor(isDark),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? kAccentViolet : appTextSecondary(isDark),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? (isDark ? Colors.white : kAccentViolet)
                      : appTextPrimary(isDark),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: isSelected ? kAccentViolet : appTextMuted(isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsLinkTile extends StatefulWidget {
  const _SettingsLinkTile({
    required this.icon,
    required this.title,
    required this.sub,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback onTap;
  final bool isDark;

  @override
  State<_SettingsLinkTile> createState() => _SettingsLinkTileState();
}

class _SettingsLinkTileState extends State<_SettingsLinkTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDark ? kDarkSurface : Colors.white,
          borderRadius: BorderRadius.circular(kRadiusMd),
          border: Border.all(
            color: _hovered
                ? kAccentViolet.withValues(alpha: 0.6)
                : appBorderColor(widget.isDark),
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(kRadiusMd),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kAccentViolet.withValues(alpha: widget.isDark ? 0.16 : 0.1),
                      borderRadius: BorderRadius.circular(8),
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
                          widget.sub,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: appTextSecondary(widget.isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
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
