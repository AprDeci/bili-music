import 'package:bilimusic/common/components/cached_avatar.dart';
import 'package:bilimusic/feature/auth/logic/bili_auth_controller.dart';
import 'package:bilimusic/common/components/underline_tab_switcher.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/common/components/car/car_cover_glow.dart';
import 'package:bilimusic/feature/player/ui/car/car_player_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final Widget content = Column(
                  children: <Widget>[
                    _CarNavigation(
                      currentLocation: currentLocation,
                      onSelect: (int index) => navigationShell.goBranch(
                        index,
                        initialLocation: true,
                      ),
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
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(
                        width: (constraints.maxWidth * 0.29).clamp(240, 400),
                        child: const CarPlayerPanel(),
                      ),
                      const SizedBox(width: 20),
                      Expanded(child: content),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CarNavigation extends ConsumerWidget {
  const _CarNavigation({required this.currentLocation, required this.onSelect});

  final String currentLocation;
  final ValueChanged<int> onSelect;

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确认退出当前 B 站账号吗？'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('退出'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(biliAuthControllerProvider.notifier).logout();
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('退出登录失败，请重试')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(biliSessionControllerProvider);
    final bool isLoggedIn = session?.isLoggedIn ?? false;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        spacing: 8,
        children: <Widget>[
          Expanded(
            child: Row(
              spacing: 8,
              children: <Widget>[
                Flexible(
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
                  constraints: const BoxConstraints(
                    minWidth: 56,
                    minHeight: 56,
                  ),
                  onPressed: () => context.go('/search'),
                  icon: const Icon(Icons.search_rounded),
                ),
              ],
            ),
          ),
          if (isLoggedIn)
            IconButton(
              tooltip: '退出登录',
              constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
              onPressed: () => _confirmLogout(context, ref),
              icon: CommonCachedAvatar(imageUrl: session?.face, size: 40),
            )
          else
            TextButton(
              style: TextButton.styleFrom(minimumSize: const Size(56, 56)),
              onPressed: () => context.push('/auth'),
              child: const Text('登录'),
            ),
          IconButton(
            tooltip: '设置',
            color: colors.onSurfaceVariant,
            constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
            onPressed: () {
              if (currentLocation != '/settings' &&
                  !currentLocation.startsWith('/settings/')) {
                context.push('/settings');
              }
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
    );
  }
}
