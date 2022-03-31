import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:mobile_app/includes/helpers.dart';
import 'package:mobile_app/includes/navigation.dart';
import 'package:mobile_app/includes/declarations.dart';
import 'package:mobile_app/models/emergency_contact.dart';
import 'package:mobile_app/includes/declarations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyContactsSettingsScreen extends StatefulWidget {
  EmergencyContactsSettingsScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyContactsSettingsScreen> createState() => _EmergencyContactsSettingsScreenState();
}

class _EmergencyContactsSettingsScreenState extends State<EmergencyContactsSettingsScreen> {
  List<EmergencyContact> _contacts = [];

  void fetchSavedContacts() async {
    _contacts = await Helpers.fetchEmergencyContacts();

    setState(() {});
  }

  void addContact(FullContact contact) async {
    String phone = "";

    List<String> phones = contact.phones
        .map((e) => e.number!.replaceAll("-", "").replaceAll(" ", ""))
        .toList()
        .unique();

    if (phones.isEmpty) return;

    if (phones.length == 1) {
      phone = phones.first;
    } else {
      await showMenu<String>(
        initialValue: phones.first,
        context: GlobalContextService.navigatorKey.currentContext ?? context,
        // position: RelativeRect.fromSize(
        //   Rect.fromCenter(center: Offset.zero, width: 100, height: 100),
        //   const Size(100, 100),
        // ),
        position: const RelativeRect.fromLTRB(100, 100, 100, 100),
        items: phones.map((number) {
          return PopupMenuItem(
            child: Text(number),
            value: number,
            onTap: () => phone = number,
          );
        }).toList(),
      );
    }

    if (phone == "") phone = phones.first;

    EmergencyContact entry = EmergencyContact(
      name: contact.name!.nickName!,
      phone: phone,
    );

    _contacts.add(entry);

    setState(() {});

    saveContacts();
  }

  void deleteContact(int index) {
    _contacts.removeAt(index);

    setState(() {});

    saveContacts();
  }

  void saveContacts() async {
    var prefs = await SharedPreferences.getInstance();

    List<String> array = [];

    for (var contact in _contacts) {
      array.add(jsonEncode(contact.toJson()));
    }

    prefs.setStringList("emergency_contacts", array);
  }

  @override
  void initState() {
    super.initState();
    fetchSavedContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contacts d'urgence")),
      body: Column(
        children: [
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () async {
              try {
                final FullContact contact = await FlutterContactPicker.pickFullContact();
                addContact(contact);
              } catch (e) {}
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.import_contacts),
                SizedBox(width: 8),
                Text("Ajouter un contact"),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                var contact = _contacts.elementAt(index);
                return SizedBox(
                  height: 56,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(contact.name),
                          const SizedBox(width: 12),
                          Text(
                            contact.phone,
                            style: const TextStyle(color: Colors.white38),
                          )
                        ],
                      ),
                      IconButton(
                        onPressed: () => deleteContact(index),
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                      )
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => Divider(),
              itemCount: _contacts.length,
            ),
          ),
        ],
      ),
    );
  }
}
