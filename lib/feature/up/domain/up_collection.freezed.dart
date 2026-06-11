// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'up_collection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpCollection {

 int get seasonId; int get mid; String get title; String get coverUrl; int get total; String? get description; DateTime? get updatedAt;
/// Create a copy of UpCollection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpCollectionCopyWith<UpCollection> get copyWith => _$UpCollectionCopyWithImpl<UpCollection>(this as UpCollection, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpCollection&&(identical(other.seasonId, seasonId) || other.seasonId == seasonId)&&(identical(other.mid, mid) || other.mid == mid)&&(identical(other.title, title) || other.title == title)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.total, total) || other.total == total)&&(identical(other.description, description) || other.description == description)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,seasonId,mid,title,coverUrl,total,description,updatedAt);

@override
String toString() {
  return 'UpCollection(seasonId: $seasonId, mid: $mid, title: $title, coverUrl: $coverUrl, total: $total, description: $description, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UpCollectionCopyWith<$Res>  {
  factory $UpCollectionCopyWith(UpCollection value, $Res Function(UpCollection) _then) = _$UpCollectionCopyWithImpl;
@useResult
$Res call({
 int seasonId, int mid, String title, String coverUrl, int total, String? description, DateTime? updatedAt
});




}
/// @nodoc
class _$UpCollectionCopyWithImpl<$Res>
    implements $UpCollectionCopyWith<$Res> {
  _$UpCollectionCopyWithImpl(this._self, this._then);

  final UpCollection _self;
  final $Res Function(UpCollection) _then;

/// Create a copy of UpCollection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? seasonId = null,Object? mid = null,Object? title = null,Object? coverUrl = null,Object? total = null,Object? description = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
seasonId: null == seasonId ? _self.seasonId : seasonId // ignore: cast_nullable_to_non_nullable
as int,mid: null == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpCollection].
extension UpCollectionPatterns on UpCollection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpCollection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpCollection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpCollection value)  $default,){
final _that = this;
switch (_that) {
case _UpCollection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpCollection value)?  $default,){
final _that = this;
switch (_that) {
case _UpCollection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int seasonId,  int mid,  String title,  String coverUrl,  int total,  String? description,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpCollection() when $default != null:
return $default(_that.seasonId,_that.mid,_that.title,_that.coverUrl,_that.total,_that.description,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int seasonId,  int mid,  String title,  String coverUrl,  int total,  String? description,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _UpCollection():
return $default(_that.seasonId,_that.mid,_that.title,_that.coverUrl,_that.total,_that.description,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int seasonId,  int mid,  String title,  String coverUrl,  int total,  String? description,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _UpCollection() when $default != null:
return $default(_that.seasonId,_that.mid,_that.title,_that.coverUrl,_that.total,_that.description,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _UpCollection implements UpCollection {
  const _UpCollection({required this.seasonId, required this.mid, required this.title, required this.coverUrl, required this.total, this.description, this.updatedAt});
  

@override final  int seasonId;
@override final  int mid;
@override final  String title;
@override final  String coverUrl;
@override final  int total;
@override final  String? description;
@override final  DateTime? updatedAt;

/// Create a copy of UpCollection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpCollectionCopyWith<_UpCollection> get copyWith => __$UpCollectionCopyWithImpl<_UpCollection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpCollection&&(identical(other.seasonId, seasonId) || other.seasonId == seasonId)&&(identical(other.mid, mid) || other.mid == mid)&&(identical(other.title, title) || other.title == title)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.total, total) || other.total == total)&&(identical(other.description, description) || other.description == description)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,seasonId,mid,title,coverUrl,total,description,updatedAt);

@override
String toString() {
  return 'UpCollection(seasonId: $seasonId, mid: $mid, title: $title, coverUrl: $coverUrl, total: $total, description: $description, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UpCollectionCopyWith<$Res> implements $UpCollectionCopyWith<$Res> {
  factory _$UpCollectionCopyWith(_UpCollection value, $Res Function(_UpCollection) _then) = __$UpCollectionCopyWithImpl;
@override @useResult
$Res call({
 int seasonId, int mid, String title, String coverUrl, int total, String? description, DateTime? updatedAt
});




}
/// @nodoc
class __$UpCollectionCopyWithImpl<$Res>
    implements _$UpCollectionCopyWith<$Res> {
  __$UpCollectionCopyWithImpl(this._self, this._then);

  final _UpCollection _self;
  final $Res Function(_UpCollection) _then;

/// Create a copy of UpCollection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? seasonId = null,Object? mid = null,Object? title = null,Object? coverUrl = null,Object? total = null,Object? description = freezed,Object? updatedAt = freezed,}) {
  return _then(_UpCollection(
seasonId: null == seasonId ? _self.seasonId : seasonId // ignore: cast_nullable_to_non_nullable
as int,mid: null == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
