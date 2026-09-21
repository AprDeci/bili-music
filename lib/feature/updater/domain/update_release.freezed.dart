// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_release.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpdateAsset {

 String get name; String get downloadUrl; int get sizeBytes; String? get sha256Hex;
/// Create a copy of UpdateAsset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateAssetCopyWith<UpdateAsset> get copyWith => _$UpdateAssetCopyWithImpl<UpdateAsset>(this as UpdateAsset, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateAsset&&(identical(other.name, name) || other.name == name)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.sha256Hex, sha256Hex) || other.sha256Hex == sha256Hex));
}


@override
int get hashCode => Object.hash(runtimeType,name,downloadUrl,sizeBytes,sha256Hex);

@override
String toString() {
  return 'UpdateAsset(name: $name, downloadUrl: $downloadUrl, sizeBytes: $sizeBytes, sha256Hex: $sha256Hex)';
}


}

/// @nodoc
abstract mixin class $UpdateAssetCopyWith<$Res>  {
  factory $UpdateAssetCopyWith(UpdateAsset value, $Res Function(UpdateAsset) _then) = _$UpdateAssetCopyWithImpl;
@useResult
$Res call({
 String name, String downloadUrl, int sizeBytes, String? sha256Hex
});




}
/// @nodoc
class _$UpdateAssetCopyWithImpl<$Res>
    implements $UpdateAssetCopyWith<$Res> {
  _$UpdateAssetCopyWithImpl(this._self, this._then);

  final UpdateAsset _self;
  final $Res Function(UpdateAsset) _then;

/// Create a copy of UpdateAsset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? downloadUrl = null,Object? sizeBytes = null,Object? sha256Hex = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,sha256Hex: freezed == sha256Hex ? _self.sha256Hex : sha256Hex // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateAsset].
extension UpdateAssetPatterns on UpdateAsset {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateAsset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateAsset() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateAsset value)  $default,){
final _that = this;
switch (_that) {
case _UpdateAsset():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateAsset value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateAsset() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String downloadUrl,  int sizeBytes,  String? sha256Hex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateAsset() when $default != null:
return $default(_that.name,_that.downloadUrl,_that.sizeBytes,_that.sha256Hex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String downloadUrl,  int sizeBytes,  String? sha256Hex)  $default,) {final _that = this;
switch (_that) {
case _UpdateAsset():
return $default(_that.name,_that.downloadUrl,_that.sizeBytes,_that.sha256Hex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String downloadUrl,  int sizeBytes,  String? sha256Hex)?  $default,) {final _that = this;
switch (_that) {
case _UpdateAsset() when $default != null:
return $default(_that.name,_that.downloadUrl,_that.sizeBytes,_that.sha256Hex);case _:
  return null;

}
}

}

/// @nodoc


class _UpdateAsset extends UpdateAsset {
  const _UpdateAsset({required this.name, required this.downloadUrl, this.sizeBytes = 0, this.sha256Hex}): super._();
  

@override final  String name;
@override final  String downloadUrl;
@override@JsonKey() final  int sizeBytes;
@override final  String? sha256Hex;

/// Create a copy of UpdateAsset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateAssetCopyWith<_UpdateAsset> get copyWith => __$UpdateAssetCopyWithImpl<_UpdateAsset>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateAsset&&(identical(other.name, name) || other.name == name)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.sha256Hex, sha256Hex) || other.sha256Hex == sha256Hex));
}


@override
int get hashCode => Object.hash(runtimeType,name,downloadUrl,sizeBytes,sha256Hex);

@override
String toString() {
  return 'UpdateAsset(name: $name, downloadUrl: $downloadUrl, sizeBytes: $sizeBytes, sha256Hex: $sha256Hex)';
}


}

/// @nodoc
abstract mixin class _$UpdateAssetCopyWith<$Res> implements $UpdateAssetCopyWith<$Res> {
  factory _$UpdateAssetCopyWith(_UpdateAsset value, $Res Function(_UpdateAsset) _then) = __$UpdateAssetCopyWithImpl;
@override @useResult
$Res call({
 String name, String downloadUrl, int sizeBytes, String? sha256Hex
});




}
/// @nodoc
class __$UpdateAssetCopyWithImpl<$Res>
    implements _$UpdateAssetCopyWith<$Res> {
  __$UpdateAssetCopyWithImpl(this._self, this._then);

  final _UpdateAsset _self;
  final $Res Function(_UpdateAsset) _then;

/// Create a copy of UpdateAsset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? downloadUrl = null,Object? sizeBytes = null,Object? sha256Hex = freezed,}) {
  return _then(_UpdateAsset(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,sha256Hex: freezed == sha256Hex ? _self.sha256Hex : sha256Hex // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$UpdateRelease {

 String get tagName; String get title; String get body; String get htmlUrl; List<UpdateAsset> get assets;
/// Create a copy of UpdateRelease
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateReleaseCopyWith<UpdateRelease> get copyWith => _$UpdateReleaseCopyWithImpl<UpdateRelease>(this as UpdateRelease, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateRelease&&(identical(other.tagName, tagName) || other.tagName == tagName)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.htmlUrl, htmlUrl) || other.htmlUrl == htmlUrl)&&const DeepCollectionEquality().equals(other.assets, assets));
}


@override
int get hashCode => Object.hash(runtimeType,tagName,title,body,htmlUrl,const DeepCollectionEquality().hash(assets));

@override
String toString() {
  return 'UpdateRelease(tagName: $tagName, title: $title, body: $body, htmlUrl: $htmlUrl, assets: $assets)';
}


}

/// @nodoc
abstract mixin class $UpdateReleaseCopyWith<$Res>  {
  factory $UpdateReleaseCopyWith(UpdateRelease value, $Res Function(UpdateRelease) _then) = _$UpdateReleaseCopyWithImpl;
@useResult
$Res call({
 String tagName, String title, String body, String htmlUrl, List<UpdateAsset> assets
});




}
/// @nodoc
class _$UpdateReleaseCopyWithImpl<$Res>
    implements $UpdateReleaseCopyWith<$Res> {
  _$UpdateReleaseCopyWithImpl(this._self, this._then);

  final UpdateRelease _self;
  final $Res Function(UpdateRelease) _then;

/// Create a copy of UpdateRelease
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tagName = null,Object? title = null,Object? body = null,Object? htmlUrl = null,Object? assets = null,}) {
  return _then(_self.copyWith(
tagName: null == tagName ? _self.tagName : tagName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,htmlUrl: null == htmlUrl ? _self.htmlUrl : htmlUrl // ignore: cast_nullable_to_non_nullable
as String,assets: null == assets ? _self.assets : assets // ignore: cast_nullable_to_non_nullable
as List<UpdateAsset>,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateRelease].
extension UpdateReleasePatterns on UpdateRelease {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateRelease value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateRelease() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateRelease value)  $default,){
final _that = this;
switch (_that) {
case _UpdateRelease():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateRelease value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateRelease() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tagName,  String title,  String body,  String htmlUrl,  List<UpdateAsset> assets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateRelease() when $default != null:
return $default(_that.tagName,_that.title,_that.body,_that.htmlUrl,_that.assets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tagName,  String title,  String body,  String htmlUrl,  List<UpdateAsset> assets)  $default,) {final _that = this;
switch (_that) {
case _UpdateRelease():
return $default(_that.tagName,_that.title,_that.body,_that.htmlUrl,_that.assets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tagName,  String title,  String body,  String htmlUrl,  List<UpdateAsset> assets)?  $default,) {final _that = this;
switch (_that) {
case _UpdateRelease() when $default != null:
return $default(_that.tagName,_that.title,_that.body,_that.htmlUrl,_that.assets);case _:
  return null;

}
}

}

/// @nodoc


class _UpdateRelease extends UpdateRelease {
  const _UpdateRelease({required this.tagName, required this.title, required this.body, required this.htmlUrl, final  List<UpdateAsset> assets = const <UpdateAsset>[]}): _assets = assets,super._();
  

@override final  String tagName;
@override final  String title;
@override final  String body;
@override final  String htmlUrl;
 final  List<UpdateAsset> _assets;
@override@JsonKey() List<UpdateAsset> get assets {
  if (_assets is EqualUnmodifiableListView) return _assets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assets);
}


/// Create a copy of UpdateRelease
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateReleaseCopyWith<_UpdateRelease> get copyWith => __$UpdateReleaseCopyWithImpl<_UpdateRelease>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateRelease&&(identical(other.tagName, tagName) || other.tagName == tagName)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.htmlUrl, htmlUrl) || other.htmlUrl == htmlUrl)&&const DeepCollectionEquality().equals(other._assets, _assets));
}


@override
int get hashCode => Object.hash(runtimeType,tagName,title,body,htmlUrl,const DeepCollectionEquality().hash(_assets));

@override
String toString() {
  return 'UpdateRelease(tagName: $tagName, title: $title, body: $body, htmlUrl: $htmlUrl, assets: $assets)';
}


}

/// @nodoc
abstract mixin class _$UpdateReleaseCopyWith<$Res> implements $UpdateReleaseCopyWith<$Res> {
  factory _$UpdateReleaseCopyWith(_UpdateRelease value, $Res Function(_UpdateRelease) _then) = __$UpdateReleaseCopyWithImpl;
@override @useResult
$Res call({
 String tagName, String title, String body, String htmlUrl, List<UpdateAsset> assets
});




}
/// @nodoc
class __$UpdateReleaseCopyWithImpl<$Res>
    implements _$UpdateReleaseCopyWith<$Res> {
  __$UpdateReleaseCopyWithImpl(this._self, this._then);

  final _UpdateRelease _self;
  final $Res Function(_UpdateRelease) _then;

/// Create a copy of UpdateRelease
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tagName = null,Object? title = null,Object? body = null,Object? htmlUrl = null,Object? assets = null,}) {
  return _then(_UpdateRelease(
tagName: null == tagName ? _self.tagName : tagName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,htmlUrl: null == htmlUrl ? _self.htmlUrl : htmlUrl // ignore: cast_nullable_to_non_nullable
as String,assets: null == assets ? _self._assets : assets // ignore: cast_nullable_to_non_nullable
as List<UpdateAsset>,
  ));
}


}

// dart format on
