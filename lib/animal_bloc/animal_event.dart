import 'package:documentation_assistant/animal_bloc/animal_state.dart';
import 'package:documentation_assistant/loading_text.dart';
import 'package:documentation_assistant/animal.dart';

sealed class AnimalEvent {
  const AnimalEvent();
}

class LoadingStarted extends AnimalEvent {
  final LoadingTypes loadingTypes;
  const LoadingStarted({required this.loadingTypes});
}

class ViewPage extends AnimalEvent {
  final ViewablePages page;
  const ViewPage({required this.page});
}

class AddFeedEvent extends AnimalEvent {
  final Animal animalToAdd;
  final DateTime currentDate;
  const AddFeedEvent({required this.animalToAdd, required this.currentDate});
}

class ToggleFecesEvent extends AnimalEvent {
  final Animal targetAnimal;

  const ToggleFecesEvent({required this.targetAnimal});
}

class SaveFecesEvent extends AnimalEvent {
}
