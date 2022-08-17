import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/enums.dart';
import 'package:quid_faciam_hodie/models/memories.dart';
import 'package:quid_faciam_hodie/screens/server_loading_screen.dart';
import 'package:quid_faciam_hodie/screens/timeline_screen.dart';

import '../../widgets/raw_memory_display.dart';

class TodayPhotoButton extends StatefulWidget {
  final VoidCallback onLeave;
  final VoidCallback onComeBack;

  const TodayPhotoButton({
    Key? key,
    required this.onLeave,
    required this.onComeBack,
  }) : super(key: key);

  @override
  State<TodayPhotoButton> createState() => _TodayPhotoButtonState();
}

class _TodayPhotoButtonState extends State<TodayPhotoButton> {
  Uint8List? data;
  MemoryType? type;

  @override
  void initState() {
    super.initState();

    final memories = context.read<Memories>();

    memories.addListener(loadMemory, ['memories']);

    loadMemory();
  }

  @override
  void dispose() {
    try {
      final memories = context.read<Memories>();

      memories.removeListener(loadMemory);
    } catch (_) {}

    super.dispose();
  }

  Future<void> loadMemory() async {
    if (!mounted) {
      return;
    }

    final memories = context.read<Memories>();

    if (memories.memories.isEmpty) {
      setState(() {
        data = null;
        type = null;
      });
      return;
    }

    final lastMemory = memories.memories.first;

    final file = await lastMemory.downloadToFile();
    final memoryData = await file.readAsBytes();

    setState(() {
      data = memoryData;
      type = lastMemory.type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        widget.onLeave();

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ServerLoadingScreen(
              nextScreen: TimelineScreen.ID,
            ),
          ),
        );

        widget.onComeBack();
      },
      child: Align(
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
                ? const SizedBox.shrink()
                : RawMemoryDisplay(
                    data: data!,
                    type: type!,
                  ),
          ),
        ),
      ),
    );
  }
}
