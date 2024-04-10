import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';
import 'package:documentation_assistant/resources.dart';
import 'package:documentation_assistant/loading_text.dart';

//TODO optimize load time like in home page
class CommentPage extends StatefulWidget {
  final List<String> animalNameList;

  final DateTime currentDate;

  const CommentPage({
    Key? key,
    required this.animalNameList,
    required this.currentDate,
  }) : super(key: key);

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
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
          backgroundColor: Colors.orange,
          foregroundColor: Colors.black,
          title: const Text('Comments'),
        ),
        body: Center(
          child: FutureBuilder(
            initialData: false,
            future: isDataLoading ? null : generateCommentMap(),
            builder: (context, snapshot) {
              if (isDataLoading == true) {
                return SizedBox(
                  height: 500,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: animalNameList.length,
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
                                child: Text(animalNameList[index]),
                              ),
                              FloatingActionButton(
                                heroTag:
                                    'checkButtonFor${animalNameList[index]}',
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.black,
                                onPressed: () async {
                                  await commentScreen(animalNameList[index]);
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
              } else {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [LoadingText('Loading comments')],
                  ),
                );
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

    List<String> animalNameValues = await currentWorksheet.values.column(6);
    List<String> commentRowValues = await currentWorksheet.values.column(7);

    for (String currentAnimal in animalNameList) {
      int animalNameRow = animalNameValues.indexOf(currentAnimal);
      int commentRow = animalNameRow + (3 * useDate.day - 1);
      String currentAnimalCommentData = commentRowValues[commentRow];

      if (currentAnimalCommentData == 'No comments for today') {
        animalCommentMap[currentAnimal]!.add(currentAnimalCommentData);
      } else {
        List<String> spltCommentStringList =
            currentAnimalCommentData.split('//');
        for (int j = 0; j < spltCommentStringList.length; j++) {
          animalCommentMap[currentAnimal]!.add(spltCommentStringList[j]);
        }
      }
    }

    // for (int i = 0; i < animalNameList.length; i++) {
    //   String currentAnimal = animalNameList[i];
    //   int currentAnimalStartingRow =
    //       await currentWorksheet.values.rowIndexOf(currentAnimal, inColumn: 6);
    //   int commentRow =
    //       currentAnimalStartingRow + (3 * int.parse(searchDate) - 1);
    //   String receivedCommentString =
    //       await currentWorksheet.values.value(column: 7, row: commentRow);

    //   //animalCommentMap[currentAnimal]!.add(receivedCommentString);
    // }
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
                    FloatingActionButton(
                        heroTag: 'cancelButton',
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.black,
                        onPressed: () {
                          Navigator.pop(context);
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
                              if (animalCommentMap[currentAnimal]![0] ==
                                  'No comments for today') {
                                animalCommentMap[currentAnimal]!.removeAt(0);
                              }

                              animalCommentMap[currentAnimal]!
                                  .add(newPotentialComment);
                            });
                            saveCommentString(currentAnimal);
                          }
                        },
                        child: const Text('Add')),
                    FloatingActionButton(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.black,
                        heroTag: 'saveButton',
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
}
