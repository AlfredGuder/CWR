import 'package:documentation_assistant/animal.dart';
import 'package:documentation_assistant/animal_bloc/animal_bloc.dart';
import 'package:documentation_assistant/animal_bloc/animal_event.dart';
import 'package:documentation_assistant/animal_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocFecesPage extends StatefulWidget {
  final DateTime selectedDate;
  final Set<Animal> animals;

  const BlocFecesPage(
      {super.key, required this.selectedDate, required this.animals});

  @override
  State<BlocFecesPage> createState() => _BlocFecesPageState();
}

class _BlocFecesPageState extends State<BlocFecesPage> {
  late Set<Animal> animalSet;
  late List<String> nameList;
  late List<bool> fecesList;
  late List<String> fecesButtonText;

  @override
  void initState() {
    super.initState();
    animalSet = widget.animals;
    for (Animal targetAnimal in animalSet) {
      nameList.add(targetAnimal.animalName);
    }
    for (String thisName in nameList) {
      fecesList.add(animalSet.lookup(thisName)!.feces);
    }
    for (bool fecesState in fecesList) {
      if (fecesState == true) {
        fecesButtonText.add('Yes');
      } else {
        fecesButtonText.add('No');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 500,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: nameList.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: 40,
                          width: 100,
                          child: Text(nameList[index]),
                        ),
                        FloatingActionButton(
                          backgroundColor: (Colors.orange),
                          foregroundColor: (Colors.black),
                          heroTag: 'fecesCheckButton$index',
                          onPressed: () {
                            if (mounted) {
                              AnimalBloc bloc = context.read<AnimalBloc>();
                              bloc.add(AddFecesEvent(
                                  animalName: nameList[index],
                                  fecesBool: fecesList[index]));
                            }
                          },
                          child: Text(fecesButtonText[index]),
                        )
                      ],
                      //   if (mounted) {
                      //   AnimalBloc bloc = context.read<AnimalBloc>();
                      //   bloc.add(AddFeedEvent(
                      //       animalToAdd: animalToUpdate,
                      //       currentDate: widget.selectedDate));
                      // }
                    ),
                    const Divider(
                      color: Colors.orange,
                    ),
                  ],
                );
              }),
        ),
        FloatingActionButton(
          heroTag: 'saveButton',
          backgroundColor: (Colors.orange),
          foregroundColor: (Colors.black),
          onPressed: () => () {}, //saveToSheet(useDate),
          child: const Text('save'),
        ),
      ],
    );
  }
}
