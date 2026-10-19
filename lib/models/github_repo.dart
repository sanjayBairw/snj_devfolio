/// Model representing a GitHub repository.
class GithubRepo {
  const GithubRepo({
    required this.name,
    required this.description,
    required this.language,
    required this.stargazersCount,
    required this.forksCount,
    required this.htmlUrl,
    this.updatedAt,
    this.topics = const [],
  });

  final String name;
  final String description;
  final String language;
  final int stargazersCount;
  final int forksCount;
  final String htmlUrl;
  final DateTime? updatedAt;
  final List<String> topics;

  factory GithubRepo.fromJson(Map<String, dynamic> json) {
    return GithubRepo(
      name: json['name'] as String? ?? 'Unnamed Repo',
      description: json['description'] as String? ?? 'No description provided.',
      language: json['language'] as String? ?? 'Dart',
      stargazersCount: (json['stargazers_count'] as num?)?.toInt() ?? 0,
      forksCount: (json['forks_count'] as num?)?.toInt() ?? 0,
      htmlUrl: json['html_url'] as String? ?? 'https://github.com/sanjayBairw',
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      topics: (json['topics'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'language': language,
        'stargazers_count': stargazersCount,
        'forks_count': forksCount,
        'html_url': htmlUrl,
        'updated_at': updatedAt?.toIso8601String(),
        'topics': topics,
      };
}

/// Model representing a GitHub user profile overview.
class GithubUser {
  const GithubUser({
    required this.login,
    required this.name,
    required this.avatarUrl,
    required this.bio,
    required this.publicRepos,
    required this.followers,
    required this.following,
    this.starsCount = 0,
  });

  final String login;
  final String name;
  final String avatarUrl;
  final String bio;
  final int publicRepos;
  final int followers;
  final int following;
  final int starsCount;

  factory GithubUser.fromJson(Map<String, dynamic> json, {int starsCount = 0}) {
    return GithubUser(
      login: json['login'] as String? ?? 'sanjayBairw',
      name: json['name'] as String? ?? 'Sanjay Bairwa',
      avatarUrl: json['avatar_url'] as String? ??
          'https://avatars.githubusercontent.com/u/188983849?v=4',
      bio: json['bio'] as String? ??
          'Open source contributor & full-stack Flutter developer',
      publicRepos: (json['public_repos'] as num?)?.toInt() ?? 13,
      followers: (json['followers'] as num?)?.toInt() ?? 0,
      following: (json['following'] as num?)?.toInt() ?? 1,
      starsCount: starsCount,
    );
  }
}

/// Fallback repositories matching the user's verified GitHub profile
const List<GithubRepo> kFallbackGithubRepos = [
  GithubRepo(
    name: 'signspeak-ai-service',
    description:
        'Sign Language Communication & gesture recognition backend service.',
    language: 'Python',
    stargazersCount: 0,
    forksCount: 0,
    htmlUrl: 'https://github.com/sanjayBairw/signspeak-ai-service',
    topics: ['python', 'mediapipe', 'ai', 'flutter'],
  ),
  GithubRepo(
    name: 'vidforensic',
    description:
        'Video forensic analysis pipeline for detecting frame corruption, duplicate frames, and freeze artifacts.',
    language: 'Dart',
    stargazersCount: 0,
    forksCount: 0,
    htmlUrl: 'https://github.com/sanjayBairw/vidforensic',
    topics: ['dart', 'flutter', 'video-analysis'],
  ),
  GithubRepo(
    name: 'TaskManager',
    description:
        'Production-ready Flutter Task Manager App with API integration, Provider state management, and clean architecture.',
    language: 'Dart',
    stargazersCount: 0,
    forksCount: 0,
    htmlUrl: 'https://github.com/sanjayBairw/TaskManager',
    topics: ['flutter', 'dart', 'provider', 'clean-architecture'],
  ),
  GithubRepo(
    name: 'TaskFlow',
    description:
        'A clean task-management app focused on intuitive mobile UX, search, filtering, and API-ready architecture.',
    language: 'TypeScript',
    stargazersCount: 0,
    forksCount: 0,
    htmlUrl: 'https://github.com/sanjayBairw/TaskFlow',
    topics: ['typescript', 'taskflow', 'api'],
  ),
  GithubRepo(
    name: 'ordertracker',
    description:
        'Real-time order tracking and management mobile application built with Flutter.',
    language: 'Dart',
    stargazersCount: 0,
    forksCount: 0,
    htmlUrl: 'https://github.com/sanjayBairw/ordertracker',
    topics: ['flutter', 'dart', 'tracker'],
  ),
  GithubRepo(
    name: 'youtube-backend',
    description:
        'RESTful API backend service for video streaming and metadata management.',
    language: 'JavaScript',
    stargazersCount: 0,
    forksCount: 0,
    htmlUrl: 'https://github.com/sanjayBairw/youtube-backend',
    topics: ['javascript', 'nodejs', 'api'],
  ),
];
