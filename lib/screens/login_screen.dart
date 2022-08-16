import 'package:flutter/material.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/extensions/snackbar.dart';
import 'package:quid_faciam_hodie/managers/authentication_manager.dart';
import 'package:quid_faciam_hodie/screens/main_screen.dart';
import 'package:quid_faciam_hodie/utils/loadable.dart';
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

  Future<void> _signUp() async {
    final response = await supabase.auth.signUp(
      emailController.text.trim(),
      passwordController.text,
    );

    final error = response.error;

    if (error != null) {
      throw Exception(error);
    }
  }

  Future<void> _signIn() async {
    final response = await supabase.auth.signIn(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    final error = response.error;

    if (error != null) {
      throw Exception(error);
    }
  }

  Future<void> signIn() async {
    try {
      await _signUp();
    } catch (error) {
      try {
        await _signIn();
      } catch (error) {
        if (mounted) {
          context.showLongErrorSnackBar(message: 'Invalid password or email');

          emailController.clear();
          passwordController.clear();
        }
        return;
      }
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, MainScreen.ID);
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
            TextField(
              controller: emailController,
              autofocus: true,
              autofillHints: const [AutofillHints.email],
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: SMALL_SPACE),
            TextField(
              obscureText: true,
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              onSubmitted: (value) => callWithLoading(signIn),
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
