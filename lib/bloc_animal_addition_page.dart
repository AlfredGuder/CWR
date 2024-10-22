import 'package:documentation_assistant/animal.dart';
import 'package:documentation_assistant/animal_bloc/animal_bloc.dart';
import 'package:documentation_assistant/animal_bloc/animal_event.dart';
import 'package:documentation_assistant/animal_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gsheets/gsheets.dart';
import 'package:documentation_assistant/resources.dart';
import 'package:documentation_assistant/sheet_builder.dart';

class BlocAnimalAddition extends StatefulWidget {
  final DateTime selectedDate;
  final List<Animal> animals;

  const BlocAnimalAddition(
      {Key? key, required this.animals, required this.selectedDate})
      : super(key: key);

  @override
  State<BlocAnimalAddition> createState() => _BlocAnimalAdditionState();
}

class _BlocAnimalAdditionState extends State<BlocAnimalAddition> {
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
    return Center(
      child: Column(
        children: [
          ListView.builder(
              shrinkWrap: true,
              itemCount: widget.animals.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 75,
                            height: 50,
                            child: Text(widget.animals[index].animalName),
                          ),
                          SizedBox(
                            width: 100,
                            height: 50,
                            child: Text(widget.animals[index].species),
                          ),
                          SizedBox(
                            width: 75,
                            height: 50,
                            child: Text(widget.animals[index].sex),
                          ),
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: Text(widget.animals[index].arksNo),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              }),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                  heroTag: 'addButton',
                  onPressed: () async {
                    Animal? animalToAdd = await addAnimal();
                    if (animalToAdd!.animalName != '' &&
                        animalToAdd.sex != '' &&
                        animalToAdd.species != '' &&
                        animalToAdd.arksNo != '') {
                      await addAnimalToFeedSheet(animalToAdd);
                      await addNewSheetForAnimal(
                          widget.selectedDate, animalToAdd);
                      setState(() {
                        widget.animals.add(animalToAdd);
                      });
                    }
                  },
                  child: const Text('Add')),
              FloatingActionButton(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
                heroTag: 'removeButton',
                onPressed: () async {
                  Animal? animalToRemove =
                      await nameRemovalScreen(widget.animals);
                  if (animalToRemove != null) {
                    await SheetService.removeAnimalRow(
                        animalToRemove.animalName);
                    setState(() {
                      widget.animals.remove(animalToRemove);
                    });
                  }
                },
                child: const Text('Remove'),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<Animal?> nameRemovalScreen(List<Animal> localAnimalList) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            backgroundColor: Colors.black,
            titleTextStyle: const TextStyle(color: Colors.white),
            contentTextStyle: const TextStyle(color: Colors.white),
            title: const Text('Pick an animal to remove'),
            content: SizedBox(
              height: 200,
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: localAnimalList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      FloatingActionButton(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.orange,
                          onPressed: () {
                            Navigator.of(context).pop(localAnimalList[index]);
                          },
                          child: Text(localAnimalList[index].animalName))
                    ],
                  );
                },
              ),
            ),
          ));

  Future<Animal?> addAnimal() async {
    Animal newAnimal = Animal(
        animalName: 'tempName',
        species: 'tempSpecies',
        sex: 'tempSex',
        arksNo: 'tempNo',
        amFeed: 0,
        midFeed: 0,
        pmFeed: 0,
        feces: false);
    newAnimal.animalName = await nameAdditionScreen() ?? '';
    controller.clear();

    newAnimal.species = await speciesAdditionScreen() ?? '';
    newAnimal.sex = await sexAdditionScreen() ?? '';
    newAnimal.arksNo = await arksAdditionScreen() ?? '';
    return newAnimal;
  }

  Future<String?> nameAdditionScreen() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black,
          titleTextStyle: const TextStyle(color: Colors.white),
          contentTextStyle: const TextStyle(color: Colors.white),
          title: const Text('Enter Animal Name:'),
          content: TextField(
            autofocus: true,
            controller: controller,
            keyboardType: TextInputType.text,
          ),
          actions: [
            FloatingActionButton(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.black,
              heroTag: 'acceptName',
              onPressed: () {
                Navigator.of(context).pop(controller.text);
                controller.clear();
              },
              child: const Text('Accept'),
            ),
          ],
        ),
      );

  Future<String?> speciesAdditionScreen() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black,
          titleTextStyle: const TextStyle(color: Colors.white),
          contentTextStyle: const TextStyle(color: Colors.white),
          title: const Text('Enter Animal Species'),
          content: TextField(
            autofocus: true,
            controller: controller,
            keyboardType: TextInputType.text,
          ),
          actions: [
            FloatingActionButton(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.black,
              heroTag: 'acceptSpecies',
              onPressed: () {
                Navigator.of(context).pop(controller.text);
                controller.clear();
              },
              child: const Text('Accept'),
            )
          ],
        ),
      );

  Future<String?> sexAdditionScreen() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            backgroundColor: Colors.black,
            titleTextStyle: const TextStyle(color: Colors.white),
            contentTextStyle: const TextStyle(color: Colors.white),
            title: const Text('Choose animal gender'),
            actions: [
              FloatingActionButton(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
                heroTag: 'MaleButton',
                onPressed: () {
                  Navigator.of(context).pop('Male');
                },
                child: const Text('Male'),
              ),
              FloatingActionButton(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
                heroTag: 'FemaleButton',
                onPressed: () {
                  Navigator.of(context).pop('Female');
                },
                child: const Text('Female'),
              ),
            ],
          ));

  Future<String?> arksAdditionScreen() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            backgroundColor: Colors.black,
            titleTextStyle: const TextStyle(color: Colors.white),
            contentTextStyle: const TextStyle(color: Colors.white),
            title: const Text('Enter Animal Arks number'),
            content: TextField(
              autofocus: true,
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
            actions: [
              FloatingActionButton(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
                heroTag: 'arksAddButton',
                onPressed: () {
                  Navigator.of(context).pop(controller.text);
                  controller.clear();
                },
                child: const Text('Add'),
              )
            ],
          ));
}
