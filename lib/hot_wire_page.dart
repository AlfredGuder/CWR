import 'package:documentation_assistant/resources.dart';
import 'package:flutter/material.dart';
import 'package:documentation_assistant/loading_text.dart';

import 'package:gsheets/gsheets.dart';

class HotWirePage extends StatefulWidget {
  final DateTime currentDate;

   const HotWirePage({Key? key, required this.currentDate}) : super(key: key);

  @override
  State<HotWirePage> createState() => _HotWirePageState();
}

class _HotWirePageState extends State<HotWirePage> {
  late DateTime useDate;
  late TextEditingController controller;
  Map<String, double> fenceValueMap = {};
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
  bool isDataLoading = false;

  Future<bool>? getFenceValues() async {
    Worksheet currentWorksheet = await SheetService.checkHotWireSheet(useDate);

    campList.map((campName) {
      fenceValueMap.putIfAbsent(campName, () => 0);
    });

    int checkColumn = useDate.month + 1;
    List<String> allValues = await currentWorksheet.values.column(checkColumn);
    for (String currentCamp in campList) {
      int startRow =
          await currentWorksheet.values.rowIndexOf(currentCamp, inColumn: 1);

      int checkRow = startRow + useDate.day;

      double campValue = double.parse(allValues[checkRow - 1]);

      // double campValue = double.parse(await currentWorksheet.values
      //     .value(column: checkColumn, row: checkRow));
      fenceValueMap[currentCamp] = campValue;
    }
    setState(() {
      isDataLoading = true;
    });
    return true;
  }

  @override
  void initState() {
    super.initState();
    useDate = widget.currentDate;
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.black,
        title: const Text('Hotwire'),
      ),
      body: Center(
        child: FutureBuilder<bool>(
          future: isDataLoading ? null : getFenceValues(),
          builder: (context, snapshot) {
            if (isDataLoading == true) {
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
                                await updateFenceValue(campList[index]) ??
                                    3.14159;
                            if (newPotentialFenceValue != 3.14159) {
                              await saveNewReading(
                                  campList[index], newPotentialFenceValue);
                              setState(() {
                                fenceValueMap[campList[index]] =
                                    newPotentialFenceValue;
                              });
                            }
                          },
                          child:
                              Text(fenceValueMap[campList[index]].toString()),
                        )
                      ],
                    );
                  });
            } else {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [LoadingText('Fetching fence values')],
                ),
              );
            }
          },
        ),
      ),
    );
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
              onPressed: submitFenceAmount,
              child: const Text('Update'),
            )
          ],
        ),
      );

  void submitFenceAmount() {
    Navigator.of(context).pop(
      double.parse(controller.text),
    );
    controller.clear();
  }

  Future<void> saveNewReading(String campName, double newReading) async {
    Worksheet currentWorksheet = await SheetService.checkHotWireSheet(useDate);
    int nameRow =
        await currentWorksheet.values.rowIndexOf(campName, inColumn: 1);
    int newReadingRow = nameRow + useDate.day;
    int newReadingColumn = useDate.month + 1;

    await currentWorksheet.values
        .insertValue(newReading, column: newReadingColumn, row: newReadingRow);
  }
}
