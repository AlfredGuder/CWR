//import 'dart:ffi';

import 'package:documentation_assistant/loading_icon.dart';
import 'package:documentation_assistant/loading_text.dart';
import 'package:documentation_assistant/resources.dart';
import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';

class FecesPage extends StatefulWidget {
  final List<String> animalNames;

  final DateTime currentDate;

  const FecesPage({
    Key? key,
    required this.animalNames,
    required this.currentDate,
  }) : super(key: key);
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
    List<bool> tempCheckList = [];
    Worksheet currentWorksheet = await SheetService.getWorkSheetByDate(useDate);
    List<String> sheetReturnValues = await currentWorksheet.values.column(4);
    List<String> nameRowList = await currentWorksheet.values.column(6);
    for (String currentAnimal in nameList) {
      int currentAnimalNameRow = nameRowList.indexOf(currentAnimal);
      int fecesRow = currentAnimalNameRow + (3 * useDate.day - 1);
      fecesStateMap[currentAnimal] = sheetReturnValues[fecesRow];
      if (fecesStateMap[currentAnimal] == 'Yes') {
        tempCheckList.add(true);
      } else {
        tempCheckList.add(false);
      }
    }

    // List<bool> tempCheckList =
    //     await Future.wait(nameList.map((animalName) async {
    //   print('fetching data for $animalName');
    //   int currentAnimalStartRow =
    //       await currentWorksheet.values.rowIndexOf(animalName, inColumn: 6);
    //   int rowToCheck = currentAnimalStartRow + (3 * useDate.day) - 1;

    //   var fecesData =
    //       await currentWorksheet.values.value(column: 4, row: rowToCheck);

    //   return fecesData == 'Yes';
    // }));

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
          backgroundColor: (Colors.orange),
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
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 500,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: nameList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      height: 40,
                                      width: 100,
                                      child: Text(nameList[index]),
                                    ),
                                    FloatingActionButton(
                                      backgroundColor: (Colors.orange),
                                      foregroundColor: (Colors.black),
                                      heroTag: 'fecesCheckButton$index',
                                      onPressed: () => updateFecesList(index),
                                      child:
                                          Text(animalFecesButtonState[index]),
                                    )
                                  ],
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
                      onPressed: () => saveToSheet(useDate),
                      child: const Text('save'),
                    ),
                  ],
                );
                //int data = snapshot.data!;
              } else {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [LoadingText('Loading')],
                  ),
                );
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
