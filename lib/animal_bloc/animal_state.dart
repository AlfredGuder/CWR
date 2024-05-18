import 'package:documentation_assistant/animal.dart';
import 'package:documentation_assistant/loading_text.dart';

sealed class AnimalState {}

class AppInitialState extends AnimalState {
  AppInitialState();
}

sealed class DataDisplayState extends AnimalState {
  final Set<Animal> loadedAnimals;
  final DateTime currentDate;
  DataDisplayState({required this.loadedAnimals, required this.currentDate});
}

class LoadingState extends AnimalState {
  final LoadingTypes loadingTypes;

  LoadingState({required this.loadingTypes});
}

class PageViewState extends DataDisplayState {
  final ViewablePages page;

  PageViewState(
      {required this.page,
      required DateTime date,
      required Set<Animal> animalSet})
      : super(currentDate: date, loadedAnimals: animalSet);
}

enum ViewablePages {
  Animal,
  Comment,
  Fence,
}
