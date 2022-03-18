import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as Map;
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
  Map.GoogleMapController? _mapController;
  Vector3 _orientation = Vector3(0, 0, 0);

  late StreamSubscription _orientationStream;

  late StreamSubscription _locationStreamSubscription;

  LocationService location =
      Provider.of<LocationService>(GlobalContextService.navigatorKey.currentContext!);

  Map.CameraPosition get _initialCameraPosition {
    return Map.CameraPosition(
      target: _currentPosition,
      zoom: 14,
    );
  }

  Map.Marker get _destinationMarker {
    return Map.Marker(
      markerId: const Map.MarkerId("_destinationPosition"),
      position: Map.LatLng(
        widget.place.info.geometry!.location!.lat!,
        widget.place.info.geometry!.location!.lng!,
      ),
      icon: Map.BitmapDescriptor.defaultMarkerWithHue(Map.BitmapDescriptor.hueViolet),
      infoWindow: Map.InfoWindow(title: "Votre direction", snippet: widget.place.info.name),
    );
  }

  Map.Polyline get _routePolyline {
    return Map.Polyline(
      polylineId: const Map.PolylineId("_route"),
      points: PolylinePoints()
          .decodePolyline(widget.directions.overviewPolyline!.points!)
          .map((e) => Map.LatLng(e.latitude, e.longitude))
          .toList(),
      color: Colors.grey.shade600,
      width: 4,
      startCap: Map.Cap.squareCap,
      endCap: Map.Cap.roundCap,
    );
  }

  Map.LatLng get _currentPosition {
    return Map.LatLng(location.currentLocation!.latitude!, location.currentLocation!.longitude!);
  }

  final _currentPositionMarkerId = const Map.MarkerId("_currentPosition");

  Map.Marker get _currentPositionMarker {
    return Map.Marker(
      markerId: _currentPositionMarkerId,
      position: _currentPosition,
      infoWindow: Map.InfoWindow(title: "Votre position actuelle", snippet: location.placemark),
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
          _buildMap(context, relativeHeading),
          _buildDirections(context, relativeHeading, _nextPoint),
        ],
        index: _currentViewIsMap ? 0 : 1,
      ),
    );
  }

  Widget _buildMap(BuildContext context, double relativeHeading) {
    return Map.GoogleMap(
      mapType: Map.MapType.normal,
      onMapCreated: (Map.GoogleMapController x) => _mapController = x,
      initialCameraPosition: _initialCameraPosition,
      markers: {_currentPositionMarker, _destinationMarker},
      polylines: {_routePolyline},
    );
  }

  Widget _buildDirections(BuildContext context, double relativeHeading, LatLng _nextPoint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${_headingToClock(relativeHeading).toString()} heures"),
              Text(
                "${SphericalUtil.computeDistanceBetween(
                  LatLng(_currentPosition.latitude, _currentPosition.longitude),
                  _nextPoint,
                ).toStringAsFixed(0)} metres",
              )
            ],
          ),
        ],
      ),
    );
  }

  int _headingToClock(double heading) {
    heading = heading < 0 ? -heading : 360 - heading;

    return 12 - heading * 12 ~/ 360;
  }
}
