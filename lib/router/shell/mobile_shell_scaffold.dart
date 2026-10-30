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

  static const double _bottomBarCornerRadius = 40;
  static const double _bottomBarHeight = 52;

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
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: playerPageVisibilityListenable,
      builder: (BuildContext context, bool isPlayerPageVisible, _) {
        return _buildScaffold(context, isPlayerPageVisible);
      },
    );
  }

  Widget _buildScaffold(BuildContext context, bool isPlayerPageVisible) {
    final PlayerState playerState = ref.watch(playerControllerProvider);
    final bool useGlassBar = ref.watch(appearanceSettingLogicProvider);
    final bool showTabs = widget.chrome.showBottomTabs && !isPlayerPageVisible;
    final bool showMiniPlayer =
        widget.chrome.showMiniPlayer &&
        playerState.hasItem &&
        !isPlayerPageVisible;

    return GlassPage(
      child: Scaffold(
        extendBody: true,
        body: widget.navigationShell,
        bottomNavigationBar: _animateChrome(
          visible: showTabs || showMiniPlayer,
          child: () => SafeArea(
            top: false,
            minimum: EdgeInsets.only(bottom: showTabs ? 10 : 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (showMiniPlayer)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: useGlassBar
                        ? MiniPlayerGlassBar(
                            state: playerState,
                            onTap: _openMiniPlayer,
                            onTogglePlayback: _togglePlayback,
                          )
                        : MiniPlayerBar(
                            state: playerState,
                            onTap: _openMiniPlayer,
                            onTogglePlayback: _togglePlayback,
                          ),
                  ),
                _animateChrome(
                  visible: showTabs,
                  child: () => Padding(
                    padding: EdgeInsets.only(top: showMiniPlayer ? 10 : 0),
                    child: FractionallySizedBox(
                      widthFactor: 0.80,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 64),
                        child: useGlassBar
                            ? _buildGlassTabBar(context)
                            : _buildFallbackTabBar(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _animateChrome({
    required bool visible,
    required Widget Function() child,
  }) {
    return AnimatedSwitcher(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 220),
      switchInCurve: _animationCurve,
      switchOutCurve: _animationCurve,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SizeTransition(
          sizeFactor: animation,
          alignment: Alignment.bottomCenter,
          child: FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
        );
      },
      child: visible ? child() : const SizedBox.shrink(),
    );
  }

  Widget _buildGlassTabBar(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return GlassTabBar.bottom(
      settings: LiquidGlassSettings(
        thickness: 14,
        refractiveIndex: 1.15,
        lightIntensity: 0.35,
        fresnelStrength: 0.4,
        chromaticAberration: 0.05,
        blur: 3,
        saturation: 0.7,
        ambientStrength: 1,
        glassColor:
            GlassThemeData.of(context).settingsFor(context)?.glassColor ??
            const LiquidGlassSettings().glassColor,
      ),
      spacing: 4,
      verticalPadding: 0,
      barHeight: _bottomBarHeight,
      horizontalPadding: 0,
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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(_bottomBarCornerRadius),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.08)),
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

  void _togglePlayback() {
    ref.read(playerControllerProvider.notifier).togglePlayback();
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
