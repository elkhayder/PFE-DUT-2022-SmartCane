import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as map;
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:mobile_app/includes/helpers.dart';
import 'package:mobile_app/includes/navigation.dart';
import 'package:mobile_app/models/place.dart';
import 'package:mobile_app/services/location.dart';
import 'package:motion_sensors/motion_sensors.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class NavigateScreen extends StatefulWidget {
  final Place place;
  final DirectionsRoute directions;

  const NavigateScreen({
    Key? key,
    required this.place,
    required this.directions,
  }) : super(key: key);

  @override
  State<NavigateScreen> createState() => _NavigateScreenState();
}

class _NavigateScreenState extends State<NavigateScreen> {
  bool _currentViewIsMap = false;
  map.GoogleMapController? _mapController;
  Vector3 _orientation = Vector3(0, 0, 0);

  late StreamSubscription _orientationStream;

  late StreamSubscription _locationStreamSubscription;

  LocationService location =
      Provider.of<LocationService>(GlobalContextService.navigatorKey.currentContext!);

  map.CameraPosition get _initialCameraPosition {
    return map.CameraPosition(
      target: _currentPosition,
      zoom: 14,
    );
  }

  map.Marker get _destinationMarker {
    return map.Marker(
      markerId: const map.MarkerId("_destinationPosition"),
      position: map.LatLng(
        widget.place.info.geometry!.location!.lat!,
        widget.place.info.geometry!.location!.lng!,
      ),
      icon: map.BitmapDescriptor.defaultMarkerWithHue(map.BitmapDescriptor.hueViolet),
      infoWindow: map.InfoWindow(title: "Votre direction", snippet: widget.place.info.name),
    );
  }

  map.Polyline get _routePolyline {
    return map.Polyline(
      polylineId: const map.PolylineId("_route"),
      points: PolylinePoints()
          .decodePolyline(widget.directions.overviewPolyline!.points!)
          .map((e) => map.LatLng(e.latitude, e.longitude))
          .toList(),
      color: Colors.grey.shade600,
      width: 4,
      startCap: map.Cap.squareCap,
      endCap: map.Cap.roundCap,
    );
  }

  map.LatLng get _currentPosition {
    return map.LatLng(location.currentLocation!.latitude!, location.currentLocation!.longitude!);
  }

  final _currentPositionMarkerId = const map.MarkerId("_currentPosition");

  map.Marker get _currentPositionMarker {
    return map.Marker(
      markerId: _currentPositionMarkerId,
      position: _currentPosition,
      infoWindow: map.InfoWindow(title: "Votre position actuelle", snippet: location.placemark),
    );
  }

  @override
  void initState() {
    super.initState();

    _locationStreamSubscription = location.stream.listen((event) {
      location.currentLocation = event;

      setState(() {});
    });

    _orientationStream = motionSensors.absoluteOrientation.listen((e) async {
      _orientation = Vector3(e.yaw, e.pitch, e.roll);

      setState(() {});
    });
  }

  @override
  void dispose() {
    _locationStreamSubscription.cancel();
    _orientationStream.cancel();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    var path = widget.directions.overviewPath!.map((e) => LatLng(e.latitude, e.longitude)).toList();

    int _indexOnPolyline = PolygonUtil.locationIndexOnPath(
      LatLng(_currentPosition.latitude, _currentPosition.longitude),
      path,
      false,
      tolerance: 5,
    );

    LatLng _nextPoint;

    if (_indexOnPolyline == -1) {
      // return const Text("Not on path");
      _nextPoint = Helpers.closestPointOnPath(
        LatLng(_currentPosition.latitude, _currentPosition.longitude),
        path,
      );
    } else {
      var geo = widget.directions.overviewPath!.elementAt(_indexOnPolyline + 1);
      _nextPoint = LatLng(geo.latitude, geo.longitude);
    }

    var absoluteHeading = SphericalUtil.computeHeading(
      LatLng(_currentPosition.latitude, _currentPosition.longitude),
      _nextPoint,
    );

    var relativeHeading = degrees(_orientation.x) + absoluteHeading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place.info.name ?? "Naviguer"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _currentViewIsMap = !_currentViewIsMap;
              });
            },
            icon: Icon(_currentViewIsMap ? Icons.directions : Icons.map),
          )
        ],
      ),
      body: IndexedStack(
        children: [
          map.GoogleMap(
            mapType: map.MapType.normal,
            onMapCreated: (map.GoogleMapController x) => _mapController = x,
            initialCameraPosition: _initialCameraPosition,
            markers: {_currentPositionMarker, _destinationMarker},
            polylines: {_routePolyline},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_indexOnPolyline == -1) ...[
                  const Text(
                    "Seems like you are not on path, please try to find an exit outside, we can lead you to the closest point that we know.",
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${_headingToClock(relativeHeading).toString()} O'Clock"),
                    Text(
                      "${SphericalUtil.computeDistanceBetween(
                        LatLng(_currentPosition.latitude, _currentPosition.longitude),
                        _nextPoint,
                      ).toStringAsFixed(0)} metres",
                    ),
                    Text(path.indexOf(_nextPoint).toString())
                  ],
                ),
              ],
            ),
          ),
        ],
        index: _currentViewIsMap ? 0 : 1,
      ),
    );
  }

  int _headingToClock(double heading) {
    heading = heading < 0 ? -heading : 360 - heading;

    return 12 - heading * 12 ~/ 360;
  }
}
