// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recent_playback_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecentPlaybackEntry {

 int get aid; String get bvid; String get title; String get author; String get coverUrl; int? get cid; String? get pageTitle; int get playedAtEpochMs;
/// Create a copy of RecentPlaybackEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecentPlaybackEntryCopyWith<RecentPlaybackEntry> get copyWith => _$RecentPlaybackEntryCopyWithImpl<RecentPlaybackEntry>(this as RecentPlaybackEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecentPlaybackEntry&&(identical(other.aid, aid) || other.aid == aid)&&(identical(other.bvid, bvid) || other.bvid == bvid)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.pageTitle, pageTitle) || other.pageTitle == pageTitle)&&(identical(other.playedAtEpochMs, playedAtEpochMs) || other.playedAtEpochMs == playedAtEpochMs));
}


@override
int get hashCode => Object.hash(runtimeType,aid,bvid,title,author,coverUrl,cid,pageTitle,playedAtEpochMs);

@override
String toString() {
  return 'RecentPlaybackEntry(aid: $aid, bvid: $bvid, title: $title, author: $author, coverUrl: $coverUrl, cid: $cid, pageTitle: $pageTitle, playedAtEpochMs: $playedAtEpochMs)';
}


}

/// @nodoc
abstract mixin class $RecentPlaybackEntryCopyWith<$Res>  {
  factory $RecentPlaybackEntryCopyWith(RecentPlaybackEntry value, $Res Function(RecentPlaybackEntry) _then) = _$RecentPlaybackEntryCopyWithImpl;
@useResult
$Res call({
 int aid, String bvid, String title, String author, String coverUrl, int? cid, String? pageTitle, int playedAtEpochMs
});




}
/// @nodoc
class _$RecentPlaybackEntryCopyWithImpl<$Res>
    implements $RecentPlaybackEntryCopyWith<$Res> {
  _$RecentPlaybackEntryCopyWithImpl(this._self, this._then);

  final RecentPlaybackEntry _self;
  final $Res Function(RecentPlaybackEntry) _then;

/// Create a copy of RecentPlaybackEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? aid = null,Object? bvid = null,Object? title = null,Object? author = null,Object? coverUrl = null,Object? cid = freezed,Object? pageTitle = freezed,Object? playedAtEpochMs = null,}) {
  return _then(_self.copyWith(
aid: null == aid ? _self.aid : aid // ignore: cast_nullable_to_non_nullable
as int,bvid: null == bvid ? _self.bvid : bvid // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,cid: freezed == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as int?,pageTitle: freezed == pageTitle ? _self.pageTitle : pageTitle // ignore: cast_nullable_to_non_nullable
as String?,playedAtEpochMs: null == playedAtEpochMs ? _self.playedAtEpochMs : playedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RecentPlaybackEntry].
extension RecentPlaybackEntryPatterns on RecentPlaybackEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecentPlaybackEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecentPlaybackEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecentPlaybackEntry value)  $default,){
final _that = this;
switch (_that) {
case _RecentPlaybackEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecentPlaybackEntry value)?  $default,){
final _that = this;
switch (_that) {
case _RecentPlaybackEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int aid,  String bvid,  String title,  String author,  String coverUrl,  int? cid,  String? pageTitle,  int playedAtEpochMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecentPlaybackEntry() when $default != null:
return $default(_that.aid,_that.bvid,_that.title,_that.author,_that.coverUrl,_that.cid,_that.pageTitle,_that.playedAtEpochMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int aid,  String bvid,  String title,  String author,  String coverUrl,  int? cid,  String? pageTitle,  int playedAtEpochMs)  $default,) {final _that = this;
switch (_that) {
case _RecentPlaybackEntry():
return $default(_that.aid,_that.bvid,_that.title,_that.author,_that.coverUrl,_that.cid,_that.pageTitle,_that.playedAtEpochMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int aid,  String bvid,  String title,  String author,  String coverUrl,  int? cid,  String? pageTitle,  int playedAtEpochMs)?  $default,) {final _that = this;
switch (_that) {
case _RecentPlaybackEntry() when $default != null:
return $default(_that.aid,_that.bvid,_that.title,_that.author,_that.coverUrl,_that.cid,_that.pageTitle,_that.playedAtEpochMs);case _:
  return null;

}
}

}

/// @nodoc


class _RecentPlaybackEntry extends RecentPlaybackEntry {
  const _RecentPlaybackEntry({required this.aid, required this.bvid, required this.title, required this.author, required this.coverUrl, this.cid, this.pageTitle, required this.playedAtEpochMs}): super._();
  

@override final  int aid;
@override final  String bvid;
@override final  String title;
@override final  String author;
@override final  String coverUrl;
@override final  int? cid;
@override final  String? pageTitle;
@override final  int playedAtEpochMs;

/// Create a copy of RecentPlaybackEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecentPlaybackEntryCopyWith<_RecentPlaybackEntry> get copyWith => __$RecentPlaybackEntryCopyWithImpl<_RecentPlaybackEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecentPlaybackEntry&&(identical(other.aid, aid) || other.aid == aid)&&(identical(other.bvid, bvid) || other.bvid == bvid)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.pageTitle, pageTitle) || other.pageTitle == pageTitle)&&(identical(other.playedAtEpochMs, playedAtEpochMs) || other.playedAtEpochMs == playedAtEpochMs));
}


@override
int get hashCode => Object.hash(runtimeType,aid,bvid,title,author,coverUrl,cid,pageTitle,playedAtEpochMs);

@override
String toString() {
  return 'RecentPlaybackEntry(aid: $aid, bvid: $bvid, title: $title, author: $author, coverUrl: $coverUrl, cid: $cid, pageTitle: $pageTitle, playedAtEpochMs: $playedAtEpochMs)';
}


}

/// @nodoc
abstract mixin class _$RecentPlaybackEntryCopyWith<$Res> implements $RecentPlaybackEntryCopyWith<$Res> {
  factory _$RecentPlaybackEntryCopyWith(_RecentPlaybackEntry value, $Res Function(_RecentPlaybackEntry) _then) = __$RecentPlaybackEntryCopyWithImpl;
@override @useResult
$Res call({
 int aid, String bvid, String title, String author, String coverUrl, int? cid, String? pageTitle, int playedAtEpochMs
});




}
/// @nodoc
class __$RecentPlaybackEntryCopyWithImpl<$Res>
    implements _$RecentPlaybackEntryCopyWith<$Res> {
  __$RecentPlaybackEntryCopyWithImpl(this._self, this._then);

  final _RecentPlaybackEntry _self;
  final $Res Function(_RecentPlaybackEntry) _then;

/// Create a copy of RecentPlaybackEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? aid = null,Object? bvid = null,Object? title = null,Object? author = null,Object? coverUrl = null,Object? cid = freezed,Object? pageTitle = freezed,Object? playedAtEpochMs = null,}) {
  return _then(_RecentPlaybackEntry(
aid: null == aid ? _self.aid : aid // ignore: cast_nullable_to_non_nullable
as int,bvid: null == bvid ? _self.bvid : bvid // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,cid: freezed == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as int?,pageTitle: freezed == pageTitle ? _self.pageTitle : pageTitle // ignore: cast_nullable_to_non_nullable
as String?,playedAtEpochMs: null == playedAtEpochMs ? _self.playedAtEpochMs : playedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
