import 'package:eduguide/authentication/onboarding.dart';
import 'package:eduguide/authentication/reset_password_page.dart';
import 'package:eduguide/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final authState = snapshot.data;
        final session = authState?.session;
        final event = authState?.event;

        //When user clicks the reset link in email, this event fires
        if (event == AuthChangeEvent.passwordRecovery) {
          return const ResetPasswordPage();
        }

        if (session != null) {
          return HomeScreen();
        }

        return const Onboarding();
      },
    );
  }
}
