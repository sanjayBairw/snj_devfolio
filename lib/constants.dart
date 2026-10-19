import 'package:flutter/material.dart';

// ─── Supabase Configuration ───────────────────────────────────────────────────
const String supabaseUrl = 'https://dvyzoiqhpapuvyjngtdr.supabase.co';
const String supabaseAnonKey =
    'sb_publishable_QsFJAiBkNwjkxnY9_pxfRQ_jb72wzcs';

/// The Supabase user-id that has full admin rights.
/// Checked client-side AND enforced by Supabase Row-Level-Security.
const String kAdminUserId = '1ac260bd-9ffd-4bc4-a277-f7bad5d38348';

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

// ─── Color Palette (Reference Match) ──────────────────────────────────────────
// Dark Theme Colors
const Color kDarkBackground = Color(0xFF070B16);
const Color kDarkSurface = Color(0xFF10172A);
const Color kDarkSurface2 = Color(0xFF162036);
const Color kDarkSurface3 = Color(0xFF1E293B);

// Neon Accent Colors
const Color kPrimaryPurple = Color(0xFF7C3AED);
const Color kAccentViolet = Color(0xFFA855F7);
const Color kElectricBlue = Color(0xFF3B82F6);
const Color kCyanAccent = Color(0xFF06B6D4);
const Color kEmeraldGreen = Color(0xFF10B981);
const Color kAmberBadge = Color(0xFFF59E0B);

// Text Colors
const Color kDarkTextPrimary = Color(0xFFF8FAFC);
const Color kDarkTextSecondary = Color(0xFF94A3B8);
const Color kDarkTextMuted = Color(0xFF64748B);

// Light Theme Colors
const Color kLightBackground = Color(0xFFF8FAFC);
const Color kLightSurface = Color(0xFFFFFFFF);
const Color kLightSurface2 = Color(0xFFF1F5F9);
const Color kLightSurface3 = Color(0xFFE2E8F0);
const Color kLightTextPrimary = Color(0xFF0F172A);
const Color kLightTextSecondary = Color(0xFF475569);
const Color kLightBorder = Color(0xFFCBD5E1);

// Backward Compatibility Aliases
const Color kInk = kDarkBackground;
const Color kPanel = kDarkSurface;
const Color kPanel2 = kDarkSurface2;
const Color kAccent = kAccentViolet;
const Color kAccentAlt = kPrimaryPurple;
const Color kMuted = kDarkTextSecondary;

// ─── Gradients ────────────────────────────────────────────────────────────────
const LinearGradient kPurpleBlueGradient = LinearGradient(
  colors: [kPrimaryPurple, kElectricBlue],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kVioletPurpleGradient = LinearGradient(
  colors: [kAccentViolet, kPrimaryPurple],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kCardGradientDark = LinearGradient(
  colors: [Color(0xFF131D35), Color(0xFF0C1322)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ─── Responsive Breakpoints ───────────────────────────────────────────────────
const double kTabletBreakpoint = 640;
const double kDesktopBreakpoint = 1024;
const double kContentMaxWidth = 1080;
