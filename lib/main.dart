import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'pages/login_selection_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Correct Firebase initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: 'https://hpkjomrgtmipyydslelf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhwa2pvbXJndG1pcHl5ZHNsZWxmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjcwODA2MTcsImV4cCI6MjA4MjY1NjYxN30.6wyc9BexBUxmrWPSty3YUkYv1F-6CtHumSaYU7ABZSI',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginSelectionPage(),
    );
  }
}