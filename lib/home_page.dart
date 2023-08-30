import 'dart:convert';

import 'package:documentation_assistant/animal.dart';
import 'package:documentation_assistant/animal_card.dart';
import 'package:documentation_assistant/comment_page.dart';
import 'package:documentation_assistant/feces_page.dart';
import 'package:documentation_assistant/main.dart';
import 'package:documentation_assistant/resources.dart';
import 'package:documentation_assistant/sheet_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsheets/gsheets.dart';
import 'package:hive/hive.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.sheetCredentials, required this.sheetId})
      : super(key: key);
  String sheetCredentials;
  String sheetId;
  //const MyHomePage({super.key});
  //Feces_Page({Key? key, required this.animalNames}) : super(key: key);
  //List<String> animalNames;

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  late String _credentials;
  late String _sheetId;
  final _myBox = Hive.box("animalFeedBox");
  late TextEditingController controller;
  String feedChoice = "MID";
  String animalChoice = "Willa";
  DateTime selectedDate = DateTime.now();
  int firstDay = 0;

  List<Animal> animalFeedList = [
    Animal(
        name: "Willa",
        species: 'Cheetah',
        sex: 'F',
        arksNo: '1',
        gatherData: {}),
    Animal(
        name: "Valora",
        species: 'Cheetah',
        sex: 'F',
        arksNo: '2',
        gatherData: {}),
    Animal(
        name: "Xayla",
        species: 'Cheetah',
        sex: 'F',
        arksNo: '3',
        gatherData: {}),
    Animal(
        name: "Cho gath",
        species: 'Cheetah',
        sex: 'M',
        arksNo: '4',
        gatherData: {})
  ];

  List<String> animalNames = [];

  void animalnamegenerator() {
    for (int i = 0; i < animalFeedList.length; i++) {
      if (animalNames.length < animalFeedList.length) {
        animalNames.add("tempanimal");
      }

      //Animal animal in animalFeedList
      //animalNames.add(animal.animalName);
      animalNames[i] = animalFeedList[i].name;
    }
  }

  String extractDate(DateTime receivedDate) {
    print(
        "Converting $receivedDate => ${Resources.hiveDataFormat.format(receivedDate)}");
    return Resources.hiveDataFormat.format(receivedDate);
  }

  void getDataForDate(DateTime checkDate, {bool displaySnackBar = true}) {
    String useDate = extractDate(checkDate);
    for (int i = 0; i < animalFeedList.length; i++) {
      if (!animalFeedList[i].hasGatherDataForDate(useDate)) {
        animalFeedList[i].createNewDateRecording(useDate);
      }
    }

    // Map<String, Animal> feedData = readAnimalsFromDate(checkDate);
    // if (displaySnackBar) {
    //   if (feedData.isEmpty) {
    //     showSnackBar("No data saved for $useDate");
    //   } else {
    //     showSnackBar("Read data for ${feedData.length} animals");
    //   }
    // }
  }

  @override
  void initState() {
    super.initState();
    _credentials = widget.sheetCredentials;
    _sheetId = widget.sheetId;
    getDataForDate(selectedDate, displaySnackBar: false);
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
                    firstDate: DateTime(2023, 5),
                    lastDate: DateTime(2023, 12),
                  );

                  if (newDate == null) return;
                  getDataForDate(newDate);
                  setState(
                    (() => selectedDate = newDate),
                  );
                },
                child: const Text("C"),
              ),
            ],
          ),
          AnimalCard(animalFeedList, selectedDate),
          Row(
            children: [
              FloatingActionButton(
                onPressed: () async {
                  Animal? animalToUpdate = await animalPicker(selectedDate);
                  if (animalToUpdate != null) {
                    int animalIndex = animalFeedList.indexWhere(
                        (Animal animal) => animal.name == animalToUpdate.name);
                    setState(() {
                      animalFeedList[animalIndex] = animalToUpdate;
                    });
                    controller.clear();
                  }
                },
                child: const Text("Add"),
              ),
              FloatingActionButton(
                heroTag: 'btn1',
                onPressed: () {}, //saveData,
                child: const Text("Save"),
              ),
              FloatingActionButton(
                heroTag: 'btn2',
                onPressed: saveSheet(selectedDate),
                child: const Text('sheet'),
              ),
              FloatingActionButton(
                heroTag: 'btn3',
                onPressed: () {
                  animalnamegenerator();
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Feces_Page(
                      animalNames: animalNames,
                      sheetCredentials: _credentials,
                      sheetId: _sheetId,
                      currentDate:
                          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                    );
                  }));
                },
                child: const Text('F'),
              ),
              FloatingActionButton(
                heroTag: 'btn4',
                onPressed: () {
                  animalnamegenerator();
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Comment_Page(
                        animalNames: animalNames,
                        sheetCredentials: _credentials,
                        sheetId: _sheetId,
                        currentDate:
                            "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}");
                  }));
                },
                child: const Text('S'),
              ),
              FloatingActionButton(
                onPressed: () {
                  sheetChecker(_credentials, _sheetId, selectedDate.month,
                      selectedDate.year, animalFeedList);
                },
                heroTag: 'btn5',
                child: Text('C'),
              )
            ],
          )
        ],
      ),
    );
  }

  Future<Animal?> animalPicker(DateTime updateDate) => showDialog(
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
                          String animalName = animal.name;
                          //print(animalChoice);

                          int animalIndex = animalFeedList.indexWhere(
                              (Animal animal) => animal.name == animalName);
                          //int animalIndex = animalIndexChooser(animalChoice, 0);
                          List<String> data =
                              (await feedTimePicker(animalIndex)).split(",");
                          if (data[1] == "AM") {
                            animal.setAmFeedForDate(
                                updateDate.toString(), int.parse(data[0]));
                          } else if (data[1] == "MID") {
                            animal.setMidFeedForDate(
                                updateDate.toString(), int.parse(data[0]));
                          } else if (data[1] == "PM") {
                            animal.setPmFeedForDate(
                                updateDate.toString(), int.parse(data[0]));
                          }
                          if (mounted) {
                            Navigator.of(context).pop(animal);
                          }
                        },
                        child: Text(animalFeedList[index].name),
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

  // Map<String, Animal> readAnimalsFromDate(DateTime tarrgetDate) {
  //   String dateKey = extractDate(tarrgetDate);
  //   var savedData = _myBox.get(dateKey);
  //   if (savedData == null) {
  //     return {};
  //   }

  //   Map<String, dynamic> decodedData = jsonDecode(savedData);
  //   Map<String, Animal> out = {}..addEntries(decodedData.entries
  //       .map((e) => MapEntry(e.key, Animal.fromJson(jsonDecode(e.value)))));

  //   return out;
  // }

  // void saveData() async {
  //   print(
  //       "Saving data for ${animalFeedList.length} animals\n${animalFeedList.map((e) => e.toString()).join("\n")}");
  //   var updateMap = {};
  //   for (Animal animal in animalFeedList) {
  //     if (animal.hasDefaultValues()) continue;
  //     updateMap[animal.name] = animal.toJson();
  //   }
  //   String feedMap = jsonEncode(updateMap);

  //   await _myBox.put(extractDate(selectedDate), feedMap);
  //   showSnackBar("Saved data for ${updateMap.length} animals");
  // }

  saveSheet(DateTime dateTime) {
    print("Saving data to sheet");
    for (int animalCounter = 0;
        animalCounter < animalFeedList.length;
        animalCounter++,) {
      uploadToSheet(animalCounter, dateTime);
    }
  }

  void uploadToSheet(int animalNumber, DateTime currentDate) {
    int updateValue = animalFeedList[animalNumber]
        .amFeed(currentDate.toString()); //animalFeedList[animalNumber].amFeed;
    updateSheetPartTwo(updateValue, 1, animalNumber + 1);

    updateValue = animalFeedList[animalNumber].midFeed(currentDate.toString());
    updateSheetPartTwo(updateValue, 2, animalNumber + 1);

    updateValue = animalFeedList[animalNumber].pmFeed(currentDate.toString());
    updateSheetPartTwo(updateValue, 3, animalNumber + 1);
  }

  void updateSheetPartTwo(int toUpload, int columnNumber, int rowNumber) async {
    //init GSheets
    final gsheets = GSheets(_credentials);

    //fetch spreadsheet by ID
    final CWRSheets = await gsheets.spreadsheet(_sheetId);

    //fetch worksheet by title
    var feedSheet = CWRSheets.worksheetByTitle('AnimalFeedSheet');

    await feedSheet!.values
        .insertValue(toUpload, column: columnNumber, row: rowNumber);
  }
}
