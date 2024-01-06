import 'package:documentation_assistant/animal.dart';
import 'package:gsheets/gsheets.dart';

void sheetChecker(String sheetCredentials, String sheetId, int monthAsInt,
    int yearAsInt, List<Animal> feedingList) async {
  //init gsheets
  final gsheets = GSheets(sheetCredentials);

  //fetch worksheet by ID
  final globalSheet = await gsheets.spreadsheet(sheetId);

  String searchDate = '$monthAsInt/$yearAsInt';
  //creates a new Worksheet, if one for the current month does not exeist
  if (globalSheet.worksheetByTitle(searchDate) == null) {
    await globalSheet.addWorksheet(searchDate);
    sheetLoadoutInit(globalSheet, searchDate, feedingList);
  } else {
    final currentSheet = globalSheet.worksheetByTitle(searchDate);
  }
}

void sheetLoadoutInit(Spreadsheet receivedSheet, String receivedDate,
    List<Animal> animalList) async {
  final currentSheet = receivedSheet.worksheetByTitle(receivedDate);
  //date builder
  int currentMonth = int.parse(receivedDate.split('/')[0]);
  int currentYear = int.parse(receivedDate.split('/')[1]);

  //determines the amount of entries required for the month
  int daysOfMonth = 0;
  if (currentMonth == 2) {
    daysOfMonth = 28;
  } else if (currentMonth == 1 ||
      currentMonth == 3 ||
      currentMonth == 5 ||
      currentMonth == 7 ||
      currentMonth == 8 ||
      currentMonth == 10 ||
      currentMonth == 12) {
    daysOfMonth = 31;
  } else if (currentMonth == 4 ||
      currentMonth == 6 ||
      currentMonth == 9 ||
      currentMonth == 11) {
    daysOfMonth = 30;
  }

  //writes title to 1:1 on sheet
  //TODO merging cells A1 to G1 still required
  await currentSheet!.values
      .insertValue('Feeding Monitoring Sheet', column: 1, row: 1);

  int nextRow = 2;
  //creates a chart for every animal
  for (int i = 0; i < animalList.length; i++) {
    //adds a row of animal specific, constant information
    List<String> firstRowValues = [
      'Species:',
      animalList[i].species,
      'Sex',
      animalList[i].sex,
      'Name',
      animalList[i].name,
      'Arks nr:',
      animalList[i].arksNo,
    ];
    await currentSheet.values.insertRow(nextRow, firstRowValues);

    nextRow = await finalRowChecker(currentSheet);

    //adds the row that contains all the collumn titles

    List<String> secondRowValues = [
      'Date',
      'Time',
      'Gram',
      'Feces',
      'Weight',
      'Parasite',
      'Commens'
    ];
    int daysToAdd = daysOfMonth + 2;
    await currentSheet.values.insertRow(nextRow, secondRowValues);

    nextRow = await finalRowChecker(currentSheet);

    //adds a collumn with the dates for the selected month
    List<String> dateCollumnString = [];
    for (int i = 1; i < daysToAdd; i++) {
      dateCollumnString.add('$i/$currentMonth');
      dateCollumnString.add(' ');
      dateCollumnString.add(' ');
    }

    await currentSheet.values
        .insertColumn(1, dateCollumnString, fromRow: nextRow);

    //adds a collumn with the Am Mid and Pm title for each day

    List<String> feedCollumnString = [];
    for (int i = 1; i < daysToAdd; i++) {
      feedCollumnString.add('AM');
      feedCollumnString.add('MID');
      feedCollumnString.add('PM');
    }

    await currentSheet.values.insertColumn(
      2,
      feedCollumnString,
      fromRow: nextRow,
    );

    nextRow = await finalRowChecker(currentSheet);
  }
}

finalRowChecker(Worksheet userSheet) async {
  await userSheet.values.appendRow([
    'awe',
  ]);
  int newRowNumber = await userSheet.values.rowIndexOf('awe', inColumn: 1);
  await userSheet.clearRow(newRowNumber);
  return newRowNumber;
}
