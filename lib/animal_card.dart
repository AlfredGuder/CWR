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
      height: 500,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: animals.length,
          itemBuilder: (BuildContext context, int index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(animals[index].animalName),
                Text("AM:${animals[index].amFeed}"),
                Text("MID:${animals[index].midFeed}"),
                Text("PM:${animals[index].pmFeed}"),
              ],
            );
          }),
    );

    /*
    Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            animalFeedList[animalNumber].animalName,
          ),
          Text("AM:${animalFeedList[animalNumber].amFeed.toString()}"),
          Text("MID:${animalFeedList[animalNumber].midFeed.toString()}"),
          Text("PM:${animalFeedList[animalNumber].pmFeed.toString()}"),
          FloatingActionButton(
            onPressed: () async {
              final feedAmount = await _dialogBuilder();
              //if (feedAmount == null || feedAmount.isEmpty) return;
              await feedPicker();
              setState(() {
                if (feedChoice == "AM") {
                  this.animalFeedList[animalNumber].amFeed = feedAmount as int;
                } else if (feedChoice == "MID") {
                  this.animalFeedList[animalNumber].midFeed = feedAmount as int;
                } else if (feedChoice == "PM") {
                  this.animalFeedList[animalNumber].pmFeed = feedAmount as int;
                } else if (feedChoice == "cancel") {
                  return;
                }
              });
              print(animalFeedList[animalNumber].amFeed);
            },
            child: const Text("Add"),
          )
        ],
      ),
    );

  */
  }

  // Future<int?> _dialogBuilder() => showDialog<int>(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: const Text("Enter amount:"),
  //         content: TextField(
  //           autofocus: true,
  //           controller: controller,
  //           keyboardType: TextInputType.number,
  //           inputFormatters: <TextInputFormatter>[
  //             FilteringTextInputFormatter.digitsOnly
  //           ],
  //         ),
  //         actions: [
  //           FloatingActionButton(
  //             onPressed: submit,
  //             child: const Text("Submit"),
  //           )
  //         ],
  //       ),
  //     );

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
