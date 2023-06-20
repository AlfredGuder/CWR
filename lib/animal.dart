import 'dart:convert';

import 'package:documentation_assistant/date_recording.dart';

class Animal {
  String name;
  Map<String, DateRecording> gatherData;
  String species;
  String sex;
  String arksNo;

  Animal(
      {required this.name,
      required this.species,
      required this.sex,
      required this.arksNo,
      required this.gatherData});

  // Animal.fromJson(Map<String, dynamic> json)
  //     : name = json["animalName"],
  //       amFeed = json["amFeed"],
  //       midFeed = json["midFeed"],
  //       pmFeed = json["pmFeed"];

  // Animal.defaultAnimal(String name)
  //     : name = name,
  //       amFeed = 0,
  //       midFeed = 0,
  //       pmFeed = 0;

  // bool hasDefaultValues() {
  //   return amFeed == 0 && midFeed == 0 && pmFeed == 0;
  // }

  String toJson() {
    Map<String, dynamic> outMap = {
      "animalName": name,
      "gatherData": gatherData,
      "arksNo": arksNo,
      "sex": sex,
      "species": species,
    };

    String out = jsonEncode(outMap);

    print("Converting\n$this\ntoJson\n$out");
    return out;
  }

  // @override
  // String toString() {
  //   return '''
  //   Animal:
  //     animalName: $name
  //     amFeed: $amFeed
  //     midFeed: $midFeed
  //     pmFeed: $pmFeed
  //   ''';
  // }

  int amFeed(String currentDate) {
    return gatherData[currentDate]?.gram[0] ?? 0;
  }

  int midFeed(String currentDate) {
    return gatherData[currentDate]?.gram[1] ?? 0;
  }

  int pmFeed(String currentDate) {
    return gatherData[currentDate]?.gram[2] ?? 0;
  }

  bool hasGatherDataForDate(String receivedDate) {
    return gatherData.containsKey(receivedDate);
  }

  void createNewDateRecording(String receivedDate) {
    gatherData[receivedDate] = DateRecording.createDefaultRecording();
  }

  void setAmFeedForDate(String receivedDate, int weightToSet) {
    gatherData[receivedDate]?.gram[0] = weightToSet;
  }

  void setMidFeedForDate(String receivedDate, int weightToSet) {
    gatherData[receivedDate]?.gram[1] = weightToSet;
  }

  void setPmFeedForDate(String receivedDate, int weightToSet) {
    gatherData[receivedDate]?.gram[2] = weightToSet;
  }
}
