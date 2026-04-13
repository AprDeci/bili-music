import 'package:bilimusic/router/components/ScaffoldWithNavBar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MobileShellScaffold extends StatelessWidget {
  const MobileShellScaffold({
    super.key,
    required this.navigationShell,
    required this.currentLocation,
  });

  final StatefulNavigationShell navigationShell;
  final String currentLocation;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithNavBar(
      navigationShell: navigationShell,
      currentLocation: currentLocation,
    );
  }
}
