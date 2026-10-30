// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listening_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ListeningState {

 String? get warning; ListeningProgress? get localConflict; ListeningProgress? get remoteConflict;
/// Create a copy of ListeningState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListeningStateCopyWith<ListeningState> get copyWith => _$ListeningStateCopyWithImpl<ListeningState>(this as ListeningState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListeningState&&(identical(other.warning, warning) || other.warning == warning)&&(identical(other.localConflict, localConflict) || other.localConflict == localConflict)&&(identical(other.remoteConflict, remoteConflict) || other.remoteConflict == remoteConflict));
}


@override
int get hashCode => Object.hash(runtimeType,warning,localConflict,remoteConflict);

@override
String toString() {
  return 'ListeningState(warning: $warning, localConflict: $localConflict, remoteConflict: $remoteConflict)';
}


}

/// @nodoc
abstract mixin class $ListeningStateCopyWith<$Res>  {
  factory $ListeningStateCopyWith(ListeningState value, $Res Function(ListeningState) _then) = _$ListeningStateCopyWithImpl;
@useResult
$Res call({
 String? warning, ListeningProgress? localConflict, ListeningProgress? remoteConflict
});


$ListeningProgressCopyWith<$Res>? get localConflict;$ListeningProgressCopyWith<$Res>? get remoteConflict;

}
/// @nodoc
class _$ListeningStateCopyWithImpl<$Res>
    implements $ListeningStateCopyWith<$Res> {
  _$ListeningStateCopyWithImpl(this._self, this._then);

  final ListeningState _self;
  final $Res Function(ListeningState) _then;

/// Create a copy of ListeningState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? warning = freezed,Object? localConflict = freezed,Object? remoteConflict = freezed,}) {
  return _then(_self.copyWith(
warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as String?,localConflict: freezed == localConflict ? _self.localConflict : localConflict // ignore: cast_nullable_to_non_nullable
as ListeningProgress?,remoteConflict: freezed == remoteConflict ? _self.remoteConflict : remoteConflict // ignore: cast_nullable_to_non_nullable
as ListeningProgress?,
  ));
}
/// Create a copy of ListeningState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListeningProgressCopyWith<$Res>? get localConflict {
    if (_self.localConflict == null) {
    return null;
  }

  return $ListeningProgressCopyWith<$Res>(_self.localConflict!, (value) {
    return _then(_self.copyWith(localConflict: value));
  });
}/// Create a copy of ListeningState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListeningProgressCopyWith<$Res>? get remoteConflict {
    if (_self.remoteConflict == null) {
    return null;
  }

  return $ListeningProgressCopyWith<$Res>(_self.remoteConflict!, (value) {
    return _then(_self.copyWith(remoteConflict: value));
  });
}
}


/// Adds pattern-matching-related methods to [ListeningState].
extension ListeningStatePatterns on ListeningState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListeningState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListeningState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListeningState value)  $default,){
final _that = this;
switch (_that) {
case _ListeningState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListeningState value)?  $default,){
final _that = this;
switch (_that) {
case _ListeningState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? warning,  ListeningProgress? localConflict,  ListeningProgress? remoteConflict)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListeningState() when $default != null:
return $default(_that.warning,_that.localConflict,_that.remoteConflict);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? warning,  ListeningProgress? localConflict,  ListeningProgress? remoteConflict)  $default,) {final _that = this;
switch (_that) {
case _ListeningState():
return $default(_that.warning,_that.localConflict,_that.remoteConflict);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? warning,  ListeningProgress? localConflict,  ListeningProgress? remoteConflict)?  $default,) {final _that = this;
switch (_that) {
case _ListeningState() when $default != null:
return $default(_that.warning,_that.localConflict,_that.remoteConflict);case _:
  return null;

}
}

}

/// @nodoc


class _ListeningState implements ListeningState {
  const _ListeningState({this.warning, this.localConflict, this.remoteConflict});
  

@override final  String? warning;
@override final  ListeningProgress? localConflict;
@override final  ListeningProgress? remoteConflict;

/// Create a copy of ListeningState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListeningStateCopyWith<_ListeningState> get copyWith => __$ListeningStateCopyWithImpl<_ListeningState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListeningState&&(identical(other.warning, warning) || other.warning == warning)&&(identical(other.localConflict, localConflict) || other.localConflict == localConflict)&&(identical(other.remoteConflict, remoteConflict) || other.remoteConflict == remoteConflict));
}


@override
int get hashCode => Object.hash(runtimeType,warning,localConflict,remoteConflict);

@override
String toString() {
  return 'ListeningState(warning: $warning, localConflict: $localConflict, remoteConflict: $remoteConflict)';
}


}

/// @nodoc
abstract mixin class _$ListeningStateCopyWith<$Res> implements $ListeningStateCopyWith<$Res> {
  factory _$ListeningStateCopyWith(_ListeningState value, $Res Function(_ListeningState) _then) = __$ListeningStateCopyWithImpl;
@override @useResult
$Res call({
 String? warning, ListeningProgress? localConflict, ListeningProgress? remoteConflict
});


@override $ListeningProgressCopyWith<$Res>? get localConflict;@override $ListeningProgressCopyWith<$Res>? get remoteConflict;

}
/// @nodoc
class __$ListeningStateCopyWithImpl<$Res>
    implements _$ListeningStateCopyWith<$Res> {
  __$ListeningStateCopyWithImpl(this._self, this._then);

  final _ListeningState _self;
  final $Res Function(_ListeningState) _then;

/// Create a copy of ListeningState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? warning = freezed,Object? localConflict = freezed,Object? remoteConflict = freezed,}) {
  return _then(_ListeningState(
warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as String?,localConflict: freezed == localConflict ? _self.localConflict : localConflict // ignore: cast_nullable_to_non_nullable
as ListeningProgress?,remoteConflict: freezed == remoteConflict ? _self.remoteConflict : remoteConflict // ignore: cast_nullable_to_non_nullable
as ListeningProgress?,
  ));
}

/// Create a copy of ListeningState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListeningProgressCopyWith<$Res>? get localConflict {
    if (_self.localConflict == null) {
    return null;
  }

  return $ListeningProgressCopyWith<$Res>(_self.localConflict!, (value) {
    return _then(_self.copyWith(localConflict: value));
  });
}/// Create a copy of ListeningState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListeningProgressCopyWith<$Res>? get remoteConflict {
    if (_self.remoteConflict == null) {
    return null;
  }

  return $ListeningProgressCopyWith<$Res>(_self.remoteConflict!, (value) {
    return _then(_self.copyWith(remoteConflict: value));
  });
}
}

// dart format on
