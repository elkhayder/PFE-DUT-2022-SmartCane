import 'package:mobile_app/bluetooth/handlers/update_cane_battery_percentage.dart';

import 'handlers/send_current_location_sms.dart';

abstract class BluetoothPayloadHandler {
  late String command;
  void handle(List<String> args);
}

// COMMAND:ARG1|ARG2|ARG3|...|ARGx
void parseBluetoothPayload(String payload) {
  final String command = payload.split(":").first;

  final List<String> args =
      payload.split(":").length == 2 ? payload.split(":").elementAt(1).split("|") : [];

  print("$command ${args.toString()}");

  final List<BluetoothPayloadHandler> _handlers = [
    SendCurrentLocationSMS(),
    UpdateCaneBatteryPercentage()
  ];

  for (var handler in _handlers) {
    if (handler.command == command) handler.handle(args);
  }
}
