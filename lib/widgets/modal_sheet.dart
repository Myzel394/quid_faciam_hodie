import 'package:flutter/material.dart';
import 'package:share_location/constants/spacing.dart';

class ModalSheet extends StatelessWidget {
  final Widget child;

  const ModalSheet({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            color: theme.bottomSheetTheme.modalBackgroundColor ??
                theme.bottomAppBarColor,
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
