import 'package:supabase_flutter/supabase_flutter.dart';

/// Konfigurasi kredensial Supabase yang disuntikkan melalui `--dart-define`
/// atau `--dart-define-from-file=env.json`.
class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  static Future<void> initialize() async {
    if (!isConfigured) {
      throw StateError(
        'SUPABASE_URL dan SUPABASE_ANON_KEY belum dikonfigurasi. '
        'Jalankan dengan --dart-define-from-file=env.json.',
      );
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }
}
