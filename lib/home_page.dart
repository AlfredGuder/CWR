import 'dart:convert';

import 'package:documentation_assistant/animal.dart';
import 'package:documentation_assistant/animal_card.dart';
import 'package:documentation_assistant/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final _myBox = Hive.box("animalFeedBox");
  late TextEditingController controller;
  String feedChoice = "MID";
  String animalChoice = "Willa";
  DateTime selectedDate = DateTime.now();
  int firstDay = 0;

  List<Animal> animalFeedList = [
    Animal(animalName: "Willa", amFeed: 0, midFeed: 0, pmFeed: 0),
    Animal(animalName: "Valora", amFeed: 0, midFeed: 0, pmFeed: 0),
    Animal(animalName: "Xayla", amFeed: 0, midFeed: 0, pmFeed: 0),
    Animal(animalName: "Cho gath", amFeed: 0, midFeed: 0, pmFeed: 5)
  ];

  String extractDate(DateTime receivedDate) {
    print(
        "Converting $receivedDate => ${Resources.hiveDataFormat.format(receivedDate)}");
    return Resources.hiveDataFormat.format(receivedDate);
  }

  void dateEditingCheck(DateTime checkDate, {bool displaySnackBar = true}) {
    String useDate = extractDate(checkDate);

    Map<String, Animal> feedData = readAnimalsFromDate(checkDate);
    if (displaySnackBar) {
      if (feedData.isEmpty) {
        showSnackBar("No data saved for $useDate");
      } else {
        showSnackBar("Read data for ${feedData.length} animals");
      }
    }
    for (Animal animal in animalFeedList) {
      String currentAnimalName = animal.animalName;
      Animal newAnimalData = feedData[currentAnimalName] ??
          Animal.defaultAnimal(currentAnimalName);

      animal.amFeed = newAnimalData.amFeed;
      animal.midFeed = newAnimalData.midFeed;
      animal.pmFeed = newAnimalData.pmFeed;
    }
  }

  @override
  void initState() {
    super.initState();
    dateEditingCheck(selectedDate, displaySnackBar: false);

    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Animals"),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  "${selectedDate.year}/${selectedDate.month}/${selectedDate.day}"),
              ElevatedButton(
                onPressed: () async {
                  DateTime? newDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2023, 5),
                  );

                  if (newDate == null) return;
                  dateEditingCheck(newDate);
                  setState(
                    (() => selectedDate = newDate),
                  );
                },
                child: const Text("C"),
              ),
            ],
          ),
          AnimalCard(animalFeedList),
          FloatingActionButton(
            onPressed: () async {
              Animal? animalToUpdate = await animalPicker();
              if (animalToUpdate != null) {
                int animalIndex = animalFeedList.indexWhere((Animal animal) =>
                    animal.animalName == animalToUpdate.animalName);
                setState(() {
                  animalFeedList[animalIndex] = animalToUpdate;
                });
                controller.clear();
              }
            },
            child: const Text("Add"),
          ),
          FloatingActionButton(
            onPressed: saveData,
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  Future<Animal?> animalPicker() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Pick Animal:"),
          content: SizedBox(
            height: 300,
            width: double.maxFinite,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: animalFeedList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          Animal animal = animalFeedList[index];
                          String animalName = animal.animalName;
                          //print(animalChoice);

                          int animalIndex = animalFeedList.indexWhere(
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
                        child: Text(animalFeedList[index].animalName),
                      )
                    ],
                  );
                }),
          ),
        ),
      );

  Future feedTimePicker(int animalChoice) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text("Choose feed time:"),
            actions: ["AM", "MID", "PM"]
                .map((time) => ElevatedButton(
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

  Future<String?> feedAmountPicker() => showDialog<String?>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Enter Amount:"),
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

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Map<String, Animal> readAnimalsFromDate(DateTime tarrgetDate) {
    String dateKey = extractDate(tarrgetDate);
    var savedData = _myBox.get(dateKey);
    if (savedData == null) {
      return {};
    }

    Map<String, dynamic> decodedData = jsonDecode(savedData);
    Map<String, Animal> out = {}..addEntries(decodedData.entries
        .map((e) => MapEntry(e.key, Animal.fromJson(jsonDecode(e.value)))));

    return out;
  }

  void saveData() async {
    print(
        "Saving data for ${animalFeedList.length} animals\n${animalFeedList.map((e) => e.toString()).join("\n")}");
    var updateMap = {};
    for (Animal animal in animalFeedList) {
      if (animal.hasDefaultValues()) continue;
      updateMap[animal.animalName] = animal.toJson();
    }
    String feedMap = jsonEncode(updateMap);

    await _myBox.put(extractDate(selectedDate), feedMap);
    showSnackBar("Saved data for ${updateMap.length} animals");
  }
}
