import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/util/color_util.dart';
import 'package:bilimusic/feature/search/ui/components/highlight_text.dart';
import 'package:flutter/material.dart';

class SearchInputBar extends StatelessWidget {
  const SearchInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.query,
    required this.onBack,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String query;
  final VoidCallback onBack;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: colorScheme.outlineVariant),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.search,
                onChanged: onChanged,
                onSubmitted: (_) => onSubmitted(),
                decoration: InputDecoration(
                  hintText: '搜索歌曲、歌手或视频',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: onClear,
                          icon: const Icon(Icons.close_rounded),
                        ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchIdleView extends StatelessWidget {
  const SearchIdleView({
    super.key,
    required this.isDesktop,
    required this.isShowingSuggestions,
    required this.query,
    required this.recentKeywords,
    required this.suggestions,
    required this.isLoadingSuggestions,
    required this.onClearHistory,
    required this.onSelectKeyword,
  });

  final bool isDesktop;
  final bool isShowingSuggestions;
  final String query;
  final List<String> recentKeywords;
  final List<String> suggestions;
  final bool isLoadingSuggestions;
  final VoidCallback onClearHistory;
  final ValueChanged<String> onSelectKeyword;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CustomScrollView(
          slivers: <Widget>[
            if (!isDesktop &&
                !isShowingSuggestions &&
                recentKeywords.isNotEmpty)
              SearchHistorySliver(
                isDesktop: isDesktop,
                recentKeywords: recentKeywords,
                onClearHistory: onClearHistory,
                onSelectKeyword: onSelectKeyword,
              ),
            const SliverToBoxAdapter(child: BottomPageSpacer.overlay()),
          ],
        ),
        if (isShowingSuggestions)
          Positioned.fill(
            child: SearchSuggestionOverlay(
              query: query,
              suggestions: suggestions,
              isLoadingSuggestions: isLoadingSuggestions,
              onSelectSuggestion: onSelectKeyword,
            ),
          ),
      ],
    );
  }
}

class SearchHistorySliver extends StatelessWidget {
  const SearchHistorySliver({
    super.key,
    required this.isDesktop,
    required this.recentKeywords,
    required this.onClearHistory,
    required this.onSelectKeyword,
  });

  final bool isDesktop;
  final List<String> recentKeywords;
  final VoidCallback onClearHistory;
  final ValueChanged<String> onSelectKeyword;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16, isDesktop ? 16 : 0, 16, 0),
      sliver: SliverList.list(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                '搜索历史',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton(onPressed: onClearHistory, child: const Text('清空')),
            ],
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: recentKeywords.map((String item) {
              return ActionChip(
                side: BorderSide.none,
                labelPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                label: Text(item),
                backgroundColor: ColorUtil.getShade(
                  theme.primaryColor,
                  100,
                ).withValues(alpha: 0.1),
                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                onPressed: () => onSelectKeyword(item),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class SearchSuggestionOverlay extends StatelessWidget {
  const SearchSuggestionOverlay({
    super.key,
    required this.suggestions,
    required this.isLoadingSuggestions,
    required this.query,
    required this.onSelectSuggestion,
  });

  final List<String> suggestions;
  final bool isLoadingSuggestions;
  final String query;
  final ValueChanged<String> onSelectSuggestion;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return ColoredBox(
      color: colorScheme.surfaceContainerLowest,
      child: Column(
        children: <Widget>[
          if (isLoadingSuggestions && suggestions.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '正在获取联想词',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: suggestions.length,
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  height: 1,
                  indent: 14,
                  endIndent: 16,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                );
              },
              itemBuilder: (BuildContext context, int index) {
                final String suggestion = suggestions[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onSelectSuggestion(suggestion),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: HighlightText(
                              text: suggestion,
                              highlight: query,
                              normalStyle: theme.textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: colorScheme.onSurface,
                              ),
                              highlightStyle: theme.textTheme.bodyMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: colorScheme.primary,
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
