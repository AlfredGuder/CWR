import 'package:documentation_assistant/home_page.dart';
import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';

class Feces_Page extends StatefulWidget {
  Feces_Page({
    Key? key,
    required this.animalNames,
    required this.sheetCredentials,
    required this.sheetId,
    required this.currentDate,
  }) : super(key: key);
  List<String> animalNames;
  String sheetCredentials;
  String sheetId;
  String currentDate;
  @override
  State<Feces_Page> createState() => _Feces_PageState();
}

class _Feces_PageState extends State<Feces_Page> {
  late List<String> nameList;
  late String sheetCreds;
  late String sheetIdentifier;
  late String useDate;

  late List<bool> animalFecesCheckList = List.filled(nameList.length, false);
  late List<String> animalFecesButtonState = List.filled(nameList.length, "No");

  @override
  void initState() {
    super.initState();
    nameList = widget.animalNames;
    sheetCreds = widget.sheetCredentials;
    sheetIdentifier = widget.sheetId;
    useDate = widget.currentDate;
    checkFecesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Feces"),
      ),
      body: Column(
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
            onPressed: saveToSheet,
            child: const Text('sheet'),
          )
        ],
      ),
    );
  }

  void checkFecesList() async {
    List<bool> tempCheckList = List.filled(nameList.length, false);
    final gsheets = GSheets(sheetCreds);
    final currentSpreasheet = await gsheets.spreadsheet(sheetIdentifier);
    final String dateByMonthYear =
        '${useDate.split('/')[1]}/${useDate.split('/')[2]}';
    var currentWorksheet = currentSpreasheet.worksheetByTitle(dateByMonthYear);
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
          await currentWorksheet!.values.rowIndexOf(currentAnimal, inColumn: 6);
      int rowToCheck =
          currentAnimalStartRow + (3 * int.parse(useDate.split('/')[0])) - 1;

      String receivedValue =
          await currentWorksheet.values.value(column: 4, row: rowToCheck);
      if (receivedValue == 'Yes') {
        tempCheckList[i] = true;
      } else if (receivedValue == 'No') {
        tempCheckList[i] == false;
      }
    }
    setState(() {
      animalFecesCheckList = tempCheckList;
      for (int i = 0; i < animalFecesCheckList.length; i++) {
        if (animalFecesCheckList[i] == true) {
          animalFecesButtonState[i] = 'Yes';
        } else if (animalFecesCheckList[i] == false) {
          animalFecesButtonState[i] = 'No';
        }
      }
    });
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

  void saveToSheet() async {
    final gsheets = GSheets(sheetCreds);
    final currentSpreasheet = await gsheets.spreadsheet(sheetIdentifier);
    final String dateByMonthYear =
        '${useDate.split('/')[1]}/${useDate.split('/')[2]}';
    var currentWorksheet = currentSpreasheet.worksheetByTitle(dateByMonthYear);
    for (int i = 0; i < nameList.length; i++) {
      String uploadValue = '';
      String currentAnimal = nameList[i];
      int currentAnimalStartRow =
          await currentWorksheet!.values.rowIndexOf(currentAnimal, inColumn: 6);
      int rowToUpdate =
          currentAnimalStartRow + (3 * int.parse(useDate.split('/')[0])) - 1;
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
