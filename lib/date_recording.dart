class DateRecording {
  List<double> weight = [];
  List<bool> feces = [];
  List<int> gram = [];
  List<String> parasites = [];
  List<String> comments = [];

  DateRecording({
    required this.parasites,
    required this.weight,
    required this.feces,
    required this.gram,
    required this.comments,
  });

  static DateRecording createDefaultRecording() {
    DateRecording newDateRecoding =
        DateRecording(parasites: [], weight: [], feces: [], gram: [
      0,
      0,
      0,
    ], comments: []);

    return newDateRecoding;
  }
}
