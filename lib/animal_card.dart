import 'package:documentation_assistant/animal.dart';
import 'package:flutter/material.dart';

class AnimalCard extends StatefulWidget {
  final List<Animal> animalFeedList;
  const AnimalCard(this.animalFeedList, {super.key});

  @override
  State<AnimalCard> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<AnimalCard> {
  late TextEditingController controller;
  String feedChoice = "MID";
  int animalNumber = 0;

  late List<Animal> animals;

  @override
  void initState() {
    super.initState();
    animals = widget.animalFeedList;
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: animals.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Divider(
                      color: Colors.orange,
                      thickness: 1.5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: 40,
                          width: 100,
                          child: Center(child: Text(animals[index].animalName)),
                        ),
                        Text('AM: ${animals[index].amFeed}'),
                        Text('MID: ${animals[index].midFeed}'),
                        Text('PM: ${animals[index].pmFeed}'),
                      ],
                    )
                  ],
                ));
          }),
    );
  }

  void submit() {
    Navigator.of(context).pop(
      int.parse(controller.text),
    );
  }

  feedPicker() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Choose feed"),
          content: Row(children: [
            ElevatedButton(
              onPressed: () {
                feedChoice = "AM";
                Navigator.of(context).pop();
              },
              child: const Text("AM"),
            ),
            ElevatedButton(
              onPressed: () {
                feedChoice = "MID";
                Navigator.of(context).pop();
              },
              child: const Text("MID"),
            ),
            ElevatedButton(
              onPressed: () {
                feedChoice = "PM";
                Navigator.of(context).pop();
              },
              child: const Text("PM"),
            ),
          ]),
          actions: [
            FloatingActionButton(
              onPressed: cancelButton,
              child: const Text("cancel"),
            ),
          ],
        ),
      );

  chooseFeed(String choice) {
    feedChoice = choice;
  }

  cancelButton() {
    feedChoice = "cancel";
    Navigator.of(context).pop();
  }
}
