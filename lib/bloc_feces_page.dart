import 'package:documentation_assistant/animal.dart';
import 'package:documentation_assistant/animal_bloc/animal_bloc.dart';
import 'package:documentation_assistant/animal_bloc/animal_event.dart';
import 'package:documentation_assistant/animal_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocFecesPage extends StatefulWidget {
  final DateTime selectedDate;
  final List<Animal> animals;

  const BlocFecesPage(
      {super.key, required this.selectedDate, required this.animals});

  @override
  State<BlocFecesPage> createState() => _BlocFecesPageState();
}

class _BlocFecesPageState extends State<BlocFecesPage> {
  
  

  @override
  void initState() {
    super.initState();

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
              itemCount: widget.animals.length,
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
                          child: Text(widget.animals[index].animalName),
                        ),
                        Switch(activeColor: Colors.orange, value: widget.animals[index].feces, onChanged: (_flag) {
                          
                          if (mounted) {
                              AnimalBloc bloc = context.read<AnimalBloc>();
                              bloc.add(ToggleFecesEvent(
                                targetAnimal: widget.animals[index],
                              ));
                        }})
                        // FloatingActionButton(
                        //   backgroundColor: (Colors.orange),
                        //   foregroundColor: (Colors.black),
                        //   heroTag: 'fecesCheckButton$index',
                        //   onPressed: () {
                        //     if (mounted) {
                        //       AnimalBloc bloc = context.read<AnimalBloc>();
                        //       bloc.add(ToggleFecesEvent(
                        //         targetAnimal: widget.animals[index],
                        //       ));
                        //     }
                        //   },
                        //   child: Text(widget.animals[index].feces? "Yes" : "No"),
                        // )
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
          onPressed: () => context.read<AnimalBloc>().add(SaveFecesEvent()), //saveToSheet(useDate),
          child: const Text('save'),
        ),
      ],
    );
  }

  // void setupPage() {
  //   for (Animal targetAnimal in animalList) {
  //     fecesMap.putIfAbsent(targetAnimal.animalName, () => targetAnimal.feces);

  //     nameList.add(targetAnimal.animalName);
  //   }
  //   for (String name in nameList) {
  //     if (fecesMap[name] == false) {
  //       fecesButtonText.add('No');
  //     } else {
  //       fecesButtonText.add('Yes');
  //     }
  //   }
  // }
}
