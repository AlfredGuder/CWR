import 'package:documentation_assistant/home_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

bool populateDummyData = true;

void main() async {
  await Hive.initFlutter();
  await Hive.openBox("animalFeedBox");
  print("Yeet");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Documentation Assistant",
      home: MyHomePage(),
    );
  }
}