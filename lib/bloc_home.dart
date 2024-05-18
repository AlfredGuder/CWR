import 'package:documentation_assistant/animal_bloc/animal_bloc.dart';
import 'package:documentation_assistant/animal_bloc/animal_state.dart';
import 'package:documentation_assistant/bloc_animal_page.dart';
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
                }, itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem(
                        value: 'Hotwire',
                        child: Row(
                          children: [
                            Icon(Icons.bolt),
                            SizedBox(width: 8),
                            Text('Hotwire'),
                          ],
                        )),
                    const PopupMenuItem(
                      value: 'Comment',
                      child: Row(
                        children: [
                          Icon(Icons.comment),
                          SizedBox(width: 8),
                          Text('Comment'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'Animals',
                      child: Row(
                        children: [
                          Icon(Icons.add),
                          SizedBox(width: 8),
                          Text('Animals')
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                        value: 'Feces',
                        child: Row(
                          children: [
                            Icon(Icons.whatshot),
                            SizedBox(width: 8),
                            Text('Feces'),
                          ],
                        ))
                  ];
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
              PageViewState() => BlocAnimalPage(
                  selectedDate: state.currentDate, animals: state.loadedAnimals)
            },
          );
        },
      ),
    );
  }
}
