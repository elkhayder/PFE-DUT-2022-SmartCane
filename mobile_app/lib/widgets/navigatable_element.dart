import 'package:flutter/material.dart';
import 'package:mobile_app/services/navigatables.dart';

class NavigatableElement extends StatefulWidget {
  Widget child;
  int index;
  FocusNode focusNode = FocusNode();
  late BuildContext context;
  bool focused = true;

  NavigatableElement({
    Key? key,
    required this.child,
    required this.index,
  }) : super(key: key);

  @override
  State<NavigatableElement> createState() => _NavigatableElementState();
}

class _NavigatableElementState extends State<NavigatableElement> {
  late NavigatablesService _navigatables;

  @override
  void initState() {
    super.initState();
    _navigatables = NavigatablesService.of(context);
    _navigatables.insertElement(widget, widget.index);
    widget.context = context;
  }

  @override
  void dispose() {
    widget.focusNode.dispose();
    _navigatables.removeElement(widget, widget.index);
    super.dispose();
  }

  // @override
  // void didUpdateWidget(NavigatableElement oldWidget) {
  //   super.didUpdateWidget(oldWidget);

  //   _navigatables.insertElement(widget, widget.index);
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigatables.removeElement(widget, widget.index);
        return true;
      },
      child: Focus(
        // autofocus: widget.index == 1,
        child: RepaintBoundary(child: widget.child),
        focusNode: widget.focusNode,
      ),
    );
  }
}
