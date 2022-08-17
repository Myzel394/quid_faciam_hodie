import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';

class ModalSheet extends StatelessWidget {
  final Widget child;

  const ModalSheet({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Material(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(LARGE_SPACE),
              topRight: Radius.circular(LARGE_SPACE),
            ),
            color: platformThemeData(
              context,
              material: (data) =>
                  data.bottomSheetTheme.modalBackgroundColor ??
                  data.bottomAppBarColor,
              cupertino: (data) => data.barBackgroundColor,
            ),
            child: Container(
              padding: const EdgeInsets.all(MEDIUM_SPACE),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
