import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/constants/values.dart';
import 'package:quid_faciam_hodie/managers/photo_manager.dart';
import 'package:quid_faciam_hodie/screens/welcome_screen/pages/view_memories_page.dart';

import 'welcome_screen/pages/create_memories_page.dart';
import 'welcome_screen/pages/get_started_page.dart';
import 'welcome_screen/pages/initial_page.dart';

const storage = FlutterSecureStorage();

class WelcomeScreen extends StatefulWidget {
  static const ID = '/welcome';

  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  NetworkImage? _initialImageForPhotoSwitching;
  final controller = PageController();

  @override
  void initState() {
    super.initState();

    storage.deleteAll();
    getInitialImageForPhotoSwitching();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  void getInitialImageForPhotoSwitching() async {
    final query = WELCOME_SCREEN_PHOTOS_QUERIES[
        Random().nextInt(WELCOME_SCREEN_PHOTOS_QUERIES.length)];
    final url = await PhotoManager.getRandomPhoto(query);

    if (!mounted) {
      return;
    }

    setState(() {
      _initialImageForPhotoSwitching = NetworkImage(url);
    });
  }

  void nextPage() {
    controller.animateToPage(
      (controller.page! + 1).toInt(),
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: MEDIUM_SPACE),
        child: Center(
          child: PageView(
            controller: controller,
            children: <Widget>[
              InitialPage(onNextPage: nextPage),
              CreateMemoriesPage(onNextPage: nextPage),
              ViewMemoriesPage(
                onNextPage: nextPage,
                initialImage: _initialImageForPhotoSwitching,
              ),
              const GetStartedPage(),
            ],
          ),
        ),
      ),
    );
  }
}
