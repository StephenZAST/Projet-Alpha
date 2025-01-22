import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    Key? key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  }) : super(key: key);

  // Breakpoints constants
  static const double MOBILE_BREAKPOINT = 850;
  static const double TABLET_BREAKPOINT = 1100;

  // Largeur du menu latéral en fonction de la taille de l'écran
  static double getSideMenuWidth(BuildContext context) {
    if (isDesktop(context)) return 250;
    if (isTablet(context)) return 200;
    return 190;
  }

  // Helpers pour détecter le type d'appareil
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < MOBILE_BREAKPOINT;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < TABLET_BREAKPOINT &&
      MediaQuery.of(context).size.width >= MOBILE_BREAKPOINT;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= TABLET_BREAKPOINT;

  // Retourne le padding approprié en fonction de la taille de l'écran
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(16.0);
    }
    if (isTablet(context)) {
      return const EdgeInsets.all(12.0);
    }
    return const EdgeInsets.all(8.0);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    // Layout responsive en fonction de la taille de l'écran
    if (size.width >= TABLET_BREAKPOINT) {
      return desktop;
    }
    // Si la largeur est entre MOBILE_BREAKPOINT et TABLET_BREAKPOINT et qu'un layout tablet existe
    else if (size.width >= MOBILE_BREAKPOINT && tablet != null) {
      return tablet!;
    }
    // Si la largeur est inférieure à MOBILE_BREAKPOINT ou qu'aucun layout tablet n'existe
    else {
      return mobile;
    }
  }
}
