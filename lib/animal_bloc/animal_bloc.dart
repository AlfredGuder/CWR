import 'dart:developer';

import 'package:documentation_assistant/animal.dart';
import 'package:documentation_assistant/animal_bloc/animal_event.dart';
import 'package:documentation_assistant/animal_bloc/animal_state.dart';
import 'package:documentation_assistant/loading_text.dart';
import 'package:documentation_assistant/resources.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gsheets/gsheets.dart';

class AnimalBloc extends Bloc<AnimalEvent, AnimalState> {
  List<Animal> loadedAnimals = [];
  List<String> fenceList = [
    'LemurFalls',
    'CPF1',
    'CPF2',
    'CPF3',
    'CPF4',
    'CPF5',
    'CPF6',
    'CPF7',
  ];

  Map<String, List<String>> commentMap = {};
  Map<String, double> fenceMap = {};

  DateTime currentDate = DateTime.now();
  AnimalBloc() : super(AppInitialState()) {
    // on<LoadingStarted>(
    //   (event, emit) => emit(LoadingState(loadingTypes: event.loadingTypes)),
    // );
    on<AnimalEvent>(
      (event, emit) async {
        switch (event) {
          case LoadingStarted():
            emit(LoadingState(loadingTypes: event.loadingTypes));
          case ViewPage():
            emit(PageViewState(
                fenceValuesMap: fenceMap,
                animalList: loadedAnimals,
                date: currentDate,
                page: event.page));
          case AddFeedEvent(
              animalToAdd: Animal targetToAdd,
              currentDate: DateTime curretDate
            ):
            saveThisData(curretDate, targetToAdd, loadedAnimals);
            int animalNumber = loadedAnimals.indexOf(targetToAdd);
            loadedAnimals[animalNumber]
              ..amFeed = targetToAdd.amFeed
              ..midFeed = targetToAdd.midFeed
              ..pmFeed = targetToAdd.pmFeed;
            emit(PageViewState(
                fenceValuesMap: fenceMap,
                page: ViewablePages.Animal,
                date: curretDate,
                animalList: loadedAnimals));

          case ToggleFecesEvent(
              targetAnimal: Animal animalName,
            ):
            int animalNumber = loadedAnimals.indexOf(animalName);
            // loadedAnimals[animalNumber].feces =
            //     !loadedAnimals[animalNumber].feces;
            if (loadedAnimals[animalNumber].feces == true) {
              loadedAnimals[animalNumber].feces = false;
            } else {
              loadedAnimals[animalNumber].feces = true;
            }
            emit(PageViewState(
                fenceValuesMap: fenceMap,
                page: ViewablePages.Feces,
                date: currentDate,
                animalList: loadedAnimals));

          case SaveFecesEvent():
            saveFecesData();

          case AddFenceValue(
              fenceToAdd: String campName,
              newValue: double userValue,
            ):
            fenceMap[campName] = userValue;
            saveFenceData(campName);
            emit(PageViewState(
                fenceValuesMap: fenceMap,
                page: ViewablePages.Fence,
                date: currentDate,
                animalList: loadedAnimals));
        }
      },
    );
    fetchAnimalList();
  }

  Future<void> fetchAnimalList() async {
    // await Future.delayed(Duration.zero);
    add(const LoadingStarted(loadingTypes: LoadingTypes.Animal));
    List<Animal> animalList = await SheetService.animalFeedListBuilder();
    add(const LoadingStarted(loadingTypes: LoadingTypes.FeedingData));
    await loadFeedingDataForDate(currentDate, animalList);
    loadedAnimals.addAll(animalList);

    add(const LoadingStarted(loadingTypes: LoadingTypes.FenceValue));
    fenceMap = await getFenceValues()!;
    add(const ViewPage(page: ViewablePages.Animal));

    add(const LoadingStarted(loadingTypes: LoadingTypes.FenceValue));
    await getCommentMap();
  }

  Future<void> loadFeedingDataForDate(
      DateTime currentDate, List<Animal> animals) async {
    Worksheet currentWorksheet =
        await SheetService.checkSheetforDate(currentDate, animals);

    Map<String, int> animalAmFeedRows = {};

    List<String> nameColumnValues = await currentWorksheet.values.column(6);
    for (Animal currentAnimal in animals) {
      int animalNameRowNumber =
          nameColumnValues.indexOf(currentAnimal.animalName);
      int amFeedRow = animalNameRowNumber + (3 * currentDate.day - 1);
      animalAmFeedRows.putIfAbsent(currentAnimal.animalName, () => amFeedRow);
    }

    List<String> columnValues = await currentWorksheet.values.column(3);
    List<String> fecesValues = await currentWorksheet.values.column(4);

    for (int i = 0; i < animals.length; i++) {
      int rowToRetrieve = animalAmFeedRows[animals[i].animalName]!;
      animals[i].amFeed = int.parse(columnValues[rowToRetrieve]);
      animals[i].midFeed = int.parse(columnValues[rowToRetrieve + 1]);
      animals[i].pmFeed = int.parse(columnValues[rowToRetrieve + 2]);
      String fecesText = fecesValues[rowToRetrieve];
      if (fecesText == 'Yes') {
        animals[i].feces = true;
      } else {
        animals[i].feces = false;
      }
    }
  }

  Future<Map<String, double>>? getFenceValues() async {
    Map<String, double> fenceValueMap = {};

    Worksheet currentWorksheet =
        await SheetService.checkHotWireSheet(currentDate);

    fenceList.map((campName) {
      fenceValueMap.putIfAbsent(campName, () => 0);
    });

    int checkColumn = currentDate.month + 1;
    List<String> allValues = await currentWorksheet.values.column(checkColumn);
    for (String currentCamp in fenceList) {
      int startRow =
          await currentWorksheet.values.rowIndexOf(currentCamp, inColumn: 1);

      int checkRow = startRow + currentDate.day;

      double campValue = double.parse(allValues[checkRow - 1]);

      // double campValue = double.parse(await currentWorksheet.values
      //     .value(column: checkColumn, row: checkRow));
      fenceValueMap[currentCamp] = campValue;
    }

    return fenceValueMap;
  }

  Future<void> getCommentMap() async {
    for (Animal currentAnimal in loadedAnimals) {
      commentMap.putIfAbsent(currentAnimal.animalName, () => []);
    }
    Worksheet currentWorksheet =
        await SheetService.getWorkSheetByDate(currentDate);
    List<String> animalNameValues = await currentWorksheet.values.column(6);
    List<String> commentRowValues = await currentWorksheet.values.column(7);

    for (Animal currentAnimal in loadedAnimals) {
      int animalNameRow = animalNameValues.indexOf(currentAnimal.animalName);
      int commentRow = animalNameRow + (3 * currentDate.day - 1);
      String currentAnimalCommentData = commentRowValues[commentRow];

      if (currentAnimalCommentData == 'No comments for today') {
        commentMap[currentAnimal.animalName]!.add(currentAnimalCommentData);
      } else {
        List<String> spltCommentStringList =
            currentAnimalCommentData.split('//');
        for (int j = 0; j < spltCommentStringList.length; j++) {
          commentMap[currentAnimal]!.add(spltCommentStringList[j]);
        }
      }
    }
  }

//TODO parse lsit of new animals, and list of old animals, calculate which ones chanced, only update them
  Future<void> saveThisData(
    DateTime receivedDate,
    Animal animalToSave,
    List<Animal> allAnimals,
  ) async {
    final Worksheet currentWorkSheet =
        await SheetService.checkSheetforDate(receivedDate, allAnimals);

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

  Future<void> saveFecesData() async {
    final Worksheet currentWorkSheet =
        await SheetService.checkSheetforDate(currentDate, loadedAnimals);

    for (Animal thisAnimal in loadedAnimals) {
      String currentAnimalName = thisAnimal.animalName;
      int currentAnimalStartingRow = await currentWorkSheet.values
          .rowIndexOf(currentAnimalName, inColumn: 6);
      int amFeedRow = currentAnimalStartingRow + (3 * currentDate.day - 1);
      await currentWorkSheet.values.insertValue(thisAnimal.feces ? "Yes" : "No",
          column: 4, row: amFeedRow);
    }
  }

  Future<void> saveFenceData(String campname) async {
    final Worksheet currentWorksheet =
        await SheetService.checkHotWireSheet(currentDate);
    for (String currentCamp in fenceList) {
      int currentCampRow =
          await currentWorksheet.values.rowIndexOf(currentCamp);
      int currentMonthRow = currentDate.month + 1;
      int currentDayRow = currentDate.day + currentCampRow;
      await currentWorksheet.values.insertValue(fenceMap[currentCamp]!,
          column: currentMonthRow, row: currentDayRow);
    }
  }
}


//Feces page

