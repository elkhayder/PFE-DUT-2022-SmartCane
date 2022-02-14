import 'package:flutter/material.dart';
import 'package:mobile_app/screens/bluetooth.dart';
import 'package:mobile_app/services/navigation.dart';
import 'package:mobile_app/services/smart_cane.dart';
import 'package:mobile_app/services/location.dart';
import 'package:provider/provider.dart';

import '/screens/home.dart';
import '/screens/maps.dart';
import '/models/screen.dart';

void main() {
  runApp(const MyApp());
}

// Addr = 98d3:33:813d33

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => SmartCaneService()),
      ],
      child: MaterialApp(
        title: 'Smart Cane',
        debugShowCheckedModeBanner: false,
        navigatorKey: GlobalContextService.navigatorKey, // set property
        // showSemanticsDebugger: true,
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark().copyWith(
          appBarTheme: ThemeData.dark().appBarTheme.copyWith(
                centerTitle: true,
                elevation: 0,
              ),
        ),
        home: SafeArea(
          child: Scaffold(
            body: IndexedStack(
              children: _screens.map((e) {
                int index = _screens.indexOf(e);
                // Ignoring symantics for hidden pages
                return ExcludeSemantics(
                  child: e.screen,
                  excluding: index != _bottomNavigationCurrentIndex,
                );
              }).toList(),
              index: _bottomNavigationCurrentIndex,
              sizing: StackFit.expand,
            ),
            bottomNavigationBar: _bottomNavigationBar(),
          ),
        ),
      ),
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
