//import 'dart:ffi';

import 'package:documentation_assistant/animal.dart';
import 'package:documentation_assistant/animal_addition.dart';
import 'package:documentation_assistant/animal_card.dart';
import 'package:documentation_assistant/comment_page.dart';
import 'package:documentation_assistant/hot_wire_page.dart';
import 'package:documentation_assistant/loading_text.dart';
import 'package:documentation_assistant/resources.dart';
import 'package:documentation_assistant/feces_page.dart';
import 'package:documentation_assistant/sheet_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsheets/gsheets.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  late TextEditingController controller;
  DateTime selectedDate = DateTime.now();
  int firstDay = 0;

  bool isDataLoading = false;
  bool isFeedListBuilt = false;

  List<Animal> animalFeedList = [];

  Future<bool> animalFeedListGenerator() async {
    animalFeedList = await SheetService.animalFeedListBuilder();
    isFeedListBuilt = true;
    return true;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: (Colors.orange),
        foregroundColor: (Colors.black),
        title: const Text("Animals"),
        actions: [
          PopupMenuButton<String>(onSelected: (value) {
            print('Selected $value');
            if (value == 'Hotwire') {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return HotWirePage(currentDate: selectedDate);
              }));
            }
            if (value == 'Comment') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return CommentPage(
                      animalNameList: animalNames, currentDate: selectedDate);
                }),
              );
            }
            if (value == 'Animals') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return AnimalAdditionPage(
                      animalDataList: animalFeedList,
                      currentDateTime: selectedDate);
                }),
              );
            }
            if (value == 'Feces') {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return FecesPage(
                    animalNames: animalNames, currentDate: selectedDate);
              }));
            }
          }, itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem(
                  value: 'Hotwire',
                  child: Row(
                    children: [
                      Icon(Icons.bolt),
                      SizedBox(width: 8),
                      Text('Hotwire'),
                    ],
                  )),
              const PopupMenuItem(
                value: 'Comment',
                child: Row(
                  children: [
                    Icon(Icons.comment),
                    SizedBox(width: 8),
                    Text('Comment'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'Animals',
                child: Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8),
                    Text('Animals')
                  ],
                ),
              ),
              const PopupMenuItem(
                  value: 'Feces',
                  child: Row(
                    children: [
                      Icon(Icons.whatshot),
                      SizedBox(width: 8),
                      Text('Feces'),
                    ],
                  ))
            ];
          }),
        ],
      ),
      body: FutureBuilder<bool>(
        initialData: false,
        future: isFeedListBuilt ? null : animalFeedListGenerator(),
        builder: ((context, snapshot) {
          if (isFeedListBuilt == true) {
            animalNames = extractAnimalNames(animalFeedList);
            return FutureBuilder(
                initialData: false,
                future: isDataLoading
                    ? null
                    : getFeedingDataByDate(selectedDate, animalFeedList),
                builder: (context, snapshot) {
                  if (isDataLoading == true) {
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
                                    "${selectedDate.year}/${selectedDate.month}/${selectedDate.day}"),
                                backgroundColor: (Colors.orange),
                                foregroundColor: (Colors.black),
                                onPressed: () async {
                                  DateTime? newDate = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime(2023),
                                    lastDate: DateTime(2024, 12),
                                  );

                                  if (newDate == null) return;

                                  setState(
                                    (() {
                                      selectedDate = newDate;
                                      isDataLoading = false;
                                    }),
                                  );
                                },
                              ),
                            ],
                          ),
                          AnimalCard(animalFeedList),
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
                                    int animalIndex = animalFeedList.indexWhere(
                                        (Animal animal) =>
                                            animal.animalName ==
                                            animalToUpdate.animalName);
                                    saveThisData(selectedDate, animalToUpdate);
                                    setState(() {
                                      animalFeedList[animalIndex] =
                                          animalToUpdate;
                                    });
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
                                  saveData(selectedDate, animalNames);
                                },
                                child: const Text("Save"),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  } else {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [LoadingText('Fetching feeding data')],
                      ),
                    );
                  }
                });
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [LoadingText('Fetching list of animals')],
              ),
            );
          }
        }),
      ),
    );
  }

  Future<void> saveThisData(
    DateTime receivedDate,
    Animal animalToSave,
  ) async {
    final Worksheet currentWorkSheet =
        await SheetService.checkSheetforDate(receivedDate, animalFeedList);

    String currentAnimalName = animalToSave.animalName;
    int currentAnimalStartingRow = await currentWorkSheet.values
        .rowIndexOf(currentAnimalName, inColumn: 6);
    int amFeedRow = currentAnimalStartingRow + (3 * receivedDate.day - 1);
    await currentWorkSheet.values
        .insertValue(animalToSave.amFeed, column: 3, row: amFeedRow);
    await currentWorkSheet.values
        .insertValue(animalToSave.midFeed, column: 3, row: amFeedRow + 1);
    await currentWorkSheet.values
        .insertValue(animalToSave.pmFeed, column: 3, row: amFeedRow + 2);
  }

  List<String> animalNames = [];
  List<String> extractAnimalNames(List<Animal> animalList) =>
      animalList.map((animal) => animal.animalName).toList();

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
                itemCount: animalFeedList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      FloatingActionButton(
                        backgroundColor: (Colors.orange),
                        foregroundColor: (Colors.black),
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
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
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

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  void saveData(
    DateTime receivedDate,
    List<String> animalnameList,
  ) async {
    final Worksheet currentWorkSheet =
        await SheetService.checkSheetforDate(receivedDate, animalFeedList);
    for (int i = 0; i < animalnameList.length; i++) {
      String currentAnimal = animalnameList[i];
      int currentAnimalStartingRow =
          await currentWorkSheet.values.rowIndexOf(currentAnimal, inColumn: 6);
      int amFeedRow = currentAnimalStartingRow + (3 * receivedDate.day - 1);
      await currentWorkSheet.values
          .insertValue(animalFeedList[i].amFeed, column: 3, row: amFeedRow);
      await currentWorkSheet.values.insertValue(animalFeedList[i].midFeed,
          column: 3, row: amFeedRow + 1);
      await currentWorkSheet.values
          .insertValue(animalFeedList[i].pmFeed, column: 3, row: amFeedRow + 2);
    }
  }

  Future<bool>? getFeedingDataByDate(
      DateTime receivedDate, List<Animal> animalList) async {
    Worksheet currentWorksheet =
        await SheetService.checkSheetforDate(receivedDate, animalFeedList);

    Map<String, int> animalAmFeedRows = {};

    List<String> nameColumnValues = await currentWorksheet.values.column(6);
    for (Animal currentAnimal in animalList) {
      int animalNameRowNumber =
          nameColumnValues.indexOf(currentAnimal.animalName);
      int amFeedRow = animalNameRowNumber + (3 * receivedDate.day - 1);
      animalAmFeedRows.putIfAbsent(currentAnimal.animalName, () => amFeedRow);
    }

    List<String> columnValues = await currentWorksheet.values.column(3);

    for (int i = 0; i < animalFeedList.length; i++) {
      int rowToRetrieve = animalAmFeedRows[animalFeedList[i].animalName]!;
      animalFeedList[i].amFeed = int.parse(columnValues[rowToRetrieve]);
      animalFeedList[i].midFeed = int.parse(columnValues[rowToRetrieve + 1]);
      animalFeedList[i].pmFeed = int.parse(columnValues[rowToRetrieve + 2]);
    }

    setState(() {
      isDataLoading = true;
    });
    return true;
  }
}
