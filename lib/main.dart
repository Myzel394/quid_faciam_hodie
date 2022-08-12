import 'package:flutter/material.dart';
import 'package:share_location/screens/welcome_screen.dart';

import 'managers/startup_page_manager.dart';

void main() async {
  final initialPage = await StartupPageManager.getPage();

  runApp(MyApp(initialPage: initialPage));
}

class MyApp extends StatelessWidget {
  final String initialPage;

  const MyApp({
    Key? key,
    required this.initialPage,
  }) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark().copyWith(
        textTheme: ThemeData.dark().textTheme.copyWith(
              headline1: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w500,
              ),
            ),
      ),
      routes: {
        WelcomeScreen.ID: (context) => WelcomeScreen(),
      },
      initialRoute: initialPage,
    );
  }
}
