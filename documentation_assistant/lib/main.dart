//import 'dart:ffi';

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import './animalCard.dart';
import './feedUpdate.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox("animalFeedBox");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Documentation Assistant",
      home: MyHomePage(),
    );
  }
}

//final List<String> animals = ["Willa", "Valora", "Thane", "T'Challa"];

class MyHomePage extends StatefulWidget {
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
    Animal("Cho gath", 0, 0, 0)
  ];

  String extractDate(String receivedDate) {
    String extractedString = receivedDate.split(" ")[0];
    return extractedString;
  }

  void dateEditingCheck(String checkDate) {
    String useDate = extractDate(checkDate);
    log(_myBox.toMap().toString(), name: "myBoxValues");

    //String editorStringCheck = _myBox.get(checkDate);
    var targetAnimal =
        _myBox.get(useDate, defaultValue: {"Am": 0, "Mid": 0, "Pm": 0});

    //print(_myBox.get(checkDate));
    // for (int i = 0; i < animalFeedList.length; i++) {
    print(targetAnimal.toString());
    var AnimalUpdateMap = targetAnimal;
    print(
      AnimalUpdateMap.toString(),
    );

    // List AnimalUpdateList = AnimalUpdateMap.values.toList();
    print(AnimalUpdateMap["Am"].runtimeType);
    animalFeedList[0].amFeed = AnimalUpdateMap["Am"];
    animalFeedList[0].midFeed = AnimalUpdateMap["Mid"];
    animalFeedList[0].pmFeed = AnimalUpdateMap["Pm"];
    print(animalFeedList[0].midFeed);
    //print(AnimalUpdateMap);
    // }
  }

  /*
  void saveData() {
    var updateMap = {
      "name": animalFeedList[0].animalName,
      "Am": animalFeedList[0].amFeed,
      "Mid": animalFeedList[0].midFeed,
      "Pm": animalFeedList[0].pmFeed,
    };

    String feedMap = jsonEncode(updateMap);
    _myBox.put(date.toString(), feedMap);
    print(_myBox.get(date.toString()));
  }
  */

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
    /*
    animalFeedList = [
      Animal("Willa", 0, 0, 0),
      Animal("Valora", 0, 0, 0),
      Animal("Xayla", 0, 0, 0)
      
    ];
*/
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
                child: Text("C"),
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
              }
            },
            child: Text("Add"),
          ),
          FloatingActionButton(
            onPressed: saveData,
            child: Text("Save"),
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
                          Navigator.of(context).pop(animal);
                        },
                        child: Text(animalFeedList[index].animalName),
                      )
                    ],
                  );
                }),
          ),
        ),
      );

  // animalIndexChooser(String animalChoice, int i) {
  //   if (animalChoice == animalFeedList[i].animalName) {
  //     return i;
  //   } else {
  //     i++;
  //     animalIndexChooser(animalChoice, i);
  //   }
  // }

  Future feedTimePicker(int animalChoice) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text("Choose feed time:"),
            actions: ["AM", "MID", "PM"]
                .map((time) => ElevatedButton(
                    onPressed: () async {
                      String amount = await feedAmountPicker() ?? "";
                      Navigator.of(context).pop(
                        "$amount,$time",
                      );
                    },
                    child: Text(time)))
                .toList()
            // [
            //   ElevatedButton(
            //       onPressed: () {
            //         feedChoice = "AM";
            //         feedAmountPicker(feedChoice, animalChoice);
            //       },
            //       child: const Text("AM")),
            //   ElevatedButton(
            //       onPressed: () {
            //         feedChoice = "MID";
            //         feedAmountPicker(feedChoice, animalChoice);
            //       },
            //       child: const Text("MID")),
            //   ElevatedButton(
            //       onPressed: () {
            //         feedChoice = "PM";
            //         feedAmountPicker(feedChoice, animalChoice);
            //       },
            //       child: const Text("PM")),
            // ],
            ),
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
    //print(_myBox.get(date.toString()));
  }

/*
  Future<int?> _dialogBuilder() => showDialog<int>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Enter amount:"),
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
              onPressed: submit,
              child: const Text("Submit"),
            )
          ],
        ),
      );

  void submit() {
    Navigator.of(context).pop(
      int.parse(controller.text),
    );
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
 */
/*
  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Choose value to modify"),
            actions: [
              FloatingActionButton(
                onPressed: _dialogSubmitter(context, "AM"),
                child: const Text("AM"),
              ),
              FloatingActionButton(
                onPressed: _dialogSubmitter(context, "MID"),
                child: const Text("MID"),
              ),
              FloatingActionButton(
                onPressed: _dialogSubmitter(context, "PM"),
                child: const Text("PM"),
              ),
            ],
          );
        });
  }
*/

  /*
  _dialogSubmitter(BuildContext context, String dialogChoice) {
    return AlertDialog(title: const Text("Enter amount:"), actions: [
      TextField(
        onSubmitted: (var amount) {
          if (dialogChoice == "AM") {
            willaClass.amFeed = amount;
          } else if (dialogChoice == "MID") {
            willaClass.midFeed = amount;
          } else if (dialogChoice == "PM") {
            willaClass.pmFeed == amount;
            Navigator.pop(context);
          }
        },
      )
    ]);
  }

  */

}

class Animal {
  var animalName;
  int amFeed = 0;
  int midFeed = 0;
  int pmFeed = 0;

  Animal(String animalName, int amFeed, int midFeed, int pmFeed) {
    this.animalName = animalName;
    this.amFeed = amFeed;
    this.midFeed = midFeed;
    this.pmFeed = pmFeed;
  }
}




/*
 Card(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  animals[0],
                ),
                Text("AM:${willaClass.amFeed.toString()}"),
                Text("MID:${willaClass.midFeed.toString()}"),
                Text("PM:${willaClass.pmFeed.toString()}"),
                FloatingActionButton(
                  onPressed: () async {
                    final feedAmount = await _dialogBuilder();
                    //if (feedAmount == null || feedAmount.isEmpty) return;
                    await feedPicker();
                    setState(() {
                      if (feedChoice == "AM") {
                        this.willaClass.amFeed = feedAmount as int;
                      } else if (feedChoice == "MID") {
                        this.willaClass.midFeed = feedAmount as int;
                      } else if (feedChoice == "PM") {
                        this.willaClass.pmFeed = feedAmount as int;
                      } else if (feedChoice == "cancel") {
                        return;
                      }
                    });
                    print(willaClass.amFeed);
                  },
                  child: const Text("Add"),
                )
              ],
            ),
          ),


          */
