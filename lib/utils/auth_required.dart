import 'package:flutter/material.dart';
import 'package:quid_faciam_hodie/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRequiredState<T extends StatefulWidget>
    extends SupabaseAuthRequiredState<T> {
  @override
  void onUnauthenticated() {
    if (mounted) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(LoginScreen.ID, (route) => false);
    }
  }
}
