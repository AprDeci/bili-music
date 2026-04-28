import 'package:bilimusic/common/components/desktop/desktop_top_bar.dart';
import 'package:bilimusic/common/components/desktop/desktop_side_panel.dart';
import 'package:bilimusic/feature/profile/ui/desktop_profile_sidebar.dart';
import 'package:bilimusic/feature/player/ui/desktop_player_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DesktopShellScaffold extends ConsumerWidget {
  const DesktopShellScaffold({
    super.key,
    required this.navigationShell,
    required this.currentLocation,
  });

  final StatefulNavigationShell navigationShell;
  final String currentLocation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DesktopProfileSidebar(currentLocation: currentLocation),
              const SizedBox(width: 16),
              // 内容区
              Expanded(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        key: desktopSidePanelHostKey,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer.withValues(
                            alpha: 0.52,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            const DesktopTopBar(),
                            Expanded(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Container(child: navigationShell),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const DesktopPlayerBar(),
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
