import 'package:bilimusic/common/components/underline_tab_switcher.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/feature/player/logic/display/player_cover_color_provider.dart';
import 'package:bilimusic/feature/player/ui/car/car_player_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const Positioned.fill(child: CarCoverGlow()),
          SafeArea(
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
                              color: Colors.transparent,
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
        ],
      ),
    );
  }
}

class CarCoverGlow extends ConsumerWidget {
  const CarCoverGlow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color? coverColor = ref.watch(playerCoverColorControllerProvider);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final HSLColor hsl = HSLColor.fromColor(coverColor ?? Colors.transparent);
    final Color glow = coverColor == null
        ? Colors.transparent
        : hsl
              .withSaturation(hsl.saturation.clamp(0.0, 0.55))
              .withLightness(dark ? 0.55 : 0.70)
              .toColor()
              .withValues(alpha: dark ? 0.18 : 0.30);
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-1.0, 1.0),
              radius: 1.1,
              colors: <Color>[glow, glow.withValues(alpha: 0)],
            ),
          ),
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        spacing: 8,
        children: <Widget>[
          Expanded(
            child: UnderlineTabSwitcher(
              labels: const <String>['我的', '推荐'],
              selectedIndex: currentLocation.startsWith('/profile')
                  ? 0
                  : currentLocation.startsWith('/home')
                  ? 1
                  : -1,
              onChanged: (int index) => onSelect(index == 0 ? 1 : 0),
              minimumSize: const Size(104, 56),
              textStyle: theme.textTheme.titleLarge,
              spacing: 8,
            ),
          ),
          IconButton(
            tooltip: '搜索',
            color: colors.onSurfaceVariant,
            constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
            onPressed: () => context.go('/search'),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: '设置',
            color: colors.onSurfaceVariant,
            constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
    );
  }
}
