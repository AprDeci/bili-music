import 'package:bilimusic/feature/search/domain/search_state.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';
import 'package:bilimusic/feature/search/logic/search_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SearchState state = ref.watch(searchPageControllerProvider);
    final SearchPageController controller = ref.read(
      searchPageControllerProvider.notifier,
    );
    final ThemeData theme = Theme.of(context);

    if (_controller.text != state.query) {
      _controller.value = TextEditingValue(
        text: state.query,
        selection: TextSelection.collapsed(offset: state.query.length),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFD8E2EC)),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x120F172A),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.search,
                        onChanged: controller.updateQuery,
                        onSubmitted: (_) => controller.submitSearch(),
                        decoration: InputDecoration(
                          hintText: '搜索歌曲、歌手或视频',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF7D8C9B),
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF5B6F82),
                            size: 20,
                          ),
                          suffixIcon: state.query.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _controller.clear();
                                    controller.clearQuery();
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: <Widget>[
                  if (state.recentKeywords.isNotEmpty) ...<Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          '搜索历史',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: controller.clearHistory,
                          child: const Text('清空'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: state.recentKeywords.map((String item) {
                        return ActionChip(
                          label: Text(item),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFD8E2EC)),
                          labelStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF334155),
                            fontWeight: FontWeight.w600,
                          ),
                          onPressed: () {
                            controller.selectKeyword(item);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Row(
                    children: <Widget>[
                      Text(
                        '搜索结果',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      if (state.submittedQuery != null &&
                          state.submittedQuery!.isNotEmpty)
                        Text(
                          '${state.results.length} 条',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SearchResultSection(
                    submittedQuery: state.submittedQuery,
                    results: state.results,
                    isLoading: state.isLoading,
                    errorMessage: state.errorMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultSection extends StatelessWidget {
  const _SearchResultSection({
    required this.submittedQuery,
    required this.results,
    required this.isLoading,
    required this.errorMessage,
  });

  final String? submittedQuery;
  final List<SearchResultItem> results;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasQuery = submittedQuery != null && submittedQuery!.isNotEmpty;

    if (!hasQuery) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: Color(0xFF2563EB),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '输入关键词开始搜索',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '当前页面已接好搜索交互，提交后会显示结果列表。',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    if (isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: <Widget>[
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.6),
            ),
            const SizedBox(height: 16),
            Text(
              '正在搜索 "$submittedQuery"',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: <Widget>[
            const Icon(
              Icons.error_outline_rounded,
              size: 30,
              color: Color(0xFFDC2626),
            ),
            const SizedBox(height: 12),
            Text(
              '搜索失败',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    if (results.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: <Widget>[
            const Icon(
              Icons.search_off_rounded,
              size: 30,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 12),
            Text(
              '没有找到相关视频',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '试试更换关键词，或者确认当前登录态和 Cookie 是否可用。',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: results.map((SearchResultItem item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: item.coverUrl.isEmpty
                    ? const Icon(
                        Icons.play_circle_outline_rounded,
                        color: Color(0xFF2563EB),
                        size: 24,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          item.coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.music_video_rounded,
                              color: Color(0xFF2563EB),
                            );
                          },
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                              height: 1.35,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _ResultTag(label: item.tagText),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${item.author} · ${item.publishTimeText}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _MetaChip(icon: Icons.play_arrow_rounded, text: item.playCountText),
                        _MetaChip(icon: Icons.subtitles_rounded, text: item.danmakuCountText),
                        _MetaChip(icon: Icons.schedule_rounded, text: item.duration),
                      ],
                    ),
                    if (item.description != null) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        item.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF64748B),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ResultTag extends StatelessWidget {
  const _ResultTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: const Color(0xFF2563EB),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.labelMedium?.copyWith(
              color: const Color(0xFF475569),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
