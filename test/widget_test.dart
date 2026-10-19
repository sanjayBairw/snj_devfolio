// Widget & unit tests for SNJ Devfolio.
// Run with: flutter test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:snj_devfolio/constants.dart';
import 'package:snj_devfolio/models/github_repo.dart';
import 'package:snj_devfolio/models/project.dart';
import 'package:snj_devfolio/screens/home_screen.dart';
import 'package:snj_devfolio/screens/contact_screen.dart';
import 'package:snj_devfolio/screens/projects_screen.dart';
import 'package:snj_devfolio/screens/about_screen.dart';
import 'package:snj_devfolio/screens/settings_screen.dart';
import 'package:snj_devfolio/screens/github_repos_screen.dart';
import 'package:snj_devfolio/screens/project_details_screen.dart';
import 'package:snj_devfolio/models/resume_data.dart';
import 'package:snj_devfolio/screens/resume_details_screen.dart';
import 'package:snj_devfolio/services/resume_parser_service.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────
Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      home: child,
    );

void main() {
  // ── Home screen ─────────────────────────────────────────────────────────────
  group('HomeScreen', () {
    testWidgets('shows developer name, role, and available status',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(body: HomeScreen(onNavigate: (_) {}))),
      );
      await tester.pump();

      expect(find.text(kDevName), findsOneWidget);
      expect(find.textContaining('Flutter Developer'), findsOneWidget);
      expect(find.text('Available for Opportunities'), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) =>
            w is RichText &&
            w.text.toPlainText().contains('solve real problems.')),
        findsOneWidget,
      );
    });

    testWidgets('View Projects button triggers onNavigate callback',
        (WidgetTester tester) async {
      int navigatedTo = -1;
      await tester.pumpWidget(
        _wrap(Scaffold(
          body: HomeScreen(onNavigate: (i) => navigatedTo = i),
        )),
      );
      await tester.pump();

      await tester.tap(find.text('View Projects'));
      expect(navigatedTo, 1);
    });

    testWidgets('View Resume and Featured Projects are displayed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(body: HomeScreen(onNavigate: (_) {}))),
      );
      await tester.pump();

      expect(find.text('View Resume'), findsOneWidget);
      expect(find.text('Featured Projects'), findsOneWidget);
    });
  });

  // ── Contact screen ───────────────────────────────────────────────────────────
  group('ContactScreen', () {
    testWidgets('renders section heading and direct contact options',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const Scaffold(body: ContactScreen())));
      await tester.pump();

      expect(find.text('Let\'s Connect!'), findsOneWidget);
      expect(find.text('Email Me'), findsOneWidget);
      expect(find.text('LinkedIn'), findsOneWidget);
      expect(find.text('GitHub'), findsOneWidget);
      expect(find.text('X (Twitter)'), findsOneWidget);
    });

    testWidgets('renders GitHub link with correct profile handle',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const Scaffold(body: ContactScreen())));
      await tester.pump();

      expect(find.text('GitHub'), findsOneWidget);
      expect(find.text('github.com/sanjayBairw'), findsOneWidget);
    });

    testWidgets('renders direct message form fields',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(const Scaffold(body: ContactScreen())));
      await tester.pump();

      expect(find.text('Your name'), findsOneWidget);
      expect(find.text('Your email'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
      expect(find.text('Open email to send'), findsOneWidget);
    });

    testWidgets('shows validation errors on empty submit',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(const Scaffold(body: ContactScreen())));
      await tester.pump();

      await tester.tap(find.text('Open email to send'));
      await tester.pump();

      expect(find.text('Enter your name'), findsOneWidget);
      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(find.text('Write a short message'), findsOneWidget);
    });

    testWidgets('accepts valid form input without showing errors',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(const Scaffold(body: ContactScreen())));
      await tester.pump();

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Your name'), 'Test Recruiter');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Your email'), 'recruiter@tech.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Message'),
          'Hello Sanjay, we would love to connect with you regarding a Flutter role.');

      await tester.pump();

      expect(find.text('Enter your name'), findsNothing);
      expect(find.text('Enter a valid email'), findsNothing);
    });
  });

  // ── Projects screen ──────────────────────────────────────────────────────────
  group('ProjectsScreen', () {
    testWidgets('shows title and horizontal filter chips',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const Scaffold(body: ProjectsScreen())));
      await tester.pumpAndSettle();

      expect(find.text('My Projects'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Featured'), findsWidgets);
      expect(find.text('GitHub'), findsWidgets);
      expect(find.text('Supabase'), findsWidgets);
    });

    testWidgets('shows fallback curated projects when Supabase offline',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const Scaffold(body: ProjectsScreen())));
      await tester.pumpAndSettle();

      expect(find.text('SignSpeak'), findsOneWidget);
      expect(find.text('SNJ Devfolio'), findsOneWidget);
    });
  });

  // ── About screen ─────────────────────────────────────────────────────────────
  group('AboutScreen', () {
    testWidgets('renders developer details, skills and education',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(const Scaffold(body: AboutScreen())));
      await tester.pump();

      expect(find.text('About Me'), findsOneWidget);
      expect(find.text('My Skills'), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
      expect(find.text('Firebase'), findsOneWidget);
      expect(find.text('Rest API'), findsOneWidget);
      expect(find.text('Education'), findsOneWidget);
    });
  });

  // ── Settings screen ──────────────────────────────────────────────────────────
  group('SettingsScreen', () {
    testWidgets('renders theme options and app information',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const Scaffold(body: SettingsScreen())));
      await tester.pump();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.textContaining('Dark'), findsOneWidget);
      expect(find.textContaining('Light'), findsOneWidget);
      expect(find.text('App Information'), findsOneWidget);
    });
  });

  // ── Project Details screen ──────────────────────────────────────────────────
  group('ProjectDetailsScreen', () {
    testWidgets('renders featured project badges without overflow on narrow screens',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final featuredProject = kSampleProjects.firstWhere((p) => p.isFeatured);
      await tester.pumpWidget(_wrap(ProjectDetailsScreen(project: featuredProject)));
      await tester.pumpAndSettle();

      expect(find.text(featuredProject.title), findsAtLeastNWidgets(1));
      expect(find.text('★ Featured Project'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('Key Highlights & Features'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
  group('GithubReposScreen', () {
    testWidgets('renders GitHub Repositories title and search input',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const GithubReposScreen()));
      await tester.pumpAndSettle();

      expect(find.text('GitHub Repositories'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  // ── Models & Serialization ───────────────────────────────────────────────────
  group('Models', () {
    test('Project model serialization works correctly', () {
      final p = Project(
        title: 'Test App',
        description: 'Test description for unit test',
        techStack: 'Flutter • Dart',
        isFeatured: true,
      );

      final json = p.toJson();
      expect(json['title'], 'Test App');
      expect(json['is_featured'], true);

      final reconstructed = Project.fromJson(json);
      expect(reconstructed.title, 'Test App');
      expect(reconstructed.isFeatured, true);
    });

    test('GithubRepo model serialization works correctly', () {
      const repo = GithubRepo(
        name: 'flutter-test-repo',
        description: 'Open source repository',
        language: 'Dart',
        stargazersCount: 42,
        forksCount: 7,
        htmlUrl: 'https://github.com/sanjayBairw/test',
      );

      final json = repo.toJson();
      expect(json['name'], 'flutter-test-repo');
      expect(json['stargazers_count'], 42);

      final reconstructed = GithubRepo.fromJson(json);
      expect(reconstructed.name, 'flutter-test-repo');
      expect(reconstructed.stargazersCount, 42);
      expect(reconstructed.language, 'Dart');
    });

    test('ResumeData serialization and deserialization works correctly', () {
      final resume = ResumeParserService.getDemoResume();
      expect(resume.fullName, isNotEmpty);
      expect(resume.skills, contains('Flutter'));
      expect(resume.skills, contains('Dart'));
      expect(resume.experiences, isNotEmpty);
      expect(resume.educations, isNotEmpty);

      final json = resume.toJson();
      final parsed = ResumeData.fromJson(json);

      expect(parsed.fullName, resume.fullName);
      expect(parsed.email, resume.email);
      expect(parsed.skills.length, resume.skills.length);
      expect(parsed.experiences.length, resume.experiences.length);
    });

    test('ResumeParserService extracts details from raw text resume', () {
      const sampleResume = '''
Johnathan Doe
Senior Flutter Engineer
Email: johnathan.doe@example.com
Phone: +1 (555) 123-4567
LinkedIn: https://linkedin.com/in/jdoe
GitHub: https://github.com/jdoe
Website: https://jdoe.dev

Professional Summary
Passionate software engineer building robust cross-platform mobile and web applications with Flutter and Dart.

Skills
Flutter, Dart, Firebase, Supabase, Git, REST API, Docker, CI/CD

Work Experience
Lead Mobile Developer - Acme Corp
Jan 2022 - Present
- Architected production Flutter apps serving over 250,000 active users.
- Reduced cold startup time by 45% using optimized dependency injection.

Flutter Developer - Tech Innovations
Jun 2020 - Dec 2021
- Built enterprise client mobile dashboard using Supabase and Flutter BLoC.

Education
Bachelor of Science in Computer Science - University of Technology
2016 - 2020

Projects
CryptoTrack Portfolio App
Live crypto tracking mobile application with real-time WebSockets and charts.

Certifications
Google Certified Associate Android Developer
''';

      final parsed = ResumeParserService.parseText(sampleResume);

      expect(parsed.fullName, 'Johnathan Doe');
      expect(parsed.headline, contains('Flutter Engineer'));
      expect(parsed.email, 'johnathan.doe@example.com');
      expect(parsed.phone, contains('555'));
      expect(parsed.linkedinUrl, 'https://linkedin.com/in/jdoe');
      expect(parsed.githubUrl, 'https://github.com/jdoe');
      expect(parsed.skills, contains('Flutter'));
      expect(parsed.skills, contains('Dart'));
      expect(parsed.skills, contains('Firebase'));
      expect(parsed.skills, contains('Supabase'));
      expect(parsed.experiences, isNotEmpty);
      expect(parsed.educations, isNotEmpty);
      expect(parsed.projects, isNotEmpty);
      expect(parsed.certifications, isNotEmpty);
    });
  });

  // ── Resume View UI Triggers ─────────────────────────────────────────────────
  group('Resume View UI Triggers', () {
    testWidgets('HomeScreen shows View Resume button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(body: HomeScreen(onNavigate: (_) {}))),
      );
      await tester.pump();

      expect(find.text('View Resume'), findsOneWidget);
    });

    testWidgets('AboutScreen shows View Resume button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(const Scaffold(body: AboutScreen())),
      );
      await tester.pump();

      expect(find.byTooltip('View Resume'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('View Resume'),
        200,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('View Resume'), findsOneWidget);
    });
  });

  // ── Resume Document Viewer ──────────────────────────────────────────────────
  group('ResumeDetailsScreen', () {
    testWidgets('renders official resume document with links and controls',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(const ResumeDetailsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text(kResumeFileName), findsOneWidget);
      expect(find.textContaining('Official Document'), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.text('Download PDF'), findsOneWidget);
      expect(find.textContaining('Links'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}


