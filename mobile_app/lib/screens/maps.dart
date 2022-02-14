import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/location.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({Key? key}) : super(key: key);

  final String apiKey = "AIzaSyDkFh2Pll810FIqdiAuLRjE8PXo7TLEVE0";

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final location = Provider.of<LocationService>(context);

    return ListView.separated(
      itemBuilder: (context, index) {
        var placemark = location.placemarks[index];
        return Text(
          [
            placemark.name,
            placemark.street,
            placemark.thoroughfare,
            placemark.subLocality,
            placemark.locality,
            placemark.administrativeArea,
            placemark.country
          ].where((e) => (e != null && e.isNotEmpty)).toList().join(", "),
        );
      },
      itemCount: location.placemarks.length,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 10);
      },
    );
  }
}
