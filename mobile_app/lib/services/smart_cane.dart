import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:mobile_app/bluetooth/bluetooth_payload_handler.dart';

class SmartCaneService extends ChangeNotifier {
  BluetoothConnection? _connection;

  bool isConnected = false;

  // Battery Percentage
  int batteryPercentage = 0;

  void setBatteryPercentage(int value) {
    batteryPercentage = value;
    notifyListeners();
  }

  String _payloadBuffer = "";

  SmartCaneService() {
    if (isConnected && _connection == null) {
      connect();
    }
  }

  void connect() async {
    // SMART CANE : 98:D3:33:81:3D:33
    const String address = "98:D3:33:81:3D:33";
    try {
      print("Connecting to bluetooth device: $address");
      _connection = await BluetoothConnection.toAddress(address);
      print('Connected to the device');
      isConnected = true;
      _connection?.input?.listen(_onRecievePayload);
    } catch (exception) {
      isConnected = false;
      print("Failed connecting to bluetooth Device : $address");
    }

    notifyListeners();
  }

  void disconnect() async {
    await _connection?.close();
    _connection?.dispose();
    isConnected = false;
    _connection = null;
    _payloadBuffer = "";
    notifyListeners();
  }

  void _onRecievePayload(Uint8List payload) {
    for (var char in payload) {
      // 0x0A (10) corresponds to \n char
      print(char);
      if (char == 0x0A) {
        parseBluetoothPayload(_payloadBuffer);
        _payloadBuffer = ""; // Reset Message buffer
      } else {
        _payloadBuffer += ascii.decode([char]);
      }
    }
    notifyListeners();
  }

  void sendPayload(String payload) {
    _connection?.output.add(
      Uint8List.fromList([...ascii.encode(payload), 0x0A]),
    );
  }
}
