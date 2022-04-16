import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile_app/includes/helpers.dart';
import 'package:mobile_app/models/place.dart';
import 'package:mobile_app/widgets/navigatable_element.dart';
import 'package:share_plus/share_plus.dart';
import 'package:android_intent_plus/android_intent.dart';

class PlaceInfosScreen extends StatefulWidget {
  final String placeId;

  const PlaceInfosScreen({Key? key, required this.placeId}) : super(key: key);

  @override
  State<PlaceInfosScreen> createState() => _PlaceInfosScreenState();
}

class _PlaceInfosScreenState extends State<PlaceInfosScreen> {
  bool _inFavourite = false;

  GlobalKey _addToFavouritesKey = GlobalKey();

  Place? _place;

  @override
  void initState() {
    super.initState();
    checkIfInFavourite();
    fetchPlace();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void fetchPlace() async {
    do {
      _place = await Helpers.getPlace(widget.placeId);
    } while (_place == null && mounted);

    setState(() {});
  }

  Future<bool> checkIfInFavourite() async {
    bool status = (await Helpers.favouritePlaces()).where((e) => e == widget.placeId).isNotEmpty;

    setState(() {
      _inFavourite = status;
    });

    return status;
  }

  @override
  Widget build(BuildContext context) {
    var distance = _place?.directions.walking == null
        ? 0.0
        : Helpers.calculateRouteDistance(_place!.directions.walking!.first.overviewPath!);

    var directionsCount = _buildDirectionsOptions(context).whereType<NavigatableElement>().length;

    return Scaffold(
      appBar: AppBar(title: Text(_place?.info.name! ?? "Loading")),
      body: _place == null
          ? const Center(child: RepaintBoundary(child: CircularProgressIndicator()))
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${_place!.info.name} @ ${_place!.info.vicinity}"),
                  const SizedBox(height: 12),
                  Text(
                    "${Helpers.formatDistanceString(distance)}, ${(distance * 1000 / 85).round()} minutes",
                  ),
                  const SizedBox(height: 24),
                  NavigatableElement(
                    index: 0,
                    child: SizedBox(
                      height: 0,
                      child: OutlinedButton(
                        onPressed: () {},
                        child: Container(),
                      ),
                    ),
                  ),
                  ..._buildDirectionsOptions(context),
                  const Divider(height: 4),
                  const SizedBox(height: 16),
                  NavigatableElement(
                    key: _addToFavouritesKey,
                    index: directionsCount + 1,
                    child: _buildButton(
                      onPressed: () async {
                        var placeId = _place!.info.placeId!;
                        _inFavourite
                            ? await Helpers.removeFavouritePlace(placeId)
                            : await Helpers.addFavouritePlace(placeId);

                        await checkIfInFavourite();
                      },
                      icon: Icon(_inFavourite ? Icons.bookmark_remove : Icons.bookmark_add),
                      label:
                          Text(_inFavourite ? "Remove from saved places" : "Add to saved places"),
                    ),
                  ),
                  const SizedBox(height: 16),
                  NavigatableElement(
                    index: directionsCount + 2,
                    child: _buildButton(
                      onPressed: () {
                        Share.share(
                            "Hey, check this place out: https://guideme.elkhayder.me/place?id=${_place?.info.placeId}");
                      },
                      icon: const Icon(Icons.share),
                      label: const Text("Share"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildButton({
    required void Function()? onPressed,
    required Widget icon,
    required Widget label,
  }) {
    return SizedBox(
      width: Size.infinite.width,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: label,
      ),
    );
  }

  List<Widget> _buildDirectionsOptions(BuildContext context) {
    List<Widget> options = [];

    List<List<dynamic>> temp = [];

    if (_place?.directions.walking != null) {
      temp.add([
        "Walking",
        Icons.directions_walk,
        "w", // Google maps for walking
      ]);
    }

    // if (_place?.directions.transit != null) {
    //   temp.add([
    //     "Transit",
    //     Icons.directions_transit,
    //     "l", // Google maps for two-wheeler
    //   ]);
    // }

    if (_place?.directions.bicycling != null) {
      temp.add([
        "Bicyclette",
        Icons.directions_bike,
        "b", // Google maps for bicycling
      ]);
    }

    if (_place?.directions.driving != null) {
      temp.add([
        "Driving",
        Icons.directions_car,
        "d", // Google maps for driving
      ]);
    }

    for (var option in temp) {
      options.addAll([
        NavigatableElement(
          index: temp.indexOf(option) + 1,
          child: _buildButton(
            onPressed: () async {
              AndroidIntent intent = AndroidIntent(
                action: 'action_view',
                package: "com.google.android.apps.maps",
                data:
                    'google.navigation:q=${_place?.info.geometry?.location?.lat},${_place?.info.geometry?.location?.lng}&mode=${option[2]}',
              );
              await intent.launch();
            },
            icon: Icon(option[1]),
            label: Text(option[0]),
          ),
        ),
        const SizedBox(height: 16)
      ]);
    }

    return options;
  }
}
