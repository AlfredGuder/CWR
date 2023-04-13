import 'dart:convert';

class Animal {
  String animalName;
  int amFeed = 0;
  int midFeed = 0;
  int pmFeed = 0;

  Animal(
      {required this.animalName,
      required this.amFeed,
      required this.midFeed,
      required this.pmFeed});

  Animal.fromJson(Map<String, dynamic> json)
      : animalName = json["animalName"],
        amFeed = json["amFeed"],
        midFeed = json["midFeed"],
        pmFeed = json["pmFeed"];

  Animal.defaultAnimal(String name)
      : animalName = name,
        amFeed = 0,
        midFeed = 0,
        pmFeed = 0;

  String toJson() {
    String out = {
      "animalName": animalName,
      "amFeed": amFeed,
      "midFeed": midFeed,
      "pmFeed": pmFeed
    }.toString();

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

  static List<Animal> dummyData = [
    Animal(animalName: "Willa", amFeed: 0, midFeed: 0, pmFeed: 0),
    Animal(animalName: "Valora", amFeed: 0, midFeed: 0, pmFeed: 0),
    Animal(animalName: "Xayla", amFeed: 0, midFeed: 0, pmFeed: 0),
    Animal(animalName: "Cho gath", amFeed: 0, midFeed: 0, pmFeed: 5)
  ];
}
