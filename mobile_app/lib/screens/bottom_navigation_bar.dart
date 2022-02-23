import 'package:flutter/material.dart';
import 'package:mobile_app/models/screen.dart';
import 'package:mobile_app/screens/bluetooth.dart';
import 'package:mobile_app/screens/home.dart';
import 'package:mobile_app/screens/maps.dart';

class BottomNavigationBarScreen extends StatefulWidget {
  const BottomNavigationBarScreen({Key? key}) : super(key: key);

  @override
  State<BottomNavigationBarScreen> createState() => _BottomNavigationBarScreenState();
}

class _BottomNavigationBarScreenState extends State<BottomNavigationBarScreen> {
  int _bottomNavigationCurrentIndex = 0;

  final List<Screen> _screens = [
    Screen(
      icon: Icons.home,
      label: "Home",
      screen: const HomeScreen(),
    ),
    Screen(
      icon: Icons.bluetooth,
      label: "Bluetooth",
      screen: const BluetoothScreen(),
    ),
    Screen(
      icon: Icons.map,
      label: "Map",
      screen: const MapsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        children: _screens.map((e) {
          int index = _screens.indexOf(e);
          // Ignoring semantics for hidden pages
          return ExcludeSemantics(
            child: e.screen,
            excluding: index != _bottomNavigationCurrentIndex,
          );
        }).toList(),
        index: _bottomNavigationCurrentIndex,
        sizing: StackFit.expand,
      ),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
      items: _screens.map((e) {
        return BottomNavigationBarItem(
          icon: Icon(e.icon),
          label: e.label,
        );
      }).toList(),
      currentIndex: _bottomNavigationCurrentIndex,
      onTap: (value) {
        setState(() {
          _bottomNavigationCurrentIndex = value;
        });
      },
    );
  }
}
