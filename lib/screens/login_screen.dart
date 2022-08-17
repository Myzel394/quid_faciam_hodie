import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/extensions/snackbar.dart';
import 'package:quid_faciam_hodie/managers/authentication_manager.dart';
import 'package:quid_faciam_hodie/screens/server_loading_screen.dart';
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
    final localizations = AppLocalizations.of(context)!;

    try {
      await _signUp();
    } catch (error) {
      try {
        await _signIn();
      } catch (error) {
        if (mounted) {
          context.showLongErrorSnackBar(
            message: localizations.loginScreenLoginError,
          );

          emailController.clear();
          passwordController.clear();
        }
        return;
      }
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, ServerLoadingScreen.ID);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.loginScreenTitle),
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
            Text(localizations.loginScreenHelpText),
            const SizedBox(height: MEDIUM_SPACE),
            TextField(
              controller: emailController,
              autofocus: true,
              autofillHints: const [AutofillHints.email],
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: localizations.loginScreenFormEmailLabel,
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: SMALL_SPACE),
            TextField(
              obscureText: true,
              controller: passwordController,
              decoration: InputDecoration(
                labelText: localizations.loginScreenFormPasswordLabel,
                prefixIcon: const Icon(Icons.lock),
              ),
              onSubmitted: (value) => callWithLoading(signIn),
            ),
            const SizedBox(height: MEDIUM_SPACE),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_right),
              label: Text(localizations.loginScreenFormSubmitButton),
              onPressed: isLoading ? null : () => callWithLoading(signIn),
            )
          ],
        ),
      ),
    );
  }
}
