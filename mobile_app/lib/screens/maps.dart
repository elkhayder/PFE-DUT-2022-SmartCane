import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile_app/includes/constants.dart';
import 'package:google_directions_api/google_directions_api.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({Key? key}) : super(key: key);

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final directionsService = DirectionsService();

  final request = const DirectionsRequest(
    origin: "33.6027558,-7.6361065",
    destination: '33.6003771,-7.6326147',
    travelMode: TravelMode.walking,
  );

  @override
  void initState() {
    super.initState();
    DirectionsService.init(Constants.GOOGLE_API_KEY);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Text("Update"),
      onPressed: () {
        directionsService.route(request, (DirectionsResult response, DirectionsStatus? status) {
          inspect(response);
          inspect(status);
        });
      },
    );
  }
}
