import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile_app/includes/constants.dart';
import 'package:mobile_app/includes/declarations.dart';
import 'package:mobile_app/includes/helpers.dart';
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

  bool isLoading = true;

  List<String?> nextPagesTokens = [];

  List<Place> _places = [];

  final directionsService = DirectionsService();

  @override
  void initState() {
    super.initState();

    _places = [];

    DirectionsService.init(Constants.GOOGLE_API_KEY);

    getPlacesByTypesList();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> getPlacesByTypesList() async {
    var location = Provider.of<LocationService>(GlobalContextService.navigatorKey.currentContext!,
        listen: false);

    for (var i = 0; i < (widget.type.types?.length ?? 1); i++) {
      var result = await searchNearbyPlaces(widget.type.types?[i]);

      if (result == null) continue;

      for (var element in result) {
        _places.add(
          Place(
            info: DetailsResult(
              name: element.name,
              placeId: element.placeId,
              geometry: element.geometry,
            ),
          ),
        );
      }

      _places = _places.unique((x) => x.info.placeId);

      setState(() {});
    }

    setState(() {
      isLoading = false;
    });

    for (var i = 0; i < _places.length; i++) {
      var place = _places.elementAt(i);

      _places[i].directions.walking = await Helpers.getDirections(destination: place);
      setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type.label),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () {
                setState(() {
                  _places = [];
                  isLoading = true;
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
    var distanceInKm = place.directions.walking?.first.overviewPath != null
        ? Helpers.calculateRouteDistance(place.directions.walking!.first.overviewPath!)
        : null;

    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          "/places/info",
          arguments: {"placeId": place.info.placeId},
        );
      },
      child: Padding(
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
              distanceInKm != null ? Helpers.formatDistanceString(distanceInKm, short: true) : "-",
              semanticsLabel: distanceInKm != null
                  ? "Distance à ${place.info.name} est ${Helpers.formatDistanceString(distanceInKm)}"
                  : "La distance vers ${place.info.name} est en train d'être calculer",
            ),
          ],
        ),
      ),
    );
  }
}
