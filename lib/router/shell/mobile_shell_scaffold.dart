import 'package:bilimusic/common/bottom_height_helper.dart';
import 'package:bilimusic/common/util/color_util.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/mini/mini_player_bar.dart';
import 'package:bilimusic/feature/player/ui/mini/mini_player_glass_bar.dart';
import 'package:bilimusic/feature/setting/logic/appearance_setting_logic.dart';
import 'package:bilimusic/feature/updater/logic/update_checker.dart';
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
  static const Duration _autoUpdateCheckDelay = Duration(milliseconds: 600);

  // 底部浮动导航栏的尺寸，玻璃与非玻璃两套共用，切换时高度一致不抖动。
  static const double _bottomBarWidthFactor = 0.92;
  static const double _bottomBarCornerRadius = 40;
  static const double _bottomBarHorizontalPadding = 64;
  static const double _bottomBarHeight = BottomHeightHelper.bottomBarHeight;
  static const double _glassBarVerticalPadding = 4;
  // 玻璃栏给内部留出上下各 4 的 padding，故栏体高度取 52，
  // 52 + 4 + 4 == 60，与非玻璃栏 / BottomHeightHelper 的高度一致。
  static const double _glassBarHeight =
      _bottomBarHeight - _glassBarVerticalPadding * 2;

  bool _didScheduleUpdateCheck = false;

  @override
  void initState() {
    super.initState();
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

      await UpdateChecker.checkAndPrompt(context);
    });
  }

  @override
  void didUpdateWidget(covariant MobileShellScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
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

    return GlassScaffold(
      body: BottomBar(
        layout: BottomBarLayout(
          width: screenWidth * _bottomBarWidthFactor,
          offset: bottomBarOffset,
          borderRadius: BorderRadius.circular(_bottomBarCornerRadius),
          fit: StackFit.expand,
          respectSafeArea: false,
        ),
        scrollBehavior: const BottomBarScrollBehavior(hideOnScroll: false),
        theme: const BottomBarThemeData(
          barDecoration: BoxDecoration(color: Colors.transparent),
        ),
        body: content,
        child: useGlassBar
            ? _buildGlassTabBar(context)
            : _buildFallbackTabBar(context),
      ),
    );
  }

  Widget _buildGlassTabBar(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return GlassTabBar.bottom(
      spacing: 4,
      verticalPadding: _glassBarVerticalPadding,
      barHeight: _glassBarHeight,
      horizontalPadding: _bottomBarHorizontalPadding,
      unselectedIconColor: theme.textTheme.bodyMedium?.color ?? Colors.black,
      selectedIconColor: colorScheme.primary,
      indicatorColor: ColorUtil.getLight(
        colorScheme.primary,
      ).withValues(alpha: 0.2),
      tabs: const <GlassTab>[
        GlassTab(
          icon: HugeIcon(icon: HugeIcons.strokeRoundedHome07, size: 20),
          label: '首页',
        ),
        GlassTab(
          icon: HugeIcon(icon: HugeIcons.strokeRoundedUser, size: 20),
          label: '我的',
        ),
      ],
      selectedIndex: widget.navigationShell.currentIndex,
      onTabSelected: _selectBranch,
    );
  }

  Widget _buildFallbackTabBar(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _bottomBarHorizontalPadding,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(_bottomBarCornerRadius),
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
          borderRadius: BorderRadius.circular(_bottomBarCornerRadius),
          child: SizedBox(
            height: _bottomBarHeight,
            child: Row(
              children: <Widget>[
                _BottomNavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  selected: widget.navigationShell.currentIndex == 0,
                  selectedColor: colorScheme.primary,
                  indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
                  onTap: () => _selectBranch(0),
                ),
                _BottomNavItem(
                  icon: Icons.person_outlined,
                  selectedIcon: Icons.person,
                  selected: widget.navigationShell.currentIndex == 1,
                  selectedColor: colorScheme.primary,
                  indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
                  onTap: () => _selectBranch(1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectBranch(int index) {
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
