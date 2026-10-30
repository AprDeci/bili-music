import 'dart:convert';

import 'package:bilimusic/common/domain/meta_lyrics.dart';
import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/core/net/bm_client.dart';
import 'package:bilimusic/feature/metadata/data/metadata_resolver.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/meting/data/meting_repository.dart';
import 'package:bilimusic/feature/meting/domain/meting_search_item.dart';
import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:bilimusic/feature/meting/logic/meting_source_preference_logic.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'metadata_lookup_service.g.dart';

@riverpod
MetadataLookupService metadataLookupService(Ref ref) {
  return MetadataLookupService(
    metingRepository: ref.read(metingRepositoryProvider),
    bmClient: ref.read(bmClientProvider.notifier),
    resolveServer: ref.read(metingSourcePreferenceLogicProvider).resolve,
  );
}

class MetadataLookupService {
  MetadataLookupService({
    required this.metingRepository,
    required this.resolveServer,
    this.bmClient,
  });

  final MetingRepository metingRepository;
  final MetingServer Function(String text) resolveServer;
  final BmClient? bmClient;

  final AppLogger _logger = AppLogger('MetadataLookup');

  Future<MetadataLookupResult> lookup({
    required PlayableItem item,
    required String title,
    bool Function()? isActive,
  }) async {
    void checkActive() {
      if (item.isSpoken || isActive?.call() == false) {
        throw StateError('Metadata lookup is no longer active');
      }
    }

    checkActive();
    final String keyword = (await resolveSearchKeyword(title)).trim();
    checkActive();
    final String? fallbackKeyword = keyword.isNotEmpty ? keyword : null;

    final List<MetingSearchItem> results = await metingRepository.search(
      keyword: keyword,
      server: resolveServer(item.lyricSearchTitles.join(' ')),
    );
    checkActive();
    for (final MetingSearchItem result in results) {
      checkActive();
      final MetaLyrics? metaLyrics = normalizeMetaLyrics(
        await _fetchLyricsOrNull(result),
      );
      checkActive();
      if (metaLyrics != null && metaLyrics.hasRenderableMainLyric) {
        return MetadataLookupResult(
          metadata: await buildMetadata(
            item: item,
            searchItem: result,
            metaLyrics: metaLyrics,
            isActive: isActive,
          ),
          searchKeyword: fallbackKeyword,
          searchResults: results,
        );
      }
    }

    return MetadataLookupResult(
      metadata: Metadata(stableId: item.stableId, updatedAt: DateTime.now()),
      searchKeyword: fallbackKeyword,
      searchResults: const <MetingSearchItem>[],
    );
  }

  Future<Metadata> buildMetadataFromSearchItem({
    required PlayableItem item,
    required MetingSearchItem searchItem,
    bool Function()? isActive,
  }) async {
    if (item.isSpoken || isActive?.call() == false) {
      throw StateError('Metadata lookup is no longer active');
    }
    return buildMetadata(
      item: item,
      searchItem: searchItem,
      metaLyrics: normalizeMetaLyrics(await _fetchLyricsOrNull(searchItem)),
      isActive: isActive,
    );
  }

  Future<Metadata> buildMetadata({
    required PlayableItem item,
    required MetingSearchItem searchItem,
    required MetaLyrics? metaLyrics,
    bool Function()? isActive,
  }) async {
    if (item.isSpoken || isActive?.call() == false) {
      throw StateError('Metadata lookup is no longer active');
    }
    String? albumArtUrl;
    try {
      albumArtUrl = _normalizeText(
        await metingRepository.fetchPicture(searchItem),
      );
    } on Object {
      albumArtUrl = null;
    }

    return MetadataResolver.fromCacheLikeValues(
      stableId: item.stableId,
      artist: searchItem.author,
      title: searchItem.title,
      lyrics: metaLyrics?.preferredMainLyric,
      metaLyrics: metaLyrics,
      albumArtUrl: albumArtUrl,
      updatedAt: DateTime.now(),
    );
  }

  String? defaultSearchKeyword(PlayableItem item) {
    for (final String title in item.lyricSearchTitles) {
      final String keyword = title.trim();
      if (keyword.isNotEmpty) {
        return keyword;
      }
    }
    return null;
  }

  Future<String> resolveSearchKeyword(String value) async {
    final String rawTitle = value.trim();
    if (rawTitle.isEmpty) {
      return '';
    }

    final String fallbackKeyword = extractSearchKeyword(rawTitle).trim();
    final BmClient? client = bmClient;
    if (client == null) {
      return fallbackKeyword;
    }
    try {
      final Response<String> response = await client.post<String>(
        '/ai',
        data: <String, dynamic>{'message': rawTitle},
        options: Options(responseType: ResponseType.plain),
      );
      final Object? decoded = jsonDecode(response.data ?? '{}');
      if (decoded is String && decoded.isNotEmpty) {
        return decoded;
      }
    } on Object catch (error) {
      _logger.d('BM 识别失败，回退正则：$error');
    }

    return fallbackKeyword;
  }

  String extractSearchKeyword(String value) {
    String result = value.trim();
    final RegExp priorityRegex = RegExp(r'《(.+?)》|「(.+?)」');
    final RegExpMatch? priorityMatch = priorityRegex.firstMatch(result);

    if (priorityMatch != null) {
      final String? group1 = priorityMatch.group(1);
      final String? group2 = priorityMatch.group(2);
      return group1 ?? group2 ?? '';
    }

    final String replacedKeyword = result
        .replaceAll(RegExp(r'【.*?】|“.*?”'), '')
        .trim();

    result = replacedKeyword.isNotEmpty ? replacedKeyword : result;
    return result;
  }

  MetaLyrics? normalizeMetaLyrics(MetaLyrics? value) {
    if (value == null) {
      return null;
    }

    final MetaLyrics normalized = MetaLyrics(
      lyric: _normalizeLyrics(value.lyric),
      translatedLyric: _normalizeLyrics(value.translatedLyric),
      romanizedLyric: _normalizeLyrics(value.romanizedLyric),
      karaokeLyric: _normalizeLyrics(value.karaokeLyric),
      karaokeTranslatedLyric: _normalizeLyrics(value.karaokeTranslatedLyric),
    );
    return normalized.hasAnyLyrics ? normalized : null;
  }

  Future<MetaLyrics?> _fetchLyricsOrNull(MetingSearchItem searchItem) async {
    try {
      return await metingRepository.fetchLyrics(searchItem);
    } on Object {
      return null;
    }
  }

  String? _normalizeLyrics(String? value) {
    final String trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _normalizeText(String? value) {
    final String trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
