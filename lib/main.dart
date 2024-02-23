import 'package:documentation_assistant/home_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

bool populateDummyData = true;
//TODO make a bonding sheet
//TODO trace amount of animal encounter
//TODO possible accounts for users
//TODO tracing who added a comment into the thing
//TODO animal training docs
//TODO hotwire sheet addition
//TODO make it pretty
//
void main() async {
  await Hive.initFlutter();
  await Hive.openBox("animalFeedBox");

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
