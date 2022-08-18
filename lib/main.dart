import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:quid_faciam_hodie/constants/themes.dart';
import 'package:quid_faciam_hodie/screens/calendar_screen.dart';
import 'package:quid_faciam_hodie/screens/grant_permission_screen.dart';
import 'package:quid_faciam_hodie/screens/login_screen.dart';
import 'package:quid_faciam_hodie/screens/main_screen.dart';
import 'package:quid_faciam_hodie/screens/server_loading_screen.dart';
import 'package:quid_faciam_hodie/screens/settings_screen.dart';
import 'package:quid_faciam_hodie/screens/timeline_screen.dart';
import 'package:quid_faciam_hodie/screens/welcome_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'managers/global_values_manager.dart';
import 'models/memories.dart';
import 'screens/empty_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  GlobalValuesManager.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final memories = Memories();

  @override
  void initState() {
    super.initState();

    watchAuthenticationStatus();
  }

  Future<void> watchAuthenticationStatus() async {
    await GlobalValuesManager.watchForInitialization();

    Supabase.instance.client.auth.onAuthStateChange((event, session) {
      switch (event) {
        case AuthChangeEvent.signedIn:
          memories.refresh();
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: memories,
      child: PlatformApp(
        title: 'Quid faciam hodie?',
        material: (_, __) => MaterialAppData(
          theme: LIGHT_THEME_MATERIAL,
          darkTheme: DARK_THEME_MATERIAL,
          themeMode: ThemeMode.system,
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routes: {
          WelcomeScreen.ID: (context) => const WelcomeScreen(),
          MainScreen.ID: (context) => const MainScreen(),
          LoginScreen.ID: (context) => const LoginScreen(),
          TimelineScreen.ID: (context) => const TimelineScreen(),
          GrantPermissionScreen.ID: (context) => const GrantPermissionScreen(),
          CalendarScreen.ID: (context) => const CalendarScreen(),
          ServerLoadingScreen.ID: (context) => const ServerLoadingScreen(),
          EmptyScreen.ID: (context) => const EmptyScreen(),
          SettingsScreen.ID: (context) => const SettingsScreen(),
        },
        initialRoute: ServerLoadingScreen.ID,
      ),
    );
  }
}
