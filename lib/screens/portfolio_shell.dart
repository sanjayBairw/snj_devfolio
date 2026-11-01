import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app.dart';
import '../constants.dart';
import '../services/supabase_service.dart';
import '../widgets/app_ui.dart';
import 'about_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'admin/admin_login_screen.dart';
import 'contact_screen.dart';
import 'github_repos_screen.dart';
import 'home_screen.dart';
import 'projects_screen.dart';
import 'settings_screen.dart';

/// Main navigation shell coordinating the SNJ Devfolio 2.0 screens.
class PortfolioShell extends StatefulWidget {
  const PortfolioShell({super.key});

  @override
  State<PortfolioShell> createState() => _PortfolioShellState();
}

class _PortfolioShellState extends State<PortfolioShell> {
  int _currentIndex = 0;

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: Container(
          decoration: BoxDecoration(
            color: (isDark ? kDarkBackground : kLightBackground).withValues(alpha: 0.94),
            border: Border(
              bottom: BorderSide(
                color: appBorderColor(isDark).withValues(alpha: 0.7),
                width: 1.0,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kContentMaxWidth),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // Brand Logo & Title
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => _goTo(0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: kAccentViolet.withValues(alpha: 0.5),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: kAccentViolet.withValues(alpha: 0.25),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    'assets/logo/Neon SNJ Devfolio Logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'SNJ',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                        color: appTextPrimary(isDark),
                                      ),
                                    ),
                                    TextSpan(
                                      text: '.DEV',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                        color: kAccentViolet,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Desktop Navigation Links
                      if (isDesktop) ...[
                        _DesktopNavLink(
                          index: '01',
                          label: 'Home',
                          isActive: _currentIndex == 0,
                          onTap: () => _goTo(0),
                        ),
                        _DesktopNavLink(
                          index: '02',
                          label: 'Projects',
                          isActive: _currentIndex == 1,
                          onTap: () => _goTo(1),
                        ),
                        _DesktopNavLink(
                          index: '03',
                          label: 'GitHub',
                          isActive: false,
                          onTap: () => _push(const GithubReposScreen()),
                        ),
                        _DesktopNavLink(
                          index: '04',
                          label: 'About',
                          isActive: _currentIndex == 2,
                          onTap: () => _goTo(2),
                        ),
                        _DesktopNavLink(
                          index: '05',
                          label: 'Contact',
                          isActive: _currentIndex == 3,
                          onTap: () => _goTo(3),
                        ),
                        const SizedBox(width: 14),
                      ] else ...[
                        _HeaderIconButton(
                          tooltip: 'GitHub Repositories',
                          icon: Icons.code_rounded,
                          onPressed: () => _push(const GithubReposScreen()),
                        ),
                      ],

                      // Theme Toggle Button
                      _HeaderIconButton(
                        tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                        icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                        onPressed: app?.toggleTheme,
                      ),

                      // Settings
                      _HeaderIconButton(
                        tooltip: 'Settings',
                        icon: Icons.settings_outlined,
                        onPressed: () => _push(const SettingsScreen()),
                      ),

                      // Admin
                      _HeaderIconButton(
                        tooltip: 'Admin Console',
                        icon: AuthService.isAdmin
                            ? Icons.admin_panel_settings_rounded
                            : Icons.shield_outlined,
                        color: AuthService.isAdmin ? kAccentViolet : null,
                        onPressed: _openAdmin,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kContentMaxWidth),
          child: IndexedStack(index: _currentIndex, children: _pages),
        ),
      ),
      // Mobile / Tablet Bottom Navigation
      bottomNavigationBar: isDesktop
          ? null
          : Container(
              decoration: BoxDecoration(
                color: isDark ? kDarkSurface : Colors.white,
                border: Border(
                  top: BorderSide(color: appBorderColor(isDark)),
                ),
              ),
              child: NavigationBar(
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
            ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.color,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: IconButton(
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
        padding: const EdgeInsets.all(7),
        icon: Icon(
          icon,
          size: 19,
          color: color ?? appTextSecondary(isDark),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class _DesktopNavLink extends StatefulWidget {
  const _DesktopNavLink({
    required this.index,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String index;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_DesktopNavLink> createState() => _DesktopNavLinkState();
}

class _DesktopNavLinkState extends State<_DesktopNavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeOrHover = widget.isActive || _hovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: TextButton(
          onPressed: widget.onTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kRadiusSm),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.index}.',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: widget.isActive
                      ? kAccentViolet
                      : appTextMuted(isDark),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                  color: activeOrHover
                      ? (isDark ? Colors.white : Colors.black)
                      : appTextSecondary(isDark),
                ),
              ),
              if (widget.isActive) ...[
                const SizedBox(width: 6),
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: kAccentViolet,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
