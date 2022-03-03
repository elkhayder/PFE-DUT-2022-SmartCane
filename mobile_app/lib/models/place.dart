import 'package:google_directions_api/google_directions_api.dart';
import 'package:google_place/google_place.dart';

class Place {
  final DetailsResult info;
  Directions directions = Directions();

  Place({required this.info});
}

class Directions {
  List<DirectionsRoute>? walking;
  List<DirectionsRoute>? bicycling;
  List<DirectionsRoute>? driving;
  List<DirectionsRoute>? transit;

  Directions({this.bicycling, this.driving, this.transit, this.walking});
}
