// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_display_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlayerDisplayInfo {

 String? get stableId; String? get title; String? get artist; String? get coverUrl; PlayerDisplaySource get source; bool get canToggleSource; int? get artistUpMid;
/// Create a copy of PlayerDisplayInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerDisplayInfoCopyWith<PlayerDisplayInfo> get copyWith => _$PlayerDisplayInfoCopyWithImpl<PlayerDisplayInfo>(this as PlayerDisplayInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerDisplayInfo&&(identical(other.stableId, stableId) || other.stableId == stableId)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.source, source) || other.source == source)&&(identical(other.canToggleSource, canToggleSource) || other.canToggleSource == canToggleSource)&&(identical(other.artistUpMid, artistUpMid) || other.artistUpMid == artistUpMid));
}


@override
int get hashCode => Object.hash(runtimeType,stableId,title,artist,coverUrl,source,canToggleSource,artistUpMid);

@override
String toString() {
  return 'PlayerDisplayInfo(stableId: $stableId, title: $title, artist: $artist, coverUrl: $coverUrl, source: $source, canToggleSource: $canToggleSource, artistUpMid: $artistUpMid)';
}


}

/// @nodoc
abstract mixin class $PlayerDisplayInfoCopyWith<$Res>  {
  factory $PlayerDisplayInfoCopyWith(PlayerDisplayInfo value, $Res Function(PlayerDisplayInfo) _then) = _$PlayerDisplayInfoCopyWithImpl;
@useResult
$Res call({
 String? stableId, String? title, String? artist, String? coverUrl, PlayerDisplaySource source, bool canToggleSource, int? artistUpMid
});




}
/// @nodoc
class _$PlayerDisplayInfoCopyWithImpl<$Res>
    implements $PlayerDisplayInfoCopyWith<$Res> {
  _$PlayerDisplayInfoCopyWithImpl(this._self, this._then);

  final PlayerDisplayInfo _self;
  final $Res Function(PlayerDisplayInfo) _then;

/// Create a copy of PlayerDisplayInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stableId = freezed,Object? title = freezed,Object? artist = freezed,Object? coverUrl = freezed,Object? source = null,Object? canToggleSource = null,Object? artistUpMid = freezed,}) {
  return _then(_self.copyWith(
stableId: freezed == stableId ? _self.stableId : stableId // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,artist: freezed == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as PlayerDisplaySource,canToggleSource: null == canToggleSource ? _self.canToggleSource : canToggleSource // ignore: cast_nullable_to_non_nullable
as bool,artistUpMid: freezed == artistUpMid ? _self.artistUpMid : artistUpMid // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayerDisplayInfo].
extension PlayerDisplayInfoPatterns on PlayerDisplayInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerDisplayInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerDisplayInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerDisplayInfo value)  $default,){
final _that = this;
switch (_that) {
case _PlayerDisplayInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerDisplayInfo value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerDisplayInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? stableId,  String? title,  String? artist,  String? coverUrl,  PlayerDisplaySource source,  bool canToggleSource,  int? artistUpMid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerDisplayInfo() when $default != null:
return $default(_that.stableId,_that.title,_that.artist,_that.coverUrl,_that.source,_that.canToggleSource,_that.artistUpMid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? stableId,  String? title,  String? artist,  String? coverUrl,  PlayerDisplaySource source,  bool canToggleSource,  int? artistUpMid)  $default,) {final _that = this;
switch (_that) {
case _PlayerDisplayInfo():
return $default(_that.stableId,_that.title,_that.artist,_that.coverUrl,_that.source,_that.canToggleSource,_that.artistUpMid);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? stableId,  String? title,  String? artist,  String? coverUrl,  PlayerDisplaySource source,  bool canToggleSource,  int? artistUpMid)?  $default,) {final _that = this;
switch (_that) {
case _PlayerDisplayInfo() when $default != null:
return $default(_that.stableId,_that.title,_that.artist,_that.coverUrl,_that.source,_that.canToggleSource,_that.artistUpMid);case _:
  return null;

}
}

}

/// @nodoc


class _PlayerDisplayInfo implements PlayerDisplayInfo {
  const _PlayerDisplayInfo({this.stableId, this.title, this.artist, this.coverUrl, this.source = PlayerDisplaySource.metadata, this.canToggleSource = false, this.artistUpMid});
  

@override final  String? stableId;
@override final  String? title;
@override final  String? artist;
@override final  String? coverUrl;
@override@JsonKey() final  PlayerDisplaySource source;
@override@JsonKey() final  bool canToggleSource;
@override final  int? artistUpMid;

/// Create a copy of PlayerDisplayInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerDisplayInfoCopyWith<_PlayerDisplayInfo> get copyWith => __$PlayerDisplayInfoCopyWithImpl<_PlayerDisplayInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerDisplayInfo&&(identical(other.stableId, stableId) || other.stableId == stableId)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.source, source) || other.source == source)&&(identical(other.canToggleSource, canToggleSource) || other.canToggleSource == canToggleSource)&&(identical(other.artistUpMid, artistUpMid) || other.artistUpMid == artistUpMid));
}


@override
int get hashCode => Object.hash(runtimeType,stableId,title,artist,coverUrl,source,canToggleSource,artistUpMid);

@override
String toString() {
  return 'PlayerDisplayInfo(stableId: $stableId, title: $title, artist: $artist, coverUrl: $coverUrl, source: $source, canToggleSource: $canToggleSource, artistUpMid: $artistUpMid)';
}


}

/// @nodoc
abstract mixin class _$PlayerDisplayInfoCopyWith<$Res> implements $PlayerDisplayInfoCopyWith<$Res> {
  factory _$PlayerDisplayInfoCopyWith(_PlayerDisplayInfo value, $Res Function(_PlayerDisplayInfo) _then) = __$PlayerDisplayInfoCopyWithImpl;
@override @useResult
$Res call({
 String? stableId, String? title, String? artist, String? coverUrl, PlayerDisplaySource source, bool canToggleSource, int? artistUpMid
});




}
/// @nodoc
class __$PlayerDisplayInfoCopyWithImpl<$Res>
    implements _$PlayerDisplayInfoCopyWith<$Res> {
  __$PlayerDisplayInfoCopyWithImpl(this._self, this._then);

  final _PlayerDisplayInfo _self;
  final $Res Function(_PlayerDisplayInfo) _then;

/// Create a copy of PlayerDisplayInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stableId = freezed,Object? title = freezed,Object? artist = freezed,Object? coverUrl = freezed,Object? source = null,Object? canToggleSource = null,Object? artistUpMid = freezed,}) {
  return _then(_PlayerDisplayInfo(
stableId: freezed == stableId ? _self.stableId : stableId // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,artist: freezed == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as PlayerDisplaySource,canToggleSource: null == canToggleSource ? _self.canToggleSource : canToggleSource // ignore: cast_nullable_to_non_nullable
as bool,artistUpMid: freezed == artistUpMid ? _self.artistUpMid : artistUpMid // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
