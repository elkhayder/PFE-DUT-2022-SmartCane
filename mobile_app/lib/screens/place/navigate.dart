import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_app/includes/navigation.dart';
import 'package:mobile_app/models/place.dart';
import 'package:mobile_app/services/location.dart';
import 'package:provider/provider.dart';

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
  late GoogleMapController _controller;

  bool _currentViewIsMap = true;

  LocationService location =
      Provider.of<LocationService>(GlobalContextService.navigatorKey.currentContext!);

  PolylinePoints polylinePoints = PolylinePoints();

  late CameraPosition _initialCameraPosition;
  late Marker _initialPositionMarker;
  late Marker _destinationMarker;
  late Polyline _routePolyline;

  @override
  void initState() {
    super.initState();

    _initialCameraPosition = CameraPosition(
      target: LatLng(location.currentLocation!.latitude!, location.currentLocation!.longitude!),
      zoom: 14,
    );

    _initialPositionMarker = Marker(
      markerId: const MarkerId("_currentPosition"),
      position: LatLng(location.currentLocation!.latitude!, location.currentLocation!.longitude!),
    );

    _destinationMarker = Marker(
      markerId: const MarkerId("_destinationPosition"),
      position: LatLng(
        widget.place.info.geometry!.location!.lat!,
        widget.place.info.geometry!.location!.lng!,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
    );

    _routePolyline = Polyline(
      polylineId: const PolylineId("_route"),
      points: polylinePoints
          .decodePolyline(widget.directions.overviewPolyline!.points!)
          .map((e) => LatLng(e.latitude, e.longitude))
          .toList(),
      color: Colors.grey.shade600,
      width: 4,
      startCap: Cap.squareCap,
      endCap: Cap.roundCap,
    );

    location.service.onLocationChanged.listen((event) {
      location.currentLocation = event;

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: _currentViewIsMap
          ? GoogleMap(
              mapType: MapType.normal,
              onMapCreated: (GoogleMapController x) => _controller = x,
              initialCameraPosition: _initialCameraPosition,
              markers: {
                _initialPositionMarker,
                _destinationMarker,
              },
              polylines: {_routePolyline},
            )
          : null,
    );
  }
}
