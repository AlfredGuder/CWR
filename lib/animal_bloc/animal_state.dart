import 'package:documentation_assistant/animal.dart';
import 'package:documentation_assistant/loading_text.dart';
import 'package:flutter/material.dart';

sealed class AnimalState {}

class AppInitialState extends AnimalState {
  AppInitialState();
}

sealed class DataDisplayState extends AnimalState {
  final List<Animal> loadedAnimals;
  final DateTime currentDate;
  final Map<String, double> fenceValues;
  DataDisplayState(
      {required this.loadedAnimals,
      required this.currentDate,
      required this.fenceValues});
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
      required List<Animal> animalList,
      required Map<String, double> fenceValuesMap})
      : super(
            currentDate: date,
            loadedAnimals: animalList,
            fenceValues: fenceValuesMap);
}

enum ViewablePages {
  Animal,
  Comment,
  Fence,
  Addition,
  Feces,
}

extension AppBarExtention on ViewablePages {
  String get displayName => switch (this) {
        ViewablePages.Animal => 'Feeding Data',
        ViewablePages.Comment => 'Comments',
        ViewablePages.Fence => 'Hotwire',
        ViewablePages.Addition => 'Addition',
        ViewablePages.Feces => 'Feces',
      };
  IconData get displayIcon => switch (this) {
        ViewablePages.Animal => Icons.catching_pokemon,
        ViewablePages.Comment => Icons.comment,
        ViewablePages.Fence => Icons.bolt,
        ViewablePages.Addition => Icons.playlist_add_rounded,
        ViewablePages.Feces => Icons.whatshot,
      };
}
