// ignore_for_file: constant_identifier_names

import 'package:documentation_assistant/animal.dart';
import 'package:documentation_assistant/sheet_builder.dart';
import 'package:intl/intl.dart';
import 'package:gsheets/gsheets.dart';

class Resources {
  static final DateFormat hiveDataFormat = DateFormat("d-M-y");
}

class SheetService {

static void setCredentials(String creds) {
  _credentials = creds;
}

  //create credentials
  static late String _credentials;

//spreadsheet id
  static const _spreadsheetId = '1KC65Z6baN0ayLJmWN1npzzDXt6Lrdvsi0M4Z4FPdP3Y';

  static Future<Worksheet> getWorkSheetByDate(DateTime targetDate) async {
    final sheetsClient = GSheets(_credentials);
    final currentSpreadSheet = await sheetsClient.spreadsheet(_spreadsheetId);

    final String dateByMonthYear = '${targetDate.month}/${targetDate.year}';

    return currentSpreadSheet.worksheetByTitle(dateByMonthYear) ??
        await createWorksheet(dateByMonthYear);
  }

  static Future<Worksheet?> getWorkSheetByTitle(String title) async {
    final sheetsClient = GSheets(_credentials);
    final currentSpreadSheet = await sheetsClient.spreadsheet(_spreadsheetId);

    return currentSpreadSheet.worksheetByTitle(title);
  }

  static Future<Worksheet> checkSheetforDate(
      DateTime targetDate, List<Animal> animalNameList) async {
    final sheetsClient = GSheets(_credentials);
    final currentSpreadSheet = await sheetsClient.spreadsheet(_spreadsheetId);

    final String dateByMonthYear = '${targetDate.month}/${targetDate.year}';
    if (currentSpreadSheet.worksheetByTitle(dateByMonthYear) == null) {
      Worksheet newSheet = await createWorksheet(dateByMonthYear);
      await sheetLoadoutInit(targetDate, animalNameList, newSheet);
      return newSheet;
    } else {
      Worksheet thisSheet =
          currentSpreadSheet.worksheetByTitle(dateByMonthYear)!;
      return thisSheet;
    }
  }

  static Future<List<Animal>> animalFeedListBuilder() async {
    final sheetsClient = GSheets(_credentials);
    final currentSpreadSheet = await sheetsClient.spreadsheet(_spreadsheetId);
    Worksheet animalListSheet =
        currentSpreadSheet.worksheetByTitle("AnimalFeedSheet")!;

    int listLength = 0;
    String nextNameValue = "Empty";
    int beginCheckAt = 3;
    while (nextNameValue != '') {
      listLength++;
      beginCheckAt++;
      nextNameValue =
          await animalListSheet.values.value(column: 1, row: beginCheckAt);
    }

    List<Animal> animalListToReturn = [];

    for (int i = 0; i < listLength; i++) {
      int rowToCheck = 3 + i;
      print('Fetching animaldata');
      var data = await Future.wait([
        animalListSheet.values.value(column: 1, row: rowToCheck), //Name
        animalListSheet.values.value(column: 4, row: rowToCheck), //arks
        animalListSheet.values.value(column: 3, row: rowToCheck), //sex
        animalListSheet.values.value(column: 2, row: rowToCheck),
      ] //species
          );

      Animal newAnimalToList = Animal(
        animalName: data[0],
        arksNo: data[1],
        sex: data[2],
        species: data[3],
        amFeed: 0,
        midFeed: 0,
        pmFeed: 0,
      );
      print('Fetched animaldata');
      animalListToReturn.add(newAnimalToList);
    }

    return animalListToReturn;
  }

  static Future<void> removeAnimalRow(String animalName) async {
    Worksheet? animalDataSheet = await getWorkSheetByTitle('AnimalFeedSheet');
    int removeRow = await animalDataSheet!.values.rowIndexOf(animalName);
    animalDataSheet.deleteRow(removeRow);
  }

  static Future<Spreadsheet?> getGlobalSpreadSheet() async {
    final sheetsClient = GSheets(_credentials);
    return await sheetsClient.spreadsheet(_spreadsheetId);
  }

  static Future<Worksheet> createWorksheet(String title) async {
    Spreadsheet globalSheet = (await getGlobalSpreadSheet())!;
    return await globalSheet.addWorksheet(title);
  }

  static Future<List<Animal>>? getAnimalsByDate(DateTime targetDate) { return Future.value([]);}
}

//TODO add save/load animal functions

enum Month {
  Jan,
  Feb,
  Mar,
  Apr,
  May,
  Jun,
  Jul,
  Aug,
  Sep,
  Oct,
  Nov,
  Dec
}

extension NumberUtils on Month {
  int days() {
    switch (this) {
      case Month.Jan:
        return 31;
      case Month.Feb:
        return 28;
      case Month.Mar:
        return 31;
      case Month.Apr:
        return 30;
      case Month.May:
        return 31;
      case Month.Jun:
        return 30;
      case Month.Jul:
        return 31;
      case Month.Aug:
        return 31;
      case Month.Sep:
        return 30;
      case Month.Oct:
        return 31;
      case Month.Nov:
        return 30;
      case Month.Dec:
        return 31;
    }
  }

  int asInt() {
    switch (this) {
      case Month.Jan:
        return 1;
      case Month.Feb:
        return 2;
      case Month.Mar:
        return 3;
      case Month.Apr:
        return 4;
      case Month.May:
        return 5;
      case Month.Jun:
        return 6;
      case Month.Jul:
        return 7;
      case Month.Aug:
        return 8;
      case Month.Sep:
        return 9;
      case Month.Oct:
        return 10;
      case Month.Nov:
        return 11;
      case Month.Dec:
        return 12;
    }
  }
}

extension MonthParsing on int {
  Month? asMonth() {
    switch (this) {
      case 1:
        return Month.Jan;
      case 2:
        return Month.Feb;
      case 3:
        return Month.Mar;
      case 4:
        return Month.Apr;
      case 5:
        return Month.Mar;
      case 6:
        return Month.Jun;
      case 7:
        return Month.Jul;
      case 8:
        return Month.Aug;
      case 9:
        return Month.Sep;
      case 10:
        return Month.Oct;
      case 11:
        return Month.Nov;
      case 12:
        return Month.Dec;

      default:
        return null;
    }
  }
}
