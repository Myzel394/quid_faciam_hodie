import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';

class UploadingPhoto extends StatefulWidget {
  final Uint8List data;

  const UploadingPhoto({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<UploadingPhoto> createState() => _UploadingPhotoState();
}

class _UploadingPhotoState extends State<UploadingPhoto>
    with TickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    animation = Tween(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutQuad,
      ),
    );

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 12,
          ),
          borderRadius: BorderRadius.circular(MEDIUM_SPACE),
        ),
        child: Image.memory(widget.data, fit: BoxFit.cover),
      ),
    );
  }
}
