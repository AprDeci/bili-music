import 'package:bilimusic/feature/meting/domain/meting_search_item.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_lyrics_state.dart';
import 'package:bilimusic/feature/player/logic/player_lyrics_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String resolveLyricSearchKeyword({
  required PlayerLyricsState lyricsState,
  required PlayableItem? item,
}) {
  return lyricsState.searchKeyword?.trim() ?? item?.title.trim() ?? '';
}

Future<void> showLyricOffsetSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (BuildContext context) {
      return const _LyricOffsetSheet();
    },
  );
}

Future<void> showManualLyricSearchSheet({
  required BuildContext context,
  required String initialKeyword,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (BuildContext context) {
      return _LyricSearchSheet(initialKeyword: initialKeyword);
    },
  );
}

class _LyricOffsetSheet extends ConsumerWidget {
  const _LyricOffsetSheet();

  static const int _stepMs = 500;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PlayerLyricsState lyricsState = ref.watch(
      playerLyricsControllerProvider,
    );
    final PlayerLyricsController controller = ref.read(
      playerLyricsControllerProvider.notifier,
    );
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                tooltip: '歌词提前 0.5 秒',
                onPressed: () => controller.adjustOffset(-_stepMs),
                icon: const Icon(Icons.remove_rounded),
              ),
              SizedBox(
                width: 96,
                child: Center(
                  child: Text(
                    _formatOffset(lyricsState.lyricOffsetMs),
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: '歌词延后 0.5 秒',
                onPressed: () => controller.adjustOffset(_stepMs),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _formatOffset(int offsetMs) {
  final double seconds = offsetMs / Duration.millisecondsPerSecond;
  if (offsetMs > 0) {
    return '+${seconds.toStringAsFixed(1)}s';
  }
  return '${seconds.toStringAsFixed(1)}s';
}

class _LyricSearchSheet extends ConsumerStatefulWidget {
  const _LyricSearchSheet({required this.initialKeyword});

  final String initialKeyword;

  @override
  ConsumerState<_LyricSearchSheet> createState() => _LyricSearchSheetState();
}

class _LyricSearchSheetState extends ConsumerState<_LyricSearchSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialKeyword);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String keyword = widget.initialKeyword.trim();
      if (keyword.isEmpty) {
        return;
      }
      ref.read(playerLyricsControllerProvider.notifier).searchManual(keyword);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PlayerLyricsState lyricsState = ref.watch(
      playerLyricsControllerProvider,
    );
    final ThemeData theme = Theme.of(context);
    final EdgeInsets insets = MediaQuery.viewInsetsOf(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, insets.bottom + 16),
        child: SizedBox(
          height: 420,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                        hintText: '搜索歌词',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                      onSubmitted: (_) => _submitSearch(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildResultList(context, theme, lyricsState)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultList(
    BuildContext context,
    ThemeData theme,
    PlayerLyricsState lyricsState,
  ) {
    if (lyricsState.isSearching && lyricsState.searchResults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (lyricsState.manualSearchError != null &&
        lyricsState.manualSearchError!.isNotEmpty) {
      return Center(
        child: Text(
          lyricsState.manualSearchError!,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    if (lyricsState.searchResults.isEmpty) {
      return Center(child: Text('没有搜索到结果', style: theme.textTheme.bodyMedium));
    }

    return ListView.separated(
      itemCount: lyricsState.searchResults.length,
      separatorBuilder: (_, _) => const Divider(height: 0),
      itemBuilder: (BuildContext context, int index) {
        final MetingSearchItem item = lyricsState.searchResults[index];
        final String title = item.title.trim().isEmpty
            ? '未知歌曲'
            : item.title.trim();
        final String author = item.author.trim().isEmpty
            ? '未知歌手'
            : item.author.trim();
        return ListTile(
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(author, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: lyricsState.isSearching
              ? null
              : () => _applyResult(context, item),
        );
      },
    );
  }

  Future<void> _applyResult(BuildContext context, MetingSearchItem item) async {
    final NavigatorState navigator = Navigator.of(context);
    await ref
        .read(playerLyricsControllerProvider.notifier)
        .applyManualResult(item);
    if (!mounted) {
      return;
    }
    final PlayerLyricsState nextState = ref.read(
      playerLyricsControllerProvider,
    );
    if (nextState.manualSearchError == null ||
        nextState.manualSearchError!.isEmpty) {
      navigator.pop();
    }
  }

  void _submitSearch() {
    ref
        .read(playerLyricsControllerProvider.notifier)
        .searchManual(_controller.text);
  }
}
