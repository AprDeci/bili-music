import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/core/devtools/route_dev_page.dart';
import 'package:bilimusic/router/routers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DevOverlay extends ConsumerWidget {
  const DevOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      right: 16,
      bottom: 112,
      child: SafeArea(
        child: FloatingActionButton.small(
          heroTag: 'dev_overlay_fab',
          onPressed: () => _showDevPanel(context, ref),
          child: const Icon(Icons.developer_mode_rounded),
        ),
      ),
    );
  }

  Future<void> _showDevPanel(BuildContext context, WidgetRef ref) {
    final BuildContext? navigatorContext = rootNavigatorKey.currentContext;
    if (navigatorContext == null) {
      return Future<void>.value();
    }

    return showModalBottomSheet<void>(
      context: navigatorContext,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return const _DevOverlayPanel();
      },
    );
  }
}

class _DevOverlayPanel extends ConsumerStatefulWidget {
  const _DevOverlayPanel();

  @override
  ConsumerState<_DevOverlayPanel> createState() => _DevOverlayPanelState();
}

class _DevOverlayPanelState extends ConsumerState<_DevOverlayPanel> {
  late final PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BiliSession? session = ref.watch(biliSessionControllerProvider);
    final double maxHeight = MediaQuery.of(context).size.height * 0.82;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                _StatusChip(session: session),
                const SizedBox(width: 12),
                _PanelTabSwitcher(
                  currentPageIndex: _currentPageIndex,
                  onSelected: (int index) {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                    );
                  },
                ),
                const Spacer(),
                IconButton(
                  tooltip: _currentPageIndex == 0 ? '复制摘要' : '复制路由',
                  onPressed: () => _copySummary(context, session),
                  icon: const Icon(Icons.content_copy_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int index) {
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
                children: <Widget>[
                  _SessionDevPage(session: session),
                  const RouteDevPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copySummary(BuildContext context, BiliSession? session) async {
    if (_currentPageIndex != 0) {
      final RouteDebugSnapshot snapshot = RouteDebugSnapshot.fromRouter(
        ref.read(routerProvider),
      );
      final String routeSummary = snapshot.toSummary();

      await Clipboard.setData(ClipboardData(text: routeSummary));
      if (!context.mounted) {
        return;
      }

      ToastUtil.show('已复制路由摘要');
      return;
    }

    final String summary = session == null
        ? 'session: null'
        : <String>[
            'mid=${session.mid ?? ''}',
            'uname=${session.uname ?? ''}',
            'hasCookie=${session.hasCookie}',
            'isLoggedIn=${session.isLoggedIn}',
            'hasProfile=${session.hasProfile}',
            'hasWbiKeys=${session.hasWbiKeys}',
            'isReady=${session.isReady}',
            'dedeUserId=${session.dedeUserId}',
            'buvid3=${session.buvid3 ?? ''}',
          ].join('\n');

    await Clipboard.setData(ClipboardData(text: summary));
    if (!context.mounted) {
      return;
    }

    ToastUtil.show('已复制 session 摘要');
  }
}

class _PanelTabSwitcher extends StatelessWidget {
  const _PanelTabSwitcher({
    required this.currentPageIndex,
    required this.onSelected,
  });

  final int currentPageIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      segments: const <ButtonSegment<int>>[
        ButtonSegment<int>(value: 0, label: Text('Session')),
        ButtonSegment<int>(value: 1, label: Text('Route')),
      ],
      selected: <int>{currentPageIndex},
      onSelectionChanged: (Set<int> selection) {
        onSelected(selection.first);
      },
      showSelectedIcon: false,
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _SessionDevPage extends StatelessWidget {
  const _SessionDevPage({required this.session});

  final BiliSession? session;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        _SectionTitle(title: 'Session 状态'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _BoolChip(label: 'hasCookie', value: session?.hasCookie ?? false),
            _BoolChip(label: 'isLoggedIn', value: session?.isLoggedIn ?? false),
            _BoolChip(label: 'hasProfile', value: session?.hasProfile ?? false),
            _BoolChip(label: 'hasWbiKeys', value: session?.hasWbiKeys ?? false),
            _BoolChip(label: 'isReady', value: session?.isReady ?? false),
          ],
        ),
        const SizedBox(height: 20),
        _SectionTitle(title: 'Session 字段'),
        if (session == null)
          const _EmptyState()
        else ...<Widget>[
          _FieldTile(label: 'mid', value: session?.mid?.toString() ?? ''),
          _FieldTile(label: 'uname', value: session?.uname ?? ''),
          _FieldTile(label: 'face', value: session?.face ?? ''),
          _FieldTile(label: 'dedeUserId', value: session?.dedeUserId ?? ''),
          _FieldTile(
            label: 'sessData',
            value: session?.sessData ?? '',
            masked: true,
          ),
          _FieldTile(
            label: 'biliJct',
            value: session?.biliJct ?? '',
            masked: true,
          ),
          _FieldTile(
            label: 'refreshToken',
            value: session?.refreshToken ?? '',
            masked: true,
          ),
          _FieldTile(label: 'buvid3', value: session?.buvid3 ?? ''),
          _FieldTile(label: 'imgKey', value: session?.imgKey ?? ''),
          _FieldTile(label: 'subKey', value: session?.subKey ?? ''),
          _FieldTile(
            label: 'cookie',
            value: session?.cookie ?? '',
            masked: true,
            multiline: true,
          ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.session});

  final BiliSession? session;

  @override
  Widget build(BuildContext context) {
    final bool ready = session?.isReady ?? false;
    final bool loggedIn = session?.isLoggedIn ?? false;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String label = ready
        ? 'ready'
        : loggedIn
        ? 'partial'
        : 'anonymous';
    final Color background = ready
        ? colorScheme.primaryContainer
        : loggedIn
        ? colorScheme.secondaryContainer
        : colorScheme.surfaceContainerHighest;
    final Color foreground = ready
        ? colorScheme.onPrimaryContainer
        : loggedIn
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _BoolChip extends StatelessWidget {
  const _BoolChip({required this.label, required this.value});

  final String label;
  final bool value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: value
            ? colorScheme.primary.withValues(alpha: 0.12)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Text(
          '$label: ${value ? 'true' : 'false'}',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: value ? colorScheme.primary : colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _FieldTile extends StatefulWidget {
  const _FieldTile({
    required this.label,
    required this.value,
    this.masked = false,
    this.multiline = false,
  });

  final String label;
  final String value;
  final bool masked;
  final bool multiline;

  @override
  State<_FieldTile> createState() => _FieldTileState();
}

class _FieldTileState extends State<_FieldTile> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String displayValue = widget.masked && !_revealed
        ? _maskValue(widget.value)
        : widget.value.ifEmpty('-');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (widget.masked && widget.value.isNotEmpty)
                IconButton(
                  tooltip: _revealed ? '隐藏' : '显示',
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    setState(() {
                      _revealed = !_revealed;
                    });
                  },
                  icon: Icon(
                    _revealed
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              IconButton(
                tooltip: '复制',
                visualDensity: VisualDensity.compact,
                onPressed: widget.value.isEmpty
                    ? null
                    : () async {
                        await Clipboard.setData(
                          ClipboardData(text: widget.value),
                        );
                        if (!context.mounted) {
                          return;
                        }
                        ToastUtil.show('已复制 ${widget.label}');
                      },
                icon: const Icon(Icons.copy_all_rounded),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SelectableText(
            displayValue,
            minLines: 1,
            maxLines: widget.multiline ? null : 2,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.35,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  String _maskValue(String value) {
    if (value.isEmpty) {
      return '-';
    }
    if (value.length <= 10) {
      return '${value.substring(0, 2)}***${value.substring(value.length - 2)}';
    }

    return '${value.substring(0, 6)}***${value.substring(value.length - 4)}';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text('当前没有可用 session。'),
    );
  }
}

extension on String {
  String ifEmpty(String fallback) {
    return isEmpty ? fallback : this;
  }
}
