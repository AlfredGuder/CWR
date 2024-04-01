import 'dart:async';

import 'package:documentation_assistant/loading_icon.dart';
import 'package:flutter/material.dart';

class LoadingText extends StatefulWidget {
  final String text;
  const LoadingText(this.text, {super.key});

  @override
  State<LoadingText> createState() => _LoadingTextState();
}

class _LoadingTextState extends State<LoadingText> {
  late Timer timer;
  static int maxDots = 3;
  int loopCount = 0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        loopCount = (loopCount + 1) % (maxDots + 1);
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String suffix = '.' * loopCount + ' ' * (maxDots - loopCount);

    return Column(
      children: [
        const LoadingIcon(),
        Text(
          widget.text + suffix,
          textAlign: TextAlign.left,
        ),
      ],
    );
  }
}
