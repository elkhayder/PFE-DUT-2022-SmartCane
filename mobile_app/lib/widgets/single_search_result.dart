import 'package:flutter/material.dart';
import 'package:mobile_app/includes/helpers.dart';
import 'package:mobile_app/models/place.dart';

class SingleSearchResult extends StatelessWidget {
  Place place;
  double? distance;
  int index;

  SingleSearchResult({
    Key? key,
    required this.place,
    this.distance,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var distanceInKm = distance ??
        (place.directions.walking?.first.overviewPath != null
            ? Helpers.calculateRouteDistance(place.directions.walking!.first.overviewPath!)
            : null);

    return InkWell(
      autofocus: index == 0,
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
              distanceInKm != null
                  ? "${Helpers.formatDistanceString(distanceInKm, short: true)}${distance != null ? "?" : ""}"
                  : (distance != null ? distance!.toStringAsFixed(2) : "-"),
              semanticsLabel: distanceInKm != null
                  ? ", Distance is ${distance != null ? "estimated to be around" : ""}${Helpers.formatDistanceString(distanceInKm)}"
                  : ", Distance is being calculated",
            ),
          ],
        ),
      ),
    );
  }
}
