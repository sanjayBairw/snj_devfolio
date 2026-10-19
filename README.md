# SNJ Devfolio — Premium Developer Portfolio

A developer portfolio for **Sanjay Bairwa** (Flutter Developer | Full Stack Developer), featuring a dark neon aesthetic, GitHub REST API integration, Supabase-powered project management, theme switching, and Android/Web builds.

## Features

| Feature | Description |
|---|---|
| Splash screen | Animated logo reveal and loading animation |
| Home | Developer introduction, opportunity status, project highlights, and resume link |
| Projects | Search, filters, project cards, and quick links |
| GitHub repositories | GitHub REST API integration, repository search, language tags, stars, and forks |
| Project details | Project highlights, technology tags, repository and demo links |
| About | Bio, skills, and education |
| Admin panel | Supabase authentication and row-level security for project management |
| Contact | Email, LinkedIn, GitHub, X, and contact form |
| Settings | System/light/dark theme selection and privacy dialogs |
| Responsive web | Desktop-friendly layout and navigation |

## Tech Stack

- Flutter and Dart
- Supabase (PostgreSQL, Auth, Row-Level Security)
- GitHub REST API
- SharedPreferences
- Android SDK, Kotlin DSL, Java 17

## Supabase Setup

Keep project-specific credentials out of this README. Configure the Supabase URL and publishable key in your local app configuration. A publishable key may be used by a client app only when database access is protected by correctly configured Row-Level Security (RLS) policies. Never commit a `sb_secret_...` key or legacy `service_role` key.

### `projects` table

Run the following SQL in the Supabase SQL Editor if the table and policies have not already been created. If you already have policies with these names, review them before rerunning the policy statements.

```sql
create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null,
  tech_stack text default '',
  github_url text default '',
  demo_url text default '',
  image_url text default '',
  is_featured boolean default false,
  is_published boolean default true,
  display_order integer default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.projects enable row level security;

-- Public users can read published projects.
create policy "Public: read published projects"
  on public.projects for select
  using (is_published = true);

-- Replace YOUR_ADMIN_USER_UUID with the UUID of the authorized admin account.
-- This policy grants that authenticated user full access to project rows.
create policy "Admin: full access"
  on public.projects for all
  to authenticated
  using (auth.uid() = 'YOUR_ADMIN_USER_UUID'::uuid)
  with check (auth.uid() = 'YOUR_ADMIN_USER_UUID'::uuid);
```

**Security note:** Replace `YOUR_ADMIN_USER_UUID` with the intended admin user's Auth UID before running the admin policy. Do not use the service-role key in Flutter or any other client app. Verify the policies in Supabase before making the project public.

## Testing

Run these commands from the project directory:

```bash
flutter analyze
flutter test
```

## Build Instructions

### Android release APK

```bash
flutter build apk --release
```

APK output:

`build/app/outputs/flutter-apk/app-release.apk`

For smaller ABI-specific APKs:

```bash
flutter build apk --release --split-per-abi
```

### Web release build

```bash
flutter build web --release
```

Web output:

`build/web/`

Deploy the web build using a hosting provider such as Firebase Hosting, Vercel, Netlify, or GitHub Pages.

## Install on Android

Connect an Android device with USB debugging enabled and run:

```bash
flutter install
```

Alternatively, copy `build/app/outputs/flutter-apk/app-release.apk` to the device and open it to install.
