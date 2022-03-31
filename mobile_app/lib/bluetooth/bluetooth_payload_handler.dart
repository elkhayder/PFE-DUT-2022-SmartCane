import 'package:mobile_app/bluetooth/handlers/start_phone_ringtone.dart';
import 'package:mobile_app/bluetooth/handlers/update_cane_battery_percentage.dart';
import 'package:mobile_app/bluetooth/handlers/speak.dart';
import 'package:mobile_app/bluetooth/handlers/send_current_location_sms.dart';

abstract class BluetoothPayloadHandler {
  late String command;
  void handle(List<String> args);
}

// COMMAND:ARG1|ARG2|ARG3|...|ARGx
void parseBluetoothPayload(String payload) {
  print(payload);

  final String command = payload.split(":").first;

  final List<String> args =
      payload.split(":").length == 2 ? payload.split(":").elementAt(1).split("|") : [];

  final List<BluetoothPayloadHandler> _handlers = [
    SendCurrentLocationSMS(),
    UpdateCaneBatteryPercentage(),
    StartPhoneRingtone(),
    Speak(),
  ];

  for (var handler in _handlers) {
    if (handler.command == command) handler.handle(args);
  }
}
