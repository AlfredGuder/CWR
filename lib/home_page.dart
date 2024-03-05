import 'package:documentation_assistant/animal.dart';
import 'package:documentation_assistant/animal_addition.dart';
import 'package:documentation_assistant/animal_card.dart';
import 'package:documentation_assistant/comment_page.dart';
import 'package:documentation_assistant/resources.dart';
import 'package:documentation_assistant/feces_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsheets/gsheets.dart';
import 'package:googleapis/sheets/v4.dart' as sheets_official;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  late TextEditingController controller;
  String feedChoice = "MID";
  String animalChoice = "Willa";
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

  String extractDate(DateTime receivedDate) {
    print(
        "Converting $receivedDate => ${Resources.hiveDataFormat.format(receivedDate)}");
    return Resources.hiveDataFormat.format(receivedDate);
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
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                  "${selectedDate.year}/${selectedDate.month}/${selectedDate.day}"),
                              FloatingActionButton(
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

                                  //getFeedingDataByDate(newDate, animalNames);

                                  setState(
                                    (() {
                                      selectedDate = newDate;
                                      isDataLoading = false;
                                    }),
                                  );
                                },
                                child: const Text("C"),
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
                                    setState(() {
                                      animalFeedList[animalIndex] =
                                          animalToUpdate;
                                    });
                                    controller.clear();
                                  }
                                },
                                child: const Text("Add"),
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
                    return const Text('fetching feeding data');
                  }
                });
          } else {
            return const Text("Fetching list of animals...");
          }
        }),
      ),
    );
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
    try {
      final currentSpreadSheet = await SheetService.getSpreadsheet();

      try {
        await fetchBatchData(currentSpreadSheet, animalList, receivedDate);
        setState(() {
          isDataLoading = true;
        });
        return true;
      } catch (e) {
        print('Error fetching data: $e');
        return false;
      } finally {}
    } catch (e, stackTrace) {
      print('Error obtaining credentials: $e');
      print(stackTrace);
    }
    return true;
  }

  // Future<bool>? getFeedingDataByDate(
  //     DateTime receivedDate, List<Animal> animalList) async {
  //   print(receivedDate);
  //   final currentWorkSheet =
  //       await SheetService.checkSheetforDate(receivedDate, animalFeedList);

  //   await Future.wait(animalList.map((currentAnimal) async {
  //     print('fetching data for ${currentAnimal.animalName}');
  //     int currentAnimalStartingRow = await currentWorkSheet.values
  //         .rowIndexOf(currentAnimal.animalName, inColumn: 6);
  //     int amFeedRow = currentAnimalStartingRow + (3 * receivedDate.day - 1);

  //     var feedData = await Future.wait([
  //       currentWorkSheet.values.value(column: 3, row: amFeedRow), //AM
  //       currentWorkSheet.values.value(column: 3, row: amFeedRow + 1), //MID
  //       currentWorkSheet.values.value(column: 3, row: amFeedRow + 2), //PM
  //     ]);
  //     print('feched data for ${currentAnimal.animalName}');
  //     currentAnimal.amFeed = int.parse(feedData[0]);
  //     currentAnimal.midFeed = int.parse(feedData[1]);
  //     currentAnimal.pmFeed = int.parse(feedData[2]);
  //   }));

  //   setState(() {
  //     isDataLoading = true;
  //   });
  //   return true;
  // }

  Future<void> fetchBatchData(Spreadsheet currentSheet, List<Animal> animalList,
      DateTime receivedDate) async {
    final batchRequest = sheets_official.BatchUpdateValuesRequest()
      ..valueInputOption = 'RAW'
      ..data = [];
    Worksheet currentWorksheet =
        await SheetService.getWorkSheetByDate(receivedDate);
    for (int i = 0; i < animalList.length; i++) {
      final currentAnimal = animalList[i];

      int currentAnimalStartingRow = await currentWorksheet.values
          .rowIndexOf(currentAnimal.animalName, inColumn: 6);
      int amFeedRow = currentAnimalStartingRow + (3 * receivedDate.day - 1);

      final valueRange = sheets_official.ValueRange()
        ..range = '$currentSheet!C$amFeedRow:C${amFeedRow + 2}'
        ..values = [
          [currentAnimal.amFeed],
          [currentAnimal.midFeed],
          [currentAnimal.pmFeed],
        ];

      batchRequest.data!.add(valueRange);
    }

    currentSheet.batchUpdate([batchRequest.toJson()]);
  }
}
