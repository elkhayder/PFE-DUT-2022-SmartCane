import 'package:flutter/material.dart';

class Screen {
  final IconData activeIcon;
  final IconData? inactiveIcon;
  final String label;
  final Widget screen;

  Screen({
    required this.activeIcon,
    this.inactiveIcon,
    required this.label,
    required this.screen,
  });
}
