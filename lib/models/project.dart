/// Data model for a portfolio project.
class Project {
  Project({
    this.id,
    required this.title,
    required this.description,
    this.techStack = '',
    this.githubUrl = '',
    this.demoUrl = '',
    this.imageUrl = '',
    this.isFeatured = false,
    this.isPublished = true,
    this.displayOrder = 0,
    this.features = const [],
  });

  /// Supabase row UUID (null until persisted).
  String? id;
  String title;
  String description;

  /// Free-text list of technologies, e.g. "Flutter • Dart • Firebase".
  String techStack;
  String githubUrl;
  String demoUrl;
  String imageUrl;
  bool isFeatured;
  bool isPublished;
  int displayOrder;
  List<String> features;

  // ── Supabase serialisation ──────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'tech_stack': techStack,
        'github_url': githubUrl,
        'demo_url': demoUrl,
        'image_url': imageUrl,
        'is_featured': isFeatured,
        'is_published': isPublished,
        'display_order': displayOrder,
      };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] as String?,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        techStack: json['tech_stack'] as String? ?? '',
        githubUrl: json['github_url'] as String? ?? '',
        demoUrl: json['demo_url'] as String? ?? '',
        imageUrl: json['image_url'] as String? ?? '',
        isFeatured: json['is_featured'] as bool? ?? false,
        isPublished: json['is_published'] as bool? ?? true,
        displayOrder: json['display_order'] as int? ?? 0,
        features: _extractFeatures(json['description'] as String? ?? ''),
      );

  static List<String> _extractFeatures(String desc) {
    if (desc.contains('SignSpeak') || desc.contains('Sign Language')) {
      return [
        'Real-time hand gesture recognition using MediaPipe',
        'AI-assisted translation from sign language to speech and text',
        'Intuitive mobile interface designed with Flutter',
        'Offline low-latency inference on edge devices',
      ];
    } else if (desc.contains('Devfolio') || desc.contains('portfolio')) {
      return [
        'Real-time remote project management with Supabase backend',
        'Supabase Auth & Row Level Security policies for admin operations',
        'Automated GitHub REST API public repository synchronization',
        'Adaptive responsive layout for Android, tablets, and Web',
        'Persistent Dark, Light, and System theme preferences',
      ];
    } else if (desc.contains('Nutrition') || desc.contains('Fitness')) {
      return [
        'AI-driven nutritional analysis and personalised meal suggestions',
        'Automated macronutrient and caloric tracking',
        'Daily habit formation and hydration tracking',
        'Cloud synchronisation with Firebase backend',
      ];
    }
    return [
      'Modular clean architecture with testable components',
      'Smooth animations and responsive layouts',
      'API-ready architecture and robust error handling',
    ];
  }

  Project copyWith({
    String? id,
    String? title,
    String? description,
    String? techStack,
    String? githubUrl,
    String? demoUrl,
    String? imageUrl,
    bool? isFeatured,
    bool? isPublished,
    int? displayOrder,
    List<String>? features,
  }) =>
      Project(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        techStack: techStack ?? this.techStack,
        githubUrl: githubUrl ?? this.githubUrl,
        demoUrl: demoUrl ?? this.demoUrl,
        imageUrl: imageUrl ?? this.imageUrl,
        isFeatured: isFeatured ?? this.isFeatured,
        isPublished: isPublished ?? this.isPublished,
        displayOrder: displayOrder ?? this.displayOrder,
        features: features ?? this.features,
      );
}

// ─── Fallback sample data matching reference screenshot ────────────────────────
final List<Project> kSampleProjects = [
  Project(
    title: 'SignSpeak',
    description:
        'Sign Language Gesture Detection & Communication App with AI.',
    techStack: 'Flutter • Firebase • MediaPipe',
    githubUrl: 'https://github.com/sanjayBairw/signspeak-ai-service',
    isFeatured: true,
    isPublished: true,
    displayOrder: 0,
    features: [
      'Real-time hand gesture recognition with MediaPipe',
      'AI-assisted translation to speech and text',
      'Clean accessibility-focused mobile UI',
      'Low-latency edge processing',
    ],
  ),
  Project(
    title: 'SNJ Devfolio',
    description:
        'My personal developer portfolio app built with Flutter & Supabase integration.',
    techStack: 'Flutter • Supabase • Dart',
    githubUrl: 'https://github.com/sanjayBairw',
    isFeatured: true,
    isPublished: true,
    displayOrder: 1,
    features: [
      'Supabase remote project management & authentication',
      'Dynamic GitHub REST API repository integration',
      'Multi-platform responsive support (Android & Web)',
      'Theme switching with preference persistence',
    ],
  ),
  Project(
    title: 'AI Nutrition Coach',
    description:
        'Personal AI Nutrition & Fitness Coach for a healthier life..',
    techStack: 'Flutter • AI/ML • Firebase',
    githubUrl: 'https://github.com/sanjayBairw',
    isFeatured: false,
    isPublished: true,
    displayOrder: 2,
    features: [
      'Smart macro & calorie calculations',
      'AI-generated meal plans and workout recommendations',
      'Hydration and fasting habit tracker',
    ],
  ),
  Project(
    title: 'Video Forensic Analyzer',
    description:
        'Video analysis pipeline for detecting freezes, duplicate frames, corruption and possible modifications.',
    techStack: 'Python • OpenCV • FFmpeg • FastAPI',
    githubUrl: 'https://github.com/sanjayBairw/vidforensic',
    isFeatured: false,
    isPublished: true,
    displayOrder: 3,
    features: [
      'Frame-by-frame tamper and freeze detection',
      'Automated corruption alerts and integrity hashing',
      'FastAPI streaming endpoints',
    ],
  ),
  Project(
    title: 'TaskFlow',
    description:
        'A clean task-management app focused on intuitive mobile UX, search, filtering, and API-ready architecture.',
    techStack: 'Flutter • Dart • REST API',
    githubUrl: 'https://github.com/sanjayBairw/TaskFlow',
    isFeatured: false,
    isPublished: true,
    displayOrder: 4,
    features: [
      'Clean state management and offline persistence',
      'Prioritisation filters and due date notifications',
    ],
  ),
];
