import 'package:documentation_assistant/animal.dart';
import 'package:documentation_assistant/sheet_builder.dart';
import 'package:intl/intl.dart';
import 'package:gsheets/gsheets.dart';

class Resources {
  static final DateFormat hiveDataFormat = DateFormat("d-M-y");
}

class SheetService {
  //create credentials
  static const _credentials = r'''
  {
  "type": "service_account",
  "project_id": "cwr-gsheet",
  "private_key_id": "6f2612c22291182a8287873c9a87c13e8138135b",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCVBGaTYFm5mgeU\n70FKE67cs1zvLK00Ls33z7Lr2uv/qqEl1lgh6bYofpDQnuSuCaTGuj+3EI10DWfS\nK7QSVsOg+QFlOYnX5R5WlB382AL5reHjWXMgC50BZvDaU+gHMQVzyKBkFZiBYHEg\nQpG2o3uiMqw7aRmm6XLNw0Jz+JnGrDnEF88tsnJdb08FYWegWx0p2UuCveMiqDeQ\neuryeZ4aPncH8ozk3DV32shsPF5NA2c2UFboA+IjNbu5FkR8SwEYtVL+ue2tQQT6\ndp8GIMdiDphvvIT3LVg3rv7H3n5Q0wRPLFzUK4Rz5SiWmkYaoCEwkfyGKOTnsRB6\nVHQcy8RvAgMBAAECggEANzEPEMyhzsVGw5mts9MAc8uWwxrn96jSLlNl8EcAG4xF\n7S6rK7xU9ECUQEBpcDAwME5xJMtjqLUCW+xF4Hj0Md2n76bU7/pzNxva03fp+jG1\ntS+/HQJQH2HSGPr0uB0m6NBI32jEOD7RB2LAd0Wrl9Juyf5OOuzB0YXdSfisc9Fq\n8lILMQaUV3Q74oqZhQYSxDnXX6cGBA9XVFmt+y+4BFlV218GR8QdslL+ZbOa3Del\nLjD+Mrs5QdotuW7PuSwQjm0sZsr77sudIHO9OH95NX5+EA2UPyFJLyaEkHwdIR5E\nzly9H/eiJhFaBr46bytdEMnnPQKfCH4WUjqxu1LosQKBgQDR0ipS/gQeH0K/k0B/\n0VNtbcJOt4XIv6xGuB/cPnP0OQbyjbQgwBPnge9223BmpqPCLMT+oapEkLxHX17v\ngoN3dgk+pZWhX+bXfpPdC6gMbvBwfEy58nIz6nHWBP2cfZw0XJE2lGmyaLFwATXo\nMk1Rvly/IPOXfGY6xWoD7aqUtwKBgQC10GZa/AlE9dlqybFSH5cKFcspM2Uu43iG\nW78RenjSIsLI0r4P76Tc3R3cgB9VRlnkfOmuUVMhIYEQKTIYBskndisAEThEDpVF\nik31M4LpMoGwnq05cgq8Auiu5OUa2T4chUXysywTxiBd6aA3q+oED97ySxB+dcZD\nx30EQnHGCQKBgDZu2YASWiseXQiqQO9n9MbM1L3rKo/7+cuW9N0EbryLFtxSGsrs\nSb2jneYt46kdzhoP10Nf2XZUPiQd/9kO+OBDBP71oi3tXUvGkMGlxoEDPulPte//\nj9UcG1A0lz7D74Q+B4YrVohsVKwEBGIquphcVF9ZQxinszXIBUrjm39dAoGARaTe\nkFua8V97OPypf9u575MJj26wg5V+xXi/Z+KSBWxrUKHpTBFwBWpt1dj+J5wbMvrm\nSG++eCJtXdNp7Oosg4EwV4ZBF1C+vTSNSC/DJbDDHPSrRiX5FqvGlbf4SqCMukAS\n2zTm3Ww3WcH0LV8c9RFfRVCbsNVMbQotSURqcIECgYAq/4Q6pV2G05y4l5pUqBzn\nSiB/8A3/SKhI94YgbRJzFFHRhzi5FS+b8iNY7KJvjBVHomF06IOFWLgt1W0neGM4\nCUq/qqMaWytr6Y2sWNNuAkOdPFyPY3CXRsZJGC/Rp+MpLBynzG8fSOjUkqidPWt8\nsXzjhzyANDreL3fh+mkbGg==\n-----END PRIVATE KEY-----\n",
  "client_email": "cwr-gsheet@cwr-gsheet.iam.gserviceaccount.com",
  "client_id": "103571088181722491554",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/cwr-gsheet%40cwr-gsheet.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}

''';

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
      bool sheetGenerationFinish =
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
      print('fetching animaldata');
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
      print('fetched animaldata');
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

  static Future<List<Animal>>? getAnimalsByDate(DateTime targetDate) {}
}

//TODO add save/load animal functions

enum Month {
  // ignore: constant_identifier_names
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
