// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorite_membership.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FavoriteMembership {

 String get id; String get collectionId; String get itemId; DateTime get addedAt;
/// Create a copy of FavoriteMembership
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoriteMembershipCopyWith<FavoriteMembership> get copyWith => _$FavoriteMembershipCopyWithImpl<FavoriteMembership>(this as FavoriteMembership, _$identity);

  /// Serializes this FavoriteMembership to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoriteMembership&&(identical(other.id, id) || other.id == id)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,collectionId,itemId,addedAt);

@override
String toString() {
  return 'FavoriteMembership(id: $id, collectionId: $collectionId, itemId: $itemId, addedAt: $addedAt)';
}


}

/// @nodoc
abstract mixin class $FavoriteMembershipCopyWith<$Res>  {
  factory $FavoriteMembershipCopyWith(FavoriteMembership value, $Res Function(FavoriteMembership) _then) = _$FavoriteMembershipCopyWithImpl;
@useResult
$Res call({
 String id, String collectionId, String itemId, DateTime addedAt
});




}
/// @nodoc
class _$FavoriteMembershipCopyWithImpl<$Res>
    implements $FavoriteMembershipCopyWith<$Res> {
  _$FavoriteMembershipCopyWithImpl(this._self, this._then);

  final FavoriteMembership _self;
  final $Res Function(FavoriteMembership) _then;

/// Create a copy of FavoriteMembership
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? collectionId = null,Object? itemId = null,Object? addedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FavoriteMembership].
extension FavoriteMembershipPatterns on FavoriteMembership {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavoriteMembership value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavoriteMembership() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavoriteMembership value)  $default,){
final _that = this;
switch (_that) {
case _FavoriteMembership():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavoriteMembership value)?  $default,){
final _that = this;
switch (_that) {
case _FavoriteMembership() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String collectionId,  String itemId,  DateTime addedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavoriteMembership() when $default != null:
return $default(_that.id,_that.collectionId,_that.itemId,_that.addedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String collectionId,  String itemId,  DateTime addedAt)  $default,) {final _that = this;
switch (_that) {
case _FavoriteMembership():
return $default(_that.id,_that.collectionId,_that.itemId,_that.addedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String collectionId,  String itemId,  DateTime addedAt)?  $default,) {final _that = this;
switch (_that) {
case _FavoriteMembership() when $default != null:
return $default(_that.id,_that.collectionId,_that.itemId,_that.addedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FavoriteMembership extends FavoriteMembership {
  const _FavoriteMembership({required this.id, required this.collectionId, required this.itemId, required this.addedAt}): super._();
  factory _FavoriteMembership.fromJson(Map<String, dynamic> json) => _$FavoriteMembershipFromJson(json);

@override final  String id;
@override final  String collectionId;
@override final  String itemId;
@override final  DateTime addedAt;

/// Create a copy of FavoriteMembership
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoriteMembershipCopyWith<_FavoriteMembership> get copyWith => __$FavoriteMembershipCopyWithImpl<_FavoriteMembership>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FavoriteMembershipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavoriteMembership&&(identical(other.id, id) || other.id == id)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,collectionId,itemId,addedAt);

@override
String toString() {
  return 'FavoriteMembership(id: $id, collectionId: $collectionId, itemId: $itemId, addedAt: $addedAt)';
}


}

/// @nodoc
abstract mixin class _$FavoriteMembershipCopyWith<$Res> implements $FavoriteMembershipCopyWith<$Res> {
  factory _$FavoriteMembershipCopyWith(_FavoriteMembership value, $Res Function(_FavoriteMembership) _then) = __$FavoriteMembershipCopyWithImpl;
@override @useResult
$Res call({
 String id, String collectionId, String itemId, DateTime addedAt
});




}
/// @nodoc
class __$FavoriteMembershipCopyWithImpl<$Res>
    implements _$FavoriteMembershipCopyWith<$Res> {
  __$FavoriteMembershipCopyWithImpl(this._self, this._then);

  final _FavoriteMembership _self;
  final $Res Function(_FavoriteMembership) _then;

/// Create a copy of FavoriteMembership
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? collectionId = null,Object? itemId = null,Object? addedAt = null,}) {
  return _then(_FavoriteMembership(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
