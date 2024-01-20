//import 'dart:ffi';

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
    // setState(() {
    //   isDataLoading = true;
    // });

    List<bool> tempCheckList = List.filled(nameList.length, false);

    Worksheet currentWorksheet = await SheetService.getWorkSheetByDate(useDate);
    //String dateToCheck = '${useDate.split('/')[0]}/${useDate.split(' / ')[1]}';
    //bool animalFecesState = false;
    for (int i = 0; i < nameList.length; i++) {
      // String animalToCheck = nameList[i];
      // int animalToCheckStartRow =
      //     await currentWorksheet!.values.rowIndexOf(animalToCheck, inColumn: 6);
      // int rowToCheck =
      //     animalToCheckStartRow + (3 * int.parse(useDate.split('/')[0])) - 1;

      String currentAnimal = nameList[i];
      int currentAnimalStartRow =
          await currentWorksheet.values.rowIndexOf(currentAnimal, inColumn: 6);
      int rowToCheck = currentAnimalStartRow + (3 * useDate.day) - 1;

      String receivedValue =
          await currentWorksheet.values.value(column: 4, row: rowToCheck);
      if (receivedValue == 'Yes') {
        tempCheckList[i] = true;
      } else if (receivedValue == 'No') {
        tempCheckList[i] = false;
      }
    }
    // setState(() {
    //   animalFecesCheckList = tempCheckList;

    // });

    setState(() {
      for (int i = 0; i < animalFecesCheckList.length; i++) {
        if (tempCheckList[i] == true) {
          animalFecesButtonState[i] = 'Yes';
        } else if (tempCheckList[i] == false) {
          animalFecesButtonState[i] = 'No';
        }
      }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
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
                    ElevatedButton(
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
                                heroTag: 'fecesCheckButton$index',
                                onPressed: () => updateFecesList(index),
                                child: Text(animalFecesButtonState[index]),
                              )
                            ],
                          );
                        }),
                    ElevatedButton(
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
