// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'metadata_backfill_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MetadataBackfillState {

 bool get isRunning; int get processed; int get total; int get matched;
/// Create a copy of MetadataBackfillState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MetadataBackfillStateCopyWith<MetadataBackfillState> get copyWith => _$MetadataBackfillStateCopyWithImpl<MetadataBackfillState>(this as MetadataBackfillState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MetadataBackfillState&&(identical(other.isRunning, isRunning) || other.isRunning == isRunning)&&(identical(other.processed, processed) || other.processed == processed)&&(identical(other.total, total) || other.total == total)&&(identical(other.matched, matched) || other.matched == matched));
}


@override
int get hashCode => Object.hash(runtimeType,isRunning,processed,total,matched);

@override
String toString() {
  return 'MetadataBackfillState(isRunning: $isRunning, processed: $processed, total: $total, matched: $matched)';
}


}

/// @nodoc
abstract mixin class $MetadataBackfillStateCopyWith<$Res>  {
  factory $MetadataBackfillStateCopyWith(MetadataBackfillState value, $Res Function(MetadataBackfillState) _then) = _$MetadataBackfillStateCopyWithImpl;
@useResult
$Res call({
 bool isRunning, int processed, int total, int matched
});




}
/// @nodoc
class _$MetadataBackfillStateCopyWithImpl<$Res>
    implements $MetadataBackfillStateCopyWith<$Res> {
  _$MetadataBackfillStateCopyWithImpl(this._self, this._then);

  final MetadataBackfillState _self;
  final $Res Function(MetadataBackfillState) _then;

/// Create a copy of MetadataBackfillState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isRunning = null,Object? processed = null,Object? total = null,Object? matched = null,}) {
  return _then(_self.copyWith(
isRunning: null == isRunning ? _self.isRunning : isRunning // ignore: cast_nullable_to_non_nullable
as bool,processed: null == processed ? _self.processed : processed // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,matched: null == matched ? _self.matched : matched // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MetadataBackfillState].
extension MetadataBackfillStatePatterns on MetadataBackfillState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MetadataBackfillState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MetadataBackfillState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MetadataBackfillState value)  $default,){
final _that = this;
switch (_that) {
case _MetadataBackfillState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MetadataBackfillState value)?  $default,){
final _that = this;
switch (_that) {
case _MetadataBackfillState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isRunning,  int processed,  int total,  int matched)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MetadataBackfillState() when $default != null:
return $default(_that.isRunning,_that.processed,_that.total,_that.matched);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isRunning,  int processed,  int total,  int matched)  $default,) {final _that = this;
switch (_that) {
case _MetadataBackfillState():
return $default(_that.isRunning,_that.processed,_that.total,_that.matched);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isRunning,  int processed,  int total,  int matched)?  $default,) {final _that = this;
switch (_that) {
case _MetadataBackfillState() when $default != null:
return $default(_that.isRunning,_that.processed,_that.total,_that.matched);case _:
  return null;

}
}

}

/// @nodoc


class _MetadataBackfillState implements MetadataBackfillState {
  const _MetadataBackfillState({this.isRunning = false, this.processed = 0, this.total = 0, this.matched = 0});
  

@override@JsonKey() final  bool isRunning;
@override@JsonKey() final  int processed;
@override@JsonKey() final  int total;
@override@JsonKey() final  int matched;

/// Create a copy of MetadataBackfillState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MetadataBackfillStateCopyWith<_MetadataBackfillState> get copyWith => __$MetadataBackfillStateCopyWithImpl<_MetadataBackfillState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MetadataBackfillState&&(identical(other.isRunning, isRunning) || other.isRunning == isRunning)&&(identical(other.processed, processed) || other.processed == processed)&&(identical(other.total, total) || other.total == total)&&(identical(other.matched, matched) || other.matched == matched));
}


@override
int get hashCode => Object.hash(runtimeType,isRunning,processed,total,matched);

@override
String toString() {
  return 'MetadataBackfillState(isRunning: $isRunning, processed: $processed, total: $total, matched: $matched)';
}


}

/// @nodoc
abstract mixin class _$MetadataBackfillStateCopyWith<$Res> implements $MetadataBackfillStateCopyWith<$Res> {
  factory _$MetadataBackfillStateCopyWith(_MetadataBackfillState value, $Res Function(_MetadataBackfillState) _then) = __$MetadataBackfillStateCopyWithImpl;
@override @useResult
$Res call({
 bool isRunning, int processed, int total, int matched
});




}
/// @nodoc
class __$MetadataBackfillStateCopyWithImpl<$Res>
    implements _$MetadataBackfillStateCopyWith<$Res> {
  __$MetadataBackfillStateCopyWithImpl(this._self, this._then);

  final _MetadataBackfillState _self;
  final $Res Function(_MetadataBackfillState) _then;

/// Create a copy of MetadataBackfillState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isRunning = null,Object? processed = null,Object? total = null,Object? matched = null,}) {
  return _then(_MetadataBackfillState(
isRunning: null == isRunning ? _self.isRunning : isRunning // ignore: cast_nullable_to_non_nullable
as bool,processed: null == processed ? _self.processed : processed // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,matched: null == matched ? _self.matched : matched // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
