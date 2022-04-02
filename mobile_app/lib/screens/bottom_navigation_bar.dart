import 'package:flutter/material.dart';
import 'package:mobile_app/models/screen.dart';
import 'package:mobile_app/screens/home.dart';
import 'package:mobile_app/screens/settings.dart';

class BottomNavigationBarScreen extends StatefulWidget {
  const BottomNavigationBarScreen({Key? key}) : super(key: key);

  @override
  State<BottomNavigationBarScreen> createState() => _BottomNavigationBarScreenState();
}

class _BottomNavigationBarScreenState extends State<BottomNavigationBarScreen> {
  int _bottomNavigationCurrentIndex = 0;

  final List<Screen> _screens = [
    Screen(
      activeIcon: Icons.navigation,
      inactiveIcon: Icons.navigation_outlined,
      label: "Home",
      screen: const HomeScreen(),
    ),
    Screen(
      activeIcon: Icons.settings,
      inactiveIcon: Icons.settings_outlined,
      label: "Settings",
      screen: const SettingScreen(),
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
        var index = _screens.indexOf(e);
        return BottomNavigationBarItem(
          icon: Icon(
            _bottomNavigationCurrentIndex == index
                ? e.activeIcon
                : (e.inactiveIcon ?? e.activeIcon),
          ),
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
