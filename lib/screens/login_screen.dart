import 'package:flutter/material.dart';
import 'package:share_location/constants/spacing.dart';
import 'package:share_location/extensions/snackbar.dart';
import 'package:share_location/managers/authentication_manager.dart';
import 'package:share_location/screens/main_screen.dart';
import 'package:share_location/utils/loadable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class LoginScreen extends StatefulWidget {
  static const ID = 'login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends AuthState<LoginScreen> with Loadable {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  Future<bool> doesEmailExist() async {
    // TODO: SECURE PROFILE READ ACCESS TO ONLY ALLOW ACCESS TO EMAIL ADDRESSES
    final response = await supabase
        .from('profiles')
        .select()
        .match({'username': emailController.text.trim()}).execute();

    return response.data.isNotEmpty;
  }

  Future<void> signIn() async {
    if (await doesEmailExist()) {
      // Login User
      final response = await supabase.auth.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      final error = response.error;

      if (mounted) {
        if (error != null) {
          context.showErrorSnackBar(message: error.message);
        } else {
          emailController.clear();
          passwordController.clear();
        }
      }
    } else {
      // Sign up User
      final response = await supabase.auth.signUp(
        emailController.text.trim(),
        passwordController.text,
      );

      final error = response.error;

      if (mounted) {
        if (error != null) {
          context.showErrorSnackBar(message: error.message);
        } else {
          Navigator.pushReplacementNamed(context, MainScreen.ID);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(MEDIUM_SPACE),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Login',
              style: theme.textTheme.headline1,
            ),
            const SizedBox(height: LARGE_SPACE),
            const Text(
              'Sign in to your account. If you do not have one already, we will automatically set up one for you.',
            ),
            const SizedBox(height: MEDIUM_SPACE),
            TextFormField(
              controller: emailController,
              autofocus: true,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: SMALL_SPACE),
            TextFormField(
              obscureText: true,
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: MEDIUM_SPACE),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_right),
              label: const Text('Login'),
              onPressed: isLoading ? null : () => callWithLoading(signIn),
            )
          ],
        ),
      ),
    );
  }
}
