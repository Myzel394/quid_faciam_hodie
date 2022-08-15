import 'package:flutter/material.dart';

class AnimateInBuilder extends StatefulWidget {
  final Widget Function(bool isActive) builder;

  const AnimateInBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  State<AnimateInBuilder> createState() => _AnimateInBuilderState();
}

class _AnimateInBuilderState extends State<AnimateInBuilder> {
  bool isActive = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        isActive = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(isActive);
  }
}
