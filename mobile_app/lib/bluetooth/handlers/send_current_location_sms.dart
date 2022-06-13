import 'package:mobile_app/includes/constants.dart';
import 'package:mobile_app/includes/helpers.dart';
import 'package:mobile_app/models/emergency_contact.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    var prefs = await SharedPreferences.getInstance();

    String message = prefs.getString("emergencyMessage") ?? Constants.Default_Emergency_Message;

    if (currentLocation?.longitude != null && currentLocation?.latitude != null) {
      message +=
          " https://www.google.com/maps/search/?api=1&query=${currentLocation!.latitude!.toString()}%2C${currentLocation.longitude!.toString()}";
    }

    List<EmergencyContact> contacts = await Helpers.fetchEmergencyContacts();

    if (contacts.isEmpty) {
      await Helpers.speak(
        "You don't have any emergency contacts, please add at least one in the settings menu.",
      );
      return;
    }

    for (var c in contacts) {
      await telephony.sendSms(
        to: c.phone,
        message: message,
      );
    }

    await Helpers.speak(
      "Location SMS sent to ${contacts.length} ${contacts.length == 1 ? "person" : "people"}",
    );
  }
}
