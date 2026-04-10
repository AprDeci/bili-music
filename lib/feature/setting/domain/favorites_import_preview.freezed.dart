// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorites_import_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FavoritesImportPreview {

 bool get hasLikedCollection; int get likedItemCount; int get customCollectionCount; int get totalEntryCount; List<FavoritesImportCollectionPreview> get collections; Set<String> get conflictingCollectionNames;
/// Create a copy of FavoritesImportPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoritesImportPreviewCopyWith<FavoritesImportPreview> get copyWith => _$FavoritesImportPreviewCopyWithImpl<FavoritesImportPreview>(this as FavoritesImportPreview, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoritesImportPreview&&(identical(other.hasLikedCollection, hasLikedCollection) || other.hasLikedCollection == hasLikedCollection)&&(identical(other.likedItemCount, likedItemCount) || other.likedItemCount == likedItemCount)&&(identical(other.customCollectionCount, customCollectionCount) || other.customCollectionCount == customCollectionCount)&&(identical(other.totalEntryCount, totalEntryCount) || other.totalEntryCount == totalEntryCount)&&const DeepCollectionEquality().equals(other.collections, collections)&&const DeepCollectionEquality().equals(other.conflictingCollectionNames, conflictingCollectionNames));
}


@override
int get hashCode => Object.hash(runtimeType,hasLikedCollection,likedItemCount,customCollectionCount,totalEntryCount,const DeepCollectionEquality().hash(collections),const DeepCollectionEquality().hash(conflictingCollectionNames));

@override
String toString() {
  return 'FavoritesImportPreview(hasLikedCollection: $hasLikedCollection, likedItemCount: $likedItemCount, customCollectionCount: $customCollectionCount, totalEntryCount: $totalEntryCount, collections: $collections, conflictingCollectionNames: $conflictingCollectionNames)';
}


}

/// @nodoc
abstract mixin class $FavoritesImportPreviewCopyWith<$Res>  {
  factory $FavoritesImportPreviewCopyWith(FavoritesImportPreview value, $Res Function(FavoritesImportPreview) _then) = _$FavoritesImportPreviewCopyWithImpl;
@useResult
$Res call({
 bool hasLikedCollection, int likedItemCount, int customCollectionCount, int totalEntryCount, List<FavoritesImportCollectionPreview> collections, Set<String> conflictingCollectionNames
});




}
/// @nodoc
class _$FavoritesImportPreviewCopyWithImpl<$Res>
    implements $FavoritesImportPreviewCopyWith<$Res> {
  _$FavoritesImportPreviewCopyWithImpl(this._self, this._then);

  final FavoritesImportPreview _self;
  final $Res Function(FavoritesImportPreview) _then;

/// Create a copy of FavoritesImportPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hasLikedCollection = null,Object? likedItemCount = null,Object? customCollectionCount = null,Object? totalEntryCount = null,Object? collections = null,Object? conflictingCollectionNames = null,}) {
  return _then(_self.copyWith(
hasLikedCollection: null == hasLikedCollection ? _self.hasLikedCollection : hasLikedCollection // ignore: cast_nullable_to_non_nullable
as bool,likedItemCount: null == likedItemCount ? _self.likedItemCount : likedItemCount // ignore: cast_nullable_to_non_nullable
as int,customCollectionCount: null == customCollectionCount ? _self.customCollectionCount : customCollectionCount // ignore: cast_nullable_to_non_nullable
as int,totalEntryCount: null == totalEntryCount ? _self.totalEntryCount : totalEntryCount // ignore: cast_nullable_to_non_nullable
as int,collections: null == collections ? _self.collections : collections // ignore: cast_nullable_to_non_nullable
as List<FavoritesImportCollectionPreview>,conflictingCollectionNames: null == conflictingCollectionNames ? _self.conflictingCollectionNames : conflictingCollectionNames // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [FavoritesImportPreview].
extension FavoritesImportPreviewPatterns on FavoritesImportPreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavoritesImportPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavoritesImportPreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavoritesImportPreview value)  $default,){
final _that = this;
switch (_that) {
case _FavoritesImportPreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavoritesImportPreview value)?  $default,){
final _that = this;
switch (_that) {
case _FavoritesImportPreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool hasLikedCollection,  int likedItemCount,  int customCollectionCount,  int totalEntryCount,  List<FavoritesImportCollectionPreview> collections,  Set<String> conflictingCollectionNames)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavoritesImportPreview() when $default != null:
return $default(_that.hasLikedCollection,_that.likedItemCount,_that.customCollectionCount,_that.totalEntryCount,_that.collections,_that.conflictingCollectionNames);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool hasLikedCollection,  int likedItemCount,  int customCollectionCount,  int totalEntryCount,  List<FavoritesImportCollectionPreview> collections,  Set<String> conflictingCollectionNames)  $default,) {final _that = this;
switch (_that) {
case _FavoritesImportPreview():
return $default(_that.hasLikedCollection,_that.likedItemCount,_that.customCollectionCount,_that.totalEntryCount,_that.collections,_that.conflictingCollectionNames);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool hasLikedCollection,  int likedItemCount,  int customCollectionCount,  int totalEntryCount,  List<FavoritesImportCollectionPreview> collections,  Set<String> conflictingCollectionNames)?  $default,) {final _that = this;
switch (_that) {
case _FavoritesImportPreview() when $default != null:
return $default(_that.hasLikedCollection,_that.likedItemCount,_that.customCollectionCount,_that.totalEntryCount,_that.collections,_that.conflictingCollectionNames);case _:
  return null;

}
}

}

/// @nodoc


class _FavoritesImportPreview extends FavoritesImportPreview {
  const _FavoritesImportPreview({required this.hasLikedCollection, required this.likedItemCount, required this.customCollectionCount, required this.totalEntryCount, final  List<FavoritesImportCollectionPreview> collections = const <FavoritesImportCollectionPreview>[], final  Set<String> conflictingCollectionNames = const <String>{}}): _collections = collections,_conflictingCollectionNames = conflictingCollectionNames,super._();
  

@override final  bool hasLikedCollection;
@override final  int likedItemCount;
@override final  int customCollectionCount;
@override final  int totalEntryCount;
 final  List<FavoritesImportCollectionPreview> _collections;
@override@JsonKey() List<FavoritesImportCollectionPreview> get collections {
  if (_collections is EqualUnmodifiableListView) return _collections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_collections);
}

 final  Set<String> _conflictingCollectionNames;
@override@JsonKey() Set<String> get conflictingCollectionNames {
  if (_conflictingCollectionNames is EqualUnmodifiableSetView) return _conflictingCollectionNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_conflictingCollectionNames);
}


/// Create a copy of FavoritesImportPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoritesImportPreviewCopyWith<_FavoritesImportPreview> get copyWith => __$FavoritesImportPreviewCopyWithImpl<_FavoritesImportPreview>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavoritesImportPreview&&(identical(other.hasLikedCollection, hasLikedCollection) || other.hasLikedCollection == hasLikedCollection)&&(identical(other.likedItemCount, likedItemCount) || other.likedItemCount == likedItemCount)&&(identical(other.customCollectionCount, customCollectionCount) || other.customCollectionCount == customCollectionCount)&&(identical(other.totalEntryCount, totalEntryCount) || other.totalEntryCount == totalEntryCount)&&const DeepCollectionEquality().equals(other._collections, _collections)&&const DeepCollectionEquality().equals(other._conflictingCollectionNames, _conflictingCollectionNames));
}


@override
int get hashCode => Object.hash(runtimeType,hasLikedCollection,likedItemCount,customCollectionCount,totalEntryCount,const DeepCollectionEquality().hash(_collections),const DeepCollectionEquality().hash(_conflictingCollectionNames));

@override
String toString() {
  return 'FavoritesImportPreview(hasLikedCollection: $hasLikedCollection, likedItemCount: $likedItemCount, customCollectionCount: $customCollectionCount, totalEntryCount: $totalEntryCount, collections: $collections, conflictingCollectionNames: $conflictingCollectionNames)';
}


}

/// @nodoc
abstract mixin class _$FavoritesImportPreviewCopyWith<$Res> implements $FavoritesImportPreviewCopyWith<$Res> {
  factory _$FavoritesImportPreviewCopyWith(_FavoritesImportPreview value, $Res Function(_FavoritesImportPreview) _then) = __$FavoritesImportPreviewCopyWithImpl;
@override @useResult
$Res call({
 bool hasLikedCollection, int likedItemCount, int customCollectionCount, int totalEntryCount, List<FavoritesImportCollectionPreview> collections, Set<String> conflictingCollectionNames
});




}
/// @nodoc
class __$FavoritesImportPreviewCopyWithImpl<$Res>
    implements _$FavoritesImportPreviewCopyWith<$Res> {
  __$FavoritesImportPreviewCopyWithImpl(this._self, this._then);

  final _FavoritesImportPreview _self;
  final $Res Function(_FavoritesImportPreview) _then;

/// Create a copy of FavoritesImportPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hasLikedCollection = null,Object? likedItemCount = null,Object? customCollectionCount = null,Object? totalEntryCount = null,Object? collections = null,Object? conflictingCollectionNames = null,}) {
  return _then(_FavoritesImportPreview(
hasLikedCollection: null == hasLikedCollection ? _self.hasLikedCollection : hasLikedCollection // ignore: cast_nullable_to_non_nullable
as bool,likedItemCount: null == likedItemCount ? _self.likedItemCount : likedItemCount // ignore: cast_nullable_to_non_nullable
as int,customCollectionCount: null == customCollectionCount ? _self.customCollectionCount : customCollectionCount // ignore: cast_nullable_to_non_nullable
as int,totalEntryCount: null == totalEntryCount ? _self.totalEntryCount : totalEntryCount // ignore: cast_nullable_to_non_nullable
as int,collections: null == collections ? _self._collections : collections // ignore: cast_nullable_to_non_nullable
as List<FavoritesImportCollectionPreview>,conflictingCollectionNames: null == conflictingCollectionNames ? _self._conflictingCollectionNames : conflictingCollectionNames // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

/// @nodoc
mixin _$FavoritesImportCollectionPreview {

 String get sourceCollectionId; String get name; bool get isLikedCollection; int get itemCount; bool get hasNameConflict;
/// Create a copy of FavoritesImportCollectionPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoritesImportCollectionPreviewCopyWith<FavoritesImportCollectionPreview> get copyWith => _$FavoritesImportCollectionPreviewCopyWithImpl<FavoritesImportCollectionPreview>(this as FavoritesImportCollectionPreview, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoritesImportCollectionPreview&&(identical(other.sourceCollectionId, sourceCollectionId) || other.sourceCollectionId == sourceCollectionId)&&(identical(other.name, name) || other.name == name)&&(identical(other.isLikedCollection, isLikedCollection) || other.isLikedCollection == isLikedCollection)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount)&&(identical(other.hasNameConflict, hasNameConflict) || other.hasNameConflict == hasNameConflict));
}


@override
int get hashCode => Object.hash(runtimeType,sourceCollectionId,name,isLikedCollection,itemCount,hasNameConflict);

@override
String toString() {
  return 'FavoritesImportCollectionPreview(sourceCollectionId: $sourceCollectionId, name: $name, isLikedCollection: $isLikedCollection, itemCount: $itemCount, hasNameConflict: $hasNameConflict)';
}


}

/// @nodoc
abstract mixin class $FavoritesImportCollectionPreviewCopyWith<$Res>  {
  factory $FavoritesImportCollectionPreviewCopyWith(FavoritesImportCollectionPreview value, $Res Function(FavoritesImportCollectionPreview) _then) = _$FavoritesImportCollectionPreviewCopyWithImpl;
@useResult
$Res call({
 String sourceCollectionId, String name, bool isLikedCollection, int itemCount, bool hasNameConflict
});




}
/// @nodoc
class _$FavoritesImportCollectionPreviewCopyWithImpl<$Res>
    implements $FavoritesImportCollectionPreviewCopyWith<$Res> {
  _$FavoritesImportCollectionPreviewCopyWithImpl(this._self, this._then);

  final FavoritesImportCollectionPreview _self;
  final $Res Function(FavoritesImportCollectionPreview) _then;

/// Create a copy of FavoritesImportCollectionPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sourceCollectionId = null,Object? name = null,Object? isLikedCollection = null,Object? itemCount = null,Object? hasNameConflict = null,}) {
  return _then(_self.copyWith(
sourceCollectionId: null == sourceCollectionId ? _self.sourceCollectionId : sourceCollectionId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isLikedCollection: null == isLikedCollection ? _self.isLikedCollection : isLikedCollection // ignore: cast_nullable_to_non_nullable
as bool,itemCount: null == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int,hasNameConflict: null == hasNameConflict ? _self.hasNameConflict : hasNameConflict // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FavoritesImportCollectionPreview].
extension FavoritesImportCollectionPreviewPatterns on FavoritesImportCollectionPreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavoritesImportCollectionPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavoritesImportCollectionPreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavoritesImportCollectionPreview value)  $default,){
final _that = this;
switch (_that) {
case _FavoritesImportCollectionPreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavoritesImportCollectionPreview value)?  $default,){
final _that = this;
switch (_that) {
case _FavoritesImportCollectionPreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sourceCollectionId,  String name,  bool isLikedCollection,  int itemCount,  bool hasNameConflict)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavoritesImportCollectionPreview() when $default != null:
return $default(_that.sourceCollectionId,_that.name,_that.isLikedCollection,_that.itemCount,_that.hasNameConflict);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sourceCollectionId,  String name,  bool isLikedCollection,  int itemCount,  bool hasNameConflict)  $default,) {final _that = this;
switch (_that) {
case _FavoritesImportCollectionPreview():
return $default(_that.sourceCollectionId,_that.name,_that.isLikedCollection,_that.itemCount,_that.hasNameConflict);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sourceCollectionId,  String name,  bool isLikedCollection,  int itemCount,  bool hasNameConflict)?  $default,) {final _that = this;
switch (_that) {
case _FavoritesImportCollectionPreview() when $default != null:
return $default(_that.sourceCollectionId,_that.name,_that.isLikedCollection,_that.itemCount,_that.hasNameConflict);case _:
  return null;

}
}

}

/// @nodoc


class _FavoritesImportCollectionPreview implements FavoritesImportCollectionPreview {
  const _FavoritesImportCollectionPreview({required this.sourceCollectionId, required this.name, required this.isLikedCollection, required this.itemCount, required this.hasNameConflict});
  

@override final  String sourceCollectionId;
@override final  String name;
@override final  bool isLikedCollection;
@override final  int itemCount;
@override final  bool hasNameConflict;

/// Create a copy of FavoritesImportCollectionPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoritesImportCollectionPreviewCopyWith<_FavoritesImportCollectionPreview> get copyWith => __$FavoritesImportCollectionPreviewCopyWithImpl<_FavoritesImportCollectionPreview>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavoritesImportCollectionPreview&&(identical(other.sourceCollectionId, sourceCollectionId) || other.sourceCollectionId == sourceCollectionId)&&(identical(other.name, name) || other.name == name)&&(identical(other.isLikedCollection, isLikedCollection) || other.isLikedCollection == isLikedCollection)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount)&&(identical(other.hasNameConflict, hasNameConflict) || other.hasNameConflict == hasNameConflict));
}


@override
int get hashCode => Object.hash(runtimeType,sourceCollectionId,name,isLikedCollection,itemCount,hasNameConflict);

@override
String toString() {
  return 'FavoritesImportCollectionPreview(sourceCollectionId: $sourceCollectionId, name: $name, isLikedCollection: $isLikedCollection, itemCount: $itemCount, hasNameConflict: $hasNameConflict)';
}


}

/// @nodoc
abstract mixin class _$FavoritesImportCollectionPreviewCopyWith<$Res> implements $FavoritesImportCollectionPreviewCopyWith<$Res> {
  factory _$FavoritesImportCollectionPreviewCopyWith(_FavoritesImportCollectionPreview value, $Res Function(_FavoritesImportCollectionPreview) _then) = __$FavoritesImportCollectionPreviewCopyWithImpl;
@override @useResult
$Res call({
 String sourceCollectionId, String name, bool isLikedCollection, int itemCount, bool hasNameConflict
});




}
/// @nodoc
class __$FavoritesImportCollectionPreviewCopyWithImpl<$Res>
    implements _$FavoritesImportCollectionPreviewCopyWith<$Res> {
  __$FavoritesImportCollectionPreviewCopyWithImpl(this._self, this._then);

  final _FavoritesImportCollectionPreview _self;
  final $Res Function(_FavoritesImportCollectionPreview) _then;

/// Create a copy of FavoritesImportCollectionPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sourceCollectionId = null,Object? name = null,Object? isLikedCollection = null,Object? itemCount = null,Object? hasNameConflict = null,}) {
  return _then(_FavoritesImportCollectionPreview(
sourceCollectionId: null == sourceCollectionId ? _self.sourceCollectionId : sourceCollectionId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isLikedCollection: null == isLikedCollection ? _self.isLikedCollection : isLikedCollection // ignore: cast_nullable_to_non_nullable
as bool,itemCount: null == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int,hasNameConflict: null == hasNameConflict ? _self.hasNameConflict : hasNameConflict // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
