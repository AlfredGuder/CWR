import 'package:documentation_assistant/animal.dart';
import 'package:documentation_assistant/animal_bloc/animal_bloc.dart';
import 'package:documentation_assistant/animal_bloc/animal_event.dart';
import 'package:documentation_assistant/animal_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocCommentpage extends StatefulWidget {
  final DateTime currentDate;
  final List<Animal> animalList;
  final Map<String, List<String>> commentMap;

  const BlocCommentpage(
      {super.key,
      required this.currentDate,
      required this.commentMap,
      required this.animalList});

  @override
  State<BlocCommentpage> createState() => _BlocCommentpageState();
}

class _BlocCommentpageState extends State<BlocCommentpage> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.commentMap.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 100,
                    height: 50,
                    child: Text(widget.animalList[index].animalName),
                  ),
                  FloatingActionButton(
                    heroTag:
                        'checkButtonFor${widget.animalList[index].animalName}',
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.black,
                    onPressed: () async {
                      await commentScreen(widget.animalList[index].animalName);
                    },
                    child: const Text('Check'),
                  ),
                ],
              ),
              const Divider(
                color: Colors.orange,
                thickness: 1.5,
              ),
            ],
          );
        },
      ),
    );
  }

  Future commentScreen(String currentAnimal) async {
    final blocContext = context;

    showDialog(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(builder: (builderContext, setState) {
            return AlertDialog(
              backgroundColor: Colors.black,
              titleTextStyle: const TextStyle(
                color: Colors.white,
              ),
              contentTextStyle: const TextStyle(
                color: Colors.orange,
              ),
              title: Text('Comments for $currentAnimal'),
              content: SizedBox(
                height: 200,
                width: double.maxFinite,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.commentMap[currentAnimal]!
                        .length, //TODO fix this error
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          Text(widget.commentMap[currentAnimal]![index]),
                        ],
                      );
                    }),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                        heroTag: 'cancelButton',
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.black,
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        child: const Text('Cancel')),
                    FloatingActionButton(
                        heroTag: 'removeButton',
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.black,
                        onPressed: () {
                          removeButton(currentAnimal);
                          setState(() {});
                        },
                        child: const Text('Remove')),
                    FloatingActionButton(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.black,
                        heroTag: 'addButton',
                        onPressed: () async {
                          String newPotentialComment =
                              await commentAdder() ?? '';
                          if (newPotentialComment != '') {
                            setState(() {
                              if (widget.commentMap[currentAnimal]![0] ==
                                  'No comments for today') {
                                widget.commentMap[currentAnimal]!.removeAt(0);
                              }

                              widget.commentMap[currentAnimal]!
                                  .add(newPotentialComment);
                            });
                            AnimalBloc bloc = blocContext.read<AnimalBloc>();
                            bloc.add(SaveAnimalComment(
                              targetAnimal: currentAnimal,
                            ));
                          }
                        },
                        child: const Text('Add')),
                    FloatingActionButton(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.black,
                        heroTag: 'saveButton',
                        onPressed: () {
                          AnimalBloc bloc = blocContext.read<AnimalBloc>();
                          bloc.add(SaveAnimalComment(
                            targetAnimal: currentAnimal,
                          ));
                          Navigator.of(context).pop();
                        },
                        child: const Text('Save')),
                  ],
                )
              ],
            );
          });
        });
  }

  Future<String?> commentAdder() => showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
            backgroundColor: Colors.black,
            titleTextStyle: const TextStyle(
              color: Colors.white,
            ),
            contentTextStyle: const TextStyle(
              color: Colors.white,
            ),
            title: const Text('Write new comment'),
            content: TextField(
              autofocus: true,
              controller: controller,
              keyboardType: TextInputType.text,
            ),
            actions: [
              FloatingActionButton(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
                onPressed: submitComment,
                //return controller.text;
                //controller.clear();

                heroTag: 'submitButton',
                child: const Text('Submit'),
              )
            ],
          ));

  void submitComment() {
    Navigator.of(context).pop(
      controller.text,
    );
    controller.clear();
  }

  void removeButton(String currentAnimal) {
    widget.commentMap[currentAnimal]!.removeLast();
    if (widget.commentMap[currentAnimal]!.isEmpty) {
      widget.commentMap[currentAnimal]!.add('No comments for today');
    }

    AnimalBloc bloc = context.read<AnimalBloc>();
    bloc.add(SaveAnimalComment(
      targetAnimal: currentAnimal,
    ));
  }
}
