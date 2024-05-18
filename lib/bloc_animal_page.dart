import 'package:documentation_assistant/animal.dart';
import 'package:documentation_assistant/animal_card.dart';
import 'package:flutter/material.dart';

class BlocAnimalPage extends StatefulWidget {
  final DateTime selectedDate;
  final Set<Animal> animals;

  const BlocAnimalPage(
      {super.key, required this.selectedDate, required this.animals});

  @override
  State<BlocAnimalPage> createState() => _BlocAnimalPageState();
}

class _BlocAnimalPageState extends State<BlocAnimalPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton.extended(
                extendedPadding: EdgeInsets.all(2),
                label: Text(
                    "${widget.selectedDate.year}/${widget.selectedDate.month}/${widget.selectedDate.day}"),
                backgroundColor: (Colors.orange),
                foregroundColor: (Colors.black),
                onPressed: () async {
                  DateTime? newDate = await showDatePicker(
                    context: context,
                    initialDate: widget.selectedDate,
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2024, 12),
                  );

                  if (newDate == null) return;
                },
              ),
            ],
          ),
          AnimalCard(widget.animals.toList()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                backgroundColor: (Colors.orange),
                foregroundColor: (Colors.black),
                heroTag: 'animalFeedButton',
                onPressed: () {},
                child: const Text("Edit"),
              ),
              FloatingActionButton(
                backgroundColor: (Colors.orange),
                foregroundColor: (Colors.black),
                heroTag: 'saveButton',
                onPressed: () {},
                child: const Text("Save"),
              ),
            ],
          )
        ],
      ),
    );
    ;
  }
}
