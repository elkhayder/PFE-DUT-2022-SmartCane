import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile_app/includes/constants.dart';
import 'package:mobile_app/includes/declarations.dart';
import 'package:mobile_app/includes/navigation.dart';
import 'package:mobile_app/models/explore_location.dart';
import 'package:mobile_app/models/place.dart';
import 'package:mobile_app/services/location.dart';
import 'package:provider/provider.dart';
import 'package:google_place/google_place.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_directions_api/google_directions_api.dart';

class FindPlacesByTypeScreen extends StatefulWidget {
  final ExploreLocationType type;

  const FindPlacesByTypeScreen({Key? key, required this.type}) : super(key: key);

  @override
  State<FindPlacesByTypeScreen> createState() => _FindPlacesByTypeScreenState();
}

class _FindPlacesByTypeScreenState extends State<FindPlacesByTypeScreen> {
  final GooglePlace googlePlace = GooglePlace(Constants.GOOGLE_API_KEY);

  // PolylinePoints polylinePoints = PolylinePoints();

  List<String?> nextPagesTokens = [];

  List<Place> _places = [];

  List<String?> _searchTokens = [null];

  final directionsService = DirectionsService();

  @override
  void initState() {
    super.initState();

    _places = [];

    DirectionsService.init(Constants.GOOGLE_API_KEY);

    getPlacesByTypesList();
  }

  Future<void> getPlacesByTypesList() async {
    var location = Provider.of<LocationService>(GlobalContextService.navigatorKey.currentContext!,
        listen: false);

    for (var i = 0; i < (widget.type.types?.length ?? 1); i++) {
      var result = await searchNearbyPlaces(widget.type.types?[i]);

      if (result == null) continue;

      for (var element in result) {
        _places.add(
          Place(info: element),
        );
      }

      _places = _places.unique((x) => x.info.placeId);

      setState(() {});
    }

    for (var i = 0; i < _places.length; i++) {
      var place = _places.elementAt(i);

      if (place.info.geometry?.location?.lat == null ||
          place.info.geometry?.location?.lng == null) {
        continue;
      }

      final request = DirectionsRequest(
        origin: "${location.currentLocation!.latitude!},${location.currentLocation!.longitude!}",
        destination:
            "${place.info.geometry!.location!.lat!},${place.info.geometry!.location!.lng!}",
        travelMode: TravelMode.walking,
      );

      directionsService.route(request, (DirectionsResult response, DirectionsStatus? status) {
        if (status == DirectionsStatus.ok) {
          _places[i].directions = response;
          setState(() {});
        } else {
          print("Erreur");
        }
      });
    }
  }

  Future<List<SearchResult>?> searchNearbyPlaces(String? type) async {
    var location = Provider.of<LocationService>(GlobalContextService.navigatorKey.currentContext!,
        listen: false);

    var currentLocation = await location.updateCurrentLocation();

    if (currentLocation == null) {
      return null;
    }

    try {
      var result = await googlePlace.search.getNearBySearch(
        Location(
          lat: currentLocation.latitude,
          lng: currentLocation.longitude,
        ),
        1000,
        type: type,
        // pagetoken: pageToken
        // rankby: RankBy.Distance,
      );

      return result?.results;
    } catch (exception) {
      inspect(exception);
      return null;
    }
  }

  double calculateRouteDistance(List<GeoCoord> path) {
    double _distance = 0;

    for (var i = 0; i < path.length - 1; i++) {
      _distance += calculateTwoPointsDistance(path[i], path[i + 1]);
    }

    return _distance;
  }

  double calculateTwoPointsDistance(GeoCoord origin, GeoCoord destination) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((destination.latitude - origin.latitude) * p) / 2 +
        cos(origin.latitude * p) *
            cos(destination.latitude * p) *
            (1 - cos((destination.longitude - origin.longitude) * p)) /
            2;
    return 12742 * asin(sqrt(a));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type.label),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          setState(() {
            _places = [];
            _searchTokens = [null];
          });
          return getPlacesByTypesList();
        },
        child: ListView.separated(
          itemBuilder: _placeEntryBuilder,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            color: Colors.white30,
          ),
          itemCount: _places.length,
        ),
      ),
    );
  }

  Widget _placeEntryBuilder(context, index) {
    var place = _places.elementAt(index);
    var distanceInKm = place.directions?.routes?.first.overviewPath != null
        ? calculateRouteDistance(place.directions!.routes!.first.overviewPath!)
        : null;

    bool isMeters = (distanceInKm ?? 0) < 1;
    int multiplyBy = isMeters ? 1000 : 1;

    String distance = ((distanceInKm ?? 0) * multiplyBy).toStringAsFixed(isMeters ? 0 : 2);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              place.info.name ?? "Unnamed",
              style: const TextStyle(height: 1.2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            distanceInKm != null ? "$distance ${isMeters ? "" : "K"}M" : "-",
            semanticsLabel: distanceInKm != null
                ? "Distance à ${place.info.name} est $distance ${isMeters ? "" : "kilo"}mètres"
                : "La distance vers ${place.info.name} est en train d'être calculer",
          ),
        ],
      ),
    );
  }
}
