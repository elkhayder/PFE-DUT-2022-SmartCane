import 'package:flutter/material.dart';
import 'package:mobile_app/bluetooth/bluetooth_payload_handler.dart';
import 'package:mobile_app/services/location.dart';
import 'package:provider/provider.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import '../services/smart_cane.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Container(
        padding: const EdgeInsets.all(16).copyWith(top: 12),
        child: Column(
          children: [
            _buildCurrentLocationRow(context),
            const Divider(
              height: 60,
              thickness: 1,
            ),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Row _buildCurrentLocationRow(BuildContext context) {
    final location = Provider.of<LocationService>(context);

    String currentPosition = "Unknown";

    if (location.placemarks.isNotEmpty) {
      var p = location.placemarks.elementAt(0);
      currentPosition = [
        p.name,
        p.street,
        p.subLocality,
        p.subAdministrativeArea,
        p.postalCode,
        p.locality,
        p.country
      ].where((element) => element?.isNotEmpty ?? false).join(", ");
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              "Your current location: $currentPosition",
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => location.updateCurrentLocation(),
          icon: const Icon(Icons.gps_fixed),
          tooltip: "Refresh location",
        )
      ],
    );
  }

  Column _buildActionButtons(BuildContext context) {
    SmartCaneService smartCane = Provider.of<SmartCaneService>(context);

    var _outlinedButtonStyle = OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(60),
    );

    const SizedBox _spacing = SizedBox(height: 16);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            "SmartCane ${!smartCane.isConnected ? "Connected, Battery ${smartCane.batteryPercentage}%" : "Disconnected"}"),
        const SizedBox(height: 24),
        OutlinedButton(
          child: Text("${smartCane.isConnected ? "Disconnected" : "Connect"} SmartCane"),
          style: _outlinedButtonStyle,
          onPressed: smartCane.isConnected ? smartCane.disconnect : smartCane.connect,
        ),
        _spacing,
        OutlinedButton(
          onPressed: () {
            // FlutterRingtonePlayer.playRingtone(volume: 1);
            parseBluetoothPayload("BATTERY_PERCENTAGE:30");
          },
          child: const Text("Where is my SmartCane?"),
          style: _outlinedButtonStyle,
        ),
        _spacing,
        OutlinedButton(
          onPressed: () {},
          child: const Text("Navigation"),
          style: _outlinedButtonStyle,
        ),
      ],
    );
  }
}
