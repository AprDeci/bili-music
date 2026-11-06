// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playback_chapter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlaybackChapter {

 Duration get start; Duration? get end; String get title;
/// Create a copy of PlaybackChapter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaybackChapterCopyWith<PlaybackChapter> get copyWith => _$PlaybackChapterCopyWithImpl<PlaybackChapter>(this as PlaybackChapter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaybackChapter&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.title, title) || other.title == title));
}


@override
int get hashCode => Object.hash(runtimeType,start,end,title);

@override
String toString() {
  return 'PlaybackChapter(start: $start, end: $end, title: $title)';
}


}

/// @nodoc
abstract mixin class $PlaybackChapterCopyWith<$Res>  {
  factory $PlaybackChapterCopyWith(PlaybackChapter value, $Res Function(PlaybackChapter) _then) = _$PlaybackChapterCopyWithImpl;
@useResult
$Res call({
 Duration start, Duration? end, String title
});




}
/// @nodoc
class _$PlaybackChapterCopyWithImpl<$Res>
    implements $PlaybackChapterCopyWith<$Res> {
  _$PlaybackChapterCopyWithImpl(this._self, this._then);

  final PlaybackChapter _self;
  final $Res Function(PlaybackChapter) _then;

/// Create a copy of PlaybackChapter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? start = null,Object? end = freezed,Object? title = null,}) {
  return _then(_self.copyWith(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as Duration,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as Duration?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaybackChapter].
extension PlaybackChapterPatterns on PlaybackChapter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaybackChapter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaybackChapter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaybackChapter value)  $default,){
final _that = this;
switch (_that) {
case _PlaybackChapter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaybackChapter value)?  $default,){
final _that = this;
switch (_that) {
case _PlaybackChapter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Duration start,  Duration? end,  String title)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaybackChapter() when $default != null:
return $default(_that.start,_that.end,_that.title);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Duration start,  Duration? end,  String title)  $default,) {final _that = this;
switch (_that) {
case _PlaybackChapter():
return $default(_that.start,_that.end,_that.title);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Duration start,  Duration? end,  String title)?  $default,) {final _that = this;
switch (_that) {
case _PlaybackChapter() when $default != null:
return $default(_that.start,_that.end,_that.title);case _:
  return null;

}
}

}

/// @nodoc


class _PlaybackChapter implements PlaybackChapter {
  const _PlaybackChapter({required this.start, this.end, required this.title});
  

@override final  Duration start;
@override final  Duration? end;
@override final  String title;

/// Create a copy of PlaybackChapter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaybackChapterCopyWith<_PlaybackChapter> get copyWith => __$PlaybackChapterCopyWithImpl<_PlaybackChapter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaybackChapter&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.title, title) || other.title == title));
}


@override
int get hashCode => Object.hash(runtimeType,start,end,title);

@override
String toString() {
  return 'PlaybackChapter(start: $start, end: $end, title: $title)';
}


}

/// @nodoc
abstract mixin class _$PlaybackChapterCopyWith<$Res> implements $PlaybackChapterCopyWith<$Res> {
  factory _$PlaybackChapterCopyWith(_PlaybackChapter value, $Res Function(_PlaybackChapter) _then) = __$PlaybackChapterCopyWithImpl;
@override @useResult
$Res call({
 Duration start, Duration? end, String title
});




}
/// @nodoc
class __$PlaybackChapterCopyWithImpl<$Res>
    implements _$PlaybackChapterCopyWith<$Res> {
  __$PlaybackChapterCopyWithImpl(this._self, this._then);

  final _PlaybackChapter _self;
  final $Res Function(_PlaybackChapter) _then;

/// Create a copy of PlaybackChapter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? start = null,Object? end = freezed,Object? title = null,}) {
  return _then(_PlaybackChapter(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as Duration,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as Duration?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
