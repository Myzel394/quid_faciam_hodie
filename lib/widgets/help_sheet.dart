import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:quid_faciam_hodie/constants/help_sheet_id.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/managers/user_help_sheets_manager.dart';
import 'package:quid_faciam_hodie/widgets/help_sheet/help_sheet_form.dart';

class HelpSheet extends StatefulWidget {
  final Widget child;
  final String title;
  final Widget helpContent;
  final HelpSheetID helpID;
  final bool forceShow;
  final bool checkOnStateChange;
  final VoidCallback? onSheetShown;
  final VoidCallback? onSheetHidden;

  const HelpSheet({
    Key? key,
    required this.child,
    required this.title,
    required this.helpContent,
    required this.helpID,
    this.forceShow = false,
    this.checkOnStateChange = false,
    this.onSheetShown,
    this.onSheetHidden,
  }) : super(key: key);

  @override
  State<HelpSheet> createState() => _HelpSheetState();
}

class _HelpSheetState extends State<HelpSheet> {
  bool isShowingSheet = false;
  BuildContext? buildContext;

  @override
  void initState() {
    super.initState();

    if (widget.forceShow) {
      showSheet();
    } else {
      checkIfSheetShouldBeShown();
    }
  }

  @override
  void dispose() {
    if (isShowingSheet && buildContext != null) {
      Navigator.pop(buildContext!);
    }

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HelpSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.checkOnStateChange) {
      checkIfSheetShouldBeShown();
    }
  }

  void showSheet() {
    if (isShowingSheet) {
      return;
    }

    Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) {
        return;
      }

      setState(() {
        isShowingSheet = true;
      });

      if (widget.onSheetShown != null) {
        widget.onSheetShown!();
      }

      final dontShowSheetAgain = await showPlatformModalSheet(
        material: MaterialModalSheetData(
          isDismissible: false,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(LARGE_SPACE),
              topRight: Radius.circular(LARGE_SPACE),
            ),
          ),
        ),
        cupertino: CupertinoModalSheetData(
          barrierDismissible: false,
          semanticsDismissible: false,
        ),
        context: context,
        builder: (buildContext) {
          this.buildContext = buildContext;

          return WillPopScope(
            onWillPop: () async {
              Navigator.pop(buildContext);
              Navigator.pop(context);

              return false;
            },
            child: HelpSheetForm(
              helpContent: widget.helpContent,
              title: widget.title,
            ),
          );
        },
      );

      if (widget.onSheetHidden != null) {
        widget.onSheetHidden!();
      }

      if (mounted) {
        setState(() {
          isShowingSheet = false;
        });
      }

      if (dontShowSheetAgain == true) {
        await UserHelpSheetsManager.setAsShown(widget.helpID);
      }
    });
  }

  Future<void> checkIfSheetShouldBeShown() async {
    final hasSheetBeShownAlready =
        await UserHelpSheetsManager.getIfAlreadyShown(widget.helpID);

    if (!hasSheetBeShownAlready && !isShowingSheet) {
      showSheet();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      alignment: Alignment.bottomCenter,
      scale: isShowingSheet ? .95 : 1,
      curve: Curves.easeOutSine,
      duration: const Duration(milliseconds: 500),
      child: widget.child,
    );
  }
}
