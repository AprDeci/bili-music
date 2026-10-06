import 'package:bilimusic/common/components/desktop/desktop_top_bar.dart';
import 'package:bilimusic/common/components/desktop/desktop_side_panel.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/feature/profile/ui/desktop_profile_sidebar.dart';
import 'package:bilimusic/feature/player/ui/desktop_player_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

class DesktopShellScaffold extends ConsumerWidget {
  const DesktopShellScaffold({
    super.key,
    required this.navigationShell,
    required this.currentLocation,
  });

  static const double _macOSTitleBarHeight = 24;

  final StatefulNavigationShell navigationShell;
  final String currentLocation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (PlatformUtil.isMacOS)
                const _MacOSTitleBarDragArea(height: _macOSTitleBarHeight),
              Expanded(
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
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  const DesktopTopBar(),
                                  Expanded(
                                    child: Container(child: navigationShell),
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
            ],
          ),
        ),
      ),
    );
  }
}

// macOS 顶部交通灯按钮的留白区域，同时支持拖动窗口。
class _MacOSTitleBarDragArea extends StatelessWidget {
  const _MacOSTitleBarDragArea({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (_) => windowManager.startDragging(),
      child: SizedBox(height: height, width: double.infinity),
    );
  }
}
