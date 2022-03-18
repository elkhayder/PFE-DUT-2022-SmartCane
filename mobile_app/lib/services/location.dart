import 'package:flutter/material.dart';
import 'package:location/location.dart' as location_package;
import 'package:geocoding/geocoding.dart' as geo_coding;

class LocationService extends ChangeNotifier {
  final location_package.Location _service = location_package.Location();
  location_package.Location get service => _service;

  late Stream<location_package.LocationData> stream;

  location_package.LocationData? _currentLocation;
  location_package.LocationData? get currentLocation => _currentLocation;
  set currentLocation(location_package.LocationData? v) {
    _currentLocation = v;
    notifyListeners();
  }

  String? placemark;

  location_package.PermissionStatus? _permissionStatus;

  bool _serviceEnabled = false;

  LocationService() {
    stream = _service.onLocationChanged.asBroadcastStream();
    _service.changeSettings(
      accuracy: location_package.LocationAccuracy.navigation,
      distanceFilter: 10,
      interval: 5000,
    );
    updateCurrentLocation();
  }

  Future<location_package.LocationData?> updateCurrentLocation() async {
    _serviceEnabled = await _service.serviceEnabled();

    if (!_serviceEnabled) {
      _serviceEnabled = await _service.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionStatus = await _service.hasPermission();

    if (_permissionStatus == location_package.PermissionStatus.denied) {
      _permissionStatus = await _service.requestPermission();
      if (_permissionStatus != location_package.PermissionStatus.granted) {
        return null;
      }
    }

    location_package.LocationData thisLocation = await _service.getLocation();

    currentLocation = thisLocation;

    await updateCurrentPlacemarks();

    notifyListeners();

    return thisLocation;
  }

  Future<void> updateCurrentPlacemarks() async {
    if (currentLocation == null) return;
    try {
      var placemarks = await geo_coding.placemarkFromCoordinates(
          currentLocation!.latitude!, currentLocation!.longitude!);

      var p = placemarks.elementAt(0);

      placemark = [
        p.name,
        p.street,
        p.subLocality,
        p.subAdministrativeArea,
        p.postalCode,
        p.locality,
        p.country
      ].where((element) => element?.isNotEmpty ?? false).join(", ");
    } catch (exception) {
      placemark = null;
    }
  }
}
