import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BluetoothConnection? _bluetoothConnection;

  bool _isBluetoothConnected = false;
  final _textInputController = TextEditingController();
  final List<String> _recievedData = [];

  void _bluetoothConnect() async {
    // SMART CANE : 98:D3:33:81:3D:33
    const String address = "98:D3:33:81:3D:33";
    try {
      print("Connection to bluetooth device: $address");
      _bluetoothConnection = await BluetoothConnection.toAddress(address);
      print('Connected to the device');
      setState(() {
        _isBluetoothConnected = true;
      });
      _bluetoothConnection?.input?.listen((event) {
        print(event);
        final message = ascii.decode(event);
        print("Recieved: $message");
        setState(() {
          _recievedData.add(message);
        });
      });
    } catch (exception) {
      setState(() {
        _isBluetoothConnected = false;
      });
      print("Failed connecting to bluetooth Device : $address");
    }
  }

  void _bluetoothDisconnect() async {
    _bluetoothConnection?.dispose();
    await _bluetoothConnection?.close();
  }

  void _bluetoothReconnect() {
    _bluetoothDisconnect();
    _bluetoothConnect();
  }

  @override
  void initState() {
    super.initState();

    _bluetoothConnect();
  }

  @override
  void dispose() {
    _bluetoothDisconnect();
    _textInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          Text(_isBluetoothConnected ? "Connected" : "Disconnected"),
          TextField(
            controller: _textInputController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Message ...',
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  _bluetoothConnection?.output.add(ascii.encode(_textInputController.text));
                  _textInputController.clear();
                },
                child: const Text("Send"),
              ),
              SizedBox(width: 12),
              OutlinedButton(
                onPressed: _bluetoothReconnect,
                child: const Text("Reconnect"),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return Text(_recievedData[index]);
              },
              itemCount: _recievedData.length,
              scrollDirection: Axis.vertical,
            ),
          )
        ],
      ),
    );
  }
}
