// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song_statistics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SongStatistics {

 String get stableId; String get title; String get author; String get coverUrl; int get playCount; int get totalPlayedMs; int? get firstPlayedAtEpochMs; int? get lastPlayedAtEpochMs;
/// Create a copy of SongStatistics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SongStatisticsCopyWith<SongStatistics> get copyWith => _$SongStatisticsCopyWithImpl<SongStatistics>(this as SongStatistics, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SongStatistics&&(identical(other.stableId, stableId) || other.stableId == stableId)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.playCount, playCount) || other.playCount == playCount)&&(identical(other.totalPlayedMs, totalPlayedMs) || other.totalPlayedMs == totalPlayedMs)&&(identical(other.firstPlayedAtEpochMs, firstPlayedAtEpochMs) || other.firstPlayedAtEpochMs == firstPlayedAtEpochMs)&&(identical(other.lastPlayedAtEpochMs, lastPlayedAtEpochMs) || other.lastPlayedAtEpochMs == lastPlayedAtEpochMs));
}


@override
int get hashCode => Object.hash(runtimeType,stableId,title,author,coverUrl,playCount,totalPlayedMs,firstPlayedAtEpochMs,lastPlayedAtEpochMs);

@override
String toString() {
  return 'SongStatistics(stableId: $stableId, title: $title, author: $author, coverUrl: $coverUrl, playCount: $playCount, totalPlayedMs: $totalPlayedMs, firstPlayedAtEpochMs: $firstPlayedAtEpochMs, lastPlayedAtEpochMs: $lastPlayedAtEpochMs)';
}


}

/// @nodoc
abstract mixin class $SongStatisticsCopyWith<$Res>  {
  factory $SongStatisticsCopyWith(SongStatistics value, $Res Function(SongStatistics) _then) = _$SongStatisticsCopyWithImpl;
@useResult
$Res call({
 String stableId, String title, String author, String coverUrl, int playCount, int totalPlayedMs, int? firstPlayedAtEpochMs, int? lastPlayedAtEpochMs
});




}
/// @nodoc
class _$SongStatisticsCopyWithImpl<$Res>
    implements $SongStatisticsCopyWith<$Res> {
  _$SongStatisticsCopyWithImpl(this._self, this._then);

  final SongStatistics _self;
  final $Res Function(SongStatistics) _then;

/// Create a copy of SongStatistics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stableId = null,Object? title = null,Object? author = null,Object? coverUrl = null,Object? playCount = null,Object? totalPlayedMs = null,Object? firstPlayedAtEpochMs = freezed,Object? lastPlayedAtEpochMs = freezed,}) {
  return _then(_self.copyWith(
stableId: null == stableId ? _self.stableId : stableId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,playCount: null == playCount ? _self.playCount : playCount // ignore: cast_nullable_to_non_nullable
as int,totalPlayedMs: null == totalPlayedMs ? _self.totalPlayedMs : totalPlayedMs // ignore: cast_nullable_to_non_nullable
as int,firstPlayedAtEpochMs: freezed == firstPlayedAtEpochMs ? _self.firstPlayedAtEpochMs : firstPlayedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int?,lastPlayedAtEpochMs: freezed == lastPlayedAtEpochMs ? _self.lastPlayedAtEpochMs : lastPlayedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [SongStatistics].
extension SongStatisticsPatterns on SongStatistics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SongStatistics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SongStatistics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SongStatistics value)  $default,){
final _that = this;
switch (_that) {
case _SongStatistics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SongStatistics value)?  $default,){
final _that = this;
switch (_that) {
case _SongStatistics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String stableId,  String title,  String author,  String coverUrl,  int playCount,  int totalPlayedMs,  int? firstPlayedAtEpochMs,  int? lastPlayedAtEpochMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SongStatistics() when $default != null:
return $default(_that.stableId,_that.title,_that.author,_that.coverUrl,_that.playCount,_that.totalPlayedMs,_that.firstPlayedAtEpochMs,_that.lastPlayedAtEpochMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String stableId,  String title,  String author,  String coverUrl,  int playCount,  int totalPlayedMs,  int? firstPlayedAtEpochMs,  int? lastPlayedAtEpochMs)  $default,) {final _that = this;
switch (_that) {
case _SongStatistics():
return $default(_that.stableId,_that.title,_that.author,_that.coverUrl,_that.playCount,_that.totalPlayedMs,_that.firstPlayedAtEpochMs,_that.lastPlayedAtEpochMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String stableId,  String title,  String author,  String coverUrl,  int playCount,  int totalPlayedMs,  int? firstPlayedAtEpochMs,  int? lastPlayedAtEpochMs)?  $default,) {final _that = this;
switch (_that) {
case _SongStatistics() when $default != null:
return $default(_that.stableId,_that.title,_that.author,_that.coverUrl,_that.playCount,_that.totalPlayedMs,_that.firstPlayedAtEpochMs,_that.lastPlayedAtEpochMs);case _:
  return null;

}
}

}

/// @nodoc


class _SongStatistics implements SongStatistics {
  const _SongStatistics({required this.stableId, this.title = '', this.author = '', this.coverUrl = '', this.playCount = 0, this.totalPlayedMs = 0, this.firstPlayedAtEpochMs, this.lastPlayedAtEpochMs});
  

@override final  String stableId;
@override@JsonKey() final  String title;
@override@JsonKey() final  String author;
@override@JsonKey() final  String coverUrl;
@override@JsonKey() final  int playCount;
@override@JsonKey() final  int totalPlayedMs;
@override final  int? firstPlayedAtEpochMs;
@override final  int? lastPlayedAtEpochMs;

/// Create a copy of SongStatistics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SongStatisticsCopyWith<_SongStatistics> get copyWith => __$SongStatisticsCopyWithImpl<_SongStatistics>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SongStatistics&&(identical(other.stableId, stableId) || other.stableId == stableId)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.playCount, playCount) || other.playCount == playCount)&&(identical(other.totalPlayedMs, totalPlayedMs) || other.totalPlayedMs == totalPlayedMs)&&(identical(other.firstPlayedAtEpochMs, firstPlayedAtEpochMs) || other.firstPlayedAtEpochMs == firstPlayedAtEpochMs)&&(identical(other.lastPlayedAtEpochMs, lastPlayedAtEpochMs) || other.lastPlayedAtEpochMs == lastPlayedAtEpochMs));
}


@override
int get hashCode => Object.hash(runtimeType,stableId,title,author,coverUrl,playCount,totalPlayedMs,firstPlayedAtEpochMs,lastPlayedAtEpochMs);

@override
String toString() {
  return 'SongStatistics(stableId: $stableId, title: $title, author: $author, coverUrl: $coverUrl, playCount: $playCount, totalPlayedMs: $totalPlayedMs, firstPlayedAtEpochMs: $firstPlayedAtEpochMs, lastPlayedAtEpochMs: $lastPlayedAtEpochMs)';
}


}

/// @nodoc
abstract mixin class _$SongStatisticsCopyWith<$Res> implements $SongStatisticsCopyWith<$Res> {
  factory _$SongStatisticsCopyWith(_SongStatistics value, $Res Function(_SongStatistics) _then) = __$SongStatisticsCopyWithImpl;
@override @useResult
$Res call({
 String stableId, String title, String author, String coverUrl, int playCount, int totalPlayedMs, int? firstPlayedAtEpochMs, int? lastPlayedAtEpochMs
});




}
/// @nodoc
class __$SongStatisticsCopyWithImpl<$Res>
    implements _$SongStatisticsCopyWith<$Res> {
  __$SongStatisticsCopyWithImpl(this._self, this._then);

  final _SongStatistics _self;
  final $Res Function(_SongStatistics) _then;

/// Create a copy of SongStatistics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stableId = null,Object? title = null,Object? author = null,Object? coverUrl = null,Object? playCount = null,Object? totalPlayedMs = null,Object? firstPlayedAtEpochMs = freezed,Object? lastPlayedAtEpochMs = freezed,}) {
  return _then(_SongStatistics(
stableId: null == stableId ? _self.stableId : stableId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,playCount: null == playCount ? _self.playCount : playCount // ignore: cast_nullable_to_non_nullable
as int,totalPlayedMs: null == totalPlayedMs ? _self.totalPlayedMs : totalPlayedMs // ignore: cast_nullable_to_non_nullable
as int,firstPlayedAtEpochMs: freezed == firstPlayedAtEpochMs ? _self.firstPlayedAtEpochMs : firstPlayedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int?,lastPlayedAtEpochMs: freezed == lastPlayedAtEpochMs ? _self.lastPlayedAtEpochMs : lastPlayedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
