import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/feature/player/ui/car/car_player_panel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

class CarShellScaffold extends StatelessWidget {
  const CarShellScaffold({
    super.key,
    required this.navigationShell,
    required this.currentLocation,
  });

  final StatefulNavigationShell navigationShell;
  final String currentLocation;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surfaceContainerLow,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            if (PlatformUtil.isMacOS)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (_) => windowManager.startDragging(),
                child: const SizedBox(height: 28, width: double.infinity),
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool wide =
                      constraints.maxWidth >= 720 ||
                      (constraints.maxWidth >= 560 &&
                          constraints.maxHeight < 400);
                  final Widget content = Column(
                    children: <Widget>[
                      _CarNavigation(
                        currentLocation: currentLocation,
                        onSelect: (int index) =>
                            navigationShell.goBranch(index),
                      ),
                      Expanded(
                        child: Material(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(24),
                          clipBehavior: Clip.antiAlias,
                          child: navigationShell,
                        ),
                      ),
                    ],
                  );
                  return Padding(
                    padding: EdgeInsets.all(wide ? 16 : 8),
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              SizedBox(
                                width: (constraints.maxWidth * 0.29).clamp(
                                  240,
                                  400,
                                ),
                                child: const CarPlayerPanel(),
                              ),
                              const SizedBox(width: 20),
                              Expanded(child: content),
                            ],
                          )
                        : Column(
                            children: <Widget>[
                              Expanded(child: content),
                              const SizedBox(height: 8),
                              const SizedBox(
                                height: 144,
                                child: CarPlayerPanel(compact: true),
                              ),
                            ],
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarNavigation extends StatelessWidget {
  const _CarNavigation({required this.currentLocation, required this.onSelect});

  final String currentLocation;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 8,
          children: <Widget>[
            for (final (int index, String label, IconData icon, String path)
                in <(int, String, IconData, String)>[
                  (1, '我的', Icons.library_music_outlined, '/profile'),
                  (0, '推荐', Icons.explore_outlined, '/home'),
                ])
              TextButton.icon(
                style: TextButton.styleFrom(
                  minimumSize: const Size(104, 56),
                  backgroundColor: currentLocation.startsWith(path)
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  textStyle: Theme.of(context).textTheme.titleMedium,
                ),
                onPressed: () => onSelect(index),
                icon: Icon(icon),
                label: Text(label),
              ),
            IconButton(
              tooltip: '搜索',
              constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
              onPressed: () => context.go('/search'),
              icon: const Icon(Icons.search_rounded),
            ),
            IconButton(
              tooltip: '设置',
              constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
              onPressed: () => context.go('/settings'),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
