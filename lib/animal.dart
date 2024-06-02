import 'dart:convert';

class Animal {
  String animalName;
  int amFeed = 0;
  int midFeed = 0;
  int pmFeed = 0;
  String species;
  String sex;
  String arksNo;
  //TODO add a function to create an animal in gsheets and constuct a sheet for it for this month and year
  //TODO for a given month and year, parse an animal
  Animal(
      {required this.animalName,
      required this.species,
      required this.sex,
      required this.arksNo,
      required this.amFeed,
      required this.midFeed,
      required this.pmFeed});

  bool hasDefaultValues() {
    return amFeed == 0 && midFeed == 0 && pmFeed == 0;
  }

  String toJson() {
    Map<String, dynamic> outMap = {
      "animalName": animalName,
      "amFeed": amFeed,
      "midFeed": midFeed,
      "pmFeed": pmFeed
    };

    String out = jsonEncode(outMap);

    print("Converting\n$this\ntoJson\n$out");
    return out;
  }

  @override
  String toString() {
    return '''
    Animal:
      animalName: $animalName
      amFeed: $amFeed
      midFeed: $midFeed
      pmFeed: $pmFeed
    ''';
  }

  @override
  operator ==(other) => other is Animal && other.arksNo == arksNo;

  @override
  int get hashCode => arksNo.hashCode;
}
