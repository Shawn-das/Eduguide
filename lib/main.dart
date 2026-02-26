import 'package:app_links/app_links.dart';
import 'package:eduguide/authentication/onboarding.dart';
import 'package:eduguide/authentication/reset_password_page.dart';
import 'package:eduguide/features/about_us_page.dart';
import 'package:eduguide/features/ai_prediction.dart';
import 'package:eduguide/features/application_status.dart';
import 'package:eduguide/features/courses_page.dart';
import 'package:eduguide/features/suggestion_based_on_profile.dart';
import 'package:eduguide/features/university_page.dart';
import 'package:eduguide/pages/home_page.dart';
import 'package:eduguide/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpmbHZrZHBoY254c3Z2ZnVuY2FxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA2NDI5NDMsImV4cCI6MjA4NjIxODk0M30.ouyWkzwMSx0uRYqPmUecsdL-_bHETRcRZvDnLf6DHaM",
    url: "https://jflvkdphcnxsvvfuncaq.supabase.co",
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() async {
    _appLinks = AppLinks();

    // Case 1: App already open, link clicked
    _appLinks.uriLinkStream.listen((uri) {
      debugPrint('DEEPLINK stream: $uri');
      _handleDeepLink(uri);
    });

    // Case 2: App was closed, link opened the app
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      debugPrint('DEEPLINK initial: $initialUri');
      _handleDeepLink(initialUri);
    }
  }

  Future<void> _handleDeepLink(Uri uri) async {
    debugPrint('DEEPLINK handling: $uri');

    final String? code = uri.queryParameters['code'];

    debugPrint('DEEPLINK code=$code');

    if (code != null) {
      try {
        // Exchange the code for a session (PKCE flow)
        await Supabase.instance.client.auth.exchangeCodeForSession(code);

        debugPrint('DEEPLINK session exchanged successfully');

        // Navigate to reset password screen
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
          (route) => false,
        );
      } catch (e) {
        debugPrint('DEEPLINK error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => HomeScreen(),
        '/profile': (context) => const ProfilePage(),
        '/university': (context) => const FindUniversityPage(),
        '/courses': (context) => const FindYourCoursePage(),
        '/ai': (context) => const AIPredictionPage(),
        '/status': (context) => const ApplicationStatusPage(),
        '/about': (context) => const AboutUsPage(),
        '/recommendations': (context) => const RecommendationPage(),
      },
      home: Onboarding(),
    );
  }
}
