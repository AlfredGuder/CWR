import 'package:documentation_assistant/animal.dart';
import 'package:documentation_assistant/animal_bloc/animal_bloc.dart';
import 'package:documentation_assistant/animal_bloc/animal_event.dart';
import 'package:documentation_assistant/animal_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gsheets/gsheets.dart';
import 'package:documentation_assistant/resources.dart';

class BlocAnimalPage extends StatefulWidget {
  final DateTime selectedDate;
  final List<Animal> animals;

  const BlocAnimalPage(
      {super.key, required this.selectedDate, required this.animals});

  @override
  State<BlocAnimalPage> createState() => _BlocAnimalPageState();
}

class _BlocAnimalPageState extends State<BlocAnimalPage> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

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
                onPressed: () async {
                  Animal? animalToUpdate = await animalPicker();
                  if (animalToUpdate != null) {
                    int animalIndex = widget.animals.toList().indexWhere(
                        (Animal animal) =>
                            animal.animalName == animalToUpdate.animalName);

                    //TODO rework setState call to use bloc instead
                    if (mounted) {
                      AnimalBloc bloc = context.read<AnimalBloc>();
                      bloc.add(AddFeedEvent(
                          animalToAdd: animalToUpdate,
                          currentDate: widget.selectedDate));
                    }

                    controller.clear();
                  }
                },
                child: const Text("Edit"),
              ),
              FloatingActionButton(
                backgroundColor: (Colors.orange),
                foregroundColor: (Colors.black),
                heroTag: 'saveButton',
                onPressed: () {
                  saveData(widget.selectedDate, widget.animals);
                },
                child: const Text("Save"),
              ),
            ],
          )
        ],
      ),
    );
  }

//collectively saves all feeding data for all animals
  void saveData(
    DateTime receivedDate,
    List<Animal> animalList,
  ) async {
    List<String> animalNames = [];
    for (Animal anim in animalList) {
      animalNames.add(anim.animalName);
    }

    final Worksheet currentWorkSheet = await SheetService.checkSheetforDate(
        receivedDate, widget.animals.toList());
    for (int i = 0; i < animalNames.length; i++) {
      String currentAnimal = animalNames[i];
      int currentAnimalStartingRow =
          await currentWorkSheet.values.rowIndexOf(currentAnimal, inColumn: 6);
      int amFeedRow = currentAnimalStartingRow + (3 * receivedDate.day - 1);
      await currentWorkSheet.values.insertValue(
          widget.animals.toList()[i].amFeed,
          column: 3,
          row: amFeedRow);
      await currentWorkSheet.values.insertValue(
          widget.animals.toList()[i].midFeed,
          column: 3,
          row: amFeedRow + 1);
      await currentWorkSheet.values.insertValue(
          widget.animals.toList()[i].pmFeed,
          column: 3,
          row: amFeedRow + 2);
    }
  }

//saves the data that was just added

//Creates a pop menu that the user can select which animal they would like to modify
  Future<Animal?> animalPicker() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: (Colors.black),
          title: const Text(
            "Pick Animal:",
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            height: 200,
            width: double.maxFinite,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.animals.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      FloatingActionButton(
                        backgroundColor: (Colors.orange),
                        foregroundColor: (Colors.black),
                        onPressed: () async {
                          Animal animal = widget.animals
                              .toList()[index]; //animalFeedList[index];
                          String animalName = animal.animalName;
                          //print(animalChoice);

                          int animalIndex = widget.animals.toList().indexWhere(
                              (Animal animal) =>
                                  animal.animalName == animalName);
                          //int animalIndex = animalIndexChooser(animalChoice, 0);
                          List<String> data =
                              (await feedTimePicker(animalIndex)).split(",");
                          if (data[1] == "AM") {
                            animal.amFeed = int.parse(data[0]);
                          } else if (data[1] == "MID") {
                            animal.midFeed = int.parse(data[0]);
                          } else if (data[1] == "PM") {
                            animal.pmFeed = int.parse(data[0]);
                          }
                          if (mounted) {
                            Navigator.of(context).pop(animal);
                          }
                        },
                        child: Text(widget.animals.toList()[index].animalName),
                      )
                    ],
                  );
                }),
          ),
        ),
      );

//Creates a popup menu that the user can select from 3 possible times that the feed took place
  Future feedTimePicker(int animalChoice) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
            backgroundColor: (Colors.black),
            titleTextStyle: const TextStyle(color: Colors.white),
            title: const Text("Choose feed time:"),
            actions: ["AM", "MID", "PM"]
                .map((time) => FloatingActionButton(
                    foregroundColor: (Colors.black),
                    backgroundColor: (Colors.orange),
                    onPressed: () async {
                      String amount = await feedAmountPicker() ?? "";
                      if (mounted) {
                        Navigator.of(context).pop(
                          "$amount,$time",
                        );
                      }
                    },
                    child: Text(time)))
                .toList()),
      );

//Creates a popup menu that the user can enter the amount of food given
  Future<String?> feedAmountPicker() => showDialog<String?>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: (Colors.black),
          titleTextStyle: const TextStyle(color: Colors.white),
          title: const Text("Enter Amount:"),
          content: TextField(
            autofocus: true,
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            // inputFormatters: <TextInputFormatter>[
            //   FilteringTextInputFormatter.digitsOnly
            // ],
          ),
          actions: [
            FloatingActionButton(
              backgroundColor: (Colors.orange),
              foregroundColor: (Colors.black),
              heroTag: 'submitbutton',
              onPressed: submitFeedAmount,
              child: const Text("Submit"),
            )
          ],
        ),
      );

  void submitFeedAmount() {
    Navigator.of(context).pop(
      controller.text,
    );
  }
}
