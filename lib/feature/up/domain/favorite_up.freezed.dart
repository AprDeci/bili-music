// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorite_up.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FavoriteUp {

 int get mid; String get name; String get avatarUrl; int? get officialType; int get favoritedAtEpochMs; int get updatedAtEpochMs;
/// Create a copy of FavoriteUp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoriteUpCopyWith<FavoriteUp> get copyWith => _$FavoriteUpCopyWithImpl<FavoriteUp>(this as FavoriteUp, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoriteUp&&(identical(other.mid, mid) || other.mid == mid)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.officialType, officialType) || other.officialType == officialType)&&(identical(other.favoritedAtEpochMs, favoritedAtEpochMs) || other.favoritedAtEpochMs == favoritedAtEpochMs)&&(identical(other.updatedAtEpochMs, updatedAtEpochMs) || other.updatedAtEpochMs == updatedAtEpochMs));
}


@override
int get hashCode => Object.hash(runtimeType,mid,name,avatarUrl,officialType,favoritedAtEpochMs,updatedAtEpochMs);

@override
String toString() {
  return 'FavoriteUp(mid: $mid, name: $name, avatarUrl: $avatarUrl, officialType: $officialType, favoritedAtEpochMs: $favoritedAtEpochMs, updatedAtEpochMs: $updatedAtEpochMs)';
}


}

/// @nodoc
abstract mixin class $FavoriteUpCopyWith<$Res>  {
  factory $FavoriteUpCopyWith(FavoriteUp value, $Res Function(FavoriteUp) _then) = _$FavoriteUpCopyWithImpl;
@useResult
$Res call({
 int mid, String name, String avatarUrl, int? officialType, int favoritedAtEpochMs, int updatedAtEpochMs
});




}
/// @nodoc
class _$FavoriteUpCopyWithImpl<$Res>
    implements $FavoriteUpCopyWith<$Res> {
  _$FavoriteUpCopyWithImpl(this._self, this._then);

  final FavoriteUp _self;
  final $Res Function(FavoriteUp) _then;

/// Create a copy of FavoriteUp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mid = null,Object? name = null,Object? avatarUrl = null,Object? officialType = freezed,Object? favoritedAtEpochMs = null,Object? updatedAtEpochMs = null,}) {
  return _then(_self.copyWith(
mid: null == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,officialType: freezed == officialType ? _self.officialType : officialType // ignore: cast_nullable_to_non_nullable
as int?,favoritedAtEpochMs: null == favoritedAtEpochMs ? _self.favoritedAtEpochMs : favoritedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int,updatedAtEpochMs: null == updatedAtEpochMs ? _self.updatedAtEpochMs : updatedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FavoriteUp].
extension FavoriteUpPatterns on FavoriteUp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavoriteUp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavoriteUp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavoriteUp value)  $default,){
final _that = this;
switch (_that) {
case _FavoriteUp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavoriteUp value)?  $default,){
final _that = this;
switch (_that) {
case _FavoriteUp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int mid,  String name,  String avatarUrl,  int? officialType,  int favoritedAtEpochMs,  int updatedAtEpochMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavoriteUp() when $default != null:
return $default(_that.mid,_that.name,_that.avatarUrl,_that.officialType,_that.favoritedAtEpochMs,_that.updatedAtEpochMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int mid,  String name,  String avatarUrl,  int? officialType,  int favoritedAtEpochMs,  int updatedAtEpochMs)  $default,) {final _that = this;
switch (_that) {
case _FavoriteUp():
return $default(_that.mid,_that.name,_that.avatarUrl,_that.officialType,_that.favoritedAtEpochMs,_that.updatedAtEpochMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int mid,  String name,  String avatarUrl,  int? officialType,  int favoritedAtEpochMs,  int updatedAtEpochMs)?  $default,) {final _that = this;
switch (_that) {
case _FavoriteUp() when $default != null:
return $default(_that.mid,_that.name,_that.avatarUrl,_that.officialType,_that.favoritedAtEpochMs,_that.updatedAtEpochMs);case _:
  return null;

}
}

}

/// @nodoc


class _FavoriteUp extends FavoriteUp {
  const _FavoriteUp({required this.mid, required this.name, required this.avatarUrl, this.officialType, required this.favoritedAtEpochMs, required this.updatedAtEpochMs}): super._();
  

@override final  int mid;
@override final  String name;
@override final  String avatarUrl;
@override final  int? officialType;
@override final  int favoritedAtEpochMs;
@override final  int updatedAtEpochMs;

/// Create a copy of FavoriteUp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoriteUpCopyWith<_FavoriteUp> get copyWith => __$FavoriteUpCopyWithImpl<_FavoriteUp>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavoriteUp&&(identical(other.mid, mid) || other.mid == mid)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.officialType, officialType) || other.officialType == officialType)&&(identical(other.favoritedAtEpochMs, favoritedAtEpochMs) || other.favoritedAtEpochMs == favoritedAtEpochMs)&&(identical(other.updatedAtEpochMs, updatedAtEpochMs) || other.updatedAtEpochMs == updatedAtEpochMs));
}


@override
int get hashCode => Object.hash(runtimeType,mid,name,avatarUrl,officialType,favoritedAtEpochMs,updatedAtEpochMs);

@override
String toString() {
  return 'FavoriteUp(mid: $mid, name: $name, avatarUrl: $avatarUrl, officialType: $officialType, favoritedAtEpochMs: $favoritedAtEpochMs, updatedAtEpochMs: $updatedAtEpochMs)';
}


}

/// @nodoc
abstract mixin class _$FavoriteUpCopyWith<$Res> implements $FavoriteUpCopyWith<$Res> {
  factory _$FavoriteUpCopyWith(_FavoriteUp value, $Res Function(_FavoriteUp) _then) = __$FavoriteUpCopyWithImpl;
@override @useResult
$Res call({
 int mid, String name, String avatarUrl, int? officialType, int favoritedAtEpochMs, int updatedAtEpochMs
});




}
/// @nodoc
class __$FavoriteUpCopyWithImpl<$Res>
    implements _$FavoriteUpCopyWith<$Res> {
  __$FavoriteUpCopyWithImpl(this._self, this._then);

  final _FavoriteUp _self;
  final $Res Function(_FavoriteUp) _then;

/// Create a copy of FavoriteUp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mid = null,Object? name = null,Object? avatarUrl = null,Object? officialType = freezed,Object? favoritedAtEpochMs = null,Object? updatedAtEpochMs = null,}) {
  return _then(_FavoriteUp(
mid: null == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,officialType: freezed == officialType ? _self.officialType : officialType // ignore: cast_nullable_to_non_nullable
as int?,favoritedAtEpochMs: null == favoritedAtEpochMs ? _self.favoritedAtEpochMs : favoritedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int,updatedAtEpochMs: null == updatedAtEpochMs ? _self.updatedAtEpochMs : updatedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
