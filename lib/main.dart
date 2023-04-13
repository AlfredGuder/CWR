import 'dart:developer';
import 'package:documentation_assistant/animal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:documentation_assistant/animal_card.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox("animalFeedBox");
  print("Yeet");

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

  List<Animal> animalFeedList = [
    Animal("Willa", 0, 0, 0),
    Animal("Valora", 0, 0, 0),
    Animal("Xayla", 0, 0, 0),
    Animal("Cho gath", 0, 0, 5)
  ];

  String extractDate(String receivedDate) {
    String extractedString = receivedDate.split(" ")[0];
    return extractedString;
  }

  void dateEditingCheck(String checkDate) {
    String useDate = extractDate(checkDate);
    log(_myBox.toMap().toString(), name: "myBoxValues");

    String? targetAnimal = _myBox.get(
      useDate,
    );

    // print("Loading animals for: $checkDate\n$targetAnimal");
    if (targetAnimal == null) {
      for (Animal animal in animalFeedList) {
        animal.amFeed = 0;
        animal.midFeed = 0;
        animal.pmFeed = 0;
      }
    } else {
      var targetAnimalMap = jsonDecode(targetAnimal);
      for (Animal animal in animalFeedList) {
        var animalMap = targetAnimalMap[animal.animalName];
        animal.amFeed = animalMap["Am"];
        animal.midFeed = animalMap["Mid"];
        animal.pmFeed = animalMap["Pm"];
      }
    }
  }

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

  DateTime date = DateTime.now();
  int firstDay = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Animals"),
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${date.year}/${date.month}/${date.day}"),
              ElevatedButton(
                onPressed: () async {
                  DateTime? newDate = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2023, 5),
                  );

                  if (newDate == null) return;
                  dateEditingCheck(newDate.toString());
                  setState(
                    (() => date = newDate),
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

                          int animalIndex = animalFeedList.indexWhere(
                              (Animal animal) =>
                                  animal.animalName == animalName);

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

  void saveData() {
    var updateMap = {};
    for (Animal animal in animalFeedList) {
      updateMap[animal.animalName] = {
        "Am": animal.amFeed,
        "Mid": animal.midFeed,
        "Pm": animal.pmFeed,
      };
    }

    String feedMap = jsonEncode(updateMap);
    _myBox.put(date.toString().split(" ")[0], feedMap);
  }

  feedPicker() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Choose feed"),
          content: Row(children: [
            ElevatedButton(
              onPressed: () {
                feedChoice = "AM";
                Navigator.of(context).pop();
              },
              child: const Text("AM"),
            ),
            ElevatedButton(
              onPressed: () {
                feedChoice = "MID";
                Navigator.of(context).pop();
              },
              child: const Text("MID"),
            ),
            ElevatedButton(
              onPressed: () {
                feedChoice = "PM";
                Navigator.of(context).pop();
              },
              child: const Text("PM"),
            ),
          ]),
          actions: [
            FloatingActionButton(
              onPressed: cancelButton,
              child: const Text("cancel"),
            ),
          ],
        ),
      );

  chooseFeed(String choice) {
    feedChoice = choice;
  }

  cancelButton() {
    feedChoice = "cancel";
    Navigator.of(context).pop();
  }
}
