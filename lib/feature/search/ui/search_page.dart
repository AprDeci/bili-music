import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/screen_util.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';
import 'package:bilimusic/feature/search/domain/search_state.dart';
import 'package:bilimusic/feature/search/domain/search_type.dart';
import 'package:bilimusic/feature/search/domain/search_user_item.dart';
import 'package:bilimusic/feature/search/logic/search_controller.dart';
import 'package:bilimusic/feature/search/ui/components/search_input_area.dart';
import 'package:bilimusic/feature/search/ui/components/search_results_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final TabController _tabController;
  int _lastTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _tabController = TabController(
      length: SearchType.values.length,
      vsync: this,
    )..addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _tabController
      ..removeListener(_handleTabChange)
      ..dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging ||
        _tabController.index == _lastTabIndex) {
      return;
    }
    _lastTabIndex = _tabController.index;
    ref
        .read(searchPageControllerProvider.notifier)
        .changeType(SearchType.values[_tabController.index]);
  }

  Future<void> _submitSearch(
    SearchPageController controller, [
    String? value,
  ]) async {
    FocusManager.instance.primaryFocus?.unfocus();

    await controller.submitSearch(value);
  }

  @override
  Widget build(BuildContext context) {
    final GoRouterState routerState = GoRouterState.of(context);
    final String from = routerState.uri.queryParameters['from'] ?? '/home';
    final SearchState state = ref.watch(searchPageControllerProvider);
    final SearchPageController controller = ref.read(
      searchPageControllerProvider.notifier,
    );
    final bool isDesktop = ScreenUtil.shouldUseDesktopShell(context);
    final String trimmedQuery = state.query.trim();
    final String trimmedSubmittedQuery = state.submittedQuery?.trim() ?? '';
    final bool isShowingSuggestions =
        !isDesktop &&
        trimmedQuery.isNotEmpty &&
        trimmedQuery != trimmedSubmittedQuery;

    _syncSearchText(state.query);
    _syncTabIndex(state.type);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            if (!isDesktop)
              SearchInputBar(
                controller: _controller,
                focusNode: _focusNode,
                query: state.query,
                onBack: () => context.go(from),
                onChanged: controller.updateQuery,
                onSubmitted: () => _submitSearch(controller),
                onClear: () {
                  _controller.clear();
                  controller.clearQuery();
                },
              ),
            Expanded(
              child: state.submittedQuery?.isNotEmpty == true
                  ? SearchResultsView(
                      state: state,
                      tabController: _tabController,
                      onLoadMore: controller.loadNextPage,
                      onChangeSort: controller.changeSort,
                      onPlayItem: (SearchResultItem item) async {
                        await PlayerUtil.playItemAndOpenPlayer(
                          context,
                          ref,
                          item: item.toPlayableItem(),
                          sourceLabel: '搜索结果',
                        );
                      },
                      onPlayNext: (SearchResultItem item) async {
                        await PlayerUtil.playItemNextWithMultiPart(
                          context,
                          ref,
                          item: item.toPlayableItem(),
                        );
                      },
                      onEnqueue: (SearchResultItem item) async {
                        await PlayerUtil.enqueueItemWithMultiPart(
                          context,
                          ref,
                          item: item.toPlayableItem(),
                        );
                      },
                      onTapUser: (SearchUserItem item) {
                        context.push('/up/${item.mid}');
                      },
                    )
                  : SearchIdleView(
                      isDesktop: isDesktop,
                      isShowingSuggestions: isShowingSuggestions,
                      query: trimmedQuery,
                      recentKeywords: state.recentKeywords,
                      suggestions: state.suggestions,
                      isLoadingSuggestions: state.isLoadingSuggestions,
                      onClearHistory: controller.clearHistory,
                      onSelectKeyword: (String value) {
                        _submitSearch(controller, value);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _syncSearchText(String query) {
    if (_controller.text == query) {
      return;
    }
    _controller.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
  }

  void _syncTabIndex(SearchType type) {
    final int stateTabIndex = SearchType.values.indexOf(type);
    if (_tabController.index == stateTabIndex ||
        _tabController.indexIsChanging) {
      return;
    }
    _lastTabIndex = stateTabIndex;
    _tabController.index = stateTabIndex;
  }
}
