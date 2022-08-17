import 'package:flutter/material.dart';

final LIGHT_THEME = ThemeData(
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
      borderRadius: BorderRadius.circular(8),
    ),
  ),
);

final DARK_THEME = ThemeData.dark().copyWith(
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
);
