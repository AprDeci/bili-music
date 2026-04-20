// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_lyrics_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlayerLyricsState {

 String? get stableId; String? get rawLyrics; String? get errorMessage; bool get isLoading; bool get hasSearched;
/// Create a copy of PlayerLyricsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerLyricsStateCopyWith<PlayerLyricsState> get copyWith => _$PlayerLyricsStateCopyWithImpl<PlayerLyricsState>(this as PlayerLyricsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerLyricsState&&(identical(other.stableId, stableId) || other.stableId == stableId)&&(identical(other.rawLyrics, rawLyrics) || other.rawLyrics == rawLyrics)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.hasSearched, hasSearched) || other.hasSearched == hasSearched));
}


@override
int get hashCode => Object.hash(runtimeType,stableId,rawLyrics,errorMessage,isLoading,hasSearched);

@override
String toString() {
  return 'PlayerLyricsState(stableId: $stableId, rawLyrics: $rawLyrics, errorMessage: $errorMessage, isLoading: $isLoading, hasSearched: $hasSearched)';
}


}

/// @nodoc
abstract mixin class $PlayerLyricsStateCopyWith<$Res>  {
  factory $PlayerLyricsStateCopyWith(PlayerLyricsState value, $Res Function(PlayerLyricsState) _then) = _$PlayerLyricsStateCopyWithImpl;
@useResult
$Res call({
 String? stableId, String? rawLyrics, String? errorMessage, bool isLoading, bool hasSearched
});




}
/// @nodoc
class _$PlayerLyricsStateCopyWithImpl<$Res>
    implements $PlayerLyricsStateCopyWith<$Res> {
  _$PlayerLyricsStateCopyWithImpl(this._self, this._then);

  final PlayerLyricsState _self;
  final $Res Function(PlayerLyricsState) _then;

/// Create a copy of PlayerLyricsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stableId = freezed,Object? rawLyrics = freezed,Object? errorMessage = freezed,Object? isLoading = null,Object? hasSearched = null,}) {
  return _then(_self.copyWith(
stableId: freezed == stableId ? _self.stableId : stableId // ignore: cast_nullable_to_non_nullable
as String?,rawLyrics: freezed == rawLyrics ? _self.rawLyrics : rawLyrics // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,hasSearched: null == hasSearched ? _self.hasSearched : hasSearched // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayerLyricsState].
extension PlayerLyricsStatePatterns on PlayerLyricsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerLyricsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerLyricsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerLyricsState value)  $default,){
final _that = this;
switch (_that) {
case _PlayerLyricsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerLyricsState value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerLyricsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? stableId,  String? rawLyrics,  String? errorMessage,  bool isLoading,  bool hasSearched)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerLyricsState() when $default != null:
return $default(_that.stableId,_that.rawLyrics,_that.errorMessage,_that.isLoading,_that.hasSearched);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? stableId,  String? rawLyrics,  String? errorMessage,  bool isLoading,  bool hasSearched)  $default,) {final _that = this;
switch (_that) {
case _PlayerLyricsState():
return $default(_that.stableId,_that.rawLyrics,_that.errorMessage,_that.isLoading,_that.hasSearched);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? stableId,  String? rawLyrics,  String? errorMessage,  bool isLoading,  bool hasSearched)?  $default,) {final _that = this;
switch (_that) {
case _PlayerLyricsState() when $default != null:
return $default(_that.stableId,_that.rawLyrics,_that.errorMessage,_that.isLoading,_that.hasSearched);case _:
  return null;

}
}

}

/// @nodoc


class _PlayerLyricsState extends PlayerLyricsState {
  const _PlayerLyricsState({this.stableId, this.rawLyrics, this.errorMessage, this.isLoading = false, this.hasSearched = false}): super._();
  

@override final  String? stableId;
@override final  String? rawLyrics;
@override final  String? errorMessage;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool hasSearched;

/// Create a copy of PlayerLyricsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerLyricsStateCopyWith<_PlayerLyricsState> get copyWith => __$PlayerLyricsStateCopyWithImpl<_PlayerLyricsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerLyricsState&&(identical(other.stableId, stableId) || other.stableId == stableId)&&(identical(other.rawLyrics, rawLyrics) || other.rawLyrics == rawLyrics)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.hasSearched, hasSearched) || other.hasSearched == hasSearched));
}


@override
int get hashCode => Object.hash(runtimeType,stableId,rawLyrics,errorMessage,isLoading,hasSearched);

@override
String toString() {
  return 'PlayerLyricsState(stableId: $stableId, rawLyrics: $rawLyrics, errorMessage: $errorMessage, isLoading: $isLoading, hasSearched: $hasSearched)';
}


}

/// @nodoc
abstract mixin class _$PlayerLyricsStateCopyWith<$Res> implements $PlayerLyricsStateCopyWith<$Res> {
  factory _$PlayerLyricsStateCopyWith(_PlayerLyricsState value, $Res Function(_PlayerLyricsState) _then) = __$PlayerLyricsStateCopyWithImpl;
@override @useResult
$Res call({
 String? stableId, String? rawLyrics, String? errorMessage, bool isLoading, bool hasSearched
});




}
/// @nodoc
class __$PlayerLyricsStateCopyWithImpl<$Res>
    implements _$PlayerLyricsStateCopyWith<$Res> {
  __$PlayerLyricsStateCopyWithImpl(this._self, this._then);

  final _PlayerLyricsState _self;
  final $Res Function(_PlayerLyricsState) _then;

/// Create a copy of PlayerLyricsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stableId = freezed,Object? rawLyrics = freezed,Object? errorMessage = freezed,Object? isLoading = null,Object? hasSearched = null,}) {
  return _then(_PlayerLyricsState(
stableId: freezed == stableId ? _self.stableId : stableId // ignore: cast_nullable_to_non_nullable
as String?,rawLyrics: freezed == rawLyrics ? _self.rawLyrics : rawLyrics // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,hasSearched: null == hasSearched ? _self.hasSearched : hasSearched // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
