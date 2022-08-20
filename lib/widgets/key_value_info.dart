import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/extensions/snackbar.dart';
import 'package:quid_faciam_hodie/utils/theme.dart';

class KeyValueInfo extends StatelessWidget {
  final String title;
  final String value;
  final bool valueCopyable;
  final IconData? icon;
  final String? disclaimer;

  const KeyValueInfo({
    Key? key,
    required this.title,
    required this.value,
    this.valueCopyable = true,
    this.icon,
    this.disclaimer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: MEDIUM_SPACE,
          horizontal: SMALL_SPACE,
        ),
        child: ListTile(
          title: Row(
            children: <Widget>[
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: SMALL_SPACE),
                  child: Icon(icon),
                ),
              Expanded(
                flex: 2,
                child: Text(
                  title,
                  style: getSubTitleTextStyle(context),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  value,
                  style: getBodyTextTextStyle(context),
                ),
              ),
            ],
          ),
          trailing: valueCopyable
              ? PlatformIconButton(
                  icon: const Icon(Icons.content_copy),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Clipboard.setData(ClipboardData(text: value));

                    context.showSuccessSnackBar(
                      message: 'Copied to clipboard!',
                    );
                  },
                )
              : null,
        ),
      ),
    );
  }
}
