import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants.dart';
import '../../services/supabase_service.dart';
import '../../widgets/app_ui.dart';
import 'admin_dashboard_screen.dart';

/// Screen 6b — Admin Login screen matching SNJ Devfolio 2.0.
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await AuthService.signIn(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      if (!mounted) return;

      final user = response.user;
      if (user == null) {
        setState(() {
          _error = 'Authentication failed. Please verify credentials.';
          _loading = false;
        });
        return;
      }

      if (user.id != kAdminUserId) {
        await AuthService.signOut();
        if (!mounted) return;
        setState(() {
          _error = 'Access denied. Account is not authorized as portfolio administrator.';
          _loading = false;
        });
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Unexpected error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Security Authentication',
          style: GoogleFonts.spaceGrotesk(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lock Icon Container
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: kAccentViolet.withValues(alpha: isDark ? 0.16 : 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: kAccentViolet.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: kAccentViolet,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Portfolio Administrator',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: appTextPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign in with your Supabase credentials to manage remote projects and portfolio metadata.',
                  style: GoogleFonts.inter(
                    color: appTextSecondary(isDark),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                if (_error != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(kRadiusMd),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _error!,
                      style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.inter(fontSize: 14),
                        decoration: const InputDecoration(
                          labelText: 'Admin Email',
                          prefixIcon: Icon(Icons.alternate_email, size: 20),
                        ),
                        validator: (v) =>
                            v == null || !v.contains('@')
                                ? 'Enter a valid admin email'
                                : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        style: GoogleFonts.inter(fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.key_outlined, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 18,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Enter your password'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: _loading ? null : _login,
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Sign in to Dashboard'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? kDarkSurface2 : kLightSurface2,
                    borderRadius: BorderRadius.circular(kRadiusMd),
                    border: Border.all(color: appBorderColor(isDark)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.shield_outlined, size: 18, color: kAccentViolet),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Enforced by Supabase Row-Level-Security (RLS). Only authenticated admin user ($kAdminUserId) possesses write permissions.',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: appTextMuted(isDark),
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
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
