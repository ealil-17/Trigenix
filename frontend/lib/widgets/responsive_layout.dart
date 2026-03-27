import 'package:flutter/material.dart';

class ResponsiveLayout {
  ResponsiveLayout._();

  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 800;
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1100;

  static double pageHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1400) return 48;
    if (width >= 1100) return 36;
    if (width >= 800) return 24;
    return 16;
  }

  static double contentMaxWidth(BuildContext context) {
    if (isDesktop(context)) return 1280;
    return 920;
  }
}
