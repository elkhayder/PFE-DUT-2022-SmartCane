import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile_app/bluetooth/bluetooth_payload_handler.dart';
import 'package:mobile_app/includes/navigation.dart';
import 'package:mobile_app/services/navigatables.dart';
import 'package:mobile_app/services/smart_cane.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';

class NavigatablesRemote implements BluetoothPayloadHandler {
  @override
  String command = "NAVIGATABLES";

  @override
  void handle(List<String> args) async {
    BuildContext? context = GlobalContextService.navigatorKey.currentContext;
    if (context == null) return;

    var navigatables = NavigatablesService.of(context);
    var cane = Provider.of<SmartCaneService>(context, listen: false);

    switch (args[0]) {
      case "NEXT":
        navigatables.focusNext();
        break;

      case "PREVIOUS":
        navigatables.focusPrevious();
        break;

      case "BACK":
        NavigatorState? navigator = GlobalContextService.navigatorKey.currentState;
        if (navigator == null) break;
        NavigatablesService.of(context).currentlyFocusedIndex = null;
        navigator.maybePop();
        break;

      case "PRESS":
        navigatables.onPressed();
        break;

      case "RESET":
        navigatables.reset();
        cane.disconnect();
        Restart.restartApp();
        break;

      case "EXPLORE":
        GlobalContextService.navigatorKey.currentState?.pushNamed("/places/explore");
        break;
    }
    // FocusScope.of(context).nextFocus();
  }
}
