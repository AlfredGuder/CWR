import 'package:documentation_assistant/animal.dart';
import 'package:documentation_assistant/resources.dart';
import 'package:gsheets/gsheets.dart';

Future<bool> sheetLoadoutInit(DateTime receivedDate, List<Animal> animalList,
    Worksheet currentSheet) async {
  //TODO refactor code so that sheetLoadoutInit launches only when creating a new sheet
  //final currentSheet = await SheetService.getWorkSheetByDate(receivedDate);
  //date builder
  int currentMonth = receivedDate.month;

  //determines the amount of entries required for the month
  int daysOfMonth = currentMonth.asMonth()!.days();

  //writes title to 1:1 on sheet
  //TODO merging cells A1 to G1 still required
  await currentSheet.values
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
      animalList[i].animalName,
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
      'Comments'
    ];

    await currentSheet.values.insertRow(nextRow, secondRowValues);

    nextRow = await finalRowChecker(currentSheet);

    //adds a collumn with the dates for the selected month
    List<String> dateCollumnString = [];
    for (int i = 1; i <= daysOfMonth; i++) {
      dateCollumnString.add('$i/$currentMonth');
      dateCollumnString.add(' ');
      dateCollumnString.add(' ');
    }

    await currentSheet.values
        .insertColumn(1, dateCollumnString, fromRow: nextRow);

    //adds a collumn with the Am Mid and Pm title for each day

    List<String> feedCollumnString = [];
    for (int i = 1; i <= daysOfMonth; i++) {
      feedCollumnString.add('AM');
      feedCollumnString.add('MID');
      feedCollumnString.add('PM');
    }

    List<String> noCommentString = [];
    for (int i = 0; i <= daysOfMonth; i++) {
      noCommentString.add('No comments for today');
      noCommentString.add(' ');
      noCommentString.add(' ');
    }

    List<String> defaultFeedingValueString = [];
    for (int i = 1; i <= daysOfMonth; i++) {
      defaultFeedingValueString.add('0');
      defaultFeedingValueString.add('0');
      defaultFeedingValueString.add('0');
    }

    List<String> defaultFecesValueString = [];
    for (int i = 1; i <= daysOfMonth; i++) {
      defaultFecesValueString.add('No');
      defaultFecesValueString.add("");
      defaultFecesValueString.add("");
    }

    await currentSheet.values.insertColumn(
      4,
      defaultFecesValueString,
      fromRow: nextRow,
    );

    await currentSheet.values.insertColumn(
      2,
      feedCollumnString,
      fromRow: nextRow,
    );

    await currentSheet.values
        .insertColumn(7, noCommentString, fromRow: nextRow);

    await currentSheet.values
        .insertColumn(3, defaultFeedingValueString, fromRow: nextRow);

    nextRow = await finalRowChecker(currentSheet);
  }
  return true;
}

finalRowChecker(Worksheet userSheet) async {
  await userSheet.values.appendRow([
    'awe',
  ]);
  int newRowNumber = await userSheet.values.rowIndexOf('awe', inColumn: 1);
  await userSheet.clearRow(newRowNumber);
  return newRowNumber;
}
