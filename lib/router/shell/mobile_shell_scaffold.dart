import 'package:bilimusic/common/bottom_height_helper.dart';
import 'package:bilimusic/common/util/color_util.dart';
import 'package:bilimusic/common/util/update_util.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/mini_player_bar.dart';
import 'package:bilimusic/feature/player/ui/mini_player_glass_bar.dart';
import 'package:bilimusic/feature/setting/logic/appearance_setting_logic.dart';
import 'package:bilimusic/router/util/mobile_branch_navigator_keys.dart';
import 'package:bilimusic/router/util/mobile_chrome_config.dart';
import 'package:bilimusic/router/util/player_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class MobileShellScaffold extends ConsumerStatefulWidget {
  const MobileShellScaffold({
    super.key,
    required this.navigationShell,
    required this.currentLocation,
    required this.chrome,
  });

  final StatefulNavigationShell navigationShell;
  final String currentLocation;
  final MobileChromeConfig chrome;

  @override
  ConsumerState<MobileShellScaffold> createState() =>
      _MobileShellScaffoldState();
}

class _MobileShellScaffoldState extends ConsumerState<MobileShellScaffold> {
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
  void didUpdateWidget(covariant MobileShellScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentIndex = widget.navigationShell.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: playerPageVisibilityListenable,
      builder: (BuildContext context, bool isPlayerPageVisible, _) {
        return _buildScaffold(context, isPlayerPageVisible);
      },
    );
  }

  Widget _buildScaffold(BuildContext context, bool isPlayerPageVisible) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final PlayerState playerState = ref.watch(playerControllerProvider);
    final bool useGlassBar = ref.watch(appearanceSettingLogicProvider);
    final double bottomBarOffset = BottomHeightHelper.bottomBarOffset(
      bottomInset: bottomInset,
    );
    final bool usesCollapsedBottomChrome =
        isPlayerPageVisible || !widget.chrome.showBottomTabs;
    final double miniPlayerVisibleBottomPadding =
        BottomHeightHelper.miniPlayerBottomPaddingWithBottomBar(
          bottomInset: bottomInset,
          bottomBarOffset: bottomBarOffset,
        );
    final double miniPlayerCollapsedBottomPadding =
        BottomHeightHelper.miniPlayerBottomPaddingWithoutBottomBar(
          bottomInset: bottomInset,
        );

    final Widget content = _buildShellContent(
      context,
      playerState,
      isPlayerPageVisible,
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
        layout: BottomBarLayout(
          width: screenWidth * 0.92,
          offset: bottomBarOffset,
          borderRadius: BorderRadius.circular(40),
          fit: StackFit.expand,
          respectSafeArea: false,
        ),
        // motion: const BottomBarMotion.curved(
        //   duration: _animationDuration,
        //   curve: _animationCurve,
        // ),
        scrollBehavior: const BottomBarScrollBehavior(hideOnScroll: false),
        theme: const BottomBarThemeData(
          barDecoration: BoxDecoration(color: Colors.transparent),
        ),
        body: content,
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
                      selectedIconColor: colorScheme.primary,
                      indicatorColor: ColorUtil.getLight(
                        colorScheme.primary,
                      ).withValues(alpha: 0.2),
                      tabs: const <GlassBottomBarTab>[
                        GlassBottomBarTab(
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedHome07,
                            size: 20,
                          ),
                          label: '首页',
                        ),
                        GlassBottomBarTab(
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedUser,
                            size: 20,
                          ),
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
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 64.0),
                      child: DecoratedBox(
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
                          child: SizedBox(
                            height: BottomHeightHelper.bottomBarHeight,
                            child: Row(
                              children: <Widget>[
                                _BottomNavItem(
                                  icon: Icons.home_outlined,
                                  selectedIcon: Icons.home,
                                  selected: _currentIndex == 0,
                                  selectedColor: colorScheme.primary,
                                  indicatorColor: colorScheme.primary
                                      .withValues(alpha: 0.12),
                                  onTap: () => _selectBranch(0),
                                ),
                                _BottomNavItem(
                                  icon: Icons.person_outlined,
                                  selectedIcon: Icons.person,
                                  selected: _currentIndex == 1,
                                  selectedColor: colorScheme.primary,
                                  indicatorColor: colorScheme.primary
                                      .withValues(alpha: 0.12),
                                  onTap: () => _selectBranch(1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectBranch(int index) {
    setState(() => _currentIndex = index);
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  Future<void> _openMiniPlayer() {
    final int currentIndex = widget.navigationShell.currentIndex;
    final NavigatorState? branchNavigator =
        currentIndex >= 0 && currentIndex < mobileBranchNavigatorKeys.length
        ? mobileBranchNavigatorKeys[currentIndex].currentState
        : null;

    return openPlayerPage(context, navigator: branchNavigator);
  }

  Widget _buildShellContent(
    BuildContext context,
    PlayerState playerState,
    bool isPlayerPageVisible,
    bool usesCollapsedBottomChrome,
    bool useGlassBar,
    double miniPlayerVisibleBottomPadding,
    double miniPlayerCollapsedBottomPadding,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        widget.navigationShell,
        if (widget.chrome.showMiniPlayer &&
            playerState.hasItem &&
            !isPlayerPageVisible)
          Align(
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
                      onTap: _openMiniPlayer,
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
                      onTap: _openMiniPlayer,
                      onTogglePlayback: () {
                        ref
                            .read(playerControllerProvider.notifier)
                            .togglePlayback();
                      },
                    ),
            ),
          ),
      ],
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.selectedColor,
    required this.indicatorColor,
    required this.onTap,
  });

  static const Color _unselectedColor = Color(0xFF7B8698);

  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final Color selectedColor;
  final Color indicatorColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Center(
          child: AnimatedContainer(
            duration: _MobileShellScaffoldState._animationDuration,
            curve: _MobileShellScaffoldState._animationCurve,
            width: 64,
            height: 32,
            decoration: BoxDecoration(
              color: selected ? indicatorColor : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              selected ? selectedIcon : icon,
              color: selected ? selectedColor : _unselectedColor,
            ),
          ),
        ),
      ),
    );
  }
}
