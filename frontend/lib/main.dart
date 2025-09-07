import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Supabase here
  await Supabase  .initialize(
    url: "https://etdewmgrpvoavevlpibg.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV0ZGV3bWdycHZvYXZldmxwaWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM3MjM4NTcsImV4cCI6MjA2OTI5OTg1N30.F6kD0t-VcM_HVh_v7sL35v1xsNi7BIITRiyt1Yy6Hu0",
  );

  runApp(const AmritaRetrieverApp());
}

class AmritaRetrieverApp extends StatelessWidget {
  const AmritaRetrieverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Amrita Retriever',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Roboto',
      ),
      home: const WelcomeScreen(),
    );
  }
}
