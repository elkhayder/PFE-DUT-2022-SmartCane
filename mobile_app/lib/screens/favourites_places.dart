import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:google_place/google_place.dart';
import 'package:mobile_app/includes/constants.dart';
import 'package:mobile_app/includes/helpers.dart';
import 'package:mobile_app/models/place.dart';
import 'package:mobile_app/widgets/navigatable_element.dart';
import 'package:mobile_app/widgets/single_search_result.dart';

class FavouritePlacesScreen extends StatefulWidget {
  const FavouritePlacesScreen({Key? key}) : super(key: key);

  @override
  State<FavouritePlacesScreen> createState() => _FavouritePlacesScreenState();
}

class _FavouritePlacesScreenState extends State<FavouritePlacesScreen> {
  List<Place> _places = [];
  List<String> _placesIds = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlaces();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void fetchPlaces() async {
    _placesIds = await Helpers.favouritePlaces();

    setState(() {});

    for (var placeId in _placesIds) {
      try {
        Place? response;

        do {
          response = await Helpers.getPlace(placeId);
        } while (response == null && mounted);

        _places.add(response!);
      } catch (e) {
        inspect(e);
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved places")),
      body: _placesIds.isEmpty
          ? const Center(child: Text("You don't have any place on this list yet"))
          : isLoading
              ? const Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Center(
                    child: SizedBox(
                      child: CircularProgressIndicator(),
                      height: 30,
                      width: 30,
                    ),
                  ),
                )
              : ListView.separated(
                  itemBuilder: (_, index) {
                    if (index == 0) {
                      return NavigatableElement(
                        child: SizedBox(
                          height: 0,
                          child: OutlinedButton(
                            onPressed: () {},
                            child: Container(),
                          ),
                        ),
                        index: index,
                      );
                    }
                    var place = _places.elementAt(index - 1);
                    return NavigatableElement(
                      key: ValueKey(place.info.placeId),
                      index: index,
                      child: SingleSearchResult(
                        index: index - 1,
                        place: place,
                        distance: Helpers.distanceTo(
                          GeoCoord(
                            place.info.geometry!.location!.lat!,
                            place.info.geometry!.location!.lng!,
                          ),
                        ),
                      ),
                    );
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    color: Colors.white30,
                  ),
                  itemCount: _places.length + 1,
                ),
    );
  }

  Widget _placeEntryBuilder(context, index) {
    if (index == _places.length) {
      // Loading symbole
      return !isLoading
          ? Container()
          : const Padding(
              padding: EdgeInsets.only(top: 32),
              child: Center(
                child: SizedBox(
                  child: CircularProgressIndicator(),
                  height: 30,
                  width: 30,
                ),
              ),
            );
    }

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
                  ? "Distance to ${place.info.name} is ${Helpers.formatDistanceString(distanceInKm)}"
                  : "Distance to ${place.info.name} is being calculated",
            ),
          ],
        ),
      ),
    );
  }
}
