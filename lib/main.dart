import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_location/screens/calendar_screen.dart';
import 'package:share_location/screens/grant_permission_screen.dart';
import 'package:share_location/screens/login_screen.dart';
import 'package:share_location/screens/main_screen.dart';
import 'package:share_location/screens/server_loading_screen.dart';
import 'package:share_location/screens/timeline_screen.dart';
import 'package:share_location/screens/welcome_screen.dart';

import 'models/memories.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
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
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: memories,
      child: MaterialApp(
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
          ServerLoadingScreen.ID: (context) => const ServerLoadingScreen(),
        },
        initialRoute: ServerLoadingScreen.ID,
      ),
    );
  }
}
