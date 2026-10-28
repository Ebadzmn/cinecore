export '../../data/models/continue_watching_model.dart';
export '../../data/models/movie_model.dart';

class StudioProviderModel {
  final String name;
  final String iconType; // 'max', 'paramount', 'disney', 'netflix'

  const StudioProviderModel({required this.name, required this.iconType});
}
