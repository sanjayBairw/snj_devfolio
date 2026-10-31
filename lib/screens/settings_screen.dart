import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app.dart';
import '../constants.dart';
import '../services/resume_download_service.dart';
import '../utils/url_utils.dart';
import '../widgets/app_ui.dart';
import '../widgets/developer_avatar.dart';
import 'github_repos_screen.dart';

/// Screen 7 — Settings.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // The app state updates its own fields synchronously, so we only need to
  // rebuild here. Without this the selected card did not refresh when the
  // brightness stayed the same (for example System -> Dark on a dark phone).
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
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        children: [
          // Profile tile (opens GitHub, which the chevron already promised)
          AppCard(
            padding: const EdgeInsets.all(16),
            onTap: () => openLink(kGithubUrl),
            child: Row(
              children: [
                const DeveloperAvatar(radius: 26, showGlow: false),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kDevName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: appTextPrimary(isDark),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        kGithubUsername,
                        style: TextStyle(
                          fontSize: 13,
                          color: appTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: appTextMuted(isDark),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const SectionHeader('Appearance'),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _ThemeModeCard(
                  icon: Icons.computer_rounded,
                  label: 'System\n(Default)',
                  isSelected: currentMode == ThemeMode.system,
                  isDark: isDark,
                  onTap: () => _setMode(ThemeMode.system),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ThemeModeCard(
                  icon: Icons.light_mode_outlined,
                  label: 'Light\nMode',
                  isSelected: currentMode == ThemeMode.light,
                  isDark: isDark,
                  onTap: () => _setMode(ThemeMode.light),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ThemeModeCard(
                  icon: Icons.dark_mode_outlined,
                  label: 'Dark\nMode',
                  isSelected: currentMode == ThemeMode.dark,
                  isDark: isDark,
                  onTap: () => _setMode(ThemeMode.dark),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // This switch now actually controls the theme cross-fade
          // and remembers the choice.
          AppCard(
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Animate theme change',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: appTextPrimary(isDark),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Fade between light and dark',
                        style: TextStyle(
                          fontSize: 12,
                          color: appTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: animate,
                  activeTrackColor: kPrimaryPurple,
                  activeThumbColor: kAccentViolet,
                  onChanged: _setAnimate,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _SettingsLinkTile(
            icon: Icons.description_rounded,
            title: 'View Resume',
            onTap: () => ResumeDownloadService.openResumePreview(context),
          ),
          const SizedBox(height: 10),
          _SettingsLinkTile(
            icon: Icons.code_rounded,
            title: 'GitHub Repositories',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GithubReposScreen()),
            ),
          ),
          const SizedBox(height: 10),
          _SettingsLinkTile(
            icon: Icons.share_rounded,
            title: 'Share Portfolio',
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
          ),
          const SizedBox(height: 10),
          _SettingsLinkTile(
            icon: Icons.info_outline_rounded,
            title: 'App Information',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'SNJ Devfolio',
              applicationVersion: kAppVersion,
              applicationLegalese: '© 2026 $kDevName. All rights reserved.',
              children: const [
                SizedBox(height: 12),
                Text(
                  'SNJ Devfolio is a developer portfolio built with Flutter, Supabase and the GitHub REST API.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _SettingsLinkTile(
            icon: Icons.security_rounded,
            title: 'Privacy Policy',
            onTap: () => _showPolicyDialog(
              title: 'Privacy Policy',
              content:
                  'SNJ Devfolio respects your privacy. No personal visitor data, tracking cookies, or contact messages are stored on private servers without explicit consent.',
            ),
          ),
          const SizedBox(height: 10),
          _SettingsLinkTile(
            icon: Icons.gavel_rounded,
            title: 'Terms & Conditions',
            onTap: () => _showPolicyDialog(
              title: 'Terms & Conditions',
              content:
                  'All project code, design layouts, and showcase assets are properties of $kDevName or their respective open-source licenses.',
            ),
          ),
        ],
      ),
    );
  }

  void _showPolicyDialog({required String title, required String content}) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(content),
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
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label.replaceAll('\n', ' '),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEDE9FE))
                  : (isDark ? kDarkSurface : Colors.white),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? kAccentViolet : appBorderColor(isDark),
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: kPrimaryPurple.withValues(alpha: 0.3),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? kAccentViolet
                      : appTextSecondary(isDark),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? Colors.white : kPrimaryPurple)
                        : appTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsLinkTile extends StatelessWidget {
  const _SettingsLinkTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: kAccentViolet, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: appTextPrimary(isDark),
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: appTextMuted(isDark)),
        ],
      ),
    );
  }
}
