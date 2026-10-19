/// Structured data model representing parsed resume information.
class ResumeData {
  ResumeData({
    required this.fullName,
    required this.headline,
    required this.email,
    required this.phone,
    required this.location,
    required this.linkedinUrl,
    required this.githubUrl,
    required this.portfolioUrl,
    required this.summary,
    required this.skills,
    required this.experiences,
    required this.educations,
    required this.projects,
    required this.certifications,
    required this.rawText,
    required this.fileName,
    required this.fileSizeBytes,
    required this.uploadedAt,
  });

  final String fullName;
  final String headline;
  final String email;
  final String phone;
  final String location;
  final String linkedinUrl;
  final String githubUrl;
  final String portfolioUrl;
  final String summary;
  final List<String> skills;
  final List<ResumeExperience> experiences;
  final List<ResumeEducation> educations;
  final List<ResumeProject> projects;
  final List<String> certifications;
  final String rawText;
  final String fileName;
  final int fileSizeBytes;
  final DateTime uploadedAt;

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'headline': headline,
        'email': email,
        'phone': phone,
        'location': location,
        'linkedinUrl': linkedinUrl,
        'githubUrl': githubUrl,
        'portfolioUrl': portfolioUrl,
        'summary': summary,
        'skills': skills,
        'experiences': experiences.map((e) => e.toJson()).toList(),
        'educations': educations.map((e) => e.toJson()).toList(),
        'projects': projects.map((e) => e.toJson()).toList(),
        'certifications': certifications,
        'fileName': fileName,
        'fileSizeBytes': fileSizeBytes,
        'uploadedAt': uploadedAt.toIso8601String(),
      };

  factory ResumeData.fromJson(Map<String, dynamic> json) => ResumeData(
        fullName: json['fullName'] as String? ?? '',
        headline: json['headline'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        location: json['location'] as String? ?? '',
        linkedinUrl: json['linkedinUrl'] as String? ?? '',
        githubUrl: json['githubUrl'] as String? ?? '',
        portfolioUrl: json['portfolioUrl'] as String? ?? '',
        summary: json['summary'] as String? ?? '',
        skills: (json['skills'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        experiences: (json['experiences'] as List<dynamic>?)
                ?.map((e) =>
                    ResumeExperience.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        educations: (json['educations'] as List<dynamic>?)
                ?.map((e) =>
                    ResumeEducation.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        projects: (json['projects'] as List<dynamic>?)
                ?.map((e) =>
                    ResumeProject.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        certifications: (json['certifications'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        rawText: json['rawText'] as String? ?? '',
        fileName: json['fileName'] as String? ?? '',
        fileSizeBytes: json['fileSizeBytes'] as int? ?? 0,
        uploadedAt: json['uploadedAt'] != null
            ? DateTime.tryParse(json['uploadedAt'].toString()) ??
                DateTime.now()
            : DateTime.now(),
      );
}

class ResumeExperience {
  const ResumeExperience({
    required this.role,
    required this.company,
    required this.duration,
    required this.description,
  });

  final String role;
  final String company;
  final String duration;
  final String description;

  Map<String, dynamic> toJson() => {
        'role': role,
        'company': company,
        'duration': duration,
        'description': description,
      };

  factory ResumeExperience.fromJson(Map<String, dynamic> json) =>
      ResumeExperience(
        role: json['role'] as String? ?? '',
        company: json['company'] as String? ?? '',
        duration: json['duration'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );
}

class ResumeEducation {
  const ResumeEducation({
    required this.degree,
    required this.institution,
    required this.year,
    required this.details,
  });

  final String degree;
  final String institution;
  final String year;
  final String details;

  Map<String, dynamic> toJson() => {
        'degree': degree,
        'institution': institution,
        'year': year,
        'details': details,
      };

  factory ResumeEducation.fromJson(Map<String, dynamic> json) =>
      ResumeEducation(
        degree: json['degree'] as String? ?? '',
        institution: json['institution'] as String? ?? '',
        year: json['year'] as String? ?? '',
        details: json['details'] as String? ?? '',
      );
}

class ResumeProject {
  const ResumeProject({
    required this.title,
    required this.description,
    required this.techStack,
    this.link = '',
  });

  final String title;
  final String description;
  final String techStack;
  final String link;

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'techStack': techStack,
        'link': link,
      };

  factory ResumeProject.fromJson(Map<String, dynamic> json) => ResumeProject(
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        techStack: json['techStack'] as String? ?? '',
        link: json['link'] as String? ?? '',
      );
}

