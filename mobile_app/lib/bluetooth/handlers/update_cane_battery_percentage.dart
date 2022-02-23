import 'package:mobile_app/bluetooth/bluetooth_payload_handler.dart';
import 'package:mobile_app/includes/navigation.dart';
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
    _smartCane?.setBatteryPercentage(int.parse(args.isNotEmpty ? args[0] : "0"));
  }
}
