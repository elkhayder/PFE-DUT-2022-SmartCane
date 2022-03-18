import 'package:telephony/telephony.dart';
import '../bluetooth_payload_handler.dart';

import 'package:mobile_app/services/location.dart';

class SendCurrentLocationSMS implements BluetoothPayloadHandler {
  final Telephony telephony = Telephony.instance;

  final LocationService location = LocationService();

  @override
  String command = "SEND_LOCATION_SMS";

  @override
  void handle(List<String> args) async {
    var currentLocation = await location.updateCurrentLocation();

    String message = "Hey dude, I'm lost. Please call me.";

    if (currentLocation?.longitude != null && currentLocation?.latitude != null) {
      String mapLink =
          "https://www.google.com/maps/search/?api=1&query=${currentLocation!.latitude!.toString()}%2C${currentLocation.longitude!.toString()}";

      message += " Here is my current location: $mapLink";
    }

    print("Send user current location: $message");

    telephony.sendSms(
      // to: "+212767265783",
      to: "+212653200413",
      message: message,
    );
  }
}
