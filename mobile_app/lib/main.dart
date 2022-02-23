import 'package:flutter/material.dart';
import 'package:mobile_app/includes/navigation.dart';
import 'package:mobile_app/screens/place/find_by_type.dart';
import 'package:mobile_app/services/smart_cane.dart';
import 'package:mobile_app/services/location.dart';
import 'package:provider/provider.dart';

import 'package:mobile_app/screens/bottom_navigation_bar.dart';
import 'package:mobile_app/screens/explore.dart';
import 'package:mobile_app/screens/find_my_phone.dart';

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
        initialRoute: "/",
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    Widget? screen;

    final args = settings.arguments as Map?;

    switch (settings.name) {
      case "/":
        screen = const BottomNavigationBarScreen();
        break;

      case "/findMyPhone":
        screen = const FindMyPhoneScreen();
        break;

      case "/places/explore":
        screen = const ExploreScreen();
        break;

      case "/places/findByType":
        screen = FindPlacesByTypeScreen(
          type: args?["type"],
        );
        break;
    }

    return MaterialPageRoute(
      builder: (_) => SafeArea(
        child: Scaffold(
          body: screen ?? _errorScreen(settings),
        ),
      ),
    );
  }

  Widget _errorScreen(RouteSettings settings) {
    return Center(child: Text("Error: ${settings.name} not found"));
  }
}
