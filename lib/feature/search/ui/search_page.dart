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

  static const List<String> _keywords = <String>[
    '洛天依',
    '初音未来',
    'Aimer',
    'YOASOBI',
    '泽野弘之',
    'BGM',
    '纯音乐',
    '翻唱',
  ];

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
    final ThemeData theme = Theme.of(context);
    final String keyword = _controller.text.trim();
    final List<String> filteredKeywords = _keywords.where((String item) {
      if (keyword.isEmpty) {
        return true;
      }
      return item.toLowerCase().contains(keyword.toLowerCase());
    }).toList();

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
                        onChanged: (_) => setState(() {}),
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
                          suffixIcon: keyword.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _controller.clear();
                                    setState(() {});
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
                  Text(
                    keyword.isEmpty ? '大家都在搜' : '搜索结果',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (filteredKeywords.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: <Widget>[
                          const Icon(
                            Icons.search_off_rounded,
                            size: 32,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '没有找到 "$keyword" 的相关内容',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...<Widget>[
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: filteredKeywords.map((String item) {
                        return ActionChip(
                          label: Text(item),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFD8E2EC)),
                          labelStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF334155),
                            fontWeight: FontWeight.w600,
                          ),
                          onPressed: () {
                            _controller.text = item;
                            _controller.selection = TextSelection.collapsed(
                              offset: item.length,
                            );
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    ...filteredKeywords.map(
                      (String item) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.music_note_rounded,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                          title: Text(item),
                          subtitle: Text(
                            keyword.isEmpty ? '热门搜索推荐' : '匹配到相关内容',
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {},
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
