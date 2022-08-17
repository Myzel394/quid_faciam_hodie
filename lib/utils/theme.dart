import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

TextStyle getBodyTextTextStyle(final BuildContext context) => platformThemeData(
      context,
      material: (data) => data.textTheme.bodyText1!,
      cupertino: (data) => data.textTheme.textStyle,
    );

Color getBodyTextColor(final BuildContext context) => platformThemeData(
      context,
      material: (data) => data.textTheme.bodyText1!.color!,
      cupertino: (data) => data.textTheme.textStyle.color!,
    );

TextStyle getTitleTextStyle(final BuildContext context) => platformThemeData(
      context,
      material: (data) => data.textTheme.headline1!,
      cupertino: (data) => data.textTheme.navLargeTitleTextStyle,
    );

TextStyle getSubTitleTextStyle(final BuildContext context) => platformThemeData(
      context,
      material: (data) => data.textTheme.subtitle1!,
      cupertino: (data) => data.textTheme.navTitleTextStyle,
    );
