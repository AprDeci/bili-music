// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'updater_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpdaterState {

 UpdatePhase get phase; int get totalBytes; String? get mirrorHost;
/// Create a copy of UpdaterState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdaterStateCopyWith<UpdaterState> get copyWith => _$UpdaterStateCopyWithImpl<UpdaterState>(this as UpdaterState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdaterState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes)&&(identical(other.mirrorHost, mirrorHost) || other.mirrorHost == mirrorHost));
}


@override
int get hashCode => Object.hash(runtimeType,phase,totalBytes,mirrorHost);

@override
String toString() {
  return 'UpdaterState(phase: $phase, totalBytes: $totalBytes, mirrorHost: $mirrorHost)';
}


}

/// @nodoc
abstract mixin class $UpdaterStateCopyWith<$Res>  {
  factory $UpdaterStateCopyWith(UpdaterState value, $Res Function(UpdaterState) _then) = _$UpdaterStateCopyWithImpl;
@useResult
$Res call({
 UpdatePhase phase, int totalBytes, String? mirrorHost
});




}
/// @nodoc
class _$UpdaterStateCopyWithImpl<$Res>
    implements $UpdaterStateCopyWith<$Res> {
  _$UpdaterStateCopyWithImpl(this._self, this._then);

  final UpdaterState _self;
  final $Res Function(UpdaterState) _then;

/// Create a copy of UpdaterState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phase = null,Object? totalBytes = null,Object? mirrorHost = freezed,}) {
  return _then(_self.copyWith(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as UpdatePhase,totalBytes: null == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as int,mirrorHost: freezed == mirrorHost ? _self.mirrorHost : mirrorHost // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdaterState].
extension UpdaterStatePatterns on UpdaterState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdaterState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdaterState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdaterState value)  $default,){
final _that = this;
switch (_that) {
case _UpdaterState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdaterState value)?  $default,){
final _that = this;
switch (_that) {
case _UpdaterState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UpdatePhase phase,  int totalBytes,  String? mirrorHost)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdaterState() when $default != null:
return $default(_that.phase,_that.totalBytes,_that.mirrorHost);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UpdatePhase phase,  int totalBytes,  String? mirrorHost)  $default,) {final _that = this;
switch (_that) {
case _UpdaterState():
return $default(_that.phase,_that.totalBytes,_that.mirrorHost);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UpdatePhase phase,  int totalBytes,  String? mirrorHost)?  $default,) {final _that = this;
switch (_that) {
case _UpdaterState() when $default != null:
return $default(_that.phase,_that.totalBytes,_that.mirrorHost);case _:
  return null;

}
}

}

/// @nodoc


class _UpdaterState extends UpdaterState {
  const _UpdaterState({this.phase = UpdatePhase.idle, this.totalBytes = 0, this.mirrorHost}): super._();
  

@override@JsonKey() final  UpdatePhase phase;
@override@JsonKey() final  int totalBytes;
@override final  String? mirrorHost;

/// Create a copy of UpdaterState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdaterStateCopyWith<_UpdaterState> get copyWith => __$UpdaterStateCopyWithImpl<_UpdaterState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdaterState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes)&&(identical(other.mirrorHost, mirrorHost) || other.mirrorHost == mirrorHost));
}


@override
int get hashCode => Object.hash(runtimeType,phase,totalBytes,mirrorHost);

@override
String toString() {
  return 'UpdaterState(phase: $phase, totalBytes: $totalBytes, mirrorHost: $mirrorHost)';
}


}

/// @nodoc
abstract mixin class _$UpdaterStateCopyWith<$Res> implements $UpdaterStateCopyWith<$Res> {
  factory _$UpdaterStateCopyWith(_UpdaterState value, $Res Function(_UpdaterState) _then) = __$UpdaterStateCopyWithImpl;
@override @useResult
$Res call({
 UpdatePhase phase, int totalBytes, String? mirrorHost
});




}
/// @nodoc
class __$UpdaterStateCopyWithImpl<$Res>
    implements _$UpdaterStateCopyWith<$Res> {
  __$UpdaterStateCopyWithImpl(this._self, this._then);

  final _UpdaterState _self;
  final $Res Function(_UpdaterState) _then;

/// Create a copy of UpdaterState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? totalBytes = null,Object? mirrorHost = freezed,}) {
  return _then(_UpdaterState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as UpdatePhase,totalBytes: null == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as int,mirrorHost: freezed == mirrorHost ? _self.mirrorHost : mirrorHost // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
