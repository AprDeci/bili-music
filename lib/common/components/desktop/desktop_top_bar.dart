import 'dart:async';

import 'package:bilimusic/common/components/bar_icon_button.dart';
import 'package:bilimusic/feature/search/domain/search_state.dart';
import 'package:bilimusic/feature/search/logic/search_controller.dart';
import 'package:bilimusic/feature/search/ui/components/highlight_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

class DesktopTopBar extends ConsumerStatefulWidget {
  const DesktopTopBar({super.key});

  @override
  ConsumerState<DesktopTopBar> createState() => _DesktopTopBarState();
}

class _DesktopTopBarState extends ConsumerState<DesktopTopBar>
    with WindowListener {
  final LayerLink _searchLayerLink = LayerLink();
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  bool _isMaximized = false;
  bool _isDropdownOpen = false;
  Timer? _closeDropdownTimer;
  OverlayEntry? _dropdownEntry;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode()..addListener(_handleFocusChanged);
    _syncWindowState();
  }

  @override
  void dispose() {
    _closeDropdownTimer?.cancel();
    _removeDropdown();
    _searchFocusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _searchController.dispose();
    windowManager.removeListener(this);
    super.dispose();
  }

  void _handleFocusChanged() {
    if (_searchFocusNode.hasFocus) {
      _closeDropdownTimer?.cancel();
      _showDropdown();
      return;
    }

    _scheduleDropdownClose();
  }

  void _scheduleDropdownClose() {
    _closeDropdownTimer?.cancel();
    _closeDropdownTimer = Timer(const Duration(milliseconds: 160), () {
      if (mounted && !_searchFocusNode.hasFocus) {
        _removeDropdown();
      }
    });
  }

  void _showDropdown() {
    _closeDropdownTimer?.cancel();
    if (_isDropdownOpen) {
      _dropdownEntry?.markNeedsBuild();
      return;
    }

    final OverlayState? overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      return;
    }

    _dropdownEntry = OverlayEntry(
      builder: (BuildContext context) {
        return _DesktopSearchDropdownEntry(
          layerLink: _searchLayerLink,
          onRequestClose: _removeDropdown,
          onTapInside: () => _closeDropdownTimer?.cancel(),
          onTapOutside: () {
            FocusScope.of(this.context).unfocus();
            _removeDropdown();
          },
          onSubmitKeyword: _submitSearch,
        );
      },
    );
    overlay.insert(_dropdownEntry!);
    _isDropdownOpen = true;
  }

  void _removeDropdown() {
    _dropdownEntry?.remove();
    _dropdownEntry = null;
    _isDropdownOpen = false;
  }

  Future<void> _submitSearch([String? value]) async {
    final SearchPageController controller = ref.read(
      searchPageControllerProvider.notifier,
    );
    await controller.submitSearch(value);
    if (!mounted) {
      return;
    }

    _searchFocusNode.unfocus();
    _removeDropdown();
    if (GoRouterState.of(context).uri.path != '/search') {
      context.go('/search');
    }
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
    final SearchState state = ref.watch(searchPageControllerProvider);

    if (_searchController.text != state.query) {
      _searchController.value = TextEditingValue(
        text: state.query,
        selection: TextSelection.collapsed(offset: state.query.length),
      );
    }

    if (_isDropdownOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dropdownEntry?.markNeedsBuild();
      });
    }

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
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: CompositedTransformTarget(
                        link: _searchLayerLink,
                        child: _DesktopSearchField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          textStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          onChanged: (String value) {
                            ref
                                .read(searchPageControllerProvider.notifier)
                                .updateQuery(value);
                            _showDropdown();
                          },
                          onSubmitted: (_) => _submitSearch(),
                          onTap: _showDropdown,
                          onClear: () {
                            _searchController.clear();
                            ref
                                .read(searchPageControllerProvider.notifier)
                                .clearQuery();
                            _showDropdown();
                          },
                        ),
                      ),
                    ),
                    const Expanded(flex: 3, child: SizedBox.shrink()),
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

class _DesktopSearchField extends StatelessWidget {
  const _DesktopSearchField({
    required this.controller,
    required this.focusNode,
    required this.textStyle,
    required this.onChanged,
    required this.onSubmitted,
    required this.onTap,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final TextStyle? textStyle;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return SizedBox(
      height: 38,
      child: CupertinoSearchTextField(
        controller: controller,
        focusNode: focusNode,
        style: textStyle,
        onTap: onTap,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onSuffixTap: onClear,
        placeholder: '搜索音乐',
        placeholderStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        backgroundColor: Colors.grey.withValues(alpha: 0.2),
        itemColor: colorScheme.onSurface,
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 10, 8),
      ),
    );
  }
}

class _DesktopSearchDropdownEntry extends ConsumerWidget {
  const _DesktopSearchDropdownEntry({
    required this.layerLink,
    required this.onRequestClose,
    required this.onTapInside,
    required this.onTapOutside,
    required this.onSubmitKeyword,
  });

  final LayerLink layerLink;
  final VoidCallback onRequestClose;
  final VoidCallback onTapInside;
  final VoidCallback onTapOutside;
  final Future<void> Function([String? value]) onSubmitKeyword;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SearchState state = ref.watch(searchPageControllerProvider);
    final String query = state.query.trim();
    final bool showSuggestions = query.isNotEmpty;

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onTapOutside,
          ),
        ),
        CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 8),
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => onTapInside(),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: _DesktopSearchDropdownCard(
                  state: state,
                  showSuggestions: showSuggestions,
                  onSelectKeyword: (String value) async {
                    onTapInside();
                    await onSubmitKeyword(value);
                  },
                  onClearHistory: () {
                    ref
                        .read(searchPageControllerProvider.notifier)
                        .clearHistory();
                    if (!showSuggestions && state.recentKeywords.isEmpty) {
                      onRequestClose();
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DesktopSearchDropdownCard extends StatelessWidget {
  const _DesktopSearchDropdownCard({
    required this.state,
    required this.showSuggestions,
    required this.onSelectKeyword,
    required this.onClearHistory,
  });

  final SearchState state;
  final bool showSuggestions;
  final ValueChanged<String> onSelectKeyword;
  final VoidCallback onClearHistory;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 360),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (showSuggestions)
                Expanded(
                  child: _DesktopSuggestionPane(
                    query: state.query.trim(),
                    suggestions: state.suggestions,
                    isLoadingSuggestions: state.isLoadingSuggestions,
                    onSelectKeyword: onSelectKeyword,
                  ),
                ),
              if (showSuggestions)
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: _DesktopHistoryPane(
                  recentKeywords: state.recentKeywords,
                  onSelectKeyword: onSelectKeyword,
                  onClearHistory: onClearHistory,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopSuggestionPane extends StatelessWidget {
  const _DesktopSuggestionPane({
    required this.query,
    required this.suggestions,
    required this.isLoadingSuggestions,
    required this.onSelectKeyword,
  });

  final String query;
  final List<String> suggestions;
  final bool isLoadingSuggestions;
  final ValueChanged<String> onSelectKeyword;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextStyle baseTextStyle =
        theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 14);
    final Color hoverColor = colorScheme.primary.withValues(alpha: 0.08);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 36,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '搜索建议',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: isLoadingSuggestions && suggestions.isEmpty
                ? Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: colorScheme.primary,
                      ),
                    ),
                  )
                : suggestions.isEmpty
                ? Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '继续输入以获取联想词',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: suggestions.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String suggestion = suggestions[index];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => onSelectKeyword(suggestion),
                          mouseCursor: SystemMouseCursors.click,
                          hoverColor: hoverColor,
                          // borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: HighlightText(
                                    text: suggestion,
                                    highlight: query,
                                    normalStyle: baseTextStyle.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    highlightStyle: baseTextStyle.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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

class _DesktopHistoryPane extends StatelessWidget {
  const _DesktopHistoryPane({
    required this.recentKeywords,
    required this.onSelectKeyword,
    required this.onClearHistory,
  });

  final List<String> recentKeywords;
  final ValueChanged<String> onSelectKeyword;
  final VoidCallback onClearHistory;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color hoverColor = colorScheme.primary.withValues(alpha: 0.08);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 36,
            child: Row(
              children: <Widget>[
                Text(
                  '搜索历史',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (recentKeywords.isNotEmpty)
                  TextButton(
                    onPressed: onClearHistory,
                    child: const Text('清空'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: recentKeywords.isEmpty
                ? Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '暂无搜索历史',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: recentKeywords.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String item = recentKeywords[index];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => onSelectKeyword(item),
                          mouseCursor: SystemMouseCursors.click,
                          hoverColor: hoverColor,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                            child: Row(
                              children: <Widget>[
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
