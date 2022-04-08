import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_app/includes/navigation.dart';
import 'package:mobile_app/screens/favourites_places.dart';
import 'package:mobile_app/screens/place/find_by_type.dart';
import 'package:mobile_app/screens/place/info.dart';
import 'package:mobile_app/screens/search_place.dart';
import 'package:mobile_app/screens/settings/emergency_contacts.dart';
import 'package:mobile_app/services/navigatables.dart';
import 'package:mobile_app/services/smart_cane.dart';
import 'package:mobile_app/services/location.dart';
import 'package:mobile_app/services/theme.dart';
import 'package:provider/provider.dart';

import 'package:mobile_app/screens/bottom_navigation_bar.dart';
import 'package:mobile_app/screens/explore.dart';
import 'package:mobile_app/screens/find_my_phone.dart';
import 'package:uni_links/uni_links.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => SmartCaneService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => NavigatablesService()),
      ],
      child: const MyApp(),
    ),
  );
}

// Addr = 98d3:33:813d33

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription _unilinkStreamSubscription;

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
    }

    initUniLinks();
  }

  Future<void> initUniLinks() async {
    try {
      parseUnilinkURI(await getInitialUri());
    } catch (e) {
      //
    }

    _unilinkStreamSubscription = uriLinkStream.listen(parseUnilinkURI, onError: (err) {});
  }

  void parseUnilinkURI(Uri? uri) {
    inspect(uri);

    if (uri == null) return;

    String? id = uri.queryParameters["id"];

    if (id == null) return;

    GlobalContextService.navigatorKey.currentState
        ?.pushNamed("/places/info", arguments: {"placeId": id});

    inspect(GlobalContextService.navigatorKey.currentState);
  }

  @override
  void dispose() {
    _unilinkStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Provider.of<ThemeService>(context);

    return MaterialApp(
      title: 'Smart Cane',
      debugShowCheckedModeBanner: false,
      navigatorKey: GlobalContextService.navigatorKey,
      // showSemanticsDebugger: true,
      themeMode: theme.mode,
      darkTheme: ThemeData.dark().copyWith(
        appBarTheme: ThemeData.dark().appBarTheme.copyWith(
              centerTitle: true,
              elevation: 1,
            ),
      ),
      theme: ThemeData.light().copyWith(
        appBarTheme: ThemeData.light().appBarTheme.copyWith(
              centerTitle: true,
              elevation: 1,
            ),
      ),
      initialRoute: "/",
      onGenerateRoute: _onGenerateRoute,
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

      case "/places/search":
        screen = const SearchPlaceScreen();
        break;

      case "/places/favourite":
        screen = const FavouritePlacesScreen();
        break;

      case "/places/findByType":
        screen = FindPlacesByTypeScreen(
          type: args?["type"],
        );
        break;

      // case "/places/navigate":
      //   screen = NavigateScreen(
      //     place: args?["place"],
      //     directions: args?["directions"],
      //   );
      //   break;

      case "/places/info":
        screen = PlaceInfosScreen(
          placeId: args?["placeId"],
        );
        break;

      case "/settings/emergency_contacts":
        screen = EmergencyContactsSettingsScreen();
        break;
    }

    return MaterialPageRoute(
      builder: (_) {
        Future.delayed(Duration.zero, () async {
          NavigatablesService.of(context).currentlyFocusedIndex = null;
          GlobalContextService.currentRouteContext = context;
        });
        return SafeArea(
          child: Scaffold(
            body: Builder(builder: (context) {
              return screen ?? _errorScreen(settings);
            }),
          ),
        );
      },
    );
  }

  Widget _errorScreen(RouteSettings settings) {
    return Center(
      child: Text("Error: ${settings.name} not found"),
    );
  }
}
