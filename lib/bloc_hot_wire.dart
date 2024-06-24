import 'package:documentation_assistant/animal.dart';
import 'package:documentation_assistant/animal_bloc/animal_bloc.dart';
import 'package:documentation_assistant/animal_bloc/animal_event.dart';
import 'package:documentation_assistant/animal_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocHotWire extends StatefulWidget {
  final DateTime currentDate;
  final Map<String, double> fenceValues;

  const BlocHotWire(
      {Key? key, required this.currentDate, required this.fenceValues})
      : super(key: key);

  @override
  State<BlocHotWire> createState() => _BlocHotWireState();
}

class _BlocHotWireState extends State<BlocHotWire> {
  late DateTime useDate;
  late TextEditingController controller;
  late Map<String, double> fenceValueMap;
  final List<String> campList = [
    'LemurFalls',
    'CPF1',
    'CPF2',
    'CPF3',
    'CPF4',
    'CPF5',
    'CPF6',
    'CPF7',
  ];

  @override
  void initState() {
    super.initState();
    useDate = widget.currentDate;
    controller = TextEditingController();
    fenceValueMap = widget.fenceValues;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: campList.length,
        itemBuilder: (BuildContext context, int index) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 150,
                height: 50,
                child: Text(campList[index]),
              ),
              FloatingActionButton(
                heroTag: 'fenceButton${campList[index]}',
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
                onPressed: () async {
                  double newPotentialFenceValue =
                      await updateFenceValue(campList[index]) ?? 3.14159;
                  if (newPotentialFenceValue != 3.14159) {
                    AnimalBloc bloc = context.read<AnimalBloc>();
                    bloc.add(AddFenceValue(
                      fenceToAdd: campList[index],
                      currentDate: useDate,
                      newValue: newPotentialFenceValue,
                    ));
                  }
                },
                child: Text(fenceValueMap[campList[index]].toString()),
              )
            ],
          );
        });
  }

  Future<double?> updateFenceValue(String campName) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            'Enter value for $campName:',
            style: const TextStyle(color: Colors.white),
          ),
          content: TextField(
            autofocus: true,
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          actions: [
            FloatingActionButton(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.black,
              heroTag: 'SubmitButton',
              onPressed: () {
                Navigator.of(context).pop(
                  double.parse(controller.text),
                );
              },
              child: const Text('Update'),
            )
          ],
        ),
      );

  void submitFence() {
    Navigator.of(context).pop(
      double.parse(controller.text),
    );
  }
}
