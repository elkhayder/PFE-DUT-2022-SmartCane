import 'package:flutter/material.dart';

class GlobalContextService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static BuildContext? currentRouteContext;
  static FocusScopeNode? currentFocusScopeNode;
}
