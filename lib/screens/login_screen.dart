import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/extensions/snackbar.dart';
import 'package:quid_faciam_hodie/managers/authentication_manager.dart';
import 'package:quid_faciam_hodie/screens/server_loading_screen.dart';
import 'package:quid_faciam_hodie/utils/loadable.dart';
import 'package:quid_faciam_hodie/widgets/icon_button_child.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'main_screen.dart';

final supabase = Supabase.instance.client;

class LoginScreen extends StatefulWidget {
  static const ID = '/login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends AuthState<LoginScreen> with Loadable {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onAuthenticated(Session session) {
    if (session.user != null) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        MainScreen.ID,
        (_) => false,
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  Future<void> _onAuthenticated() async {
    if (!mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ServerLoadingScreen(),
      ),
    );
  }

  Future<void> signIn() async {
    final localizations = AppLocalizations.of(context)!;

    final response = await supabase.auth.signIn(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    final error = response.error;

    if (!mounted) {
      return;
    }

    if (error != null) {
      context.showLongErrorSnackBar(
        message: localizations.loginScreenLoginFailed,
      );

      passwordController.clear();
      return;
    }

    _onAuthenticated();
  }

  Future<void> signUp() async {
    final localizations = AppLocalizations.of(context)!;

    final response = await supabase.auth.signUp(
      emailController.text.trim(),
      passwordController.text,
    );

    final error = response.error;

    if (!mounted) {
      return;
    }

    if (error != null) {
      context.showLongErrorSnackBar(
        message: localizations.loginScreenSignUpFailed,
      );

      passwordController.clear();
      return;
    }

    _onAuthenticated();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(localizations.loginScreenTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(MEDIUM_SPACE),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              localizations.loginScreenTitle,
              style: platformThemeData(
                context,
                material: (data) => data.textTheme.headline1,
                cupertino: (data) => data.textTheme.navLargeTitleTextStyle,
              ),
            ),
            const Flexible(child: SizedBox(height: LARGE_SPACE)),
            Flexible(
              child: Text(
                localizations.loginScreenHelpText,
                style: platformThemeData(
                  context,
                  material: (data) => data.textTheme.bodyText1,
                  cupertino: (data) => data.textTheme.textStyle,
                ),
              ),
            ),
            const Flexible(child: SizedBox(height: MEDIUM_SPACE)),
            PlatformTextField(
              controller: emailController,
              autofocus: true,
              autofillHints: const [AutofillHints.email],
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              material: (_, __) => MaterialTextFieldData(
                decoration: InputDecoration(
                  labelText: localizations.loginScreenFormEmailLabel,
                  prefixIcon: Icon(context.platformIcons.mail),
                ),
              ),
              cupertino: (_, __) => CupertinoTextFieldData(
                placeholder: localizations.loginScreenFormEmailLabel,
                prefix: Icon(context.platformIcons.mail),
              ),
            ),
            const SizedBox(height: SMALL_SPACE),
            PlatformTextField(
              obscureText: true,
              controller: passwordController,
              material: (_, __) => MaterialTextFieldData(
                decoration: InputDecoration(
                  labelText: localizations.loginScreenFormPasswordLabel,
                  prefixIcon: Icon(context.platformIcons.padLock),
                ),
              ),
              cupertino: (_, __) => CupertinoTextFieldData(
                placeholder: localizations.loginScreenFormPasswordLabel,
                prefix: Icon(context.platformIcons.padLock),
              ),
              onSubmitted: (value) => callWithLoading(signIn),
            ),
            const Flexible(child: SizedBox(height: MEDIUM_SPACE)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                PlatformElevatedButton(
                  onPressed: isLoading ? null : () => callWithLoading(signIn),
                  child: IconButtonChild(
                    icon: Icon(context.platformIcons.forward),
                    label: Text(localizations.loginScreenFormLoginButton),
                  ),
                ),
                PlatformTextButton(
                  onPressed: isLoading ? null : () => callWithLoading(signUp),
                  child: IconButtonChild(
                    icon: Icon(context.platformIcons.add),
                    label: Text(localizations.loginScreenFormSignUpButton),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
