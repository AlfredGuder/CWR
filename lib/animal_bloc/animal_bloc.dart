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

  for (int i = 0; i < animals.length; i++) {
    int rowToRetrieve = animalAmFeedRows[animals[i].animalName]!;
    animals[i].amFeed = int.parse(columnValues[rowToRetrieve]);
    animals[i].midFeed = int.parse(columnValues[rowToRetrieve + 1]);
    animals[i].pmFeed = int.parse(columnValues[rowToRetrieve + 2]);
  }
}
