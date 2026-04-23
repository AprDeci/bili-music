import 'package:bilimusic/common/components/bar_icon_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class DesktopTopBar extends StatefulWidget {
  const DesktopTopBar({super.key});

  @override
  State<DesktopTopBar> createState() => _DesktopTopBarState();
}

class _DesktopTopBarState extends State<DesktopTopBar> with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _syncWindowState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _syncWindowState() async {
    final bool isMaximized = await windowManager.isMaximized();
    if (!mounted || isMaximized == _isMaximized) {
      return;
    }

    setState(() {
      _isMaximized = isMaximized;
    });
  }

  @override
  void onWindowMaximize() {
    _syncWindowState();
  }

  @override
  void onWindowUnmaximize() {
    _syncWindowState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      height: 56,
      child: DragToMoveArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: _toggleMaximize,
          child: Row(
            children: <Widget>[
              const SizedBox(width: 16),
              const _LeadingSlot(),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CupertinoSearchTextField(
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        placeholder: '搜索音乐',
                      ),
                    ),
                    Expanded(flex: 3, child: const SizedBox.shrink()),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Tooltip(
                waitDuration: const Duration(seconds: 1),
                message: '最小化',
                child: BarIconButton(
                  icon: Icons.remove_rounded,
                  iconSize: 18,
                  onPressed: () => windowManager.minimize(),
                ),
              ),
              Tooltip(
                waitDuration: const Duration(seconds: 1),
                message: _isMaximized ? '还原' : '最大化',
                child: BarIconButton(
                  icon: _isMaximized
                      ? Icons.filter_none_rounded
                      : Icons.crop_square_rounded,
                  iconSize: 16,
                  onPressed: _toggleMaximize,
                ),
              ),
              Tooltip(
                waitDuration: const Duration(seconds: 1),
                message: '关闭',
                child: BarIconButton(
                  icon: Icons.close_rounded,
                  iconSize: 18,
                  onPressed: () => windowManager.close(),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleMaximize() async {
    if (await windowManager.isMaximized()) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
    await _syncWindowState();
  }
}

class _LeadingSlot extends StatelessWidget {
  const _LeadingSlot();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color iconColor = theme.colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _GhostAction(icon: Icons.chevron_left_rounded, color: iconColor),
        const SizedBox(width: 4),
        _GhostAction(icon: Icons.chevron_right_rounded, color: iconColor),
      ],
    );
  }
}

class _GhostAction extends StatelessWidget {
  const _GhostAction({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Icon(icon, size: 18, color: color),
    );
  }
}
