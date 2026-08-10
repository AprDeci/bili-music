// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playback_tracking_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlaybackTrackingState {

 String? get stableId; String get title; String get author; String get coverUrl; int get durationMs; int get playedMs; int get lastPositionMs; bool get isPlaying; bool get counted;
/// Create a copy of PlaybackTrackingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaybackTrackingStateCopyWith<PlaybackTrackingState> get copyWith => _$PlaybackTrackingStateCopyWithImpl<PlaybackTrackingState>(this as PlaybackTrackingState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaybackTrackingState&&(identical(other.stableId, stableId) || other.stableId == stableId)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.playedMs, playedMs) || other.playedMs == playedMs)&&(identical(other.lastPositionMs, lastPositionMs) || other.lastPositionMs == lastPositionMs)&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.counted, counted) || other.counted == counted));
}


@override
int get hashCode => Object.hash(runtimeType,stableId,title,author,coverUrl,durationMs,playedMs,lastPositionMs,isPlaying,counted);

@override
String toString() {
  return 'PlaybackTrackingState(stableId: $stableId, title: $title, author: $author, coverUrl: $coverUrl, durationMs: $durationMs, playedMs: $playedMs, lastPositionMs: $lastPositionMs, isPlaying: $isPlaying, counted: $counted)';
}


}

/// @nodoc
abstract mixin class $PlaybackTrackingStateCopyWith<$Res>  {
  factory $PlaybackTrackingStateCopyWith(PlaybackTrackingState value, $Res Function(PlaybackTrackingState) _then) = _$PlaybackTrackingStateCopyWithImpl;
@useResult
$Res call({
 String? stableId, String title, String author, String coverUrl, int durationMs, int playedMs, int lastPositionMs, bool isPlaying, bool counted
});




}
/// @nodoc
class _$PlaybackTrackingStateCopyWithImpl<$Res>
    implements $PlaybackTrackingStateCopyWith<$Res> {
  _$PlaybackTrackingStateCopyWithImpl(this._self, this._then);

  final PlaybackTrackingState _self;
  final $Res Function(PlaybackTrackingState) _then;

/// Create a copy of PlaybackTrackingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stableId = freezed,Object? title = null,Object? author = null,Object? coverUrl = null,Object? durationMs = null,Object? playedMs = null,Object? lastPositionMs = null,Object? isPlaying = null,Object? counted = null,}) {
  return _then(_self.copyWith(
stableId: freezed == stableId ? _self.stableId : stableId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,playedMs: null == playedMs ? _self.playedMs : playedMs // ignore: cast_nullable_to_non_nullable
as int,lastPositionMs: null == lastPositionMs ? _self.lastPositionMs : lastPositionMs // ignore: cast_nullable_to_non_nullable
as int,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,counted: null == counted ? _self.counted : counted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaybackTrackingState].
extension PlaybackTrackingStatePatterns on PlaybackTrackingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaybackTrackingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaybackTrackingState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaybackTrackingState value)  $default,){
final _that = this;
switch (_that) {
case _PlaybackTrackingState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaybackTrackingState value)?  $default,){
final _that = this;
switch (_that) {
case _PlaybackTrackingState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? stableId,  String title,  String author,  String coverUrl,  int durationMs,  int playedMs,  int lastPositionMs,  bool isPlaying,  bool counted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaybackTrackingState() when $default != null:
return $default(_that.stableId,_that.title,_that.author,_that.coverUrl,_that.durationMs,_that.playedMs,_that.lastPositionMs,_that.isPlaying,_that.counted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? stableId,  String title,  String author,  String coverUrl,  int durationMs,  int playedMs,  int lastPositionMs,  bool isPlaying,  bool counted)  $default,) {final _that = this;
switch (_that) {
case _PlaybackTrackingState():
return $default(_that.stableId,_that.title,_that.author,_that.coverUrl,_that.durationMs,_that.playedMs,_that.lastPositionMs,_that.isPlaying,_that.counted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? stableId,  String title,  String author,  String coverUrl,  int durationMs,  int playedMs,  int lastPositionMs,  bool isPlaying,  bool counted)?  $default,) {final _that = this;
switch (_that) {
case _PlaybackTrackingState() when $default != null:
return $default(_that.stableId,_that.title,_that.author,_that.coverUrl,_that.durationMs,_that.playedMs,_that.lastPositionMs,_that.isPlaying,_that.counted);case _:
  return null;

}
}

}

/// @nodoc


class _PlaybackTrackingState implements PlaybackTrackingState {
  const _PlaybackTrackingState({this.stableId, this.title = '', this.author = '', this.coverUrl = '', this.durationMs = 0, this.playedMs = 0, this.lastPositionMs = 0, this.isPlaying = false, this.counted = false});
  

@override final  String? stableId;
@override@JsonKey() final  String title;
@override@JsonKey() final  String author;
@override@JsonKey() final  String coverUrl;
@override@JsonKey() final  int durationMs;
@override@JsonKey() final  int playedMs;
@override@JsonKey() final  int lastPositionMs;
@override@JsonKey() final  bool isPlaying;
@override@JsonKey() final  bool counted;

/// Create a copy of PlaybackTrackingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaybackTrackingStateCopyWith<_PlaybackTrackingState> get copyWith => __$PlaybackTrackingStateCopyWithImpl<_PlaybackTrackingState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaybackTrackingState&&(identical(other.stableId, stableId) || other.stableId == stableId)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.playedMs, playedMs) || other.playedMs == playedMs)&&(identical(other.lastPositionMs, lastPositionMs) || other.lastPositionMs == lastPositionMs)&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.counted, counted) || other.counted == counted));
}


@override
int get hashCode => Object.hash(runtimeType,stableId,title,author,coverUrl,durationMs,playedMs,lastPositionMs,isPlaying,counted);

@override
String toString() {
  return 'PlaybackTrackingState(stableId: $stableId, title: $title, author: $author, coverUrl: $coverUrl, durationMs: $durationMs, playedMs: $playedMs, lastPositionMs: $lastPositionMs, isPlaying: $isPlaying, counted: $counted)';
}


}

/// @nodoc
abstract mixin class _$PlaybackTrackingStateCopyWith<$Res> implements $PlaybackTrackingStateCopyWith<$Res> {
  factory _$PlaybackTrackingStateCopyWith(_PlaybackTrackingState value, $Res Function(_PlaybackTrackingState) _then) = __$PlaybackTrackingStateCopyWithImpl;
@override @useResult
$Res call({
 String? stableId, String title, String author, String coverUrl, int durationMs, int playedMs, int lastPositionMs, bool isPlaying, bool counted
});




}
/// @nodoc
class __$PlaybackTrackingStateCopyWithImpl<$Res>
    implements _$PlaybackTrackingStateCopyWith<$Res> {
  __$PlaybackTrackingStateCopyWithImpl(this._self, this._then);

  final _PlaybackTrackingState _self;
  final $Res Function(_PlaybackTrackingState) _then;

/// Create a copy of PlaybackTrackingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stableId = freezed,Object? title = null,Object? author = null,Object? coverUrl = null,Object? durationMs = null,Object? playedMs = null,Object? lastPositionMs = null,Object? isPlaying = null,Object? counted = null,}) {
  return _then(_PlaybackTrackingState(
stableId: freezed == stableId ? _self.stableId : stableId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,playedMs: null == playedMs ? _self.playedMs : playedMs // ignore: cast_nullable_to_non_nullable
as int,lastPositionMs: null == lastPositionMs ? _self.lastPositionMs : lastPositionMs // ignore: cast_nullable_to_non_nullable
as int,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,counted: null == counted ? _self.counted : counted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
