import 'package:flutter/material.dart';
import 'package:mobile_app/includes/constants.dart';
import 'package:mobile_app/services/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late TextEditingController emergencyMessageController = TextEditingController();

  @override
  void dispose() {
    emergencyMessageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _theme(context),
          InkWell(
            onTap: () async {
              var prefs = await SharedPreferences.getInstance();
              emergencyMessageController.text =
                  prefs.getString("emergencyMessage") ?? Constants.defaultEmergencyMessage;
              String? message = await showEmergencyMessagePopup();
              await prefs.setString(
                  "emergencyMessage", message ?? Constants.defaultEmergencyMessage);
            },
            child: Container(
              height: 56,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Align(
                child: Text("Emergency message"),
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed("/settings/emergency_contacts");
            },
            child: Container(
              height: 56,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Align(
                child: Text("Emergency contacts"),
                alignment: Alignment.centerLeft,
              ),
            ),
          )
        ],
      ),
    );
  }

  ListTile _theme(BuildContext context) {
    var theme = Provider.of<ThemeService>(context);

    return ListTile(
      minLeadingWidth: 0,
      leading: const Padding(
        padding: EdgeInsets.only(top: 10),
        child: Text("Theme"),
      ),
      trailing: DropdownButton<ThemeMode>(
        value: theme.mode,
        items: const [
          DropdownMenuItem(
            child: Text("Light"),
            value: ThemeMode.light,
          ),
          DropdownMenuItem(
            child: Text("Dark"),
            value: ThemeMode.dark,
          ),
          DropdownMenuItem(
            child: Text("System"),
            value: ThemeMode.system,
          ),
        ],
        onChanged: (value) {
          if (value == null) return;
          theme.mode = value;
        },
      ),
    );
  }

  Future<String?> showEmergencyMessagePopup() {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Emergency message"),
        content: TextField(
          decoration: const InputDecoration(hintText: "Emergency message"),
          autofocus: true,
          controller: emergencyMessageController,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(emergencyMessageController.text);
            },
            child: const Text("Confirm"),
          )
        ],
      ),
    );
  }
}
