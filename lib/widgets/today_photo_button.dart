import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/enums.dart';
import 'package:quid_faciam_hodie/screens/server_loading_screen.dart';
import 'package:quid_faciam_hodie/screens/timeline_screen.dart';

import 'raw_memory_display.dart';

class TodayPhotoButton extends StatelessWidget {
  final Uint8List? data;
  final MemoryType? type;
  final VoidCallback onLeave;
  final VoidCallback onComeBack;

  const TodayPhotoButton({
    Key? key,
    required this.onLeave,
    required this.onComeBack,
    this.data,
    this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        onLeave();

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServerLoadingScreen(
              nextScreen: TimelineScreen.ID,
            ),
          ),
        );

        onComeBack();
      },
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(SMALL_SPACE),
          color: Colors.grey,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(SMALL_SPACE),
          child: (data == null || type == null)
              ? const SizedBox()
              : RawMemoryDisplay(
                  data: data!,
                  type: type!,
                ),
        ),
      ),
    );
  }
}
