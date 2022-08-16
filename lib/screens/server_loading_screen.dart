import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_location/constants/apis.dart';
import 'package:share_location/constants/spacing.dart';
import 'package:share_location/managers/global_values_manager.dart';
import 'package:share_location/models/memories.dart';
import 'package:share_location/widgets/dot_animation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'main_screen.dart';
import 'welcome_screen.dart';

class ServerLoadingScreen extends StatefulWidget {
  static const ID = 'server_loading';

  const ServerLoadingScreen({Key? key}) : super(key: key);

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
    GlobalValuesManager.setCameras(await availableCameras());
    await Supabase.initialize(
      url: SUPABASE_API_URL,
      anonKey: SUPABASE_API_KEY,
      debug: kDebugMode,
    );

    final memories = context.read<Memories>();
    final session = Supabase.instance.client.auth.session();

    if (session != null) {
      memories.initialize().then((_) {
        Navigator.pushReplacementNamed(context, MainScreen.ID);
      });
    } else {
      Navigator.pushReplacementNamed(context, WelcomeScreen.ID);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const <Widget>[
            Icon(Icons.cloud, size: 60),
            SizedBox(height: SMALL_SPACE),
            DotAnimation(
              initialFadeInDelay: Duration.zero,
              fadeInDuration: Duration(seconds: 1),
              fadeOutDuration: Duration(seconds: 1),
              fadeInDelay: Duration(seconds: 6),
              fadeOutDelay: Duration.zero,
            ),
            DotAnimation(
              initialFadeInDelay: Duration(seconds: 2),
              fadeInDuration: Duration(seconds: 1),
              fadeOutDuration: Duration(seconds: 1),
              fadeInDelay: Duration(seconds: 6),
              fadeOutDelay: Duration.zero,
            ),
            DotAnimation(
              initialFadeInDelay: Duration(seconds: 4),
              fadeInDuration: Duration(seconds: 1),
              fadeOutDuration: Duration(seconds: 1),
              fadeInDelay: Duration(seconds: 6),
              fadeOutDelay: Duration.zero,
            ),
            SizedBox(height: SMALL_SPACE),
            Icon(Icons.smartphone, size: 60),
            SizedBox(height: LARGE_SPACE),
            Text(
              'We are loading your data',
            ),
          ],
        ),
      ),
    );
  }
}
