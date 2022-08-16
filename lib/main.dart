import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_location/constants/apis.dart';
import 'package:share_location/screens/calendar_screen.dart';
import 'package:share_location/screens/grant_permission_screen.dart';
import 'package:share_location/screens/login_screen.dart';
import 'package:share_location/screens/main_screen.dart';
import 'package:share_location/screens/timeline_screen.dart';
import 'package:share_location/screens/welcome_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'managers/global_values_manager.dart';
import 'managers/startup_page_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SUPABASE_API_URL,
    anonKey: SUPABASE_API_KEY,
    debug: kDebugMode,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  GlobalValuesManager.setCameras(await availableCameras());

  final initialPage = await StartupPageManager.getPage();

  runApp(MyApp(initialPage: initialPage));
}

class MyApp extends StatelessWidget {
  final String initialPage;

  const MyApp({
    Key? key,
    required this.initialPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark().copyWith(
        textTheme: ThemeData.dark().textTheme.copyWith(
              headline1: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w500,
              ),
            ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          helperMaxLines: 10,
          errorMaxLines: 10,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      routes: {
        WelcomeScreen.ID: (context) => const WelcomeScreen(),
        MainScreen.ID: (context) => const MainScreen(),
        LoginScreen.ID: (context) => const LoginScreen(),
        TimelineScreen.ID: (context) => const TimelineScreen(),
        GrantPermissionScreen.ID: (context) => const GrantPermissionScreen(),
        CalendarScreen.ID: (context) => const CalendarScreen(),
      },
      initialRoute: initialPage,
    );
  }
}
