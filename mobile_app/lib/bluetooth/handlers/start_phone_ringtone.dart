import 'package:mobile_app/bluetooth/bluetooth_payload_handler.dart';
import 'package:mobile_app/includes/navigation.dart';

class StartPhoneRingtone implements BluetoothPayloadHandler {
  @override
  String command = "RING";

  @override
  void handle(List<String> args) {
    GlobalContextService.navigatorKey.currentState?.pushNamed("/findMyPhone");
  }
}
