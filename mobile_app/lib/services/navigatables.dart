import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mobile_app/includes/helpers.dart';
import 'package:mobile_app/includes/navigation.dart';
import 'package:mobile_app/screens/home.dart';
import 'package:mobile_app/widgets/navigatable_element.dart';
import 'package:mobile_app/widgets/single_search_result.dart';
import 'package:provider/provider.dart';

class NavigatablesService extends ChangeNotifier {
  List<List<NavigatableElement>> elements = [];
  int? currentlyFocusedIndex;
  int get length => elements.length - 1;

  void focusNext() {
    int nextIndex = currentlyFocusedIndex == null ? 0 : currentlyFocusedIndex! + 1;

    // nextIndex = nextIndex % (length - 1);
    nextIndex = nextIndex % length;

    focusElementAtIndex(nextIndex);

    currentlyFocusedIndex = nextIndex;

    notifyListeners();
  }

  void focusPrevious() {
    int previousIndex = currentlyFocusedIndex == null || currentlyFocusedIndex == 0
        ? length - 1
        : currentlyFocusedIndex! - 1;

    focusElementAtIndex(previousIndex);

    currentlyFocusedIndex = previousIndex;

    notifyListeners();
  }

  void focusElementAtIndex(int index) {
    elements.removeWhere((x) => x.isEmpty);

    // var context = elements.elementAt(index).last.context;
    // final renderObject = context.findRenderObject() as dynamic;
    // renderObject.focusable = true;
    // renderObject.focused = true;
    // inspect(renderObject);
    // var e = renderObject.debugSemantics as SemanticsNode;
    // e.sendEvent(AnnounceSemanticsEvent(renderObject.child.debugSemantics.label, TextDirection.ltr));

    // inspect(elements);

    try {
      NavigatableElement element = elements.elementAt(index).last;
      FocusNode node = element.focusNode;
      GlobalContextService.navigatorKey.currentState?.focusScopeNode.requestFocus(node);
      // node.nearestScope?.requestFocus(node);
      node.nextFocus();
    } catch (error) {
      inspect(error);
      Helpers.speak(
        "Failed to navigate to the element you requested, please reset the navigation and try again",
      );
    }
  }

// d608c
  void insertElement(NavigatableElement e, int index) {
    try {
      elements.elementAt(index).add(e);
    } catch (exception) {
      elements.insert(index, [e]);
    }
    //notifyListeners();
  }

  void removeElement(NavigatableElement e, int index) {
    try {
      elements.elementAt(index).remove(e);
    } catch (e) {}
    //notifyListeners();
  }

  void reset() {
    var navigator = GlobalContextService.navigatorKey.currentState;

    if (navigator == null) return;

    navigator.popUntil((route) => false);

    elements = [];
    currentlyFocusedIndex = null;

    navigator.pushNamed("/");
    // Helpers.speak("Navigation reset succefully");
    //notifyListeners();
  }

  void onPressed() {
    if (currentlyFocusedIndex == null) return;

    var element = elements.elementAt(currentlyFocusedIndex! + 1).last.child as dynamic;

    if (element is SingleSearchResult) {
      GlobalContextService.navigatorKey.currentState?.pushNamed(
        "/places/info",
        arguments: {"placeId": element.place.info.placeId},
      );
    }

    if (element is SizedBox) {
      element = element.child;
    }

    try {
      element.onPressed();
    } catch (e) {}
  }

  static NavigatablesService of(BuildContext context, {bool listen = false}) =>
      Provider.of<NavigatablesService>(context, listen: listen);
}
