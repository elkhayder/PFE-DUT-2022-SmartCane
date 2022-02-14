import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/smart_cane.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({Key? key}) : super(key: key);

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  final _textInputController = TextEditingController();
  final List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textInputController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var bluetooth = Provider.of<SmartCaneService>(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          Text(bluetooth.isConnected ? "Connected" : "Disconnected"),
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
                onPressed: () {},
                child: const Text("Send"),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {},
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
