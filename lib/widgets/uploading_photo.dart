import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:share_location/constants/spacing.dart';

class UploadingPhoto extends StatefulWidget {
  final Uint8List data;
  final VoidCallback onDone;

  const UploadingPhoto({
    Key? key,
    required this.data,
    required this.onDone,
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

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            widget.onDone();
          }
        });
      }
    });

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
            width: 15,
          ),
          borderRadius: BorderRadius.circular(SMALL_SPACE),
        ),
        child: Image.memory(widget.data, fit: BoxFit.cover),
      ),
    );
  }
}
