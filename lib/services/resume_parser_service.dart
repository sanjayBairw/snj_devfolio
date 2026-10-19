import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/resume_data.dart';

/// Intelligent Resume Parser Service.
/// Picks PDF or text resume files, extracts raw text, and structures key professional details.
class ResumeParserService {
  /// Open file picker, extract text from selected PDF/TXT/MD, and parse details.
  static Future<ResumeData?> pickAndParseResume() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'md'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;
      Uint8List? fileBytes = file.bytes;

      // Fallback on desktop/mobile if bytes were not directly loaded
      if (fileBytes == null && file.path != null) {
        fileBytes = await File(file.path!).readAsBytes();
      }

      if (fileBytes == null || fileBytes.isEmpty) {
        throw Exception('Could not read file data. Please try another file.');
      }

      final ext = file.extension?.toLowerCase() ?? '';
      String rawText = '';

      if (ext == 'pdf') {
        final PdfDocument document = PdfDocument(inputBytes: fileBytes);
        rawText = PdfTextExtractor(document).extractText();
        document.dispose();
      } else {
        // Plain text / Markdown
        rawText = utf8.decode(fileBytes, allowMalformed: true);
      }

      if (rawText.trim().isEmpty) {
        throw Exception(
            'The selected document contains no readable text. If it is a scanned image, OCR is required.');
      }

      return parseText(
        rawText,
        fileName: file.name,
        fileSizeBytes: file.size,
      );
    } catch (e) {
      debugPrint('ResumeParser error: $e');
      rethrow;
    }
  }

  /// Parses raw text content into a structured [ResumeData] model.
  static ResumeData parseText(
    String rawText, {
    String fileName = 'Uploaded Resume',
    int fileSizeBytes = 0,
  }) {
    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // 1. Contact & Social Extraction
    final email = _extractEmail(rawText);
    final phone = _extractPhone(rawText);
    final linkedinUrl = _extractLinkedin(rawText);
    final githubUrl = _extractGithub(rawText);
    final portfolioUrl = _extractPortfolio(rawText);
    final location = _extractLocation(rawText, lines);

    // 2. Name & Headline Extraction
    final fullName = _extractFullName(lines, email);
    final headline = _extractHeadline(lines, fullName);

    // 3. Skills Extraction
    final skills = _extractSkills(rawText);

    // 4. Section Split & Detailed Extraction
    final sections = _splitIntoSections(rawText);

    final summary = _extractSummary(sections, lines);
    final experiences = _extractExperiences(sections['experience'] ?? '');
    final educations = _extractEducations(sections['education'] ?? '');
    final projects = _extractProjects(sections['projects'] ?? '');
    final certifications = _extractCertifications(sections['certifications'] ?? '');

    return ResumeData(
      fullName: fullName,
      headline: headline,
      email: email,
      phone: phone,
      location: location,
      linkedinUrl: linkedinUrl,
      githubUrl: githubUrl,
      portfolioUrl: portfolioUrl,
      summary: summary,
      skills: skills,
      experiences: experiences,
      educations: educations,
      projects: projects,
      certifications: certifications,
      rawText: rawText,
      fileName: fileName,
      fileSizeBytes: fileSizeBytes,
      uploadedAt: DateTime.now(),
    );
  }

  // ─── Contact Regex Helpers ──────────────────────────────────────────────────

  static String _extractEmail(String text) {
    final emailRegex = RegExp(
      r'[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+',
      caseSensitive: false,
    );
    final match = emailRegex.firstMatch(text);
    return match?.group(0) ?? '';
  }

  static String _extractPhone(String text) {
    final phoneRegex = RegExp(
      r'(?:\+?\d{1,3}[\s-]?)?\(?\d{2,5}\)?[\s.-]?\d{3,5}[\s.-]?\d{3,5}',
    );
    for (final match in phoneRegex.allMatches(text)) {
      final str = match.group(0)?.trim() ?? '';
      final digits = str.replaceAll(RegExp(r'\D'), '');
      if (digits.length >= 10 && digits.length <= 15) {
        return str;
      }
    }
    return '';
  }

  static String _extractLinkedin(String text) {
    final match = RegExp(
      r'(https?:\/\/)?(www\.)?linkedin\.com\/in\/[a-zA-Z0-9_\-\/]+',
      caseSensitive: false,
    ).firstMatch(text);
    if (match != null) {
      var val = match.group(0)!;
      if (!val.startsWith('http')) val = 'https://$val';
      return val;
    }
    return '';
  }

  static String _extractGithub(String text) {
    final match = RegExp(
      r'(https?:\/\/)?(www\.)?github\.com\/[a-zA-Z0-9_\-\/]+',
      caseSensitive: false,
    ).firstMatch(text);
    if (match != null) {
      var val = match.group(0)!;
      if (!val.startsWith('http')) val = 'https://$val';
      return val;
    }
    return '';
  }

  static String _extractPortfolio(String text) {
    final match = RegExp(
      r'(https?:\/\/)?(www\.)?[a-zA-Z0-9_\-]+\.(?:dev|me|io|app|tech)(?:\/[a-zA-Z0-9_\-\.]*)?',
      caseSensitive: false,
    ).firstMatch(text);
    if (match != null) {
      var val = match.group(0)!;
      if (!val.startsWith('http')) val = 'https://$val';
      return val;
    }
    return '';
  }

  static String _extractLocation(String text, List<String> lines) {
    final locationRegex = RegExp(
      r'\b(India|United States|USA|United Kingdom|UK|Germany|Canada|Australia|Singapore|Dubai|Remote|Delhi|Jaipur|Bangalore|Bengaluru|Mumbai|Hyderabad|Pune|Chennai|Kolkata|London|San Francisco|New York)\b',
      caseSensitive: false,
    );
    final match = locationRegex.firstMatch(text);
    if (match != null) {
      // Find line containing this match
      for (final line in lines.take(15)) {
        if (line.toLowerCase().contains(match.group(0)!.toLowerCase())) {
          // If the line is short (typical location line), return it cleaned
          if (line.length < 50 && !line.contains('@')) {
            return line.replaceAll(RegExp(r'[•|,]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
          }
        }
      }
      return match.group(0) ?? '';
    }
    return '';
  }

  // ─── Name & Title Extraction ────────────────────────────────────────────────

  static String _extractFullName(List<String> lines, String email) {
    for (final line in lines.take(6)) {
      final clean = line.replaceAll(RegExp(r'[^a-zA-Z\s]'), '').trim();
      final lower = clean.toLowerCase();

      // Skip generic titles/labels
      if (lower.contains('resume') ||
          lower.contains('curriculum') ||
          lower.contains('vitae') ||
          lower.contains('contact') ||
          lower.contains('profile') ||
          lower.contains('portfolio') ||
          lower.contains('page') ||
          lower.isEmpty) {
        continue;
      }

      // Candidate name is usually 2 to 4 words, alphabetic
      final words = clean.split(RegExp(r'\s+')).where((w) => w.length > 1).toList();
      if (words.length >= 2 && words.length <= 4) {
        return words.map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase()).join(' ');
      }
    }

    // Fallback: derive from email username
    if (email.isNotEmpty) {
      final user = email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z]'), ' ').trim();
      if (user.isNotEmpty) {
        return user.split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '').join(' ');
      }
    }

    return 'Candidate';
  }

  static String _extractHeadline(List<String> lines, String name) {
    final roles = [
      'Flutter Developer',
      'Flutter Engineer',
      'Mobile Developer',
      'Mobile Engineer',
      'Full Stack Developer',
      'Full Stack Engineer',
      'Mobile Application Developer',
      'Software Engineer',
      'Software Developer',
      'Frontend Developer',
      'Backend Developer',
      'Android Developer',
      'iOS Developer',
      'Data Scientist',
      'Machine Learning Engineer',
      'DevOps Engineer',
      'UI/UX Designer',
      'System Architect',
    ];

    for (final line in lines.take(10)) {
      if (line.toLowerCase() == name.toLowerCase()) continue;
      for (final role in roles) {
        if (line.toLowerCase().contains(role.toLowerCase())) {
          return line;
        }
      }
    }

    // Check first 5 lines for any line containing "Developer", "Engineer", "Specialist"
    for (final line in lines.take(6)) {
      if (line.toLowerCase() == name.toLowerCase()) continue;
      if (line.toLowerCase().contains('developer') ||
          line.toLowerCase().contains('engineer') ||
          line.toLowerCase().contains('designer') ||
          line.toLowerCase().contains('architect')) {
        return line.length < 60 ? line : '${line.substring(0, 57)}...';
      }
    }

    return 'Software Developer';
  }

  // ─── Skills Extraction ──────────────────────────────────────────────────────

  static List<String> _extractSkills(String text) {
    const knownSkills = [
      'Flutter', 'Dart', 'Firebase', 'Supabase', 'Python', 'Java', 'Kotlin', 'Swift',
      'JavaScript', 'TypeScript', 'React', 'React Native', 'Node.js', 'Express',
      'FastAPI', 'Django', 'Flask', 'C++', 'C#', 'Go', 'PHP', 'Ruby',
      'HTML', 'CSS', 'Tailwind', 'Bootstrap', 'Sass', 'UI/UX', 'Figma',
      'PostgreSQL', 'MySQL', 'MongoDB', 'SQLite', 'Redis',
      'REST API', 'GraphQL', 'WebSockets', 'gRPC',
      'Git', 'GitHub', 'GitLab', 'Docker', 'Kubernetes', 'AWS', 'GCP', 'Azure',
      'Linux', 'CI/CD', 'OpenCV', 'MediaPipe', 'Machine Learning', 'AI', 'TensorFlow',
      'Provider', 'Riverpod', 'Bloc', 'Redux', 'GetX', 'Clean Architecture', 'MVVM',
      'Unit Testing', 'Widget Testing', 'Agile', 'Scrum'
    ];

    final found = <String>{};
    final lower = text.toLowerCase();

    for (final skill in knownSkills) {
      // Escape for regex
      final pattern = RegExp('\\b${RegExp.escape(skill.toLowerCase())}\\b');
      if (pattern.hasMatch(lower)) {
        found.add(skill);
      }
    }

    return found.toList()..sort();
  }

  // ─── Section Splitter ───────────────────────────────────────────────────────

  static Map<String, String> _splitIntoSections(String text) {
    final sectionKeywords = {
      'summary': [
        'summary',
        'professional summary',
        'profile',
        'about me',
        'career objective',
        'objective'
      ],
      'experience': [
        'experience',
        'work experience',
        'employment history',
        'professional experience',
        'internships',
        'work history'
      ],
      'education': [
        'education',
        'academic background',
        'qualifications',
        'educational qualifications'
      ],
      'projects': [
        'projects',
        'key projects',
        'personal projects',
        'academic projects',
        'selected projects'
      ],
      'skills': [
        'skills',
        'technical skills',
        'core competencies',
        'technologies',
        'skills & tools'
      ],
      'certifications': [
        'certifications',
        'certificates',
        'licenses',
        'achievements',
        'awards'
      ],
    };

    final lines = text.split('\n');
    final Map<String, List<String>> sectionLines = {
      'summary': [],
      'experience': [],
      'education': [],
      'projects': [],
      'skills': [],
      'certifications': [],
    };

    String currentSection = 'summary';

    for (final rawLine in lines) {
      final line = rawLine.trim();
      final lower = line.toLowerCase().replaceAll(RegExp(r'[^a-z\s]'), '').trim();

      // Check if this line is a section header
      String? matchedKey;
      for (final entry in sectionKeywords.entries) {
        if (entry.value.contains(lower)) {
          matchedKey = entry.key;
          break;
        }
      }

      if (matchedKey != null) {
        currentSection = matchedKey;
      } else {
        sectionLines[currentSection]?.add(line);
      }
    }

    return sectionLines.map((k, v) => MapEntry(k, v.join('\n')));
  }

  // ─── Detailed Section Extractors ────────────────────────────────────────────

  static String _extractSummary(Map<String, String> sections, List<String> lines) {
    final sectionText = sections['summary']?.trim() ?? '';
    if (sectionText.isNotEmpty && sectionText.length > 30) {
      return sectionText.split('\n').take(4).join(' ').trim();
    }

    // Fallback: take lines 2 to 5 if they look descriptive
    for (int i = 1; i < lines.length && i < 8; i++) {
      final line = lines[i];
      if (line.length > 50 && !line.contains('@') && !line.contains('http')) {
        return line;
      }
    }

    return 'Motivated developer passionate about building high-performance applications, innovative user experiences, and scalable solutions.';
  }

  static List<ResumeExperience> _extractExperiences(String text) {
    if (text.trim().isEmpty) return [];

    final list = <ResumeExperience>[];
    final blocks = text.split(RegExp(r'\n{2,}'));

    for (final b in blocks) {
      final lines = b.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
      if (lines.isEmpty) continue;

      final role = lines.first;
      String company = lines.length > 1 ? lines[1] : '';
      String duration = '';
      String description = '';

      // Check for year / duration in first few lines
      final durationRegex = RegExp(r'\b(20\d\d|19\d\d|present|current)\b', caseSensitive: false);
      for (int i = 0; i < lines.length && i < 3; i++) {
        if (durationRegex.hasMatch(lines[i])) {
          duration = lines[i];
          break;
        }
      }

      final descLines = lines.skip(company.isNotEmpty ? 2 : 1).where((l) => l != duration).toList();
      description = descLines.join('\n');

      if (role.isNotEmpty) {
        list.add(ResumeExperience(
          role: role,
          company: company,
          duration: duration,
          description: description,
        ));
      }
    }

    return list.take(5).toList();
  }

  static List<ResumeEducation> _extractEducations(String text) {
    if (text.trim().isEmpty) return [];

    final list = <ResumeEducation>[];
    final blocks = text.split(RegExp(r'\n{2,}'));

    for (final b in blocks) {
      final lines = b.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
      if (lines.isEmpty) continue;

      final degree = lines.first;
      final institution = lines.length > 1 ? lines[1] : '';
      String year = '';

      final yearMatch = RegExp(r'\b(19\d\d|20\d\d)\b').firstMatch(b);
      if (yearMatch != null) {
        year = yearMatch.group(0)!;
      }

      final details = lines.skip(institution.isNotEmpty ? 2 : 1).join(' ');

      list.add(ResumeEducation(
        degree: degree,
        institution: institution,
        year: year,
        details: details,
      ));
    }

    return list.take(3).toList();
  }

  static List<ResumeProject> _extractProjects(String text) {
    if (text.trim().isEmpty) return [];

    final list = <ResumeProject>[];
    final blocks = text.split(RegExp(r'\n{2,}'));

    for (final b in blocks) {
      final lines = b.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
      if (lines.isEmpty) continue;

      final title = lines.first;
      String description = '';
      String techStack = '';
      String link = '';

      for (final line in lines.skip(1)) {
        if (line.toLowerCase().contains('github.com') || line.toLowerCase().contains('http')) {
          link = line;
        } else if (line.toLowerCase().contains('tech') || line.toLowerCase().contains('stack') || line.contains('•')) {
          techStack = line;
        } else {
          description = description.isEmpty ? line : '$description $line';
        }
      }

      list.add(ResumeProject(
        title: title,
        description: description,
        techStack: techStack,
        link: link,
      ));
    }

    return list.take(5).toList();
  }

  static List<String> _extractCertifications(String text) {
    if (text.trim().isEmpty) return [];
    return text
        .split('\n')
        .map((l) => l.replaceAll(RegExp(r'^[•\-\*]\s*'), '').trim())
        .where((l) => l.length > 3)
        .take(6)
        .toList();
  }

  /// Provides a realistic sample resume for testing and instant demonstration.
  static ResumeData getDemoResume() {
    const sample = '''
Sanjay Bairwa
Flutter Developer • Full Stack Developer
bairwas361@gmail.com | +91 9876543210 | Jaipur, India
linkedin.com/in/sanjay-buhadiya-812657404 | github.com/sanjayBairw

PROFESSIONAL SUMMARY
Passionate and innovative Flutter Developer with extensive experience building production-grade cross-platform mobile and web applications with Supabase, Firebase, Dart, and Python. Proven track record in state management, clean architecture, and responsive UI design.

CORE COMPETENCIES & TECHNICAL SKILLS
Flutter, Dart, Firebase, Supabase, Python, JavaScript, Node.js, REST API, Git, GitHub, SQLite, Provider, Riverpod, Clean Architecture, UI/UX Design, Docker, Linux, MediaPipe, OpenCV.

WORK EXPERIENCE
Flutter Developer & Open Source Contributor
SNJ Devfolio & Independent Projects | 2023 - Present
• Designed and shipped responsive Flutter portfolio with Supabase backend and Row Level Security.
• Integrated GitHub REST APIs for automatic public repository synchronisation.
• Implemented persistent multi-theme preference management and custom animated UI components.

Mobile Application Developer Intern
Tech Innovators Lab | 2022 - 2023
• Developed cross-platform mobile modules using Flutter, Firebase Authentication, and Cloud Firestore.
• Optimized state management with Provider reducing app load latency by 35%.

PROJECTS
SignSpeak — AI Sign Language Gesture Detector
Flutter, Firebase, MediaPipe, Python
Real-time hand gesture recognition with MediaPipe converting gestures to speech and text with offline inference.

AI Nutrition & Fitness Coach
Flutter, Firebase, AI/ML
Smart macro calculator and personalized meal/workout generator with cloud database synchronization.

Video Forensic Analyzer
Python, OpenCV, FFmpeg, FastAPI
Video integrity and corruption detection pipeline detecting frozen frames, tampering, and cryptographic hashing.

EDUCATION
Bachelor of Technology (B.Tech) in Computer Science & Engineering
Guru Ghasidas Central University | 2021 - 2025
Specialized in Mobile Systems, Algorithms, Distributed Databases & Cloud Computing.

CERTIFICATIONS & ACHIEVEMENTS
• Google Cloud Digital Leader Certification
• Flutter & Dart Certified Application Developer
• Hackathon Winner — Best Accessibility Mobile App (SignSpeak)
''';

    return parseText(
      sample,
      fileName: 'Sanjay_Bairwa_Resume.pdf',
      fileSizeBytes: 245000,
    );
  }
}
