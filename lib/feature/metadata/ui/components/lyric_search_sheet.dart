import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/meting/data/meting_repository.dart';
import 'package:bilimusic/feature/meting/domain/meting_search_item.dart';
import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// 优先元数据信息-提取信息-原标题
String resolveLyricSearchKeyword({
  required MetadataState metadataState,
  required PlayableItem? item,
}) {
  final String metadataKeyword = _metadataSearchKeyword(metadataState, item);
  if (metadataKeyword.isNotEmpty) {
    return metadataKeyword;
  }

  return metadataState.searchKeyword?.trim() ?? item?.title.trim() ?? '';
}

String _metadataSearchKeyword(MetadataState metadataState, PlayableItem? item) {
  final metadata = metadataState.metadata;
  if (metadata == null || metadata.stableId != item?.stableId) {
    return '';
  }

  final String title = metadata.title?.trim() ?? '';
  final String artist = metadata.artist?.trim() ?? '';
  if (title.isNotEmpty && artist.isNotEmpty) {
    return '$title-$artist';
  }
  if (title.isNotEmpty) {
    return title;
  }
  return artist;
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

class _LyricSearchSheet extends ConsumerStatefulWidget {
  const _LyricSearchSheet({required this.initialKeyword});

  final String initialKeyword;

  @override
  ConsumerState<_LyricSearchSheet> createState() => _LyricSearchSheetState();
}

class _LyricSearchSheetState extends ConsumerState<_LyricSearchSheet> {
  late final TextEditingController _controller;
  final Map<String, Future<String?>> _pictureFutureCache =
      <String, Future<String?>>{};
  MetingServer _selectedServer = MetingServer.netease;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialKeyword);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String keyword = widget.initialKeyword.trim();
      if (keyword.isEmpty) {
        return;
      }
      ref
          .read(metadataControllerProvider.notifier)
          .searchManual(keyword, server: _selectedServer);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MetadataState metadataState = ref.watch(metadataControllerProvider);
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
                    flex: 1,
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
                  const SizedBox(width: 20),
                  DropdownMenu<MetingServer>(
                    initialSelection: _selectedServer,
                    label: const Text('平台'),
                    width: 160,
                    dropdownMenuEntries: MetingServer.values
                        .map(
                          (MetingServer server) =>
                              DropdownMenuEntry<MetingServer>(
                                value: server,
                                label: server.label,
                              ),
                        )
                        .toList(growable: false),
                    onSelected: (MetingServer? server) {
                      if (server == null || server == _selectedServer) {
                        return;
                      }
                      setState(() {
                        _selectedServer = server;
                      });
                      _submitSearch();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildResultList(context, theme, metadataState)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultList(
    BuildContext context,
    ThemeData theme,
    MetadataState metadataState,
  ) {
    if (metadataState.isSearching && metadataState.searchResults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (metadataState.manualSearchError != null &&
        metadataState.manualSearchError!.isNotEmpty) {
      return Center(
        child: Text(
          metadataState.manualSearchError!,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    if (metadataState.searchResults.isEmpty) {
      return Center(child: Text('没有搜索到结果', style: theme.textTheme.bodyMedium));
    }

    return ListView.separated(
      itemCount: metadataState.searchResults.length,
      separatorBuilder: (_, _) => const Divider(height: 0),
      itemBuilder: (BuildContext context, int index) {
        final MetingSearchItem item = metadataState.searchResults[index];
        final String title = item.title.trim().isEmpty
            ? '未知歌曲'
            : item.title.trim();
        final String author = item.author.trim().isEmpty
            ? '未知歌手'
            : item.author.trim();
        return _LyricSearchResultTile(
          title: title,
          author: author,
          pictureUrlFuture: _pictureFutureFor(item),
          enabled: !metadataState.isSearching,
          onTap: () => _applyResult(context, item),
        );
      },
    );
  }

  Future<void> _applyResult(BuildContext context, MetingSearchItem item) async {
    final NavigatorState navigator = Navigator.of(context);
    await ref.read(metadataControllerProvider.notifier).applyManualResult(item);
    if (!mounted) {
      return;
    }
    final MetadataState nextState = ref.read(metadataControllerProvider);
    if (nextState.manualSearchError == null ||
        nextState.manualSearchError!.isEmpty) {
      navigator.pop();
    }
  }

  Future<String?> _loadPictureUrl(MetingSearchItem item) async {
    try {
      final String url = await ref
          .read(metingRepositoryProvider)
          .fetchPicture(item, size: 120);
      final String trimmedUrl = url.trim();
      return trimmedUrl.isEmpty ? null : trimmedUrl;
    } on Object {
      return null;
    }
  }

  Future<String?> _pictureFutureFor(MetingSearchItem item) {
    final String cacheKey =
        '${item.server.name}:${item.id}:${item.picId ?? ''}';
    return _pictureFutureCache.putIfAbsent(
      cacheKey,
      () => _loadPictureUrl(item),
    );
  }

  void _submitSearch() {
    ref
        .read(metadataControllerProvider.notifier)
        .searchManual(_controller.text, server: _selectedServer);
  }
}

class _LyricSearchResultTile extends StatelessWidget {
  const _LyricSearchResultTile({
    required this.title,
    required this.author,
    required this.pictureUrlFuture,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String author;
  final Future<String?> pictureUrlFuture;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: FutureBuilder<String?>(
        future: pictureUrlFuture,
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          return CommonCachedImage(
            imageUrl: snapshot.data,
            width: 44,
            height: 44,
            borderRadius: BorderRadius.circular(8),
          );
        },
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(author, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: enabled ? onTap : null,
    );
  }
}
