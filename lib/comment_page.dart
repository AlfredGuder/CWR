import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';
import 'resources.dart';

//TODO optimize load time like in home page
class Comment_Page extends StatefulWidget {
  final List<String> animalNameList;

  final DateTime currentDate;

  const Comment_Page({
    Key? key,
    required this.animalNameList,
    required this.currentDate,
  }) : super(key: key);

  @override
  State<Comment_Page> createState() => _Comment_PageState();
}

class _Comment_PageState extends State<Comment_Page> {
  late List<String> animalNameList;
  late String sheetCreds;
  late String sheetIdentifier;
  late DateTime useDate;
  late TextEditingController controller;
  List<String> commentList = ['testAwe']; //TODO fix this
  Map<String, List<String>> animalCommentMap = {};

  bool isDataLoading = false;

  @override
  void initState() {
    super.initState();
    animalNameList = widget.animalNameList;

    useDate = widget.currentDate;
    controller = TextEditingController();
    commentMapBuilder();
    //generateCommentMap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Comments'),
        ),
        body: Center(
          child: FutureBuilder(
            initialData: false,
            future: isDataLoading ? null : generateCommentMap(),
            builder: (context, snapshot) {
              if (isDataLoading == true) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Return'),
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: animalNameList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(animalNameList[index]),
                              ElevatedButton(
                                onPressed: () async {
                                  await commentScreen(animalNameList[index]);
                                },
                                child: const Text('Check'),
                              ),
                            ],
                          );
                        })
                  ],
                );
              } else {
                return const Text("Loading...");
              }
            },
          ),
        ));
  }
  //

  void commentMapBuilder() {
    for (int i = 0; i < animalNameList.length; i++) {
      animalCommentMap.putIfAbsent(animalNameList[i], () => []);
    }
  }

  Future<bool?> generateCommentMap() async {
    //
    //add laoding indicatior

    String searchDate = useDate.day.toString();
    Worksheet currentWorksheet = await SheetService.getWorkSheetByDate(useDate);
    for (int i = 0; i < animalNameList.length; i++) {
      String currentAnimal = animalNameList[i];
      int currentAnimalStartingRow =
          await currentWorksheet.values.rowIndexOf(currentAnimal, inColumn: 6);
      int commentRow =
          currentAnimalStartingRow + (3 * int.parse(searchDate) - 1);
      String receivedCommentString =
          await currentWorksheet.values.value(column: 7, row: commentRow);

      if (receivedCommentString == 'No comments for today') {
        animalCommentMap[currentAnimal]!.add(receivedCommentString);
      } else {
        List<String> spltCommentStringList = receivedCommentString.split('//');
        for (int j = 0; j < spltCommentStringList.length; j++) {
          animalCommentMap[currentAnimal]!.add(spltCommentStringList[j]);
        }
      }

      //animalCommentMap[currentAnimal]!.add(receivedCommentString);
    }
    setState(() {
      isDataLoading = true;
    });
    return true;
  }

  Future commentScreen(String currentAnimal) async {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Comments for $currentAnimal'),
              content: SizedBox(
                height: 200,
                width: double.maxFinite,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: animalCommentMap[currentAnimal]!
                        .length, //TODO fix this error
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          Text(animalCommentMap[currentAnimal]![index]),
                        ],
                      );
                    }),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel')),
                    ElevatedButton(
                        onPressed: () {
                          removeButton(currentAnimal);
                          setState(() {});
                        },
                        child: const Text('Remove')),
                    ElevatedButton(
                        onPressed: () async {
                          String newPotentialComment =
                              await commentAdder() ?? '';
                          if (newPotentialComment != '') {
                            setState(() {
                              if (animalCommentMap[currentAnimal]![0] ==
                                  'No comments for today') {
                                animalCommentMap[currentAnimal]!.removeAt(0);
                              }

                              animalCommentMap[currentAnimal]!
                                  .add(newPotentialComment);
                            });
                          }
                        },
                        child: const Text('Add')),
                    ElevatedButton(
                        onPressed: () {
                          saveCommentString(currentAnimal);
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

  void removeButton(String currentAnimal) {
    animalCommentMap[currentAnimal]!.removeLast();
    if (animalCommentMap[currentAnimal]!.isEmpty) {
      animalCommentMap[currentAnimal]!.add('No comments for today');
    }

    saveCommentString(currentAnimal);
  }

  void saveCommentString(String currentAnimal) async {
    String uploadString = '';
    String searchDate = useDate.day.toString();
    Worksheet currentWorkSheet = await SheetService.getWorkSheetByDate(useDate);
    int currentAnimalStartingRow =
        await currentWorkSheet.values.rowIndexOf(currentAnimal, inColumn: 6);
    int commentRow = currentAnimalStartingRow + (3 * int.parse(searchDate) - 1);

    if (animalCommentMap[currentAnimal]!.length == 1) {
      uploadString = animalCommentMap[currentAnimal]![0];
    } else {
      for (int i = 0; i < animalCommentMap[currentAnimal]!.length; i++) {
        uploadString = '$uploadString//${animalCommentMap[currentAnimal]![i]}';
      }
    }
    currentWorkSheet.values
        .insertValue(uploadString, column: 7, row: commentRow);

    uploadString = '';
  }

  Future<String?> commentAdder() => showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text('Write new comment'),
            content: TextField(
              autofocus: true,
              controller: controller,
              keyboardType: TextInputType.text,
            ),
            actions: [
              FloatingActionButton(
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
}
