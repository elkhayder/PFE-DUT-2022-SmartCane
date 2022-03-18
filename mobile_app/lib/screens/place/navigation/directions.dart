import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:mobile_app/includes/helpers.dart';
import 'package:mobile_app/models/place.dart';
import 'package:mobile_app/services/location.dart';
import 'package:motion_sensors/motion_sensors.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class DirectionsNavigation extends StatefulWidget {
  final Place place;
  final DirectionsRoute directions;

  const DirectionsNavigation({
    Key? key,
    required this.place,
    required this.directions,
  }) : super(key: key);

  @override
  State<DirectionsNavigation> createState() => _DirectionsNavigationState();
}

class _DirectionsNavigationState extends State<DirectionsNavigation> {
  Vector3 _orientation = Vector3(0, 0, 0);

  StreamSubscription? _orientationStream;
  StreamSubscription? _locationStream;

  @override
  void initState() {
    super.initState();

    _orientationStream = motionSensors.absoluteOrientation.listen((e) {
      _orientation = Vector3(e.yaw, e.pitch, e.roll);
      setState(() {});
    });

    var _location = Provider.of<LocationService>(context, listen: false);

    _locationStream = _location.stream.listen((event) {
      _location.currentLocation = event;
    });
  }

  @override
  void dispose() {
    _orientationStream?.cancel();
    _locationStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var location = Provider.of<LocationService>(context);
    var path = widget.directions.overviewPath!.map((e) => LatLng(e.latitude, e.longitude)).toList();
    var currentPosition =
        LatLng(location.currentLocation!.latitude!, location.currentLocation!.longitude!);

    int _indexOnPolyline = PolygonUtil.locationIndexOnPath(
      currentPosition,
      path,
      false,
      tolerance: 10,
    );

    LatLng _nextPoint;

    if (_indexOnPolyline == -1) {
      // return const Text("Not on path");
      _nextPoint = Helpers.closestPointOnPath(currentPosition, path);
    } else {
      var geo = widget.directions.overviewPath!.elementAt(_indexOnPolyline);
      _nextPoint = LatLng(geo.latitude, geo.longitude);
    }

    var absoluteHeading = SphericalUtil.computeHeading(currentPosition, _nextPoint);

    var relativeHeading = degrees(_orientation.x) + absoluteHeading;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("${_headingToClock(relativeHeading).toString()} heures"),
              Text(
                SphericalUtil.computeDistanceBetween(
                  LatLng(currentPosition.latitude, currentPosition.longitude),
                  _nextPoint,
                ).toStringAsFixed(0),
              )
            ],
          ),
          Text("${relativeHeading.toStringAsFixed(0)}, $_indexOnPolyline"),
        ],
      ),
    );
  }

  int _headingToClock(double heading) {
    heading = heading < 0 ? -heading : 360 - heading;

    return 12 - heading * 12 ~/ 360;
  }
}
