import 'package:flutter/material.dart';
import 'package:mobile_app/services/theme.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _theme(context),
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
}
