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
  final VoidCallback? onSheetShown;
  final VoidCallback? onSheetHidden;

  const HelpSheet({
    Key? key,
    required this.child,
    required this.title,
    required this.helpContent,
    required this.helpID,
    this.forceShow = false,
    this.onSheetShown,
    this.onSheetHidden,
  }) : super(key: key);

  @override
  State<HelpSheet> createState() => _HelpSheetState();
}

class _HelpSheetState extends State<HelpSheet> {
  bool isShowingSheet = false;

  @override
  void initState() {
    super.initState();

    if (widget.forceShow) {
      showSheet();
    } else {
      checkIfSheetShouldBeShown();
    }
  }

  void showSheet() {
    if (isShowingSheet) {
      return;
    }

    Timer(Duration(milliseconds: 300), () async {
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
        context: context,
        builder: (_) => HelpSheetForm(
          helpContent: widget.helpContent,
          title: widget.title,
        ),
      );

      if (widget.onSheetHidden != null) {
        widget.onSheetHidden!();
      }

      if (mounted) {
        setState(() {
          isShowingSheet = false;
        });
      }

      if (dontShowSheetAgain) {
        await UserHelpSheetsManager.setAsShown(widget.helpID);
      }
    });
  }

  Future<void> checkIfSheetShouldBeShown() async {
    final hasSheetBeShownAlready =
        await UserHelpSheetsManager.getIfAlreadyShown(widget.helpID);

    if (!hasSheetBeShownAlready) {
      showSheet();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isShowingSheet ? .95 : 1,
      curve: Curves.easeOutSine,
      duration: const Duration(milliseconds: 500),
      child: widget.child,
    );
  }
}
