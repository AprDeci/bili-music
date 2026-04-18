import 'package:bilimusic/common/bottom_height_helper.dart';
import 'package:bilimusic/common/util/update_util.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/mini_player_bar.dart';
import 'package:bilimusic/feature/player/ui/mini_player_glass_bar.dart';
import 'package:bilimusic/feature/setting/logic/appearance_setting_logic.dart';
import 'package:bilimusic/router/player_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/widgets/surfaces/glass_bottom_bar.dart';

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
  static const Duration _animationDuration = Duration(milliseconds: 200);
  static const Curve _animationCurve = Curves.easeInOutCubic;
  static const double _navHiddenSlideOffset = 1.2;
  static const Duration _autoUpdateCheckDelay = Duration(milliseconds: 600);

  int _currentIndex = 0;
  bool _didScheduleUpdateCheck = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.navigationShell.currentIndex;
    _scheduleAutoUpdateCheck();
  }

  void _scheduleAutoUpdateCheck() {
    if (_didScheduleUpdateCheck) {
      return;
    }

    _didScheduleUpdateCheck = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(_autoUpdateCheckDelay);
      if (!mounted) {
        return;
      }

      await UpdateUtil.checkAndPromptForUpdate(context);
    });
  }

  @override
  void didUpdateWidget(covariant ScaffoldWithNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentIndex = widget.navigationShell.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final PlayerState playerState = ref.watch(playerControllerProvider);
    final bool useGlassBar = ref.watch(appearanceSettingLogicProvider);
    final bool usesCollapsedBottomChrome = _usesCollapsedBottomChrome(
      widget.currentLocation,
    );
    final double miniPlayerVisibleBottomPadding =
        BottomHeightHelper.miniPlayerBottomPaddingWithBottomBar(
          bottomInset: bottomInset,
        );
    final double miniPlayerCollapsedBottomPadding =
        BottomHeightHelper.miniPlayerBottomPaddingWithoutBottomBar(
          bottomInset: bottomInset,
        );

    final Widget content = _buildShellContent(
      context,
      playerState,
      usesCollapsedBottomChrome,
      useGlassBar,
      miniPlayerVisibleBottomPadding,
      miniPlayerCollapsedBottomPadding,
    );

    if (usesCollapsedBottomChrome) {
      return Scaffold(body: content);
    }

    return Scaffold(
      body: BottomBar(
        fit: StackFit.expand,
        borderRadius: BorderRadius.circular(40),
        offset: 0,
        barColor: Colors.transparent,
        duration: _animationDuration,
        width: screenWidth * 0.92,
        child: IgnorePointer(
          ignoring: usesCollapsedBottomChrome,
          child: AnimatedOpacity(
            duration: _animationDuration,
            curve: _animationCurve,
            opacity: usesCollapsedBottomChrome ? 0 : 1,
            child: AnimatedSlide(
              duration: _animationDuration,
              curve: _animationCurve,
              offset: usesCollapsedBottomChrome
                  ? const Offset(0, _navHiddenSlideOffset)
                  : Offset.zero,
              child: useGlassBar
                  ? GlassBottomBar(
                      glassSettings: const LiquidGlassSettings(),
                      spacing: 4,
                      verticalPadding: 4,
                      barHeight: 54,
                      horizontalPadding: 64,
                      unselectedIconColor:
                          theme.textTheme.bodyMedium?.color ?? Colors.black,
                      selectedIconColor:
                          theme.textTheme.bodyMedium?.color ?? Colors.black,
                      tabs: const <GlassBottomBarTab>[
                        GlassBottomBarTab(
                          icon: Icon(Icons.home_outlined),
                          label: '首页',
                        ),
                        GlassBottomBarTab(
                          icon: Icon(Icons.person_outlined),
                          label: '我的',
                        ),
                      ],
                      selectedIndex: _currentIndex,
                      onTabSelected: (int index) {
                        setState(() => _currentIndex = index);
                        widget.navigationShell.goBranch(
                          index,
                          initialLocation:
                              index == widget.navigationShell.currentIndex,
                        );
                      },
                    )
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
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
                            height: BottomHeightHelper.bottomBarHeight,
                            indicatorColor: colorScheme.primary.withValues(
                              alpha: 0.12,
                            ),
                            iconTheme:
                                WidgetStateProperty.resolveWith<IconThemeData>((
                                  Set<WidgetState> states,
                                ) {
                                  if (states.contains(WidgetState.selected)) {
                                    return IconThemeData(
                                      color: colorScheme.primary,
                                    );
                                  }

                                  return const IconThemeData(
                                    color: Color(0xFF7B8698),
                                  );
                                }),
                          ),
                          child: NavigationBar(
                            selectedIndex: _currentIndex,
                            onDestinationSelected: (int index) {
                              setState(() => _currentIndex = index);
                              widget.navigationShell.goBranch(
                                index,
                                initialLocation:
                                    index ==
                                    widget.navigationShell.currentIndex,
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
            ),
          ),
        ),
        body: (BuildContext context, ScrollController scrollController) =>
            content,
      ),
    );
  }

  Widget _buildShellContent(
    BuildContext context,
    PlayerState playerState,
    bool usesCollapsedBottomChrome,
    bool useGlassBar,
    double miniPlayerVisibleBottomPadding,
    double miniPlayerCollapsedBottomPadding,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        widget.navigationShell,
        ValueListenableBuilder<bool>(
          valueListenable: playerPageVisibilityListenable,
          builder: (BuildContext context, bool isPlayerPageVisible, _) {
            if (!playerState.hasItem || isPlayerPageVisible) {
              return const SizedBox.shrink();
            }

            return Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedSlide(
                duration: _animationDuration,
                curve: _animationCurve,
                offset: usesCollapsedBottomChrome
                    ? const Offset(0, 0.12)
                    : Offset.zero,
                child: useGlassBar
                    ? MiniPlayerGlassBar(
                        state: playerState,
                        bottomPadding: usesCollapsedBottomChrome
                            ? miniPlayerCollapsedBottomPadding
                            : miniPlayerVisibleBottomPadding,
                        onTap: () => openPlayerPage(context),
                        onTogglePlayback: () {
                          ref
                              .read(playerControllerProvider.notifier)
                              .togglePlayback();
                        },
                      )
                    : MiniPlayerBar(
                        state: playerState,
                        bottomPadding: usesCollapsedBottomChrome
                            ? miniPlayerCollapsedBottomPadding
                            : miniPlayerVisibleBottomPadding,
                        onTap: () => openPlayerPage(context),
                        onTogglePlayback: () {
                          ref
                              .read(playerControllerProvider.notifier)
                              .togglePlayback();
                        },
                      ),
              ),
            );
          },
        ),
      ],
    );
  }

  bool _usesCollapsedBottomChrome(String location) {
    return location == '/profile/favorites' ||
        location.startsWith('/profile/favorites/') ||
        location == '/search';
  }
}
