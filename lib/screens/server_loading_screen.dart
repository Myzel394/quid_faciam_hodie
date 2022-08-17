import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/managers/global_values_manager.dart';
import 'package:quid_faciam_hodie/models/memories.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'main_screen.dart';
import 'server_loading_screen/dot_animation.dart';
import 'welcome_screen.dart';

class ServerLoadingScreen extends StatefulWidget {
  static const ID = 'server_loading';

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
    await GlobalValuesManager.waitForServerInitialization();

    final memories = context.read<Memories>();
    final session = Supabase.instance.client.auth.session();

    if (session != null) {
      if (!memories.isInitialized) {
        await memories.initialize();
      }

      Navigator.pushReplacementNamed(
        context,
        widget.nextScreen ?? MainScreen.ID,
      );
    } else {
      Navigator.pushReplacementNamed(context, WelcomeScreen.ID);
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
            const Icon(Icons.cloud, size: 60),
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
            const Icon(Icons.smartphone, size: 60),
            const SizedBox(height: LARGE_SPACE),
            Text(localizations.serverLoadingScreenDescription),
          ],
        ),
      ),
    );
  }
}
