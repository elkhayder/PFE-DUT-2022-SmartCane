import 'package:flutter/material.dart';
import 'package:mobile_app/includes/helpers.dart';
import 'package:mobile_app/models/place.dart';
import 'package:share_plus/share_plus.dart';

class PlaceInfosScreen extends StatefulWidget {
  final String placeId;

  const PlaceInfosScreen({Key? key, required this.placeId}) : super(key: key);

  @override
  State<PlaceInfosScreen> createState() => _PlaceInfosScreenState();
}

class _PlaceInfosScreenState extends State<PlaceInfosScreen> {
  bool _inFavourite = false;

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

    return Scaffold(
      appBar: AppBar(title: Text(_place?.info.name! ?? "Loading")),
      body: _place == null
          ? const Center(child: CircularProgressIndicator())
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
                  ..._buildDirectionsOptions(context),
                  _buildButton(
                    onPressed: () async {
                      var placeId = _place!.info.placeId!;
                      _inFavourite
                          ? await Helpers.removeFavouritePlace(placeId)
                          : await Helpers.addFavouritePlace(placeId);

                      await checkIfInFavourite();
                    },
                    icon: Icon(_inFavourite ? Icons.bookmark_remove : Icons.bookmark_add),
                    label: Text(_inFavourite ? "Retirer du favouries" : "Ajouter aux favouries"),
                  ),
                  const SizedBox(height: 16),
                  _buildButton(
                    onPressed: () {
                      Share.share(
                          'Je partage avec vous cet endroit: ${_place?.info.name} https://place.com/?id=${_place?.info.placeId}');
                    },
                    icon: const Icon(Icons.share),
                    label: const Text("Partager"),
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

    if (_place!.directions.walking != null) {
      temp.add([
        "À pied",
        Icons.directions_walk,
        _place?.directions.walking,
      ]);
    }

    if (_place!.directions.transit != null) {
      temp.add([
        "Transit",
        Icons.directions_transit,
        _place?.directions.transit,
      ]);
    }

    if (_place!.directions.bicycling != null) {
      temp.add([
        "Bicyclette",
        Icons.directions_bike,
        _place?.directions.bicycling,
      ]);
    }

    if (_place!.directions.driving != null) {
      temp.add([
        "Voiture",
        Icons.directions_car,
        _place?.directions.driving,
      ]);
    }

    for (var option in temp) {
      options.addAll([
        _buildButton(
          onPressed: () {
            Navigator.of(context).pushNamed("/places/navigate", arguments: {
              "place": _place!,
              "directions": option[2].first,
            });
          },
          icon: Icon(option[1]),
          label: Text(option[0]),
        ),
        const SizedBox(height: 16)
      ]);
    }

    return options;
  }
}
