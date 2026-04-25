import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (Use your own credentials)
  // await Supabase.initialize(
  //   url: 'YOUR_SUPABASE_URL',
  //   anonKey: 'YOUR_SUPABASE_ANON_KEY',
  // );

  runApp(
    const ProviderScope(
      child: HaveABreakApp(),
    ),
  );
}

class HaveABreakApp extends StatelessWidget {
  const HaveABreakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'have_a_break',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      // Check for permission to decide initial route
      home: const DashboardScreen(), 
    );
  }
}
