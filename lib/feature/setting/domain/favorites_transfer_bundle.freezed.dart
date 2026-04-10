// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorites_transfer_bundle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FavoritesTransferBundle {

 int get schemaVersion; DateTime get exportedAt; List<FavoriteCollection> get collections; List<FavoriteEntry> get entries; List<FavoriteMembership> get memberships;
/// Create a copy of FavoritesTransferBundle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoritesTransferBundleCopyWith<FavoritesTransferBundle> get copyWith => _$FavoritesTransferBundleCopyWithImpl<FavoritesTransferBundle>(this as FavoritesTransferBundle, _$identity);

  /// Serializes this FavoritesTransferBundle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoritesTransferBundle&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.exportedAt, exportedAt) || other.exportedAt == exportedAt)&&const DeepCollectionEquality().equals(other.collections, collections)&&const DeepCollectionEquality().equals(other.entries, entries)&&const DeepCollectionEquality().equals(other.memberships, memberships));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,exportedAt,const DeepCollectionEquality().hash(collections),const DeepCollectionEquality().hash(entries),const DeepCollectionEquality().hash(memberships));

@override
String toString() {
  return 'FavoritesTransferBundle(schemaVersion: $schemaVersion, exportedAt: $exportedAt, collections: $collections, entries: $entries, memberships: $memberships)';
}


}

/// @nodoc
abstract mixin class $FavoritesTransferBundleCopyWith<$Res>  {
  factory $FavoritesTransferBundleCopyWith(FavoritesTransferBundle value, $Res Function(FavoritesTransferBundle) _then) = _$FavoritesTransferBundleCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, DateTime exportedAt, List<FavoriteCollection> collections, List<FavoriteEntry> entries, List<FavoriteMembership> memberships
});




}
/// @nodoc
class _$FavoritesTransferBundleCopyWithImpl<$Res>
    implements $FavoritesTransferBundleCopyWith<$Res> {
  _$FavoritesTransferBundleCopyWithImpl(this._self, this._then);

  final FavoritesTransferBundle _self;
  final $Res Function(FavoritesTransferBundle) _then;

/// Create a copy of FavoritesTransferBundle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? exportedAt = null,Object? collections = null,Object? entries = null,Object? memberships = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,exportedAt: null == exportedAt ? _self.exportedAt : exportedAt // ignore: cast_nullable_to_non_nullable
as DateTime,collections: null == collections ? _self.collections : collections // ignore: cast_nullable_to_non_nullable
as List<FavoriteCollection>,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<FavoriteEntry>,memberships: null == memberships ? _self.memberships : memberships // ignore: cast_nullable_to_non_nullable
as List<FavoriteMembership>,
  ));
}

}


/// Adds pattern-matching-related methods to [FavoritesTransferBundle].
extension FavoritesTransferBundlePatterns on FavoritesTransferBundle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavoritesTransferBundle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavoritesTransferBundle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavoritesTransferBundle value)  $default,){
final _that = this;
switch (_that) {
case _FavoritesTransferBundle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavoritesTransferBundle value)?  $default,){
final _that = this;
switch (_that) {
case _FavoritesTransferBundle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  DateTime exportedAt,  List<FavoriteCollection> collections,  List<FavoriteEntry> entries,  List<FavoriteMembership> memberships)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavoritesTransferBundle() when $default != null:
return $default(_that.schemaVersion,_that.exportedAt,_that.collections,_that.entries,_that.memberships);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  DateTime exportedAt,  List<FavoriteCollection> collections,  List<FavoriteEntry> entries,  List<FavoriteMembership> memberships)  $default,) {final _that = this;
switch (_that) {
case _FavoritesTransferBundle():
return $default(_that.schemaVersion,_that.exportedAt,_that.collections,_that.entries,_that.memberships);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  DateTime exportedAt,  List<FavoriteCollection> collections,  List<FavoriteEntry> entries,  List<FavoriteMembership> memberships)?  $default,) {final _that = this;
switch (_that) {
case _FavoritesTransferBundle() when $default != null:
return $default(_that.schemaVersion,_that.exportedAt,_that.collections,_that.entries,_that.memberships);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FavoritesTransferBundle extends FavoritesTransferBundle {
  const _FavoritesTransferBundle({this.schemaVersion = 1, required this.exportedAt, final  List<FavoriteCollection> collections = const <FavoriteCollection>[], final  List<FavoriteEntry> entries = const <FavoriteEntry>[], final  List<FavoriteMembership> memberships = const <FavoriteMembership>[]}): _collections = collections,_entries = entries,_memberships = memberships,super._();
  factory _FavoritesTransferBundle.fromJson(Map<String, dynamic> json) => _$FavoritesTransferBundleFromJson(json);

@override@JsonKey() final  int schemaVersion;
@override final  DateTime exportedAt;
 final  List<FavoriteCollection> _collections;
@override@JsonKey() List<FavoriteCollection> get collections {
  if (_collections is EqualUnmodifiableListView) return _collections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_collections);
}

 final  List<FavoriteEntry> _entries;
@override@JsonKey() List<FavoriteEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

 final  List<FavoriteMembership> _memberships;
@override@JsonKey() List<FavoriteMembership> get memberships {
  if (_memberships is EqualUnmodifiableListView) return _memberships;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_memberships);
}


/// Create a copy of FavoritesTransferBundle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoritesTransferBundleCopyWith<_FavoritesTransferBundle> get copyWith => __$FavoritesTransferBundleCopyWithImpl<_FavoritesTransferBundle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FavoritesTransferBundleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavoritesTransferBundle&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.exportedAt, exportedAt) || other.exportedAt == exportedAt)&&const DeepCollectionEquality().equals(other._collections, _collections)&&const DeepCollectionEquality().equals(other._entries, _entries)&&const DeepCollectionEquality().equals(other._memberships, _memberships));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,exportedAt,const DeepCollectionEquality().hash(_collections),const DeepCollectionEquality().hash(_entries),const DeepCollectionEquality().hash(_memberships));

@override
String toString() {
  return 'FavoritesTransferBundle(schemaVersion: $schemaVersion, exportedAt: $exportedAt, collections: $collections, entries: $entries, memberships: $memberships)';
}


}

/// @nodoc
abstract mixin class _$FavoritesTransferBundleCopyWith<$Res> implements $FavoritesTransferBundleCopyWith<$Res> {
  factory _$FavoritesTransferBundleCopyWith(_FavoritesTransferBundle value, $Res Function(_FavoritesTransferBundle) _then) = __$FavoritesTransferBundleCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, DateTime exportedAt, List<FavoriteCollection> collections, List<FavoriteEntry> entries, List<FavoriteMembership> memberships
});




}
/// @nodoc
class __$FavoritesTransferBundleCopyWithImpl<$Res>
    implements _$FavoritesTransferBundleCopyWith<$Res> {
  __$FavoritesTransferBundleCopyWithImpl(this._self, this._then);

  final _FavoritesTransferBundle _self;
  final $Res Function(_FavoritesTransferBundle) _then;

/// Create a copy of FavoritesTransferBundle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? exportedAt = null,Object? collections = null,Object? entries = null,Object? memberships = null,}) {
  return _then(_FavoritesTransferBundle(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,exportedAt: null == exportedAt ? _self.exportedAt : exportedAt // ignore: cast_nullable_to_non_nullable
as DateTime,collections: null == collections ? _self._collections : collections // ignore: cast_nullable_to_non_nullable
as List<FavoriteCollection>,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<FavoriteEntry>,memberships: null == memberships ? _self._memberships : memberships // ignore: cast_nullable_to_non_nullable
as List<FavoriteMembership>,
  ));
}


}

// dart format on
