import 'dart:collection';
import 'dart:convert';

import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';

const int clipboardSyncPayloadVersion = 3;
const String _bm3Header = 'BM3';

class ClipboardSyncPayload {
  const ClipboardSyncPayload({
    required this.userId,
    required this.updatedAtEpochMs,
    required this.favoritesState,
    required this.settings,
  });

  final String userId;
  final int updatedAtEpochMs;
  final FavoritesState favoritesState;
  final Map<String, String> settings;

  factory ClipboardSyncPayload.fromJsonString(String value) {
    final String trimmed = value.trim();
    if (trimmed.startsWith(_bm3Header)) {
      return _fromBm3String(trimmed);
    }

    final Object? decoded = jsonDecode(value);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Clipboard payload must be an object.');
    }
    if (_readInt(decoded['v']) != 1) {
      throw const FormatException('Unsupported clipboard payload version.');
    }

    return ClipboardSyncPayload(
      userId: _readString(decoded['u']),
      updatedAtEpochMs: _readInt(decoded['t']),
      favoritesState: FavoritesState(
        collections: _readRows(
          decoded['c'],
        ).map(_collectionFromRow).toList(growable: false),
        entries: _readRows(
          decoded['e'],
        ).map(_entryFromRow).toList(growable: false),
        memberships: _readRows(
          decoded['m'],
        ).map(_membershipFromRow).toList(growable: false),
      ),
      settings: _readSettings(decoded['s']),
    );
  }

  String toJsonString() {
    final List<String> lines = <String>[_bm3Header];
    final List<String> likedRefs = _itemRefsForCollection(
      favoritesState,
      FavoriteCollection.likedCollectionId,
    );
    if (likedRefs.isNotEmpty) {
      lines.add('L:${likedRefs.join(',')}');
    }

    final Map<String, List<FavoriteEntry>> playlistItemsByName =
        <String, List<FavoriteEntry>>{};
    for (final FavoriteCollection collection in favoritesState.collections) {
      if (collection.isLikedCollection) {
        continue;
      }
      final String name = collection.name.trim();
      if (name.isEmpty) {
        continue;
      }
      final List<FavoriteEntry> items = favoritesState.itemsForCollection(
        collection.id,
      );
      if (items.isEmpty) {
        continue;
      }
      playlistItemsByName
          .putIfAbsent(name, () => <FavoriteEntry>[])
          .addAll(items);
    }

    for (final MapEntry<String, List<FavoriteEntry>> entry
        in playlistItemsByName.entries) {
      final List<String> refs = _itemRefsForItems(entry.value);
      if (refs.isEmpty) {
        continue;
      }
      lines.add('P:${_escapeCollectionName(entry.key)}=${refs.join(',')}');
    }

    return lines.join('\n');
  }
}

ClipboardSyncPayload _fromBm3String(String value) {
  final DateTime now = DateTime.now();
  final Map<String, FavoriteCollection> collections =
      <String, FavoriteCollection>{
        FavoriteCollection.likedCollectionId: FavoriteCollection.liked(
          now: now,
        ),
      };
  final Map<String, FavoriteEntry> entries = <String, FavoriteEntry>{};
  final Map<String, FavoriteMembership> memberships =
      <String, FavoriteMembership>{};

  for (final String rawLine in const LineSplitter().convert(value).skip(1)) {
    final String line = rawLine.trim();
    if (line.isEmpty) {
      continue;
    }
    if (line.startsWith('L:')) {
      _addBm3Refs(
        collectionId: FavoriteCollection.likedCollectionId,
        refs: _readBm3Refs(line.substring(2)),
        entries: entries,
        memberships: memberships,
        now: now,
      );
      continue;
    }
    if (line.startsWith('P:')) {
      final _Bm3PlaylistLine? playlistLine = _parseBm3PlaylistLine(
        line.substring(2),
      );
      if (playlistLine == null) {
        continue;
      }
      final String collectionId = _collectionIdForBm3Name(playlistLine.name);
      collections[collectionId] = FavoriteCollection(
        id: collectionId,
        name: playlistLine.name,
        createdAt: now,
        updatedAt: now,
      );
      _addBm3Refs(
        collectionId: collectionId,
        refs: playlistLine.refs,
        entries: entries,
        memberships: memberships,
        now: now,
      );
    }
  }

  final Set<String> referencedItemIds = memberships.values
      .map((FavoriteMembership membership) => membership.itemId)
      .toSet();
  return ClipboardSyncPayload(
    userId: '',
    updatedAtEpochMs: 0,
    favoritesState: FavoritesState(
      collections: collections.values.toList(growable: false),
      entries: entries.values
          .where(
            (FavoriteEntry entry) => referencedItemIds.contains(entry.itemId),
          )
          .toList(growable: false),
      memberships: memberships.values.toList(growable: false),
    ),
    settings: const <String, String>{},
  );
}

void _addBm3Refs({
  required String collectionId,
  required List<String> refs,
  required Map<String, FavoriteEntry> entries,
  required Map<String, FavoriteMembership> memberships,
  required DateTime now,
}) {
  for (final String ref in refs) {
    for (final _DecodedItemRef decodedRef in _decodeItemRefs(ref)) {
      entries.putIfAbsent(
        decodedRef.stableId,
        () => FavoriteEntry(
          itemId: decodedRef.stableId,
          aid: decodedRef.aid ?? 0,
          bvid: decodedRef.bvid ?? '',
          title: ref,
          author: '',
          coverUrl: '',
          cid: decodedRef.cid,
          createdAt: now,
          updatedAt: now,
        ),
      );
      final FavoriteMembership membership = FavoriteMembership.create(
        collectionId: collectionId,
        itemId: decodedRef.stableId,
        addedAt: now,
      );
      memberships[membership.id] = membership;
    }
  }
}

List<String> _itemRefsForCollection(FavoritesState state, String collectionId) {
  return _itemRefsForItems(state.itemsForCollection(collectionId));
}

List<String> _itemRefsForItems(List<FavoriteEntry> items) {
  final Map<String, LinkedHashSet<int>> groupedCids =
      <String, LinkedHashSet<int>>{};
  final LinkedHashSet<String> refs = LinkedHashSet<String>();

  for (final FavoriteEntry entry in items) {
    final _EncodedItemRef? encodedRef = _encodeItemRef(entry.itemId);
    if (encodedRef == null) {
      continue;
    }
    final int? cid = encodedRef.cid;
    if (cid == null || cid <= 0) {
      refs.add(encodedRef.base);
      continue;
    }
    groupedCids
        .putIfAbsent(encodedRef.base, () => LinkedHashSet<int>())
        .add(cid);
  }

  for (final MapEntry<String, LinkedHashSet<int>> entry
      in groupedCids.entries) {
    refs.add('${entry.key}#${entry.value.join('.')}');
  }

  return refs.toList(growable: false);
}

FavoritesState mergeClipboardFavorites({
  required FavoritesState localState,
  required FavoritesState remoteState,
}) {
  final Map<String, FavoriteCollection> collections =
      <String, FavoriteCollection>{};
  for (final FavoriteCollection collection in localState.collections) {
    collections[collection.id] = collection;
  }
  collections.putIfAbsent(
    FavoriteCollection.likedCollectionId,
    FavoriteCollection.liked,
  );

  final Map<String, FavoriteEntry> entries = <String, FavoriteEntry>{};
  for (final FavoriteEntry entry in remoteState.entries) {
    entries[entry.itemId] = entry;
  }
  for (final FavoriteEntry entry in localState.entries) {
    entries[entry.itemId] = entry;
  }

  final Map<String, FavoriteMembership> memberships =
      <String, FavoriteMembership>{};
  for (final FavoriteMembership membership in remoteState.memberships) {
    final String collectionId = _targetCollectionIdForRemote(
      remoteCollectionId: membership.collectionId,
      localCollections: localState.collections,
      remoteCollections: remoteState.collections,
      collections: collections,
    );
    final FavoriteMembership normalized = FavoriteMembership.create(
      collectionId: collectionId,
      itemId: membership.itemId,
      addedAt: membership.addedAt,
    );
    memberships[normalized.id] = normalized;
  }
  for (final FavoriteMembership membership in localState.memberships) {
    memberships[membership.id] = membership;
  }

  return FavoritesState(
    collections: collections.values.toList(growable: false),
    entries: entries.values.toList(growable: false),
    memberships: memberships.values.toList(growable: false),
  );
}

String _targetCollectionIdForRemote({
  required String remoteCollectionId,
  required List<FavoriteCollection> localCollections,
  required List<FavoriteCollection> remoteCollections,
  required Map<String, FavoriteCollection> collections,
}) {
  if (remoteCollectionId == FavoriteCollection.likedCollectionId) {
    return FavoriteCollection.likedCollectionId;
  }

  final FavoriteCollection? remoteCollection = _findCollectionById(
    remoteCollections,
    remoteCollectionId,
  );
  if (remoteCollection == null) {
    return remoteCollectionId;
  }
  final String normalizedRemoteName = _normalizeCollectionName(
    remoteCollection.name,
  );
  for (final FavoriteCollection localCollection in localCollections) {
    if (localCollection.isLikedCollection) {
      continue;
    }
    if (_normalizeCollectionName(localCollection.name) ==
        normalizedRemoteName) {
      return localCollection.id;
    }
  }

  collections.putIfAbsent(remoteCollection.id, () => remoteCollection);
  return remoteCollection.id;
}

FavoriteCollection? _findCollectionById(
  List<FavoriteCollection> collections,
  String id,
) {
  for (final FavoriteCollection collection in collections) {
    if (collection.id == id) {
      return collection;
    }
  }
  return null;
}

String _normalizeCollectionName(String name) {
  return name.trim();
}

String _collectionIdForBm3Name(String name) {
  final String encoded = base64Url
      .encode(utf8.encode(_normalizeCollectionName(name)))
      .replaceAll('=', '');
  return 'sync:$encoded';
}

_EncodedItemRef? _encodeItemRef(String stableId) {
  RegExpMatch? match = RegExp(r'^bvid:([^:]+):cid:(\d+)$').firstMatch(stableId);
  if (match != null) {
    return _EncodedItemRef(
      base: _trimBvPrefix(match.group(1) ?? ''),
      cid: int.tryParse(match.group(2) ?? ''),
    );
  }
  match = RegExp(r'^bvid:([^:]+)$').firstMatch(stableId);
  if (match != null) {
    return _EncodedItemRef(base: _trimBvPrefix(match.group(1) ?? ''));
  }
  match = RegExp(r'^aid:(\d+):cid:(\d+)$').firstMatch(stableId);
  if (match != null) {
    return _EncodedItemRef(
      base: 'a${match.group(1)}',
      cid: int.tryParse(match.group(2) ?? ''),
    );
  }
  match = RegExp(r'^aid:(\d+)$').firstMatch(stableId);
  if (match != null) {
    return _EncodedItemRef(base: 'a${match.group(1)}');
  }
  return _EncodedItemRef(base: stableId);
}

List<_DecodedItemRef> _decodeItemRefs(String rawRef) {
  final String ref = rawRef.trim();
  final int separatorIndex = ref.indexOf('#');
  if (separatorIndex <= 0 || separatorIndex >= ref.length - 1) {
    final _DecodedItemRef? decodedRef = _decodeItemRef(ref);
    return decodedRef == null
        ? const <_DecodedItemRef>[]
        : <_DecodedItemRef>[decodedRef];
  }

  final String base = ref.substring(0, separatorIndex);
  final List<String> cidParts = ref
      .substring(separatorIndex + 1)
      .split('.')
      .where((String value) => value.trim().isNotEmpty)
      .toList(growable: false);
  if (cidParts.length <= 1) {
    final _DecodedItemRef? decodedRef = _decodeItemRef(ref);
    return decodedRef == null
        ? const <_DecodedItemRef>[]
        : <_DecodedItemRef>[decodedRef];
  }

  return cidParts
      .map((String cid) => _decodeItemRef('$base#$cid'))
      .whereType<_DecodedItemRef>()
      .toList(growable: false);
}

_DecodedItemRef? _decodeItemRef(String rawRef) {
  final String ref = rawRef.trim();
  if (ref.isEmpty) {
    return null;
  }

  RegExpMatch? match = RegExp(r'^(BV[^#,\s]+)#(\d+)$').firstMatch(ref);
  if (match != null) {
    final String bvid = match.group(1) ?? '';
    final int cid = int.tryParse(match.group(2) ?? '') ?? 0;
    if (bvid.isEmpty || cid <= 0) {
      return null;
    }
    return _DecodedItemRef(
      stableId: 'bvid:$bvid:cid:$cid',
      bvid: bvid,
      cid: cid,
    );
  }

  match = RegExp(r'^(BV[^#,\s]+)$').firstMatch(ref);
  if (match != null) {
    final String bvid = match.group(1) ?? '';
    return _DecodedItemRef(stableId: 'bvid:$bvid', bvid: bvid);
  }

  match = RegExp(r'^(?:av|a)(\d+)#(\d+)$').firstMatch(ref);
  if (match != null) {
    final int aid = int.tryParse(match.group(1) ?? '') ?? 0;
    final int cid = int.tryParse(match.group(2) ?? '') ?? 0;
    if (aid <= 0 || cid <= 0) {
      return null;
    }
    return _DecodedItemRef(stableId: 'aid:$aid:cid:$cid', aid: aid, cid: cid);
  }

  match = RegExp(r'^(?:av|a)(\d+)$').firstMatch(ref);
  if (match != null) {
    final int aid = int.tryParse(match.group(1) ?? '') ?? 0;
    if (aid <= 0) {
      return null;
    }
    return _DecodedItemRef(stableId: 'aid:$aid', aid: aid);
  }

  if (ref.startsWith('bvid:') || ref.startsWith('aid:')) {
    return _DecodedItemRef(stableId: ref);
  }

  match = RegExp(r'^([^#,\s]+)#(\d+)$').firstMatch(ref);
  if (match != null) {
    final String bvid = _restoreBvPrefix(match.group(1) ?? '');
    final int cid = int.tryParse(match.group(2) ?? '') ?? 0;
    if (bvid.isEmpty || cid <= 0) {
      return null;
    }
    return _DecodedItemRef(
      stableId: 'bvid:$bvid:cid:$cid',
      bvid: bvid,
      cid: cid,
    );
  }

  match = RegExp(r'^([^#,\s]+)$').firstMatch(ref);
  if (match != null) {
    final String bvid = _restoreBvPrefix(match.group(1) ?? '');
    return _DecodedItemRef(stableId: 'bvid:$bvid', bvid: bvid);
  }
  return null;
}

String _trimBvPrefix(String bvid) {
  return bvid.startsWith('BV') ? bvid.substring(2) : bvid;
}

String _restoreBvPrefix(String value) {
  return value.startsWith('BV') ? value : 'BV$value';
}

List<String> _readBm3Refs(String value) {
  return value
      .split(',')
      .map((String ref) => ref.trim())
      .where((String ref) => ref.isNotEmpty)
      .toList(growable: false);
}

_Bm3PlaylistLine? _parseBm3PlaylistLine(String value) {
  final int separatorIndex = _firstUnescapedEquals(value);
  if (separatorIndex < 0) {
    return null;
  }
  final String name = _unescapeCollectionName(
    value.substring(0, separatorIndex),
  ).trim();
  if (name.isEmpty) {
    return null;
  }
  return _Bm3PlaylistLine(
    name: name,
    refs: _readBm3Refs(value.substring(separatorIndex + 1)),
  );
}

int _firstUnescapedEquals(String value) {
  bool escaped = false;
  for (int index = 0; index < value.length; index += 1) {
    final String char = value[index];
    if (escaped) {
      escaped = false;
      continue;
    }
    if (char == r'\') {
      escaped = true;
      continue;
    }
    if (char == '=') {
      return index;
    }
  }
  return -1;
}

String _escapeCollectionName(String name) {
  return name
      .replaceAll(r'\', r'\\')
      .replaceAll('\r', '')
      .replaceAll('\n', r'\n')
      .replaceAll(',', r'\,')
      .replaceAll('=', r'\=');
}

String _unescapeCollectionName(String value) {
  final StringBuffer buffer = StringBuffer();
  bool escaped = false;
  for (int index = 0; index < value.length; index += 1) {
    final String char = value[index];
    if (!escaped) {
      if (char == r'\') {
        escaped = true;
      } else {
        buffer.write(char);
      }
      continue;
    }
    if (char == 'n') {
      buffer.write('\n');
    } else {
      buffer.write(char);
    }
    escaped = false;
  }
  if (escaped) {
    buffer.write(r'\');
  }
  return buffer.toString();
}

class _Bm3PlaylistLine {
  const _Bm3PlaylistLine({required this.name, required this.refs});

  final String name;
  final List<String> refs;
}

class _EncodedItemRef {
  const _EncodedItemRef({required this.base, this.cid});

  final String base;
  final int? cid;
}

class _DecodedItemRef {
  const _DecodedItemRef({
    required this.stableId,
    this.aid,
    this.bvid,
    this.cid,
  });

  final String stableId;
  final int? aid;
  final String? bvid;
  final int? cid;
}

FavoriteCollection _collectionFromRow(List<dynamic> row) {
  final DateTime now = DateTime.now();
  return FavoriteCollection(
    id: _readStringAt(row, 0),
    name: _readStringAt(row, 1),
    source: _readCollectionSource(_readStringAt(row, 2)),
    isSystem: _readBoolAt(row, 3),
    remoteId: _readNullableStringAt(row, 4),
    coverUrl: _readNullableStringAt(row, 5),
    itemCount: _readIntAt(row, 6),
    isManagedByApp: _readBoolAt(row, 7),
    lastSyncedAt: _readNullableDateAt(row, 8),
    createdAt: _readNullableDateAt(row, 9) ?? now,
    updatedAt: _readNullableDateAt(row, 10) ?? now,
  );
}

FavoriteEntry _entryFromRow(List<dynamic> row) {
  final DateTime now = DateTime.now();
  return FavoriteEntry(
    itemId: _readStringAt(row, 0),
    aid: _readIntAt(row, 1),
    bvid: _readStringAt(row, 2),
    title: _readStringAt(row, 3),
    author: _readStringAt(row, 4),
    coverUrl: _readStringAt(row, 5),
    ownerMid: _readNullableIntAt(row, 6),
    cid: _readNullableIntAt(row, 7),
    page: _readNullableIntAt(row, 8),
    pageTitle: _readNullableStringAt(row, 9),
    durationText: _readNullableStringAt(row, 10),
    createdAt: _readNullableDateAt(row, 11) ?? now,
    updatedAt: _readNullableDateAt(row, 12) ?? now,
  );
}

FavoriteMembership _membershipFromRow(List<dynamic> row) {
  final String collectionId = _readStringAt(row, 1);
  final String itemId = _readStringAt(row, 2);
  return FavoriteMembership(
    id: _readStringAt(row, 0).isEmpty
        ? FavoriteMembership.membershipId(
            collectionId: collectionId,
            itemId: itemId,
          )
        : _readStringAt(row, 0),
    collectionId: collectionId,
    itemId: itemId,
    addedAt: _readNullableDateAt(row, 3) ?? DateTime.now(),
  );
}

FavoriteCollectionSource _readCollectionSource(String value) {
  return FavoriteCollectionSource.values.firstWhere(
    (FavoriteCollectionSource source) => source.name == value,
    orElse: () => FavoriteCollectionSource.local,
  );
}

Map<String, String> _readSettings(Object? value) {
  if (value is! Map<String, dynamic>) {
    return const <String, String>{};
  }
  return <String, String>{
    for (final MapEntry<String, dynamic> entry in value.entries)
      if (entry.value is String) entry.key: entry.value as String,
  };
}

List<List<dynamic>> _readRows(Object? value) {
  if (value is! List<dynamic>) {
    return const <List<dynamic>>[];
  }
  return value
      .whereType<List<dynamic>>()
      .map((List<dynamic> row) => row)
      .toList(growable: false);
}

DateTime? _readNullableDateAt(List<dynamic> row, int index) {
  final int? value = _readNullableIntAt(row, index);
  if (value == null || value <= 0) {
    return null;
  }
  return DateTime.fromMillisecondsSinceEpoch(value);
}

String _readString(Object? value) {
  return value is String ? value : '';
}

int _readInt(Object? value) {
  return (value as num?)?.toInt() ?? 0;
}

String _readStringAt(List<dynamic> row, int index) {
  if (index < 0 || index >= row.length) {
    return '';
  }
  return _readString(row[index]);
}

String? _readNullableStringAt(List<dynamic> row, int index) {
  final String value = _readStringAt(row, index).trim();
  return value.isEmpty ? null : value;
}

int _readIntAt(List<dynamic> row, int index) {
  if (index < 0 || index >= row.length) {
    return 0;
  }
  return _readInt(row[index]);
}

int? _readNullableIntAt(List<dynamic> row, int index) {
  if (index < 0 || index >= row.length) {
    return null;
  }
  final Object? value = row[index];
  if (value == null) {
    return null;
  }
  return _readInt(value);
}

bool _readBoolAt(List<dynamic> row, int index) {
  if (index < 0 || index >= row.length) {
    return false;
  }
  final Object? value = row[index];
  if (value is bool) {
    return value;
  }
  return _readInt(value) == 1;
}
