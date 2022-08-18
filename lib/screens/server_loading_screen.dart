import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/managers/global_values_manager.dart';
import 'package:quid_faciam_hodie/models/memories.dart';
import 'package:quid_faciam_hodie/screens/grant_permission_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'empty_screen.dart';
import 'main_screen.dart';
import 'server_loading_screen/dot_animation.dart';
import 'welcome_screen.dart';

class ServerLoadingScreen extends StatefulWidget {
  static const ID = '/';

  final String? nextScreen;

  const ServerLoadingScreen({
    Key? key,
    this.nextScreen,
  }) : super(key: key);

  @override
  State<ServerLoadingScreen> createState() => _ServerLoadingScreenState();
}

class _ServerLoadingScreenState extends State<ServerLoadingScreen> {
  @override
  void initState() {
    super.initState();

    load();
  }

  Future<void> load() async {
    if (!(await GlobalValuesManager.hasGrantedPermissions())) {
      Navigator.pushReplacementNamed(
        context,
        GrantPermissionScreen.ID,
      );
    }

    await GlobalValuesManager.watchForInitialization();

    final memories = context.read<Memories>();
    final session = Supabase.instance.client.auth.session();

    if (session != null) {
      if (!memories.isInitialized) {
        await memories.initialize();
      }

      if (!mounted) {
        return;
      }

      if (widget.nextScreen == null) {
        Navigator.pushNamed(
          context,
          MainScreen.ID,
        );
      } else {
        if (memories.memories.isEmpty) {
          Navigator.pushReplacementNamed(
            context,
            EmptyScreen.ID,
          );
        } else {
          Navigator.pushReplacementNamed(
            context,
            widget.nextScreen!,
          );
        }
      }
    } else {
      Navigator.pushReplacementNamed(
        context,
        WelcomeScreen.ID,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.cloud,
              size: 60,
              color: Colors.white,
            ),
            const SizedBox(height: SMALL_SPACE),
            const DotAnimation(
              initialFadeInDelay: Duration.zero,
              fadeInDuration: Duration(seconds: 1),
              fadeOutDuration: Duration(seconds: 1),
              fadeInDelay: Duration(seconds: 4),
              fadeOutDelay: Duration.zero,
            ),
            const DotAnimation(
              initialFadeInDelay: Duration(seconds: 2),
              fadeInDuration: Duration(seconds: 1),
              fadeOutDuration: Duration(seconds: 1),
              fadeInDelay: Duration(seconds: 4),
              fadeOutDelay: Duration.zero,
            ),
            const DotAnimation(
              initialFadeInDelay: Duration(seconds: 4),
              fadeInDuration: Duration(seconds: 1),
              fadeOutDuration: Duration(seconds: 1),
              fadeInDelay: Duration(seconds: 4),
              fadeOutDelay: Duration.zero,
            ),
            const SizedBox(height: SMALL_SPACE),
            const Icon(
              Icons.phone_android_rounded,
              size: 60,
              color: Colors.white,
            ),
            const SizedBox(height: LARGE_SPACE),
            Text(
              localizations.serverLoadingScreenDescription,
              style: platformThemeData(
                context,
                material: (data) => data.textTheme.bodyText1!.copyWith(
                  color: Colors.white,
                ),
                cupertino: (data) => data.textTheme.textStyle.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
