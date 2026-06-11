// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'up_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpProfile {

 int get mid; String get name; String get avatarUrl; int get followerCount; int? get officialType;
/// Create a copy of UpProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpProfileCopyWith<UpProfile> get copyWith => _$UpProfileCopyWithImpl<UpProfile>(this as UpProfile, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpProfile&&(identical(other.mid, mid) || other.mid == mid)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.followerCount, followerCount) || other.followerCount == followerCount)&&(identical(other.officialType, officialType) || other.officialType == officialType));
}


@override
int get hashCode => Object.hash(runtimeType,mid,name,avatarUrl,followerCount,officialType);

@override
String toString() {
  return 'UpProfile(mid: $mid, name: $name, avatarUrl: $avatarUrl, followerCount: $followerCount, officialType: $officialType)';
}


}

/// @nodoc
abstract mixin class $UpProfileCopyWith<$Res>  {
  factory $UpProfileCopyWith(UpProfile value, $Res Function(UpProfile) _then) = _$UpProfileCopyWithImpl;
@useResult
$Res call({
 int mid, String name, String avatarUrl, int followerCount, int? officialType
});




}
/// @nodoc
class _$UpProfileCopyWithImpl<$Res>
    implements $UpProfileCopyWith<$Res> {
  _$UpProfileCopyWithImpl(this._self, this._then);

  final UpProfile _self;
  final $Res Function(UpProfile) _then;

/// Create a copy of UpProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mid = null,Object? name = null,Object? avatarUrl = null,Object? followerCount = null,Object? officialType = freezed,}) {
  return _then(_self.copyWith(
mid: null == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,followerCount: null == followerCount ? _self.followerCount : followerCount // ignore: cast_nullable_to_non_nullable
as int,officialType: freezed == officialType ? _self.officialType : officialType // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpProfile].
extension UpProfilePatterns on UpProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpProfile value)  $default,){
final _that = this;
switch (_that) {
case _UpProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UpProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int mid,  String name,  String avatarUrl,  int followerCount,  int? officialType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpProfile() when $default != null:
return $default(_that.mid,_that.name,_that.avatarUrl,_that.followerCount,_that.officialType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int mid,  String name,  String avatarUrl,  int followerCount,  int? officialType)  $default,) {final _that = this;
switch (_that) {
case _UpProfile():
return $default(_that.mid,_that.name,_that.avatarUrl,_that.followerCount,_that.officialType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int mid,  String name,  String avatarUrl,  int followerCount,  int? officialType)?  $default,) {final _that = this;
switch (_that) {
case _UpProfile() when $default != null:
return $default(_that.mid,_that.name,_that.avatarUrl,_that.followerCount,_that.officialType);case _:
  return null;

}
}

}

/// @nodoc


class _UpProfile implements UpProfile {
  const _UpProfile({required this.mid, required this.name, required this.avatarUrl, required this.followerCount, this.officialType});
  

@override final  int mid;
@override final  String name;
@override final  String avatarUrl;
@override final  int followerCount;
@override final  int? officialType;

/// Create a copy of UpProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpProfileCopyWith<_UpProfile> get copyWith => __$UpProfileCopyWithImpl<_UpProfile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpProfile&&(identical(other.mid, mid) || other.mid == mid)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.followerCount, followerCount) || other.followerCount == followerCount)&&(identical(other.officialType, officialType) || other.officialType == officialType));
}


@override
int get hashCode => Object.hash(runtimeType,mid,name,avatarUrl,followerCount,officialType);

@override
String toString() {
  return 'UpProfile(mid: $mid, name: $name, avatarUrl: $avatarUrl, followerCount: $followerCount, officialType: $officialType)';
}


}

/// @nodoc
abstract mixin class _$UpProfileCopyWith<$Res> implements $UpProfileCopyWith<$Res> {
  factory _$UpProfileCopyWith(_UpProfile value, $Res Function(_UpProfile) _then) = __$UpProfileCopyWithImpl;
@override @useResult
$Res call({
 int mid, String name, String avatarUrl, int followerCount, int? officialType
});




}
/// @nodoc
class __$UpProfileCopyWithImpl<$Res>
    implements _$UpProfileCopyWith<$Res> {
  __$UpProfileCopyWithImpl(this._self, this._then);

  final _UpProfile _self;
  final $Res Function(_UpProfile) _then;

/// Create a copy of UpProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mid = null,Object? name = null,Object? avatarUrl = null,Object? followerCount = null,Object? officialType = freezed,}) {
  return _then(_UpProfile(
mid: null == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,followerCount: null == followerCount ? _self.followerCount : followerCount // ignore: cast_nullable_to_non_nullable
as int,officialType: freezed == officialType ? _self.officialType : officialType // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
