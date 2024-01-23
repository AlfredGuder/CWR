import 'package:flutter/material.dart';
import 'package:documentation_assistant/animal.dart';
import 'package:flutter/services.dart';

class AnimalAdditionPage extends StatefulWidget {
  final List<Animal> animalDataList;

  const AnimalAdditionPage({Key? key, required this.animalDataList})
      : super(key: key);

  @override
  State<AnimalAdditionPage> createState() => _AnimalAdditionPageState();
}

class _AnimalAdditionPageState extends State<AnimalAdditionPage> {
  late List<Animal> currentAnimalList;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    currentAnimalList = widget.animalDataList;
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Animal List"),
      ),
      body: Center(
        child: Column(
          children: [
            ListView.builder(
                shrinkWrap: true,
                itemCount: currentAnimalList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(currentAnimalList[index].animalName),
                          Text(currentAnimalList[index].species),
                          Text(currentAnimalList[index].sex),
                          Text(currentAnimalList[index].arksNo),
                        ],
                      )
                    ],
                  );
                }),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                    heroTag: 'addButton',
                    onPressed: () async {
                      Animal? animalToAdd = await addAnimal();
                      if (animalToAdd!.animalName != '' &&
                          animalToAdd.sex != '' &&
                          animalToAdd.species != '' &&
                          animalToAdd.arksNo != '') {
                        () {}; //TODO add animal to GSheets
                        setState(() {
                          currentAnimalList.add(animalToAdd);
                        });
                      }
                    },
                    child: const Text('Add')),
                FloatingActionButton(
                  heroTag: 'removeButton',
                  onPressed: () {},
                  child: const Text('Remove'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<Animal?> addAnimal() async {
    Animal newAnimal = Animal(
      animalName: 'tempName',
      species: 'tempSpecies',
      sex: 'tempSex',
      arksNo: 'tempNo',
      amFeed: 0,
      midFeed: 0,
      pmFeed: 0,
    );
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
          title: const Text('Enter Animal Name:'),
          content: TextField(
            autofocus: true,
            controller: controller,
            keyboardType: TextInputType.text,
          ),
          actions: [
            FloatingActionButton(
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
          title: const Text('Enter Animal Species'),
          content: TextField(
            autofocus: true,
            controller: controller,
            keyboardType: TextInputType.text,
          ),
          actions: [
            FloatingActionButton(
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
            title: const Text('Choose animal gender'),
            actions: [
              FloatingActionButton(
                heroTag: 'MaleButton',
                onPressed: () {
                  Navigator.of(context).pop('Male');
                },
                child: const Text('Male'),
              ),
              FloatingActionButton(
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
