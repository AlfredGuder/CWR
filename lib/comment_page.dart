import 'package:documentation_assistant/home_page.dart';
import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';

class Comment_Page extends StatefulWidget {
  Comment_Page({
    Key? key,
    required this.animalNames,
    required this.sheetCredentials,
    required this.sheetId,
    required this.currentDate,
  }) : super(key: key);

  List<String> animalNames;
  String sheetCredentials;
  String sheetId;
  String currentDate;

  @override
  State<Comment_Page> createState() => _Comment_PageState();
}

class _Comment_PageState extends State<Comment_Page> {
  late List<String> nameList;
  late String sheetCreds;
  late String sheetIdentifier;
  late String useDate;
  late TextEditingController commentController;
  Map<String, List<String>> animalCommentMap = {};
  Map<String, int> animalCommentCounterMap = {};
  int commentCounter = 0;

  @override
  void initState() {
    super.initState();
    nameList = widget.animalNames;
    sheetCreds = widget.sheetCredentials;
    sheetIdentifier = widget.sheetId;
    useDate = widget.currentDate;
    commentController = TextEditingController();
    for (int i = 0; i < nameList.length; i++) {
      animalCommentMap.putIfAbsent(nameList[i], () => []);
    }
    //creates a loop to load the current animalcomments into a counter list
    for (int i = 0; i < nameList.length; i++) {
      commentCounter = animalCommentMap[nameList[i]]!.length;
      animalCommentCounterMap[nameList[i]] = commentCounter;
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('return'),
          ),
          ElevatedButton(onPressed: () {}, child: const Text('maptest')),
          ListView.builder(
              shrinkWrap: true,
              itemCount: nameList.length,
              itemBuilder: (BuildContext context, int index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(nameList[index]),
                    Text(animalCommentCounterMap[nameList[index]].toString()),
                    FloatingActionButton(
                      //Animal? animalToUpdate = await animalPicker(selectedDate)
                      onPressed: () async {
                        String additionalComment =
                            await animalCommentViewer(nameList[index]);
                        animalCommentMap[nameList[index]]!
                            .add(additionalComment);
                        setState(() {});
                      },
                      heroTag: 'annimalCommentButton${nameList[index]}',
                      child: const Text('add comment'),
                    ),
                  ],
                );
              })
        ],
      ),
    );
  }

  List<String> tempCommentList = [];

  //Creates a popup window, showing currently stored comments for a specific animal
  Future animalCommentViewer(String animalName) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('$animalName comment list'),
          content: SizedBox(
            height: 300,
            width: double.maxFinite,
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: animalCommentMap[animalName]!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Row(
                      //mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(animalCommentMap[animalName]![index]),
                        FloatingActionButton(
                          onPressed:
                              () {}, //TODO add function to remove a comment
                          child: Text('remove'),
                          heroTag: 'button$index',
                        ),
                        //TODO add a button to accept a new string from user and add it to the list
                      ],
                    );
                  },
                ),
                FloatingActionButton(
                    onPressed: () async {
                      // for (int i = 0;
                      //     i < animalCommentMap[animalName]!.length;
                      //     i++) {
                      //   tempCommentList[i] = animalCommentMap[animalName]![i];
                      // }
                      String newComment = await animalCommentAdd();

                      //tempCommentList.add(newComment);

                      Navigator.of(context).pop(newComment);
                      // if (mounted) {
                      //   Navigator.of(context).pop();
                      // }

                      //animalCommentMap[animalName]!.add(newComment);
                      //Navigator.of(context).pop();
                    },
                    heroTag: 'addComment',
                    child: const Text('add')),
              ],
            ),
          ),
        ),
      );

  Future animalCommentAdd() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter new comment'),
        content: TextField(
          autofocus: true,
          controller: commentController,
          keyboardType: TextInputType.multiline,
        ),
        actions: [
          FloatingActionButton(
            onPressed: submitComment,
            child: const Text('Add'),
          )
        ],
      ),
    );
  }

  void submitComment() {
    Navigator.of(context).pop(
      commentController.text,
    );
  }
}
