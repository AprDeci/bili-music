import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/mini_player_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends ConsumerStatefulWidget {
  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
    required this.currentLocation,
  });

  final StatefulNavigationShell navigationShell;
  final String currentLocation;

  @override
  ConsumerState<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends ConsumerState<ScaffoldWithNavBar> {
  int _currentIndex = 0;

  @override
  void didUpdateWidget(covariant ScaffoldWithNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentIndex = widget.navigationShell.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final PlayerState playerState = ref.watch(playerControllerProvider);
    final bool shouldHideBottomNav = _shouldHideBottomNav(
      widget.currentLocation,
    );

    return Scaffold(
      body: shouldHideBottomNav
          ? _ShellContent(
              navigationShell: widget.navigationShell,
              playerState: playerState,
              onMiniPlayerTap: () => context.push('/player'),
              onTogglePlayback: () {
                ref.read(playerControllerProvider.notifier).togglePlayback();
              },
            )
          : BottomBar(
              fit: StackFit.expand,
              borderRadius: BorderRadius.circular(40),
              offset: 0,
              barColor: Colors.transparent,
              duration: const Duration(milliseconds: 300),
              width: screenWidth * 0.92,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                  ),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 30,
                      offset: Offset(0, 16),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: NavigationBarTheme(
                    data: NavigationBarThemeData(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      height: 60,
                      indicatorColor: colorScheme.primary.withValues(
                        alpha: 0.12,
                      ),
                      iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return IconThemeData(color: colorScheme.primary);
                          }

                          return const IconThemeData(color: Color(0xFF7B8698));
                        },
                      ),
                    ),
                    child: NavigationBar(
                      selectedIndex: _currentIndex,
                      onDestinationSelected: (int index) {
                        setState(() => _currentIndex = index);
                        widget.navigationShell.goBranch(
                          index,
                          initialLocation:
                              index == widget.navigationShell.currentIndex,
                        );
                      },
                      labelBehavior:
                          NavigationDestinationLabelBehavior.alwaysHide,
                      destinations: const <NavigationDestination>[
                        NavigationDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home),
                          label: '首页',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.person_outlined),
                          selectedIcon: Icon(Icons.person),
                          label: '我的',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              body: (BuildContext context, ScrollController scrollController) {
                return _ShellContent(
                  navigationShell: widget.navigationShell,
                  playerState: playerState,
                  onMiniPlayerTap: () => context.push('/player'),
                  onTogglePlayback: () {
                    ref
                        .read(playerControllerProvider.notifier)
                        .togglePlayback();
                  },
                );
              },
            ),
    );
  }

  bool _shouldHideBottomNav(String location) {
    return location == '/profile/favorites' ||
        location.startsWith('/profile/favorites/');
  }
}

class _ShellContent extends StatelessWidget {
  const _ShellContent({
    required this.navigationShell,
    required this.playerState,
    required this.onMiniPlayerTap,
    required this.onTogglePlayback,
  });

  final StatefulNavigationShell navigationShell;
  final PlayerState playerState;
  final VoidCallback onMiniPlayerTap;
  final VoidCallback onTogglePlayback;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        navigationShell,
        if (playerState.hasItem)
          Align(
            alignment: Alignment.bottomCenter,
            child: MiniPlayerBar(
              state: playerState,
              onTap: onMiniPlayerTap,
              onTogglePlayback: onTogglePlayback,
            ),
          ),
      ],
    );
  }
}
