import 'package:flutter_tts/flutter_tts.dart';
import 'package:mobile_app/bluetooth/bluetooth_payload_handler.dart';
import 'package:mobile_app/includes/helpers.dart';

class Speak implements BluetoothPayloadHandler {
  @override
  String command = "SPEAK";

  @override
  void handle(List<String> args) async {
    await Helpers.speak(args[0]);
  }
}
