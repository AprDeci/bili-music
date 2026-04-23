import 'package:bilimusic/feature/player/ui/mini_player_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DesktopShellScaffold extends StatelessWidget {
  const DesktopShellScaffold({
    super.key,
    required this.navigationShell,
    required this.currentLocation,
  });

  final StatefulNavigationShell navigationShell;
  final String currentLocation;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(width: 240, padding: const EdgeInsets.all(20)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ColoredBox(
                        color: colorScheme.surfaceContainerLowest,
                        child: navigationShell,
                      ),
                    ),
                    SizedBox(height: 56, child: Text("playerbar")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
