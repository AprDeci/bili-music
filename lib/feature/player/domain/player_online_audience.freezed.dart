// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_online_audience.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlayerOnlineAudience {

 String? get totalText; String? get countText; bool get showTotal; bool get showCount; DateTime get fetchedAt;
/// Create a copy of PlayerOnlineAudience
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerOnlineAudienceCopyWith<PlayerOnlineAudience> get copyWith => _$PlayerOnlineAudienceCopyWithImpl<PlayerOnlineAudience>(this as PlayerOnlineAudience, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerOnlineAudience&&(identical(other.totalText, totalText) || other.totalText == totalText)&&(identical(other.countText, countText) || other.countText == countText)&&(identical(other.showTotal, showTotal) || other.showTotal == showTotal)&&(identical(other.showCount, showCount) || other.showCount == showCount)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt));
}


@override
int get hashCode => Object.hash(runtimeType,totalText,countText,showTotal,showCount,fetchedAt);

@override
String toString() {
  return 'PlayerOnlineAudience(totalText: $totalText, countText: $countText, showTotal: $showTotal, showCount: $showCount, fetchedAt: $fetchedAt)';
}


}

/// @nodoc
abstract mixin class $PlayerOnlineAudienceCopyWith<$Res>  {
  factory $PlayerOnlineAudienceCopyWith(PlayerOnlineAudience value, $Res Function(PlayerOnlineAudience) _then) = _$PlayerOnlineAudienceCopyWithImpl;
@useResult
$Res call({
 String? totalText, String? countText, bool showTotal, bool showCount, DateTime fetchedAt
});




}
/// @nodoc
class _$PlayerOnlineAudienceCopyWithImpl<$Res>
    implements $PlayerOnlineAudienceCopyWith<$Res> {
  _$PlayerOnlineAudienceCopyWithImpl(this._self, this._then);

  final PlayerOnlineAudience _self;
  final $Res Function(PlayerOnlineAudience) _then;

/// Create a copy of PlayerOnlineAudience
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalText = freezed,Object? countText = freezed,Object? showTotal = null,Object? showCount = null,Object? fetchedAt = null,}) {
  return _then(_self.copyWith(
totalText: freezed == totalText ? _self.totalText : totalText // ignore: cast_nullable_to_non_nullable
as String?,countText: freezed == countText ? _self.countText : countText // ignore: cast_nullable_to_non_nullable
as String?,showTotal: null == showTotal ? _self.showTotal : showTotal // ignore: cast_nullable_to_non_nullable
as bool,showCount: null == showCount ? _self.showCount : showCount // ignore: cast_nullable_to_non_nullable
as bool,fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayerOnlineAudience].
extension PlayerOnlineAudiencePatterns on PlayerOnlineAudience {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerOnlineAudience value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerOnlineAudience() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerOnlineAudience value)  $default,){
final _that = this;
switch (_that) {
case _PlayerOnlineAudience():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerOnlineAudience value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerOnlineAudience() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? totalText,  String? countText,  bool showTotal,  bool showCount,  DateTime fetchedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerOnlineAudience() when $default != null:
return $default(_that.totalText,_that.countText,_that.showTotal,_that.showCount,_that.fetchedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? totalText,  String? countText,  bool showTotal,  bool showCount,  DateTime fetchedAt)  $default,) {final _that = this;
switch (_that) {
case _PlayerOnlineAudience():
return $default(_that.totalText,_that.countText,_that.showTotal,_that.showCount,_that.fetchedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? totalText,  String? countText,  bool showTotal,  bool showCount,  DateTime fetchedAt)?  $default,) {final _that = this;
switch (_that) {
case _PlayerOnlineAudience() when $default != null:
return $default(_that.totalText,_that.countText,_that.showTotal,_that.showCount,_that.fetchedAt);case _:
  return null;

}
}

}

/// @nodoc


class _PlayerOnlineAudience extends PlayerOnlineAudience {
  const _PlayerOnlineAudience({this.totalText, this.countText, this.showTotal = false, this.showCount = false, required this.fetchedAt}): super._();
  

@override final  String? totalText;
@override final  String? countText;
@override@JsonKey() final  bool showTotal;
@override@JsonKey() final  bool showCount;
@override final  DateTime fetchedAt;

/// Create a copy of PlayerOnlineAudience
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerOnlineAudienceCopyWith<_PlayerOnlineAudience> get copyWith => __$PlayerOnlineAudienceCopyWithImpl<_PlayerOnlineAudience>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerOnlineAudience&&(identical(other.totalText, totalText) || other.totalText == totalText)&&(identical(other.countText, countText) || other.countText == countText)&&(identical(other.showTotal, showTotal) || other.showTotal == showTotal)&&(identical(other.showCount, showCount) || other.showCount == showCount)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt));
}


@override
int get hashCode => Object.hash(runtimeType,totalText,countText,showTotal,showCount,fetchedAt);

@override
String toString() {
  return 'PlayerOnlineAudience(totalText: $totalText, countText: $countText, showTotal: $showTotal, showCount: $showCount, fetchedAt: $fetchedAt)';
}


}

/// @nodoc
abstract mixin class _$PlayerOnlineAudienceCopyWith<$Res> implements $PlayerOnlineAudienceCopyWith<$Res> {
  factory _$PlayerOnlineAudienceCopyWith(_PlayerOnlineAudience value, $Res Function(_PlayerOnlineAudience) _then) = __$PlayerOnlineAudienceCopyWithImpl;
@override @useResult
$Res call({
 String? totalText, String? countText, bool showTotal, bool showCount, DateTime fetchedAt
});




}
/// @nodoc
class __$PlayerOnlineAudienceCopyWithImpl<$Res>
    implements _$PlayerOnlineAudienceCopyWith<$Res> {
  __$PlayerOnlineAudienceCopyWithImpl(this._self, this._then);

  final _PlayerOnlineAudience _self;
  final $Res Function(_PlayerOnlineAudience) _then;

/// Create a copy of PlayerOnlineAudience
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalText = freezed,Object? countText = freezed,Object? showTotal = null,Object? showCount = null,Object? fetchedAt = null,}) {
  return _then(_PlayerOnlineAudience(
totalText: freezed == totalText ? _self.totalText : totalText // ignore: cast_nullable_to_non_nullable
as String?,countText: freezed == countText ? _self.countText : countText // ignore: cast_nullable_to_non_nullable
as String?,showTotal: null == showTotal ? _self.showTotal : showTotal // ignore: cast_nullable_to_non_nullable
as bool,showCount: null == showCount ? _self.showCount : showCount // ignore: cast_nullable_to_non_nullable
as bool,fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
