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
      await _signIn();
    } catch (error) {
      try {
        await _signUp();
      } catch (error) {
        if (mounted) {
          if (isMaterial(context))
            context.showLongErrorSnackBar(
              message: localizations.loginScreenLoginFailed,
            );

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
            const SizedBox(height: LARGE_SPACE),
            Text(
              localizations.loginScreenHelpText,
              style: platformThemeData(
                context,
                material: (data) => data.textTheme.bodyText1,
                cupertino: (data) => data.textTheme.textStyle,
              ),
            ),
            const SizedBox(height: MEDIUM_SPACE),
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
            const SizedBox(height: MEDIUM_SPACE),
            PlatformElevatedButton(
              onPressed: isLoading ? null : () => callWithLoading(signIn),
              child: IconButtonChild(
                icon: Icon(context.platformIcons.forward),
                label: Text(localizations.loginScreenFormSubmitButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
