import 'package:flutter/material.dart';
import '../app.dart';
import '../constants.dart';
import '../services/supabase_service.dart';
import 'about_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'admin/admin_login_screen.dart';
import 'contact_screen.dart';
import 'github_repos_screen.dart';
import 'home_screen.dart';
import 'projects_screen.dart';
import 'settings_screen.dart';

/// Main navigation shell coordinating the portfolio screens.
class PortfolioShell extends StatefulWidget {
  const PortfolioShell({super.key});

  @override
  State<PortfolioShell> createState() => _PortfolioShellState();
}

class _PortfolioShellState extends State<PortfolioShell> {
  int _currentIndex = 0;

  // Built once, so pages are not recreated on every rebuild and each tab keeps
  // its state (scroll position, filters, loaded data).
  late final List<Widget> _pages = [
    HomeScreen(onNavigate: _goTo),
    const ProjectsScreen(),
    const AboutScreen(),
    const ContactScreen(),
  ];

  void _goTo(int index) => setState(() => _currentIndex = index);

  void _push(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  void _openAdmin() => _push(
        AuthService.isAdmin
            ? const AdminDashboardScreen()
            : const AdminLoginScreen(),
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final app = SNJDevfolioApp.of(context);
    final isDesktop = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;

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
              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    fontSize: 16,
                  ),
                  children: [
                    TextSpan(
                      text: 'SNJ.',
                      style: TextStyle(
                        color: isDark ? Colors.white : kLightTextPrimary,
                      ),
                    ),
                    const TextSpan(
                      text: 'DEV',
                      style: TextStyle(color: kAccentViolet),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Desktop: full link row. Phones use the bottom bar instead.
          if (isDesktop) ...[
            _DesktopNavLink(
              label: 'Home',
              isActive: _currentIndex == 0,
              onTap: () => _goTo(0),
            ),
            _DesktopNavLink(
              label: 'Projects',
              isActive: _currentIndex == 1,
              onTap: () => _goTo(1),
            ),
            _DesktopNavLink(
              label: 'GitHub',
              isActive: false,
              onTap: () => _push(const GithubReposScreen()),
            ),
            _DesktopNavLink(
              label: 'About',
              isActive: _currentIndex == 2,
              onTap: () => _goTo(2),
            ),
            _DesktopNavLink(
              label: 'Contact',
              isActive: _currentIndex == 3,
              onTap: () => _goTo(3),
            ),
            const SizedBox(width: 14),
          ] else
            // On desktop GitHub is already a nav link, so only show the icon here.
            _AppBarIcon(
              tooltip: 'GitHub Repositories',
              icon: const Icon(Icons.code_rounded, size: 20),
              onPressed: () => _push(const GithubReposScreen()),
            ),

          _AppBarIcon(
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
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
          _AppBarIcon(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined, size: 20),
            onPressed: () => _push(const SettingsScreen()),
          ),
          _AppBarIcon(
            tooltip: 'Admin Panel',
            onPressed: _openAdmin,
            icon: Icon(
              AuthService.isAdmin
                  ? Icons.admin_panel_settings_rounded
                  : Icons.shield_outlined,
              color: AuthService.isAdmin ? kAccentViolet : null,
              size: 20,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kContentMaxWidth),
          child: IndexedStack(index: _currentIndex, children: _pages),
        ),
      ),
      // Desktop already has the top links, so the bottom bar is phone/tablet only.
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _goTo,
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

class _AppBarIcon extends StatelessWidget {
  const _AppBarIcon({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final Widget icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
      padding: const EdgeInsets.all(7),
      icon: icon,
      onPressed: onPressed,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 3),
            // Underline shows which page you are on.
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: isActive ? 20 : 0,
              decoration: BoxDecoration(
                gradient: kVioletPurpleGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
