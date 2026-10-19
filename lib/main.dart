import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );
  } catch (e) {
    // Supabase init failed — app continues with local fallback data.
    debugPrint('⚠️  Supabase initialisation error: $e');
  }

  runApp(const SNJDevfolioApp());
}
