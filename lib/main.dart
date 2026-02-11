import 'package:eduguide/authentication/onboarding.dart';
import 'package:eduguide/features/admin_forum_page.dart';
import 'package:eduguide/features/ai_prediction.dart';
import 'package:eduguide/features/application_status.dart';
import 'package:eduguide/features/courses_page.dart';
import 'package:eduguide/features/university_page.dart';
import 'package:eduguide/pages/home_page.dart';
import 'package:eduguide/profile/about_page.dart';
import 'package:eduguide/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpmbHZrZHBoY254c3Z2ZnVuY2FxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA2NDI5NDMsImV4cCI6MjA4NjIxODk0M30.ouyWkzwMSx0uRYqPmUecsdL-_bHETRcRZvDnLf6DHaM",
    url: "https://jflvkdphcnxsvvfuncaq.supabase.co",
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        routes: {
    '/home': (context) => HomeScreen(),
    '/profile': (context) => const ProfilePage(),
    '/university': (context) => const UniversityPage(),
    '/courses': (context) => const CoursesPage(),
    '/ai': (context) => const AIPredictionPage(),
    '/status': (context) => const ApplicationStatusPage(),
    '/forum': (context) => const AdminForumPage(),
    '/about': (context) => const AboutPage(),
  },
      debugShowCheckedModeBanner: false, home:Onboarding());
  }
}
