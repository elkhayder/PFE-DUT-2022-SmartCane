import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class FindMyPhoneScreen extends StatefulWidget {
  const FindMyPhoneScreen({Key? key}) : super(key: key);

  @override
  State<FindMyPhoneScreen> createState() => _FindMyPhoneScreenState();
}

class _FindMyPhoneScreenState extends State<FindMyPhoneScreen> {
  FocusNode buttonNode = FocusNode();

  @override
  void initState() {
    super.initState();
    FlutterRingtonePlayer.playRingtone(volume: 1);
    Future.delayed(Duration(seconds: 2), () {
      FocusScope.of(context).requestFocus(buttonNode);
    });
  }

  @override
  void deactivate() {
    FlutterRingtonePlayer.stop();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Ringing"),
          const SizedBox(height: 24),
          OutlinedButton(
            autofocus: true,
            focusNode: buttonNode,
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Back"),
          ),
        ],
      ),
    );
  }
}
