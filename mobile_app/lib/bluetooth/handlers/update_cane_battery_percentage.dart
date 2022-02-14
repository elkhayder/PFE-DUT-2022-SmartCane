import 'package:flutter/material.dart';
import 'package:mobile_app/bluetooth/bluetooth_payload_handler.dart';
import 'package:mobile_app/services/navigation.dart';
import 'package:mobile_app/services/smart_cane.dart';
import 'package:provider/provider.dart';

class UpdateCaneBatteryPercentage implements BluetoothPayloadHandler {
  SmartCaneService? _smartCane;

  UpdateCaneBatteryPercentage() {
    var context = GlobalContextService.navigatorKey.currentContext;
    if (context != null) {
      _smartCane = Provider.of<SmartCaneService>(context, listen: false);
    }
  }

  @override
  String command = "BATTERY_PERCENTAGE";

  @override
  void handle(List<String> args) {
    print(_smartCane);
    _smartCane?.setBatteryPercentage(int.parse(args[0]));
  }
}
