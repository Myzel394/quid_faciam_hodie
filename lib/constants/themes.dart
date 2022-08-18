import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';

final LIGHT_THEME_MATERIAL = ThemeData(
  textTheme: ThemeData().textTheme.copyWith(
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
      borderRadius: BorderRadius.circular(MEDIUM_SPACE),
    ),
  ),
);

final DARK_THEME_MATERIAL = ThemeData.dark().copyWith(
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
      borderRadius: BorderRadius.circular(MEDIUM_SPACE),
    ),
  ),
);

final LIGHT_THEME_CUPERTINO = CupertinoThemeData().copyWith(
  textTheme: CupertinoThemeData().textTheme.copyWith(
        navLargeTitleTextStyle: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w500,
        ),
      ),
);
