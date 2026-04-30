// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_import_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppImportPreview {

 bool get hasLikedCollection; int get likedItemCount; int get customCollectionCount; int get totalEntryCount; bool get hasSettings; List<AppImportCollectionPreview> get collections; Set<String> get conflictingCollectionNames;
/// Create a copy of AppImportPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppImportPreviewCopyWith<AppImportPreview> get copyWith => _$AppImportPreviewCopyWithImpl<AppImportPreview>(this as AppImportPreview, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppImportPreview&&(identical(other.hasLikedCollection, hasLikedCollection) || other.hasLikedCollection == hasLikedCollection)&&(identical(other.likedItemCount, likedItemCount) || other.likedItemCount == likedItemCount)&&(identical(other.customCollectionCount, customCollectionCount) || other.customCollectionCount == customCollectionCount)&&(identical(other.totalEntryCount, totalEntryCount) || other.totalEntryCount == totalEntryCount)&&(identical(other.hasSettings, hasSettings) || other.hasSettings == hasSettings)&&const DeepCollectionEquality().equals(other.collections, collections)&&const DeepCollectionEquality().equals(other.conflictingCollectionNames, conflictingCollectionNames));
}


@override
int get hashCode => Object.hash(runtimeType,hasLikedCollection,likedItemCount,customCollectionCount,totalEntryCount,hasSettings,const DeepCollectionEquality().hash(collections),const DeepCollectionEquality().hash(conflictingCollectionNames));

@override
String toString() {
  return 'AppImportPreview(hasLikedCollection: $hasLikedCollection, likedItemCount: $likedItemCount, customCollectionCount: $customCollectionCount, totalEntryCount: $totalEntryCount, hasSettings: $hasSettings, collections: $collections, conflictingCollectionNames: $conflictingCollectionNames)';
}


}

/// @nodoc
abstract mixin class $AppImportPreviewCopyWith<$Res>  {
  factory $AppImportPreviewCopyWith(AppImportPreview value, $Res Function(AppImportPreview) _then) = _$AppImportPreviewCopyWithImpl;
@useResult
$Res call({
 bool hasLikedCollection, int likedItemCount, int customCollectionCount, int totalEntryCount, bool hasSettings, List<AppImportCollectionPreview> collections, Set<String> conflictingCollectionNames
});




}
/// @nodoc
class _$AppImportPreviewCopyWithImpl<$Res>
    implements $AppImportPreviewCopyWith<$Res> {
  _$AppImportPreviewCopyWithImpl(this._self, this._then);

  final AppImportPreview _self;
  final $Res Function(AppImportPreview) _then;

/// Create a copy of AppImportPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hasLikedCollection = null,Object? likedItemCount = null,Object? customCollectionCount = null,Object? totalEntryCount = null,Object? hasSettings = null,Object? collections = null,Object? conflictingCollectionNames = null,}) {
  return _then(_self.copyWith(
hasLikedCollection: null == hasLikedCollection ? _self.hasLikedCollection : hasLikedCollection // ignore: cast_nullable_to_non_nullable
as bool,likedItemCount: null == likedItemCount ? _self.likedItemCount : likedItemCount // ignore: cast_nullable_to_non_nullable
as int,customCollectionCount: null == customCollectionCount ? _self.customCollectionCount : customCollectionCount // ignore: cast_nullable_to_non_nullable
as int,totalEntryCount: null == totalEntryCount ? _self.totalEntryCount : totalEntryCount // ignore: cast_nullable_to_non_nullable
as int,hasSettings: null == hasSettings ? _self.hasSettings : hasSettings // ignore: cast_nullable_to_non_nullable
as bool,collections: null == collections ? _self.collections : collections // ignore: cast_nullable_to_non_nullable
as List<AppImportCollectionPreview>,conflictingCollectionNames: null == conflictingCollectionNames ? _self.conflictingCollectionNames : conflictingCollectionNames // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [AppImportPreview].
extension AppImportPreviewPatterns on AppImportPreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppImportPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppImportPreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppImportPreview value)  $default,){
final _that = this;
switch (_that) {
case _AppImportPreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppImportPreview value)?  $default,){
final _that = this;
switch (_that) {
case _AppImportPreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool hasLikedCollection,  int likedItemCount,  int customCollectionCount,  int totalEntryCount,  bool hasSettings,  List<AppImportCollectionPreview> collections,  Set<String> conflictingCollectionNames)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppImportPreview() when $default != null:
return $default(_that.hasLikedCollection,_that.likedItemCount,_that.customCollectionCount,_that.totalEntryCount,_that.hasSettings,_that.collections,_that.conflictingCollectionNames);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool hasLikedCollection,  int likedItemCount,  int customCollectionCount,  int totalEntryCount,  bool hasSettings,  List<AppImportCollectionPreview> collections,  Set<String> conflictingCollectionNames)  $default,) {final _that = this;
switch (_that) {
case _AppImportPreview():
return $default(_that.hasLikedCollection,_that.likedItemCount,_that.customCollectionCount,_that.totalEntryCount,_that.hasSettings,_that.collections,_that.conflictingCollectionNames);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool hasLikedCollection,  int likedItemCount,  int customCollectionCount,  int totalEntryCount,  bool hasSettings,  List<AppImportCollectionPreview> collections,  Set<String> conflictingCollectionNames)?  $default,) {final _that = this;
switch (_that) {
case _AppImportPreview() when $default != null:
return $default(_that.hasLikedCollection,_that.likedItemCount,_that.customCollectionCount,_that.totalEntryCount,_that.hasSettings,_that.collections,_that.conflictingCollectionNames);case _:
  return null;

}
}

}

/// @nodoc


class _AppImportPreview extends AppImportPreview {
  const _AppImportPreview({required this.hasLikedCollection, required this.likedItemCount, required this.customCollectionCount, required this.totalEntryCount, this.hasSettings = false, final  List<AppImportCollectionPreview> collections = const <AppImportCollectionPreview>[], final  Set<String> conflictingCollectionNames = const <String>{}}): _collections = collections,_conflictingCollectionNames = conflictingCollectionNames,super._();
  

@override final  bool hasLikedCollection;
@override final  int likedItemCount;
@override final  int customCollectionCount;
@override final  int totalEntryCount;
@override@JsonKey() final  bool hasSettings;
 final  List<AppImportCollectionPreview> _collections;
@override@JsonKey() List<AppImportCollectionPreview> get collections {
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


/// Create a copy of AppImportPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppImportPreviewCopyWith<_AppImportPreview> get copyWith => __$AppImportPreviewCopyWithImpl<_AppImportPreview>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppImportPreview&&(identical(other.hasLikedCollection, hasLikedCollection) || other.hasLikedCollection == hasLikedCollection)&&(identical(other.likedItemCount, likedItemCount) || other.likedItemCount == likedItemCount)&&(identical(other.customCollectionCount, customCollectionCount) || other.customCollectionCount == customCollectionCount)&&(identical(other.totalEntryCount, totalEntryCount) || other.totalEntryCount == totalEntryCount)&&(identical(other.hasSettings, hasSettings) || other.hasSettings == hasSettings)&&const DeepCollectionEquality().equals(other._collections, _collections)&&const DeepCollectionEquality().equals(other._conflictingCollectionNames, _conflictingCollectionNames));
}


@override
int get hashCode => Object.hash(runtimeType,hasLikedCollection,likedItemCount,customCollectionCount,totalEntryCount,hasSettings,const DeepCollectionEquality().hash(_collections),const DeepCollectionEquality().hash(_conflictingCollectionNames));

@override
String toString() {
  return 'AppImportPreview(hasLikedCollection: $hasLikedCollection, likedItemCount: $likedItemCount, customCollectionCount: $customCollectionCount, totalEntryCount: $totalEntryCount, hasSettings: $hasSettings, collections: $collections, conflictingCollectionNames: $conflictingCollectionNames)';
}


}

/// @nodoc
abstract mixin class _$AppImportPreviewCopyWith<$Res> implements $AppImportPreviewCopyWith<$Res> {
  factory _$AppImportPreviewCopyWith(_AppImportPreview value, $Res Function(_AppImportPreview) _then) = __$AppImportPreviewCopyWithImpl;
@override @useResult
$Res call({
 bool hasLikedCollection, int likedItemCount, int customCollectionCount, int totalEntryCount, bool hasSettings, List<AppImportCollectionPreview> collections, Set<String> conflictingCollectionNames
});




}
/// @nodoc
class __$AppImportPreviewCopyWithImpl<$Res>
    implements _$AppImportPreviewCopyWith<$Res> {
  __$AppImportPreviewCopyWithImpl(this._self, this._then);

  final _AppImportPreview _self;
  final $Res Function(_AppImportPreview) _then;

/// Create a copy of AppImportPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hasLikedCollection = null,Object? likedItemCount = null,Object? customCollectionCount = null,Object? totalEntryCount = null,Object? hasSettings = null,Object? collections = null,Object? conflictingCollectionNames = null,}) {
  return _then(_AppImportPreview(
hasLikedCollection: null == hasLikedCollection ? _self.hasLikedCollection : hasLikedCollection // ignore: cast_nullable_to_non_nullable
as bool,likedItemCount: null == likedItemCount ? _self.likedItemCount : likedItemCount // ignore: cast_nullable_to_non_nullable
as int,customCollectionCount: null == customCollectionCount ? _self.customCollectionCount : customCollectionCount // ignore: cast_nullable_to_non_nullable
as int,totalEntryCount: null == totalEntryCount ? _self.totalEntryCount : totalEntryCount // ignore: cast_nullable_to_non_nullable
as int,hasSettings: null == hasSettings ? _self.hasSettings : hasSettings // ignore: cast_nullable_to_non_nullable
as bool,collections: null == collections ? _self._collections : collections // ignore: cast_nullable_to_non_nullable
as List<AppImportCollectionPreview>,conflictingCollectionNames: null == conflictingCollectionNames ? _self._conflictingCollectionNames : conflictingCollectionNames // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

/// @nodoc
mixin _$AppImportCollectionPreview {

 String get sourceCollectionId; String get name; bool get isLikedCollection; int get itemCount; bool get hasNameConflict;
/// Create a copy of AppImportCollectionPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppImportCollectionPreviewCopyWith<AppImportCollectionPreview> get copyWith => _$AppImportCollectionPreviewCopyWithImpl<AppImportCollectionPreview>(this as AppImportCollectionPreview, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppImportCollectionPreview&&(identical(other.sourceCollectionId, sourceCollectionId) || other.sourceCollectionId == sourceCollectionId)&&(identical(other.name, name) || other.name == name)&&(identical(other.isLikedCollection, isLikedCollection) || other.isLikedCollection == isLikedCollection)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount)&&(identical(other.hasNameConflict, hasNameConflict) || other.hasNameConflict == hasNameConflict));
}


@override
int get hashCode => Object.hash(runtimeType,sourceCollectionId,name,isLikedCollection,itemCount,hasNameConflict);

@override
String toString() {
  return 'AppImportCollectionPreview(sourceCollectionId: $sourceCollectionId, name: $name, isLikedCollection: $isLikedCollection, itemCount: $itemCount, hasNameConflict: $hasNameConflict)';
}


}

/// @nodoc
abstract mixin class $AppImportCollectionPreviewCopyWith<$Res>  {
  factory $AppImportCollectionPreviewCopyWith(AppImportCollectionPreview value, $Res Function(AppImportCollectionPreview) _then) = _$AppImportCollectionPreviewCopyWithImpl;
@useResult
$Res call({
 String sourceCollectionId, String name, bool isLikedCollection, int itemCount, bool hasNameConflict
});




}
/// @nodoc
class _$AppImportCollectionPreviewCopyWithImpl<$Res>
    implements $AppImportCollectionPreviewCopyWith<$Res> {
  _$AppImportCollectionPreviewCopyWithImpl(this._self, this._then);

  final AppImportCollectionPreview _self;
  final $Res Function(AppImportCollectionPreview) _then;

/// Create a copy of AppImportCollectionPreview
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


/// Adds pattern-matching-related methods to [AppImportCollectionPreview].
extension AppImportCollectionPreviewPatterns on AppImportCollectionPreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppImportCollectionPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppImportCollectionPreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppImportCollectionPreview value)  $default,){
final _that = this;
switch (_that) {
case _AppImportCollectionPreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppImportCollectionPreview value)?  $default,){
final _that = this;
switch (_that) {
case _AppImportCollectionPreview() when $default != null:
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
case _AppImportCollectionPreview() when $default != null:
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
case _AppImportCollectionPreview():
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
case _AppImportCollectionPreview() when $default != null:
return $default(_that.sourceCollectionId,_that.name,_that.isLikedCollection,_that.itemCount,_that.hasNameConflict);case _:
  return null;

}
}

}

/// @nodoc


class _AppImportCollectionPreview implements AppImportCollectionPreview {
  const _AppImportCollectionPreview({required this.sourceCollectionId, required this.name, required this.isLikedCollection, required this.itemCount, required this.hasNameConflict});
  

@override final  String sourceCollectionId;
@override final  String name;
@override final  bool isLikedCollection;
@override final  int itemCount;
@override final  bool hasNameConflict;

/// Create a copy of AppImportCollectionPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppImportCollectionPreviewCopyWith<_AppImportCollectionPreview> get copyWith => __$AppImportCollectionPreviewCopyWithImpl<_AppImportCollectionPreview>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppImportCollectionPreview&&(identical(other.sourceCollectionId, sourceCollectionId) || other.sourceCollectionId == sourceCollectionId)&&(identical(other.name, name) || other.name == name)&&(identical(other.isLikedCollection, isLikedCollection) || other.isLikedCollection == isLikedCollection)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount)&&(identical(other.hasNameConflict, hasNameConflict) || other.hasNameConflict == hasNameConflict));
}


@override
int get hashCode => Object.hash(runtimeType,sourceCollectionId,name,isLikedCollection,itemCount,hasNameConflict);

@override
String toString() {
  return 'AppImportCollectionPreview(sourceCollectionId: $sourceCollectionId, name: $name, isLikedCollection: $isLikedCollection, itemCount: $itemCount, hasNameConflict: $hasNameConflict)';
}


}

/// @nodoc
abstract mixin class _$AppImportCollectionPreviewCopyWith<$Res> implements $AppImportCollectionPreviewCopyWith<$Res> {
  factory _$AppImportCollectionPreviewCopyWith(_AppImportCollectionPreview value, $Res Function(_AppImportCollectionPreview) _then) = __$AppImportCollectionPreviewCopyWithImpl;
@override @useResult
$Res call({
 String sourceCollectionId, String name, bool isLikedCollection, int itemCount, bool hasNameConflict
});




}
/// @nodoc
class __$AppImportCollectionPreviewCopyWithImpl<$Res>
    implements _$AppImportCollectionPreviewCopyWith<$Res> {
  __$AppImportCollectionPreviewCopyWithImpl(this._self, this._then);

  final _AppImportCollectionPreview _self;
  final $Res Function(_AppImportCollectionPreview) _then;

/// Create a copy of AppImportCollectionPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sourceCollectionId = null,Object? name = null,Object? isLikedCollection = null,Object? itemCount = null,Object? hasNameConflict = null,}) {
  return _then(_AppImportCollectionPreview(
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
