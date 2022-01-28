import 'dart:convert';
import 'dart:typed_data';

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
  final List<Message> _messages = [];
  String _messageBuffer = "";

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
      _bluetoothConnection?.input?.listen(_onRecievePayload);
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

  void _onRecievePayload(Uint8List payload) {
    for (var char in payload) {
      // 0x0A (10) corresponds to \n char
      if (char == 0x0A) {
        setState(() {
          _messages.add(Message(content: _messageBuffer, isSent: false));
          _messageBuffer = ""; // Reset Message buffer
        });
      } else {
        _messageBuffer += ascii.decode([char]);
      }
    }
  }

  void _onSendPayload() {
    String value = _textInputController.text;
    _bluetoothConnection?.output.add(
      Uint8List.fromList([...ascii.encode(value), 0x0A]),
    );
    _textInputController.clear();
    setState(() {
      _messages.add(Message(content: value, isSent: true));
    });
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
                onPressed: _onSendPayload,
                child: const Text("Send"),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _bluetoothReconnect,
                child: const Text("Reconnect"),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                Message message = _messages[_messages.length - index - 1];
                return Text(
                  message.content,
                  textAlign: message.isSent ? TextAlign.right : TextAlign.left,
                );
              },
              itemCount: _messages.length,
              scrollDirection: Axis.vertical,
            ),
          )
        ],
      ),
    );
  }
}

class Message {
  bool isSent;
  String content;

  Message({required this.content, required this.isSent});
}
