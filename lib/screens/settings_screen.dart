import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app.dart';
import '../constants.dart';
import '../widgets/developer_avatar.dart';
import 'github_repos_screen.dart';

/// Screen 7 — Settings screen matching the reference screenshot.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dynamicTransitions = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final app = SNJDevfolioApp.of(context);
    final currentMode = app?.currentThemeMode ?? ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications are up to date.')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        children: [
          // ── Profile Overview Tile (Screen 7 Reference) ────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? kDarkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : kLightBorder,
              ),
            ),
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
                          color: isDark ? Colors.white : kLightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        kGithubUsername,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? kDarkTextSecondary : kLightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? kDarkTextMuted : Colors.grey,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Appearance Section (Screen 7 Reference) ───────────────────────
          Text(
            'Appearance',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : kLightTextPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // 3 Theme Mode Selector Cards
          Row(
            children: [
              Expanded(
                child: _ThemeModeCard(
                  icon: Icons.computer_rounded,
                  label: 'System\n(Default)',
                  isSelected: currentMode == ThemeMode.system,
                  isDark: isDark,
                  onTap: () => app?.setThemeMode(ThemeMode.system),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ThemeModeCard(
                  icon: Icons.light_mode_outlined,
                  label: 'Light\nMode',
                  isSelected: currentMode == ThemeMode.light,
                  isDark: isDark,
                  onTap: () => app?.setThemeMode(ThemeMode.light),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ThemeModeCard(
                  icon: Icons.dark_mode_outlined,
                  label: 'Dark\nMode',
                  isSelected: currentMode == ThemeMode.dark,
                  isDark: isDark,
                  onTap: () => app?.setThemeMode(ThemeMode.dark),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Dynamic Theme Switch ListTile
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dynamic Theme',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : kLightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Smooth transitions',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? kDarkTextSecondary : kLightTextSecondary,
                      ),
                    ),
                  ],
                ),
                Switch.adaptive(
                  value: _dynamicTransitions,
                  activeTrackColor: kPrimaryPurple,
                  activeThumbColor: kAccentViolet,
                  onChanged: (val) {
                    setState(() => _dynamicTransitions = val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── App Information & Legal Links ─────────────────────────────────
          _SettingsLinkTile(
            icon: Icons.info_outline_rounded,
            title: 'App Information',
            isDark: isDark,
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'SNJ Devfolio',
                applicationVersion: '1.0.0+1',
                applicationLegalese: '© 2026 Sanjay Bairwa. All rights reserved.',
                children: const [
                  SizedBox(height: 12),
                  Text(
                    'SNJ Devfolio is a professional developer portfolio powered by Flutter, Supabase remote management, and GitHub REST API integration.',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          _SettingsLinkTile(
            icon: Icons.security_rounded,
            title: 'Privacy Policy',
            isDark: isDark,
            onTap: () {
              _showPolicyDialog(
                context,
                title: 'Privacy Policy',
                content:
                    'SNJ Devfolio respects your privacy. No personal visitor data, tracking cookies, or contact messages are stored on private servers without explicit consent.',
              );
            },
          ),
          const SizedBox(height: 10),
          _SettingsLinkTile(
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            isDark: isDark,
            onTap: () {
              _showPolicyDialog(
                context,
                title: 'Terms & Conditions',
                content:
                    'All project code, design layouts, and showcase assets are properties of Sanjay Bairwa or their respective open-source licenses.',
              );
            },
          ),
          const SizedBox(height: 10),
          _SettingsLinkTile(
            icon: Icons.code_rounded,
            title: 'GitHub Repositories',
            isDark: isDark,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GithubReposScreen()),
              );
            },
          ),
          const SizedBox(height: 10),
          _SettingsLinkTile(
            icon: Icons.share_rounded,
            title: 'Share Portfolio',
            isDark: isDark,
            onTap: () {
              Clipboard.setData(const ClipboardData(
                text: 'Sanjay Bairwa — Flutter Developer Portfolio\nEmail: $kContactEmail',
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Portfolio details copied to clipboard!'),
                  backgroundColor: kPrimaryPurple,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPolicyDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
    return GestureDetector(
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
            color: isSelected
                ? kAccentViolet
                : (isDark ? Colors.white.withValues(alpha: 0.08) : kLightBorder),
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
                  : (isDark ? kDarkTextSecondary : kLightTextSecondary),
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
                    : (isDark ? kDarkTextSecondary : kLightTextSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsLinkTile extends StatelessWidget {
  const _SettingsLinkTile({
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
          color: isDark ? Colors.white.withValues(alpha: 0.08) : kLightBorder,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(icon, color: kAccentViolet, size: 22),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : kLightTextPrimary,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: isDark ? kDarkTextMuted : Colors.grey,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
