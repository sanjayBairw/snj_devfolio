import 'package:flutter/material.dart';

// ─── Supabase Configuration ───────────────────────────────────────────────────
// Override at build time without editing code:
//   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
// The defaults keep the app working exactly as before.
const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://dvyzoiqhpapuvyjngtdr.supabase.co',
);
const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'sb_publishable_QsFJAiBkNwjkxnY9_pxfRQ_jb72wzcs',
);

/// The Supabase user-id that has full admin rights.
/// Checked client-side AND enforced by Supabase Row-Level-Security.
const String kAdminUserId = '1ac260bd-9ffd-4bc4-a277-f7bad5d38348';

// ─── App ──────────────────────────────────────────────────────────────────────
const String kAppVersion = '1.0.0+1';

// ─── Profile Details ──────────────────────────────────────────────────────────
const String kDevName = 'Sanjay Bairwa';
const String kDevRole = 'Flutter Developer • Full Stack Developer';
const String kDevRolePipe = 'Flutter Developer | Full Stack Developer';
const String kDevBio =
    'I\'m a passionate Flutter developer dedicated to building innovative and user-friendly mobile applications. I love turning ideas into reality using modern technologies.';
const String kDevHeadline = 'Building apps that\nsolve real problems.';
const String kDevTagline = 'Build • Innovate • Inspire';
const String kDevSubtitle = 'A Developer Portfolio\nby Sanjay Bairwa';
const String kGithubUsername = 'sanjayBairw';
const String kGithubUrl = 'https://github.com/sanjayBairw';
const String kLinkedinUrl =
    'https://www.linkedin.com/in/sanjay-buhadiya-812657404';
const String kResumeUrl =
    'https://drive.google.com/drive/folders/1gGBkZGDtx2S14lQNIJNj3h-lgXIq3-LO';
const String kXUrl = 'https://x.com/snj_142005';
const String kContactEmail = 'bairwas361@gmail.com';
const String kAvatarUrl = 'https://avatars.githubusercontent.com/u/188983849?v=4';
const String kProfileAssetPath = 'assets/images/profile.jpg';
const String kResumeAssetPath = 'assets/document/SnjR_removed.pdf';
const String kResumeFileName = 'Sanjay_Bairwa_Resume.pdf';
const String kResumeImagePage1 = 'assets/document/resume_page_1.png';

// ─── Skills (single source of truth for Home + About) ─────────────────────────
const Map<String, List<String>> kSkillGroups = {
  'Mobile': ['Flutter', 'Dart', 'Firebase'],
  'Backend': ['Rest API', 'FastAPI', 'Node.js', 'MongoDB'],
  'Tools': ['Git'],
};

final List<String> kAllSkills = [
  for (final group in kSkillGroups.values) ...group,
];

// ─── Color Palette (SNJ Devfolio 2.0 Specification) ───────────────────────────
// Dark Theme Colors
const Color kDarkBackground = Color(0xFF08090D);
const Color kDarkSecondaryBackground = Color(0xFF101116);
const Color kDarkSurface = Color(0xFF171920);
const Color kDarkSurface2 = Color(0xFF1E212A);
const Color kDarkSurface3 = Color(0xFF262935);
const Color kDarkBorder = Color(0xFF292B34);

// Accent Colors (Selective & Premium)
const Color kAccentBlue = Color(0xFF69A7FF);
const Color kAccentViolet = Color(0xFF9877FF);
const Color kElectricBlue = Color(0xFF69A7FF); // alias
const Color kPrimaryPurple = Color(0xFF9877FF); // alias
const Color kCyanAccent = Color(0xFF38BDF8);
const Color kEmeraldGreen = Color(0xFF10B981);
const Color kAmberBadge = Color(0xFFF59E0B);

// Dark Text Colors
const Color kDarkTextPrimary = Color(0xFFF5F5F2);
const Color kDarkTextSecondary = Color(0xFF999BA5);
const Color kDarkTextMuted = Color(0xFF6A6D7C);

// Light Theme Colors
const Color kLightBackground = Color(0xFFFBFBFD);
const Color kLightSecondaryBackground = Color(0xFFF2F4F7);
const Color kLightSurface = Color(0xFFFFFFFF);
const Color kLightSurface2 = Color(0xFFF5F7FA);
const Color kLightSurface3 = Color(0xFFE5E7EB);
const Color kLightBorder = Color(0xFFE2E4E9);
const Color kLightTextPrimary = Color(0xFF0D0F14);
const Color kLightTextSecondary = Color(0xFF64748B);
const Color kLightTextMuted = Color(0xFF94A3B8);

// Backward Compatibility Aliases
const Color kInk = kDarkBackground;
const Color kPanel = kDarkSurface;
const Color kPanel2 = kDarkSurface2;
const Color kAccent = kAccentViolet;
const Color kAccentAlt = kAccentBlue;
const Color kMuted = kDarkTextSecondary;

// ─── Gradients ────────────────────────────────────────────────────────────────
const LinearGradient kVioletBlueGradient = LinearGradient(
  colors: [kAccentViolet, kAccentBlue],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kPurpleBlueGradient = LinearGradient(
  colors: [kAccentViolet, kAccentBlue],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kVioletPurpleGradient = LinearGradient(
  colors: [kAccentViolet, Color(0xFF7C3AED)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kCardGradientDark = LinearGradient(
  colors: [Color(0xFF151720), Color(0xFF0E0F14)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kGlassSurfaceGradientDark = LinearGradient(
  colors: [Color(0x331E212A), Color(0x1A101116)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ─── Radius Tokens ────────────────────────────────────────────────────────────
const double kRadiusXs = 6;
const double kRadiusSm = 10;
const double kRadiusMd = 16;
const double kRadiusLg = 22;
const double kRadiusXl = 30;

// ─── Responsive Breakpoints ───────────────────────────────────────────────────
const double kTabletBreakpoint = 680;
const double kDesktopBreakpoint = 1040;
const double kContentMaxWidth = 1200;

