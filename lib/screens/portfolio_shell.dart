import 'package:flutter/material.dart';
import '../app.dart';
import '../constants.dart';
import '../services/supabase_service.dart';
import 'home_screen.dart';
import 'projects_screen.dart';
import 'github_repos_screen.dart';
import 'about_screen.dart';
import 'contact_screen.dart';
import 'settings_screen.dart';
import 'admin/admin_login_screen.dart';
import 'admin/admin_dashboard_screen.dart';

/// Main navigation shell coordinating the portfolio screens.
class PortfolioShell extends StatefulWidget {
  const PortfolioShell({super.key});

  @override
  State<PortfolioShell> createState() => _PortfolioShellState();
}

class _PortfolioShellState extends State<PortfolioShell> {
  int _currentIndex = 0;

  void _openAdmin() {
    if (AuthService.isAdmin) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
      );
    }
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _openGitHub() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GithubReposScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final app = SNJDevfolioApp.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= kDesktopBreakpoint;

    final pages = [
      HomeScreen(onNavigate: (i) => setState(() => _currentIndex = i)),
      const ProjectsScreen(),
      const AboutScreen(),
      const ContactScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryPurple.withValues(alpha: 0.35),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/logo/Neon SNJ Devfolio Logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'SNJ.',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        fontSize: 16,
                        color: isDark ? Colors.white : kLightTextPrimary,
                      ),
                    ),
                    const TextSpan(
                      text: 'DEV',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        fontSize: 16,
                        color: kAccentViolet,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Desktop Navigation Links
          if (isDesktop) ...[
            _DesktopNavLink(
              label: 'Home',
              isActive: _currentIndex == 0,
              onTap: () => setState(() => _currentIndex = 0),
            ),
            _DesktopNavLink(
              label: 'Projects',
              isActive: _currentIndex == 1,
              onTap: () => setState(() => _currentIndex = 1),
            ),
            _DesktopNavLink(
              label: 'GitHub',
              isActive: false,
              onTap: _openGitHub,
            ),
            _DesktopNavLink(
              label: 'About',
              isActive: _currentIndex == 2,
              onTap: () => setState(() => _currentIndex = 2),
            ),
            _DesktopNavLink(
              label: 'Contact',
              isActive: _currentIndex == 3,
              onTap: () => setState(() => _currentIndex = 3),
            ),
            const SizedBox(width: 14),
          ],

          // GitHub Screen Action
          IconButton(
            tooltip: 'GitHub Repositories',
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            padding: const EdgeInsets.all(7),
            icon: const Icon(Icons.code_rounded, size: 20),
            onPressed: _openGitHub,
          ),

          // Theme Toggle Action
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            padding: const EdgeInsets.all(7),
            onPressed: app?.toggleTheme,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                key: ValueKey(isDark),
                size: 20,
              ),
            ),
          ),

          // Settings Action
          IconButton(
            tooltip: 'Settings',
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            padding: const EdgeInsets.all(7),
            icon: const Icon(Icons.settings_outlined, size: 20),
            onPressed: _openSettings,
          ),

          // Admin Action
          IconButton(
            tooltip: 'Admin Panel',
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            padding: const EdgeInsets.all(7),
            icon: Icon(
              AuthService.isAdmin
                  ? Icons.admin_panel_settings_rounded
                  : Icons.shield_outlined,
              color: AuthService.isAdmin ? kAccentViolet : null,
              size: 20,
            ),
            onPressed: _openAdmin,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kContentMaxWidth),
          child: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'About',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Contact',
          ),
        ],
      ),
    );
  }
}

class _DesktopNavLink extends StatelessWidget {
  const _DesktopNavLink({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: isActive ? kAccentViolet : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
