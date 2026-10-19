import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants.dart';
import '../models/project.dart';

// ─── Supabase client accessor ─────────────────────────────────────────────────

/// Returns the Supabase client, or null if not yet initialised (e.g. in tests).
SupabaseClient? get _client {
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
}

// ─── Auth service ─────────────────────────────────────────────────────────────
class AuthService {
  /// Signed-in user, or null if not initialised / not signed in.
  static User? get currentUser {
    try {
      return _client?.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  static bool get isLoggedIn => currentUser != null;

  /// True only when the signed-in user matches the configured admin UID.
  static bool get isAdmin =>
      isLoggedIn && currentUser!.id == kAdminUserId;

  static Stream<AuthState> get authStateChanges {
    try {
      return _client!.auth.onAuthStateChange;
    } catch (_) {
      return const Stream.empty();
    }
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) throw StateError('Supabase not initialised.');
    return client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    await _client?.auth.signOut();
  }
}

// ─── Project service (Supabase CRUD) ─────────────────────────────────────────
class ProjectService {
  static const String _table = 'projects';

  /// Public: fetch published projects ordered by display_order ASC.
  /// Throws if Supabase is not available — callers should catch and use fallback.
  static Future<List<Project>> fetchPublished() async {
    final client = _client;
    if (client == null) throw StateError('Supabase not initialised.');
    final data = await client
        .from(_table)
        .select()
        .eq('is_published', true)
        .order('display_order', ascending: true);
    return (data as List<dynamic>)
        .map((e) => Project.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Admin: fetch ALL projects (RLS must permit this for the admin uid).
  static Future<List<Project>> fetchAll() async {
    final client = _client;
    if (client == null) throw StateError('Supabase not initialised.');
    final data = await client
        .from(_table)
        .select()
        .order('display_order', ascending: true);
    return (data as List<dynamic>)
        .map((e) => Project.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Insert a new project and return it with the server-assigned id.
  static Future<Project> insert(Project project) async {
    final client = _client;
    if (client == null) throw StateError('Supabase not initialised.');
    final data = await client
        .from(_table)
        .insert(project.toJson())
        .select()
        .single();
    return Project.fromJson(Map<String, dynamic>.from(data as Map));
  }

  /// Update an existing project (requires id to be set).
  static Future<Project> update(Project project) async {
    assert(project.id != null, 'Cannot update a project without an id');
    final client = _client;
    if (client == null) throw StateError('Supabase not initialised.');
    final data = await client
        .from(_table)
        .update({
          ...project.toJson(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', project.id!)
        .select()
        .single();
    return Project.fromJson(Map<String, dynamic>.from(data as Map));
  }

  /// Delete a project by id.
  static Future<void> delete(String id) async {
    final client = _client;
    if (client == null) throw StateError('Supabase not initialised.');
    await client.from(_table).delete().eq('id', id);
  }
}

