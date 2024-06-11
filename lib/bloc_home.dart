import 'package:documentation_assistant/animal_bloc/animal_bloc.dart';
import 'package:documentation_assistant/animal_bloc/animal_event.dart';
import 'package:documentation_assistant/animal_bloc/animal_state.dart';
import 'package:documentation_assistant/bloc_animal_page.dart';
import 'package:documentation_assistant/bloc_feces_page.dart';
import 'package:documentation_assistant/loading_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocHome extends StatefulWidget {
  const BlocHome({super.key});

  @override
  State<BlocHome> createState() => _BlocHomeState();
}

class _BlocHomeState extends State<BlocHome> {
  late final AnimalBloc bloc;

  @override
  void initState() {
    bloc = AnimalBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnimalBloc>.value(
      value: bloc,
      child: BlocBuilder<AnimalBloc, AnimalState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: (Colors.orange),
              foregroundColor: (Colors.black),
              title: const Text("Animals"),
              actions: [
                PopupMenuButton<String>(onSelected: (value) {
                  bool enabled = state is! LoadingState;
                  print('Selected $value $enabled');
                  if (enabled) {
                    AnimalBloc bloc = context.read<AnimalBloc>();
                    bloc.add(ViewPage(page: viewablePagesFromString(value)!));
                  }
                }, itemBuilder: (BuildContext context) {
                  return ViewablePages.values
                      .map(
                        (e) => PopupMenuItem(
                          value: e.displayName,
                          child: Row(
                            children: [
                              Icon(e.displayIcon),
                              SizedBox(width: 8),
                              Text(e.displayName),
                            ],
                          ),
                        ),
                      )
                      .toList();
                }),
              ],
            ),
            body: switch (state) {
              AppInitialState() => const Center(child: Text('CWR')),
              LoadingState() => LoadingText(switch (state.loadingTypes) {
                  LoadingTypes.Animal => 'Loading animal data',
                  LoadingTypes.FeedingData => 'Loading feeding data',
                  LoadingTypes.FenceValue => 'Loading fence values',
                }),
              PageViewState(page: ViewablePages.Animal) => BlocAnimalPage(
                  selectedDate: state.currentDate,
                  animals: state.loadedAnimals),
              PageViewState(page: ViewablePages.Feces) => BlocFecesPage(
                  selectedDate: state.currentDate,
                  animals: state.loadedAnimals,
                ),
              //TODO fix this page
              PageViewState(page: ViewablePages.Addition) => BlocFecesPage(
                  selectedDate: state.currentDate,
                  animals: state.loadedAnimals,
                ),
              //TODO fix this page
              PageViewState(page: ViewablePages.Comment) => BlocFecesPage(
                  selectedDate: state.currentDate,
                  animals: state.loadedAnimals,
                ),
              //TODO fix this page
              PageViewState(page: ViewablePages.Fence) => BlocFecesPage(
                  selectedDate: state.currentDate,
                  animals: state.loadedAnimals,
                )
            },
          );
        },
      ),
    );
  }
}

ViewablePages? viewablePagesFromString(String value) {
  return switch (value) {
    'Feeding Data' => ViewablePages.Animal,
    'Comments' => ViewablePages.Comment,
    'Hotwire' => ViewablePages.Fence,
    'Addition' => ViewablePages.Addition,
    _ => null
  };
}
