// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'metadata_cache_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MetadataCacheEntry {

 String get stableId; String? get artist; String? get title; String? get lyrics; MetaLyrics? get metaLyrics; String? get albumArtUrl; int get lyricOffsetMs; int get updatedAtEpochMs;
/// Create a copy of MetadataCacheEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MetadataCacheEntryCopyWith<MetadataCacheEntry> get copyWith => _$MetadataCacheEntryCopyWithImpl<MetadataCacheEntry>(this as MetadataCacheEntry, _$identity);

  /// Serializes this MetadataCacheEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MetadataCacheEntry&&(identical(other.stableId, stableId) || other.stableId == stableId)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.title, title) || other.title == title)&&(identical(other.lyrics, lyrics) || other.lyrics == lyrics)&&(identical(other.metaLyrics, metaLyrics) || other.metaLyrics == metaLyrics)&&(identical(other.albumArtUrl, albumArtUrl) || other.albumArtUrl == albumArtUrl)&&(identical(other.lyricOffsetMs, lyricOffsetMs) || other.lyricOffsetMs == lyricOffsetMs)&&(identical(other.updatedAtEpochMs, updatedAtEpochMs) || other.updatedAtEpochMs == updatedAtEpochMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stableId,artist,title,lyrics,metaLyrics,albumArtUrl,lyricOffsetMs,updatedAtEpochMs);

@override
String toString() {
  return 'MetadataCacheEntry(stableId: $stableId, artist: $artist, title: $title, lyrics: $lyrics, metaLyrics: $metaLyrics, albumArtUrl: $albumArtUrl, lyricOffsetMs: $lyricOffsetMs, updatedAtEpochMs: $updatedAtEpochMs)';
}


}

/// @nodoc
abstract mixin class $MetadataCacheEntryCopyWith<$Res>  {
  factory $MetadataCacheEntryCopyWith(MetadataCacheEntry value, $Res Function(MetadataCacheEntry) _then) = _$MetadataCacheEntryCopyWithImpl;
@useResult
$Res call({
 String stableId, String? artist, String? title, String? lyrics, MetaLyrics? metaLyrics, String? albumArtUrl, int lyricOffsetMs, int updatedAtEpochMs
});


$MetaLyricsCopyWith<$Res>? get metaLyrics;

}
/// @nodoc
class _$MetadataCacheEntryCopyWithImpl<$Res>
    implements $MetadataCacheEntryCopyWith<$Res> {
  _$MetadataCacheEntryCopyWithImpl(this._self, this._then);

  final MetadataCacheEntry _self;
  final $Res Function(MetadataCacheEntry) _then;

/// Create a copy of MetadataCacheEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stableId = null,Object? artist = freezed,Object? title = freezed,Object? lyrics = freezed,Object? metaLyrics = freezed,Object? albumArtUrl = freezed,Object? lyricOffsetMs = null,Object? updatedAtEpochMs = null,}) {
  return _then(_self.copyWith(
stableId: null == stableId ? _self.stableId : stableId // ignore: cast_nullable_to_non_nullable
as String,artist: freezed == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,lyrics: freezed == lyrics ? _self.lyrics : lyrics // ignore: cast_nullable_to_non_nullable
as String?,metaLyrics: freezed == metaLyrics ? _self.metaLyrics : metaLyrics // ignore: cast_nullable_to_non_nullable
as MetaLyrics?,albumArtUrl: freezed == albumArtUrl ? _self.albumArtUrl : albumArtUrl // ignore: cast_nullable_to_non_nullable
as String?,lyricOffsetMs: null == lyricOffsetMs ? _self.lyricOffsetMs : lyricOffsetMs // ignore: cast_nullable_to_non_nullable
as int,updatedAtEpochMs: null == updatedAtEpochMs ? _self.updatedAtEpochMs : updatedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of MetadataCacheEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MetaLyricsCopyWith<$Res>? get metaLyrics {
    if (_self.metaLyrics == null) {
    return null;
  }

  return $MetaLyricsCopyWith<$Res>(_self.metaLyrics!, (value) {
    return _then(_self.copyWith(metaLyrics: value));
  });
}
}


/// Adds pattern-matching-related methods to [MetadataCacheEntry].
extension MetadataCacheEntryPatterns on MetadataCacheEntry {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MetadataCacheEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MetadataCacheEntry() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MetadataCacheEntry value)  $default,){
final _that = this;
switch (_that) {
case _MetadataCacheEntry():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MetadataCacheEntry value)?  $default,){
final _that = this;
switch (_that) {
case _MetadataCacheEntry() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String stableId,  String? artist,  String? title,  String? lyrics,  MetaLyrics? metaLyrics,  String? albumArtUrl,  int lyricOffsetMs,  int updatedAtEpochMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MetadataCacheEntry() when $default != null:
return $default(_that.stableId,_that.artist,_that.title,_that.lyrics,_that.metaLyrics,_that.albumArtUrl,_that.lyricOffsetMs,_that.updatedAtEpochMs);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String stableId,  String? artist,  String? title,  String? lyrics,  MetaLyrics? metaLyrics,  String? albumArtUrl,  int lyricOffsetMs,  int updatedAtEpochMs)  $default,) {final _that = this;
switch (_that) {
case _MetadataCacheEntry():
return $default(_that.stableId,_that.artist,_that.title,_that.lyrics,_that.metaLyrics,_that.albumArtUrl,_that.lyricOffsetMs,_that.updatedAtEpochMs);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String stableId,  String? artist,  String? title,  String? lyrics,  MetaLyrics? metaLyrics,  String? albumArtUrl,  int lyricOffsetMs,  int updatedAtEpochMs)?  $default,) {final _that = this;
switch (_that) {
case _MetadataCacheEntry() when $default != null:
return $default(_that.stableId,_that.artist,_that.title,_that.lyrics,_that.metaLyrics,_that.albumArtUrl,_that.lyricOffsetMs,_that.updatedAtEpochMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MetadataCacheEntry extends MetadataCacheEntry {
  const _MetadataCacheEntry({required this.stableId, this.artist, this.title, this.lyrics, this.metaLyrics, this.albumArtUrl, this.lyricOffsetMs = 0, required this.updatedAtEpochMs}): super._();
  factory _MetadataCacheEntry.fromJson(Map<String, dynamic> json) => _$MetadataCacheEntryFromJson(json);

@override final  String stableId;
@override final  String? artist;
@override final  String? title;
@override final  String? lyrics;
@override final  MetaLyrics? metaLyrics;
@override final  String? albumArtUrl;
@override@JsonKey() final  int lyricOffsetMs;
@override final  int updatedAtEpochMs;

/// Create a copy of MetadataCacheEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MetadataCacheEntryCopyWith<_MetadataCacheEntry> get copyWith => __$MetadataCacheEntryCopyWithImpl<_MetadataCacheEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MetadataCacheEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MetadataCacheEntry&&(identical(other.stableId, stableId) || other.stableId == stableId)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.title, title) || other.title == title)&&(identical(other.lyrics, lyrics) || other.lyrics == lyrics)&&(identical(other.metaLyrics, metaLyrics) || other.metaLyrics == metaLyrics)&&(identical(other.albumArtUrl, albumArtUrl) || other.albumArtUrl == albumArtUrl)&&(identical(other.lyricOffsetMs, lyricOffsetMs) || other.lyricOffsetMs == lyricOffsetMs)&&(identical(other.updatedAtEpochMs, updatedAtEpochMs) || other.updatedAtEpochMs == updatedAtEpochMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stableId,artist,title,lyrics,metaLyrics,albumArtUrl,lyricOffsetMs,updatedAtEpochMs);

@override
String toString() {
  return 'MetadataCacheEntry(stableId: $stableId, artist: $artist, title: $title, lyrics: $lyrics, metaLyrics: $metaLyrics, albumArtUrl: $albumArtUrl, lyricOffsetMs: $lyricOffsetMs, updatedAtEpochMs: $updatedAtEpochMs)';
}


}

/// @nodoc
abstract mixin class _$MetadataCacheEntryCopyWith<$Res> implements $MetadataCacheEntryCopyWith<$Res> {
  factory _$MetadataCacheEntryCopyWith(_MetadataCacheEntry value, $Res Function(_MetadataCacheEntry) _then) = __$MetadataCacheEntryCopyWithImpl;
@override @useResult
$Res call({
 String stableId, String? artist, String? title, String? lyrics, MetaLyrics? metaLyrics, String? albumArtUrl, int lyricOffsetMs, int updatedAtEpochMs
});


@override $MetaLyricsCopyWith<$Res>? get metaLyrics;

}
/// @nodoc
class __$MetadataCacheEntryCopyWithImpl<$Res>
    implements _$MetadataCacheEntryCopyWith<$Res> {
  __$MetadataCacheEntryCopyWithImpl(this._self, this._then);

  final _MetadataCacheEntry _self;
  final $Res Function(_MetadataCacheEntry) _then;

/// Create a copy of MetadataCacheEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stableId = null,Object? artist = freezed,Object? title = freezed,Object? lyrics = freezed,Object? metaLyrics = freezed,Object? albumArtUrl = freezed,Object? lyricOffsetMs = null,Object? updatedAtEpochMs = null,}) {
  return _then(_MetadataCacheEntry(
stableId: null == stableId ? _self.stableId : stableId // ignore: cast_nullable_to_non_nullable
as String,artist: freezed == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,lyrics: freezed == lyrics ? _self.lyrics : lyrics // ignore: cast_nullable_to_non_nullable
as String?,metaLyrics: freezed == metaLyrics ? _self.metaLyrics : metaLyrics // ignore: cast_nullable_to_non_nullable
as MetaLyrics?,albumArtUrl: freezed == albumArtUrl ? _self.albumArtUrl : albumArtUrl // ignore: cast_nullable_to_non_nullable
as String?,lyricOffsetMs: null == lyricOffsetMs ? _self.lyricOffsetMs : lyricOffsetMs // ignore: cast_nullable_to_non_nullable
as int,updatedAtEpochMs: null == updatedAtEpochMs ? _self.updatedAtEpochMs : updatedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of MetadataCacheEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MetaLyricsCopyWith<$Res>? get metaLyrics {
    if (_self.metaLyrics == null) {
    return null;
  }

  return $MetaLyricsCopyWith<$Res>(_self.metaLyrics!, (value) {
    return _then(_self.copyWith(metaLyrics: value));
  });
}
}

// dart format on
