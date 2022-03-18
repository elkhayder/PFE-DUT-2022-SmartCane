import 'dart:developer';
import 'dart:math';

import 'package:google_directions_api/google_directions_api.dart';
import 'package:google_place/google_place.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:mobile_app/includes/constants.dart';
import 'package:mobile_app/includes/navigation.dart';
import 'package:mobile_app/models/place.dart';
import 'package:mobile_app/services/location.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Helpers {
  static double calculateRouteDistance(List<GeoCoord> path) {
    double _distance = 0;

    for (var i = 0; i < path.length - 1; i++) {
      _distance += calculateTwoPointsDistance(path[i], path[i + 1]);
    }

    return _distance;
  }

  static double calculateTwoPointsDistance(GeoCoord origin, GeoCoord destination) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((destination.latitude - origin.latitude) * p) / 2 +
        cos(origin.latitude * p) *
            cos(destination.latitude * p) *
            (1 - cos((destination.longitude - origin.longitude) * p)) /
            2;
    return 12742 * asin(sqrt(a));
  }

  static String formatDistanceString(double distance, {bool short = false}) {
    bool isMeters = distance < 1;
    int multiplyBy = isMeters ? 1000 : 1;

    String output =
        "${(distance * multiplyBy).toStringAsFixed(isMeters ? 0 : 2)}  ${isMeters ? "" : short ? "K" : "kilo"}${short ? "M" : "mètres"}";

    return output;
  }

  static Future<List<String>> favouritePlaces() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getStringList('favorite_places_ids') ?? [];
  }

  static Future<bool> addFavouritePlace(String placeId) async {
    var _places = await favouritePlaces();
    final prefs = await SharedPreferences.getInstance();

    _places.add(placeId);

    return await prefs.setStringList("favorite_places_ids", _places);
  }

  static Future<bool> removeFavouritePlace(String placeId) async {
    var _places = await favouritePlaces();
    final prefs = await SharedPreferences.getInstance();

    return await prefs.setStringList(
      "favorite_places_ids",
      _places.where((element) => element != placeId).toList(),
    );
  }

  static Future<Place?> getPlace(String placeId) async {
    GooglePlace googlePlace = GooglePlace(Constants.GOOGLE_API_KEY);

    DirectionsService.init(Constants.GOOGLE_API_KEY);

    var infoRequest = await googlePlace.details.get(
      placeId,
      language: "fr",
    );

    if (infoRequest?.result == null) {
      print("Error loading $placeId");
      return null;
    }

    var place = Place(info: infoRequest!.result!);

    if (place.info.geometry?.location?.lat == null || place.info.geometry?.location?.lng == null) {
      return place;
    }

    for (var mode in [
      TravelMode.bicycling,
      TravelMode.driving,
      TravelMode.transit,
      TravelMode.walking,
    ]) {
      var routes = await getDirections(destination: place, travelMode: mode);

      if (mode == TravelMode.driving) place.directions.driving = routes;
      if (mode == TravelMode.bicycling) place.directions.bicycling = routes;
      if (mode == TravelMode.transit) place.directions.transit = routes;
      if (mode == TravelMode.walking) place.directions.walking = routes;
    }

    inspect(place);

    return place;
  }

  static Future<List<DirectionsRoute>?> getDirections({
    required Place destination,
    TravelMode travelMode = TravelMode.walking,
  }) async {
    var location = Provider.of<LocationService>(GlobalContextService.navigatorKey.currentContext!,
        listen: false);

    final directionsService = DirectionsService();

    List<DirectionsRoute>? result;

    final request = DirectionsRequest(
      origin: "${location.currentLocation!.latitude!},${location.currentLocation!.longitude!}",
      destination:
          "${destination.info.geometry!.location!.lat!},${destination.info.geometry!.location!.lng!}",
      travelMode: travelMode,
      language: "fr",
    );

    try {
      await directionsService.route(request, (DirectionsResult response, DirectionsStatus? status) {
        if (status == DirectionsStatus.ok) {
          result = response.routes;
        }
      });
    } catch (e) {
      inspect(e);
    }

    return result;
  }

  static LatLng closestPointOnPath(LatLng position, List<LatLng> path) {
    double closestPointDistance = double.infinity;
    LatLng closestPoint = path[0];

    for (var point in path) {
      var d = SphericalUtil.computeDistanceBetween(position, point);

      if (d < closestPointDistance) {
        closestPointDistance = d.toDouble();
        closestPoint = point;
      }
    }

    return closestPoint;
  }
}
