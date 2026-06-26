import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

typedef SelectableAutoScrollItemBuilder<T, K> =
    Widget Function(
      BuildContext context,
      T item,
      SelectableListItemState<T, K> state,
    );

typedef SelectableAutoScrollChildBuilder<T, K> =
    Widget? Function(
      BuildContext context,
      T item,
      SelectableListItemState<T, K> state,
    );

class SelectableListItemState<T, K> {
  const SelectableListItemState({
    required this.item,
    required this.key,
    required this.index,
    required this.selected,
    required this.multiSelectEnabled,
    required this.toggleSelected,
    required this.handleTap,
    required this.enterMultiSelectAndToggle,
  });

  final T item;
  final K key;
  final int index;
  final bool selected;
  final bool multiSelectEnabled;
  final VoidCallback toggleSelected;
  final VoidCallback handleTap;
  final VoidCallback enterMultiSelectAndToggle;
}

class SelectableAutoScrollListView<T, K> extends StatefulWidget {
  const SelectableAutoScrollListView({
    super.key,
    required this.items,
    required this.itemKeyOf,
    required this.titleBuilder,
    required this.selectedKeys,
    required this.onSelectionChanged,
    this.itemBuilder,
    this.selectionItemBuilder,
    this.subtitleBuilder,
    this.leadingBuilder,
    this.trailingBuilder,
    this.checkboxControlAffinity = ListTileControlAffinity.leading,
    this.multiSelectEnabled,
    this.initialMultiSelectEnabled = false,
    this.onMultiSelectModeChanged,
    this.initialScrollKey,
    this.scrollToKey,
    this.onItemTap,
    this.footer,
    this.padding,
    this.separatorBuilder,
    this.estimatedItemExtent = 72,
    this.physics,
    this.shrinkWrap = false,
  });

  final List<T> items;
  final K Function(T item) itemKeyOf;
  final SelectableAutoScrollChildBuilder<T, K> titleBuilder;
  final SelectableAutoScrollItemBuilder<T, K>? itemBuilder;
  final SelectableAutoScrollItemBuilder<T, K>? selectionItemBuilder;
  final SelectableAutoScrollChildBuilder<T, K>? subtitleBuilder;
  final SelectableAutoScrollChildBuilder<T, K>? leadingBuilder;
  final SelectableAutoScrollChildBuilder<T, K>? trailingBuilder;
  final ListTileControlAffinity checkboxControlAffinity;
  final Set<K> selectedKeys;
  final ValueChanged<Set<K>> onSelectionChanged;
  final bool? multiSelectEnabled;
  final bool initialMultiSelectEnabled;
  final ValueChanged<bool>? onMultiSelectModeChanged;
  final K? initialScrollKey;
  final K? scrollToKey;
  final ValueChanged<T>? onItemTap;
  final Widget? footer;
  final EdgeInsetsGeometry? padding;
  final IndexedWidgetBuilder? separatorBuilder;
  final double estimatedItemExtent;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  @override
  State<SelectableAutoScrollListView<T, K>> createState() =>
      _SelectableAutoScrollListViewState<T, K>();
}

class _SelectableAutoScrollListViewState<T, K>
    extends State<SelectableAutoScrollListView<T, K>> {
  late final AutoScrollController _scrollController;
  late bool _internalMultiSelectEnabled;
  bool _didFocusInitialItem = false;

  bool get _multiSelectEnabled =>
      widget.multiSelectEnabled ?? _internalMultiSelectEnabled;

  @override
  void initState() {
    super.initState();
    _scrollController = AutoScrollController(
      suggestedRowHeight: widget.estimatedItemExtent,
    );
    _internalMultiSelectEnabled = widget.initialMultiSelectEnabled;
    _focusInitialItem();
  }

  @override
  void didUpdateWidget(covariant SelectableAutoScrollListView<T, K> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_didFocusInitialItem) {
      _focusInitialItem();
    }

    final K? scrollToKey = widget.scrollToKey;
    if (scrollToKey != null && scrollToKey != oldWidget.scrollToKey) {
      _scrollToKeyAfterFrame(scrollToKey);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.separatorBuilder == null) {
      return ListView.builder(
        controller: _scrollController,
        padding: widget.padding,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        itemCount: _itemCount,
        itemBuilder: _buildItem,
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: widget.padding,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      itemCount: _itemCount,
      itemBuilder: _buildItem,
      separatorBuilder: widget.separatorBuilder!,
    );
  }

  int get _itemCount => widget.items.length + (widget.footer == null ? 0 : 1);

  Widget _buildItem(BuildContext context, int index) {
    if (index == widget.items.length) {
      return widget.footer!;
    }

    final T item = widget.items[index];
    final K itemKey = widget.itemKeyOf(item);
    final bool selected = widget.selectedKeys.contains(itemKey);
    final SelectableListItemState<T, K> itemState =
        SelectableListItemState<T, K>(
          item: item,
          key: itemKey,
          index: index,
          selected: selected,
          multiSelectEnabled: _multiSelectEnabled,
          toggleSelected: () => _toggleSelected(itemKey),
          handleTap: () => _handleTap(item, itemKey),
          enterMultiSelectAndToggle: () => _enterMultiSelectAndToggle(itemKey),
        );

    return AutoScrollTag(
      key: ValueKey<K>(itemKey),
      controller: _scrollController,
      index: index,
      child: _buildItemContent(context, item, itemState),
    );
  }

  Widget _buildItemContent(
    BuildContext context,
    T item,
    SelectableListItemState<T, K> state,
  ) {
    if (state.multiSelectEnabled) {
      return widget.selectionItemBuilder?.call(context, item, state) ??
          _buildDefaultSelectionTile(context, item, state);
    }

    return widget.itemBuilder?.call(context, item, state) ??
        _buildDefaultListTile(context, item, state);
  }

  Widget _buildDefaultListTile(
    BuildContext context,
    T item,
    SelectableListItemState<T, K> state,
  ) {
    return ListTile(
      leading: widget.leadingBuilder?.call(context, item, state),
      title: widget.titleBuilder(context, item, state),
      subtitle: widget.subtitleBuilder?.call(context, item, state),
      trailing: widget.trailingBuilder?.call(context, item, state),
      selected: state.selected,
      onTap: state.handleTap,
      onLongPress: state.enterMultiSelectAndToggle,
    );
  }

  Widget _buildDefaultSelectionTile(
    BuildContext context,
    T item,
    SelectableListItemState<T, K> state,
  ) {
    return GestureDetector(
      onLongPress: state.enterMultiSelectAndToggle,
      child: CheckboxListTile(
        value: state.selected,
        controlAffinity: widget.checkboxControlAffinity,
        secondary: _buildSelectionSecondary(context, item, state),
        title: widget.titleBuilder(context, item, state),
        subtitle: widget.subtitleBuilder?.call(context, item, state),
        selected: state.selected,
        onChanged: (_) => state.toggleSelected(),
      ),
    );
  }

  Widget? _buildSelectionSecondary(
    BuildContext context,
    T item,
    SelectableListItemState<T, K> state,
  ) {
    if (widget.checkboxControlAffinity == ListTileControlAffinity.leading) {
      return widget.trailingBuilder?.call(context, item, state);
    }

    return widget.leadingBuilder?.call(context, item, state);
  }

  void _handleTap(T item, K itemKey) {
    if (_multiSelectEnabled) {
      _toggleSelected(itemKey);
      return;
    }

    widget.onItemTap?.call(item);
  }

  void _enterMultiSelectAndToggle(K itemKey) {
    if (!_multiSelectEnabled) {
      _setMultiSelectEnabled(true);
    }
    _toggleSelected(itemKey);
  }

  void _setMultiSelectEnabled(bool enabled) {
    if (widget.multiSelectEnabled == null) {
      setState(() => _internalMultiSelectEnabled = enabled);
    }
    widget.onMultiSelectModeChanged?.call(enabled);
  }

  void _toggleSelected(K itemKey) {
    final Set<K> nextSelectedKeys = <K>{...widget.selectedKeys};
    if (!nextSelectedKeys.add(itemKey)) {
      nextSelectedKeys.remove(itemKey);
    }
    widget.onSelectionChanged(nextSelectedKeys);
  }

  void _focusInitialItem() {
    final K? initialScrollKey = widget.initialScrollKey;
    if (_didFocusInitialItem || initialScrollKey == null) {
      return;
    }

    if (_indexOfKey(initialScrollKey) < 0) {
      return;
    }

    _didFocusInitialItem = true;
    _scrollToKeyAfterFrame(initialScrollKey);
  }

  void _scrollToKeyAfterFrame(K itemKey) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }

      final int index = _indexOfKey(itemKey);
      if (index < 0) {
        return;
      }

      await _scrollController.scrollToIndex(
        index,
        preferPosition: AutoScrollPosition.middle,
      );
    });
  }

  int _indexOfKey(K itemKey) {
    return widget.items.indexWhere(
      (T item) => widget.itemKeyOf(item) == itemKey,
    );
  }
}
