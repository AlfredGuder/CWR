import 'dart:async';
import 'package:flutter/material.dart';

class LoadingIcon extends StatefulWidget {
  const LoadingIcon({super.key});
  static const List<String> imageFiles = [
    "assets/images/image-1.jpg",
    "assets/images/image 2.jpg",
    "assets/images/image 3.jpg",
    "assets/images/image 4.jpg",
    "assets/images/image 5.jpg",
    "assets/images/image 6.jpg",
    "assets/images/image 7.jpg",
  ];
  @override
  State<LoadingIcon> createState() => _LoadingIconState();
}

class _LoadingIconState extends State<LoadingIcon> {
  late Timer timer;
  String displayFrame = LoadingIcon.imageFiles[0];
  int loopCount = 0;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 75), (timer) {
      setState(() {
        loopCount = loopCount + 1;
        displayFrame =
            LoadingIcon.imageFiles[loopCount % (LoadingIcon.imageFiles.length)];

        //displayFrame = (loopCount + 1) % LoadingIcon.imageFiles.length;
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
    return SizedBox(
      width: 150,
      height: 75,
      child: Image(
        image: AssetImage(displayFrame),
        fit: BoxFit.cover,
      ),
    );
  }
}
