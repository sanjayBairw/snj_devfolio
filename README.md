<<<<<<< HEAD
# SNJ Devfolio — Premium Developer Portfolio

A developer portfolio for **Sanjay Bairwa** (Flutter Developer | Full Stack Developer), matching the reference design with dark neon aesthetics, GitHub REST API integration, Supabase remote project management, light/dark/system theme switching, and production builds for Android & Web.

---

## ✨ Features & Implemented Reference Screens

| Screen / Feature | Description | Status |
|---|---|---|
| **Screen 1 — Splash Screen** | Animated logo reveal with purple-blue glow, neon ribbon background, tagline "Build • Innovate • Inspire", and loading bar | ✅ Verified |
| **Screen 2 — Home Screen** | Glowing developer avatar, "🟢 Available for Opportunities" badge, headline, primary CTAs (View Projects, Download Resume), stats badges, and featured project cards | ✅ Verified |
| **Screen 3 — My Projects** | Filter chips (All, Featured, GitHub, Supabase), search query filter, cards with status badges and quick links | ✅ Verified |
| **Screen 4 — GitHub Repositories** | Dynamic GitHub REST API integration for `@sanjaybairwa`, profile stats, search, language tags, stars/forks, and rate-limit fallback | ✅ Verified |
| **Screen 5 — Project Details** | Detailed view with hero banner, key highlights list, technology chips, and live demo/repo links | ✅ Verified |
| **Screen 6 — About Me** | Bio card, metrics (10+ Projects, 1K+ Stars, 2+ Years Exp.), 8 core skill chips, and B.Tech CSE education section | ✅ Verified |
| **Screen 7 — Admin Panel** | Supabase Auth + RLS enforcement (`kAdminUserId`), remote project creation, editing, publish/unpublish, deletion, and status badge | ✅ Verified |
| **Screen 8 — Contact Screen** | "Let's Connect!", illustrated envelope graphic, verified email (`sanjaybairwa2004@gmail.com`), LinkedIn, GitHub, X links, and message form with email fallback | ✅ Verified |
| **Screen 9 — Settings** | Visual theme selector (System, Light, Dark), dynamic theme toggle, and legal/privacy dialogs | ✅ Verified |
| **Screen 10 — Responsive Web** | Max-width content constraint (`1080px`), responsive top navigation links, and full desktop browser support | ✅ Verified |

---

## 🛠 Tech Stack

- **Flutter**: `3.35.7` (Channel stable)
- **Dart**: `3.12.0`
- **Backend / Database**: Supabase (PostgreSQL, Auth, Row-Level Security)
- **REST APIs**: GitHub REST API v3
- **State & Storage**: Flutter StatefulWidget + SharedPreferences (`snj_theme_mode`)
- **Android Target**: Android SDK 37 (API 21+ compatible), Kotlin DSL, Java 17

---

## 🔐 Supabase Configuration

- **Project URL**: `https://dvyzoiqhpapuvyjngtdr.supabase.co`
- **Publishable Key**: `sb_publishable_QsFJAiBkNwjkxnY9_pxfRQ_jb72wzcs`
- **Admin User ID**: `1ac260bd-9ffd-4bc4-a277-f7bad5d38348`

### Database Schema (`projects` table)

```sql
create table if not exists public.projects (
  id            uuid        default gen_random_uuid() primary key,
  title         text        not null,
  description   text        not null,
  tech_stack    text        default '',
  github_url    text        default '',
  demo_url      text        default '',
  image_url     text        default '',
  is_featured   boolean     default false,
  is_published  boolean     default true,
  display_order integer     default 0,
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);

-- Row-Level Security Policies
alter table public.projects enable row level security;

-- Public read access for published projects
create policy "Public: read published projects"
  on public.projects for select
  using (is_published = true);

-- Admin full access
create policy "Admin: full access"
  on public.projects for all
  using (auth.uid() = '1ac260bd-9ffd-4bc4-a277-f7bad5d38348');
```

---

## 🧪 Testing & Quality Assurance

All static analysis and test suites run cleanly:

```bash
# Run static analysis
flutter analyze

# Run unit and widget tests
flutter test
```

**Results**:
- `flutter analyze`: **0 issues found**
- `flutter test`: **14/14 tests passed** (covering Home, Projects, Contact, About, Settings, GitHub Repos, and serialization models).

---

## 🚀 Build Instructions

### 1. Android Release APK

```bash
# Single Universal APK
flutter build apk --release

# Split by ABI (Recommended for smaller downloads: ~15MB each)
flutter build apk --release --split-per-abi
```

**Generated Artifact**:
- `build/app/outputs/flutter-apk/app-release.apk` (Tested & verified)

### 2. Web Release Build

```bash
flutter build web --release
```

**Generated Artifact**:
- `build/web/` (Ready for deployment to Firebase Hosting, Vercel, Netlify, or GitHub Pages).

---

## 📱 Installation on Android Device

1. Connect your Android device via USB with USB Debugging enabled.
2. Run:
   ```bash
   flutter install
   ```
   Or copy `build/app/outputs/flutter-apk/app-release.apk` directly to your phone and open it to install.
=======
# snj_devfolio
>>>>>>> 70840842e5cd089975d028134951a77e993af43f
