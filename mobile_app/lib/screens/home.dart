import 'package:flutter/material.dart';
import 'package:mobile_app/services/location.dart';
import 'package:provider/provider.dart';
import 'package:android_intent_plus/android_intent.dart';

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
      body: SingleChildScrollView(
        child: Container(
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
      ),
    );
  }

  Row _buildCurrentLocationRow(BuildContext context) {
    final location = Provider.of<LocationService>(context);

    String currentPosition = location.placemark ?? "Unknown";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              "Your current location is: $currentPosition",
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
          "SmartCane is ${smartCane.isConnected ? "connected. Battery level is ${smartCane.batteryPercentage}%" : "disconnected"}",
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          child: Text("${smartCane.isConnected ? "Disc" : "C"}onnect SmartCane"),
          style: _outlinedButtonStyle,
          onPressed: smartCane.isConnected ? smartCane.disconnect : smartCane.connect,
        ),
        _spacing,
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pushNamed("/places/explore");
          },
          child: const Text("Explore"),
          style: _outlinedButtonStyle,
        ),
        _spacing,
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pushNamed("/places/search");
          },
          child: const Text("Search"),
          style: _outlinedButtonStyle,
        ),
        _spacing,
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pushNamed("/places/favourite");
          },
          child: const Text("Saved places"),
          style: _outlinedButtonStyle,
        ),
        _spacing,
        OutlinedButton(
          onPressed: () {
            smartCane.send("RING", []);
          },
          child: const Text("Where is my SmartCane?"),
          style: _outlinedButtonStyle,
        ),
      ],
    );
  }
}
