import 'package:documentation_assistant/animal.dart';
import 'package:documentation_assistant/animal_card.dart';
import 'package:flutter/material.dart';

class BlocFecesPage extends StatefulWidget {
  final DateTime selectedDate;
  final Set<Animal> animals;

  const BlocFecesPage(
      {super.key, required this.selectedDate, required this.animals});

  @override
  State<BlocFecesPage> createState() => _BlocFecesPageState();
}

class _BlocFecesPageState extends State<BlocFecesPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
