import 'package:flutter/material.dart';

class DelayRender extends StatefulWidget {
  final Widget child;
  final Widget placeholder;
  final Duration delay;

  const DelayRender({
    Key? key,
    required this.child,
    this.placeholder = const SizedBox(),
    this.delay = const Duration(milliseconds: 120),
  }) : super(key: key);

  @override
  State<DelayRender> createState() => _DelayRenderState();
}

class _DelayRenderState extends State<DelayRender> {
  bool allowRendering = false;

  @override
  void initState() {
    super.initState();

    startTimer();
  }

  Future<void> startTimer() async {
    await Future.delayed(widget.delay);

    if (!mounted) {
      return;
    }

    setState(() {
      allowRendering = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!allowRendering) {
      return widget.placeholder;
    }

    return widget.child;
  }
}
