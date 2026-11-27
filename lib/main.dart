import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/destinations/data/destination_repository.dart';
import 'features/destinations/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');

  String? initError;
  if (SupabaseConfig.isConfigured) {
    try {
      await SupabaseConfig.initialize();
    } catch (e) {
      initError = e.toString();
    }
  } else {
    initError =
        'SUPABASE_URL dan SUPABASE_ANON_KEY belum dikonfigurasi.\n'
        'Salin env.example.json menjadi env.json lalu jalankan:\n'
        'flutter run --dart-define-from-file=env.json';
  }

  runApp(WisataDaerahApp(initError: initError));
}

class WisataDaerahApp extends StatelessWidget {
  const WisataDaerahApp({super.key, this.initError});

  final String? initError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jelajah Wisata Lampung',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: initError != null
          ? _ConfigErrorScreen(message: initError!)
          : HomeScreen(repository: SupabaseDestinationRepository()),
    );
  }
}

class _ConfigErrorScreen extends StatelessWidget {
  const _ConfigErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.settings_outlined, size: 56, color: Colors.teal),
              const SizedBox(height: 16),
              const Text(
                'Konfigurasi Supabase Diperlukan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF475569)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
