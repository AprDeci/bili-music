// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorite_collection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FavoriteCollection {

 String get id; String get name; bool get isSystem; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of FavoriteCollection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoriteCollectionCopyWith<FavoriteCollection> get copyWith => _$FavoriteCollectionCopyWithImpl<FavoriteCollection>(this as FavoriteCollection, _$identity);

  /// Serializes this FavoriteCollection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoriteCollection&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isSystem, isSystem) || other.isSystem == isSystem)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,isSystem,createdAt,updatedAt);

@override
String toString() {
  return 'FavoriteCollection(id: $id, name: $name, isSystem: $isSystem, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FavoriteCollectionCopyWith<$Res>  {
  factory $FavoriteCollectionCopyWith(FavoriteCollection value, $Res Function(FavoriteCollection) _then) = _$FavoriteCollectionCopyWithImpl;
@useResult
$Res call({
 String id, String name, bool isSystem, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$FavoriteCollectionCopyWithImpl<$Res>
    implements $FavoriteCollectionCopyWith<$Res> {
  _$FavoriteCollectionCopyWithImpl(this._self, this._then);

  final FavoriteCollection _self;
  final $Res Function(FavoriteCollection) _then;

/// Create a copy of FavoriteCollection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? isSystem = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isSystem: null == isSystem ? _self.isSystem : isSystem // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FavoriteCollection].
extension FavoriteCollectionPatterns on FavoriteCollection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavoriteCollection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavoriteCollection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavoriteCollection value)  $default,){
final _that = this;
switch (_that) {
case _FavoriteCollection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavoriteCollection value)?  $default,){
final _that = this;
switch (_that) {
case _FavoriteCollection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  bool isSystem,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavoriteCollection() when $default != null:
return $default(_that.id,_that.name,_that.isSystem,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  bool isSystem,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FavoriteCollection():
return $default(_that.id,_that.name,_that.isSystem,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  bool isSystem,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FavoriteCollection() when $default != null:
return $default(_that.id,_that.name,_that.isSystem,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FavoriteCollection extends FavoriteCollection {
  const _FavoriteCollection({required this.id, required this.name, required this.isSystem, required this.createdAt, required this.updatedAt}): super._();
  factory _FavoriteCollection.fromJson(Map<String, dynamic> json) => _$FavoriteCollectionFromJson(json);

@override final  String id;
@override final  String name;
@override final  bool isSystem;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of FavoriteCollection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoriteCollectionCopyWith<_FavoriteCollection> get copyWith => __$FavoriteCollectionCopyWithImpl<_FavoriteCollection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FavoriteCollectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavoriteCollection&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isSystem, isSystem) || other.isSystem == isSystem)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,isSystem,createdAt,updatedAt);

@override
String toString() {
  return 'FavoriteCollection(id: $id, name: $name, isSystem: $isSystem, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FavoriteCollectionCopyWith<$Res> implements $FavoriteCollectionCopyWith<$Res> {
  factory _$FavoriteCollectionCopyWith(_FavoriteCollection value, $Res Function(_FavoriteCollection) _then) = __$FavoriteCollectionCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, bool isSystem, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$FavoriteCollectionCopyWithImpl<$Res>
    implements _$FavoriteCollectionCopyWith<$Res> {
  __$FavoriteCollectionCopyWithImpl(this._self, this._then);

  final _FavoriteCollection _self;
  final $Res Function(_FavoriteCollection) _then;

/// Create a copy of FavoriteCollection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? isSystem = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_FavoriteCollection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isSystem: null == isSystem ? _self.isSystem : isSystem // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
