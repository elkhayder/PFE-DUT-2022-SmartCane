import 'package:google_directions_api/google_directions_api.dart';
import 'package:google_place/google_place.dart';

class Place {
  final SearchResult info;
  DirectionsResult? directions;

  Place({required this.info, this.directions});
}
