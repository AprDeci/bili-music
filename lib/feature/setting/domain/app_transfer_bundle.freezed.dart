// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_transfer_bundle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppTransferBundle {

 int get schemaVersion; DateTime get exportedAt; FavoritesTransferBundle get favorites; Map<String, String> get settings;
/// Create a copy of AppTransferBundle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppTransferBundleCopyWith<AppTransferBundle> get copyWith => _$AppTransferBundleCopyWithImpl<AppTransferBundle>(this as AppTransferBundle, _$identity);

  /// Serializes this AppTransferBundle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppTransferBundle&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.exportedAt, exportedAt) || other.exportedAt == exportedAt)&&(identical(other.favorites, favorites) || other.favorites == favorites)&&const DeepCollectionEquality().equals(other.settings, settings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,exportedAt,favorites,const DeepCollectionEquality().hash(settings));

@override
String toString() {
  return 'AppTransferBundle(schemaVersion: $schemaVersion, exportedAt: $exportedAt, favorites: $favorites, settings: $settings)';
}


}

/// @nodoc
abstract mixin class $AppTransferBundleCopyWith<$Res>  {
  factory $AppTransferBundleCopyWith(AppTransferBundle value, $Res Function(AppTransferBundle) _then) = _$AppTransferBundleCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, DateTime exportedAt, FavoritesTransferBundle favorites, Map<String, String> settings
});


$FavoritesTransferBundleCopyWith<$Res> get favorites;

}
/// @nodoc
class _$AppTransferBundleCopyWithImpl<$Res>
    implements $AppTransferBundleCopyWith<$Res> {
  _$AppTransferBundleCopyWithImpl(this._self, this._then);

  final AppTransferBundle _self;
  final $Res Function(AppTransferBundle) _then;

/// Create a copy of AppTransferBundle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? exportedAt = null,Object? favorites = null,Object? settings = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,exportedAt: null == exportedAt ? _self.exportedAt : exportedAt // ignore: cast_nullable_to_non_nullable
as DateTime,favorites: null == favorites ? _self.favorites : favorites // ignore: cast_nullable_to_non_nullable
as FavoritesTransferBundle,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}
/// Create a copy of AppTransferBundle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FavoritesTransferBundleCopyWith<$Res> get favorites {
  
  return $FavoritesTransferBundleCopyWith<$Res>(_self.favorites, (value) {
    return _then(_self.copyWith(favorites: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppTransferBundle].
extension AppTransferBundlePatterns on AppTransferBundle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppTransferBundle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppTransferBundle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppTransferBundle value)  $default,){
final _that = this;
switch (_that) {
case _AppTransferBundle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppTransferBundle value)?  $default,){
final _that = this;
switch (_that) {
case _AppTransferBundle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  DateTime exportedAt,  FavoritesTransferBundle favorites,  Map<String, String> settings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppTransferBundle() when $default != null:
return $default(_that.schemaVersion,_that.exportedAt,_that.favorites,_that.settings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  DateTime exportedAt,  FavoritesTransferBundle favorites,  Map<String, String> settings)  $default,) {final _that = this;
switch (_that) {
case _AppTransferBundle():
return $default(_that.schemaVersion,_that.exportedAt,_that.favorites,_that.settings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  DateTime exportedAt,  FavoritesTransferBundle favorites,  Map<String, String> settings)?  $default,) {final _that = this;
switch (_that) {
case _AppTransferBundle() when $default != null:
return $default(_that.schemaVersion,_that.exportedAt,_that.favorites,_that.settings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppTransferBundle extends AppTransferBundle {
  const _AppTransferBundle({this.schemaVersion = 2, required this.exportedAt, required this.favorites, final  Map<String, String> settings = const <String, String>{}}): _settings = settings,super._();
  factory _AppTransferBundle.fromJson(Map<String, dynamic> json) => _$AppTransferBundleFromJson(json);

@override@JsonKey() final  int schemaVersion;
@override final  DateTime exportedAt;
@override final  FavoritesTransferBundle favorites;
 final  Map<String, String> _settings;
@override@JsonKey() Map<String, String> get settings {
  if (_settings is EqualUnmodifiableMapView) return _settings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_settings);
}


/// Create a copy of AppTransferBundle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppTransferBundleCopyWith<_AppTransferBundle> get copyWith => __$AppTransferBundleCopyWithImpl<_AppTransferBundle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppTransferBundleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppTransferBundle&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.exportedAt, exportedAt) || other.exportedAt == exportedAt)&&(identical(other.favorites, favorites) || other.favorites == favorites)&&const DeepCollectionEquality().equals(other._settings, _settings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,exportedAt,favorites,const DeepCollectionEquality().hash(_settings));

@override
String toString() {
  return 'AppTransferBundle(schemaVersion: $schemaVersion, exportedAt: $exportedAt, favorites: $favorites, settings: $settings)';
}


}

/// @nodoc
abstract mixin class _$AppTransferBundleCopyWith<$Res> implements $AppTransferBundleCopyWith<$Res> {
  factory _$AppTransferBundleCopyWith(_AppTransferBundle value, $Res Function(_AppTransferBundle) _then) = __$AppTransferBundleCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, DateTime exportedAt, FavoritesTransferBundle favorites, Map<String, String> settings
});


@override $FavoritesTransferBundleCopyWith<$Res> get favorites;

}
/// @nodoc
class __$AppTransferBundleCopyWithImpl<$Res>
    implements _$AppTransferBundleCopyWith<$Res> {
  __$AppTransferBundleCopyWithImpl(this._self, this._then);

  final _AppTransferBundle _self;
  final $Res Function(_AppTransferBundle) _then;

/// Create a copy of AppTransferBundle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? exportedAt = null,Object? favorites = null,Object? settings = null,}) {
  return _then(_AppTransferBundle(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,exportedAt: null == exportedAt ? _self.exportedAt : exportedAt // ignore: cast_nullable_to_non_nullable
as DateTime,favorites: null == favorites ? _self.favorites : favorites // ignore: cast_nullable_to_non_nullable
as FavoritesTransferBundle,settings: null == settings ? _self._settings : settings // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

/// Create a copy of AppTransferBundle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FavoritesTransferBundleCopyWith<$Res> get favorites {
  
  return $FavoritesTransferBundleCopyWith<$Res>(_self.favorites, (value) {
    return _then(_self.copyWith(favorites: value));
  });
}
}

// dart format on
