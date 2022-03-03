import 'package:flutter/material.dart';
import 'package:location/location.dart' as location_package;
import 'package:geocoding/geocoding.dart' as geo_coding;

class LocationService extends ChangeNotifier {
  final location_package.Location _service = location_package.Location();

  location_package.Location get service => _service;

  location_package.LocationData? _currentLocation;

  location_package.LocationData? get currentLocation => _currentLocation;

  set currentLocation(location_package.LocationData? v) {
    _currentLocation = v;
    notifyListeners();
  }

  String? placemark;

  location_package.PermissionStatus? _permissionGranted;

  bool _serviceEnabled = false;

  LocationService() {
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

    _permissionGranted = await _service.hasPermission();

    if (_permissionGranted == location_package.PermissionStatus.denied) {
      _permissionGranted = await _service.requestPermission();
      if (_permissionGranted != location_package.PermissionStatus.granted) {
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
