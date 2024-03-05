//import 'dart:ffi';

import 'package:documentation_assistant/resources.dart';
import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';

class FecesPage extends StatefulWidget {
  final List<String> animalNames;

  final DateTime currentDate;

  const FecesPage({
    super.key,
    required this.animalNames,
    required this.currentDate,
  });
  @override
  State<FecesPage> createState() => _FecesPageState();
}

class _FecesPageState extends State<FecesPage> {
  late List<String> nameList;

  late DateTime useDate;

  late List<bool> animalFecesCheckList = List.filled(nameList.length, false);
  late List<String> animalFecesButtonState = List.filled(nameList.length, "No");

  bool isDataLoading = false;

  Future<bool>? checkFecesList() async {
    Map<String, String> fecesStateMap = {};

    for (int i = 0; i < nameList.length; i++) {
      fecesStateMap.putIfAbsent(nameList[i], () => 'No');
    }

    // setState(() {
    //   isDataLoading = true;
    // });

    Worksheet currentWorksheet = await SheetService.getWorkSheetByDate(useDate);
    List<bool> tempCheckList =
        await Future.wait(nameList.map((animalName) async {
      print('fetching data for $animalName');
      int currentAnimalStartRow =
          await currentWorksheet.values.rowIndexOf(animalName, inColumn: 6);
      int rowToCheck = currentAnimalStartRow + (3 * useDate.day) - 1;

      var fecesData =
          await currentWorksheet.values.value(column: 4, row: rowToCheck);

      return fecesData == 'Yes';
    }));

    setState(() {
      animalFecesButtonState =
          tempCheckList.map((hasFeces) => hasFeces ? 'Yes' : 'No').toList();

      isDataLoading = true;
    });

    return true;
  }

  @override
  void initState() {
    super.initState();
    nameList = widget.animalNames;

    useDate = widget.currentDate;

    // animalFecesCheckList = List.filled(nameList.length, false);
    // animalFecesButtonState = List.filled(nameList.length, "No");

    //checkFecesList();
  }

  //TODO optimize load time like in home page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF27127),
          foregroundColor: (Colors.black),
          title: const Text("Feces"),
        ),
        body: Center(
          child: FutureBuilder<bool>(
            initialData: false,
            future: isDataLoading ? null : checkFecesList(),
            builder: (context, snapshot) {
              // snapshot.connectionState == ConnectionState.done
              if (isDataLoading == true) {
                //int data = snapshot.data!;
                return Column(
                  children: [
                    FloatingActionButton(
                      heroTag: 'returnButton',
                      backgroundColor: const Color(0xFFF27127),
                      foregroundColor: (Colors.black),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Return'),
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: nameList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(nameList[index]),
                              FloatingActionButton(
                                backgroundColor: const Color(0xFFF27127),
                                foregroundColor: (Colors.black),
                                heroTag: 'fecesCheckButton$index',
                                onPressed: () => updateFecesList(index),
                                child: Text(animalFecesButtonState[index]),
                              )
                            ],
                          );
                        }),
                    FloatingActionButton(
                      heroTag: 'saveButton',
                      backgroundColor: const Color(0xFFF27127),
                      foregroundColor: (Colors.black),
                      onPressed: () => saveToSheet(useDate),
                      child: const Text('sheet'),
                    )
                  ],
                );
              } else {
                return const Text("Loading...");
              }
            },
          ),
        ));
  }

  void updateFecesList(int animalNumber) {
    late bool newValueBool;
    if (animalFecesCheckList[animalNumber] == false) {
      newValueBool = true;
    } else if (animalFecesCheckList[animalNumber] == true) {
      newValueBool = false;
    }

    late String newValueString;
    if (animalFecesButtonState[animalNumber] == "Yes") {
      newValueString = "No";
    } else if (animalFecesButtonState[animalNumber] == "No") {
      newValueString = "Yes";
    }

    setState(() {
      animalFecesCheckList[animalNumber] = newValueBool;
      animalFecesButtonState[animalNumber] = newValueString;
    });

    print(nameList[animalNumber]);
    print("is now");
    print(animalFecesCheckList[animalNumber]);
  }

  void saveToSheet(DateTime receivedDate) async {
    Worksheet currentWorksheet =
        await SheetService.getWorkSheetByDate(receivedDate);
    for (int i = 0; i < nameList.length; i++) {
      String uploadValue = '';
      String currentAnimal = nameList[i];
      int currentAnimalStartRow =
          await currentWorksheet.values.rowIndexOf(currentAnimal, inColumn: 6);
      int rowToUpdate = currentAnimalStartRow + (3 * useDate.day) - 1;
      if (animalFecesCheckList[i] == false) {
        uploadValue = 'No';
      } else if (animalFecesCheckList[i] == true) {
        uploadValue = 'Yes';
      }

      await currentWorksheet.values
          .insertValue(uploadValue, column: 4, row: rowToUpdate);
      print('${nameList[i]} has been updated to $uploadValue');
    }
  }
}
