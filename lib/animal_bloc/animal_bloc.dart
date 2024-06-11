import 'dart:developer';

import 'package:documentation_assistant/animal.dart';
import 'package:documentation_assistant/animal_bloc/animal_event.dart';
import 'package:documentation_assistant/animal_bloc/animal_state.dart';
import 'package:documentation_assistant/loading_text.dart';
import 'package:documentation_assistant/resources.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gsheets/gsheets.dart';

class AnimalBloc extends Bloc<AnimalEvent, AnimalState> {
  Set<Animal> loadedAnimals = {};

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
                animalSet: loadedAnimals, date: currentDate, page: event.page));
          case AddFeedEvent(
              animalToAdd: Animal targetToAdd,
              currentDate: DateTime curretDate
            ):
            saveThisData(curretDate, targetToAdd, loadedAnimals.toList());
            loadedAnimals.lookup(targetToAdd)!
              ..amFeed = targetToAdd.amFeed
              ..midFeed = targetToAdd.midFeed
              ..pmFeed = targetToAdd.pmFeed;
            emit(PageViewState(
                page: ViewablePages.Animal,
                date: curretDate,
                animalSet: loadedAnimals));

          case AddFecesEvent(
              animalName: String animalName,
              fecesBool: bool fecesBool
            ):
            loadedAnimals.lookup(animalName)!.feces =
                !loadedAnimals.lookup(animalName)!.feces;
            emit(PageViewState(
                page: ViewablePages.Feces,
                date: currentDate,
                animalSet: loadedAnimals));
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
    add(const ViewPage(page: ViewablePages.Animal));
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

//  loadedAnimals.lookup(targetToAdd)!
//               ..amFeed = targetToAdd.amFeed
//               ..midFeed = targetToAdd.midFeed
//               ..pmFeed = targetToAdd.pmFeed;

//fecesList
}


//Feces page

