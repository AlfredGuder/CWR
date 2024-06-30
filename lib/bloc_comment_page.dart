import 'package:documentation_assistant/animal.dart';
import 'package:documentation_assistant/animal_bloc/animal_bloc.dart';
import 'package:documentation_assistant/animal_bloc/animal_event.dart';
import 'package:documentation_assistant/animal_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocCommentpage extends StatefulWidget {
  final DateTime currentDate;
  final Map<String, List<String>> commentMap;

  const BlocCommentpage(
      {super.key, required this.currentDate, required this.commentMap});

  @override
  State<BlocCommentpage> createState() => _BlocCommentpageState();
}

class _BlocCommentpageState extends State<BlocCommentpage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
