// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_user_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchUserItem {

 int get mid; String get name; String get avatarUrl; String get sign; String get fansText; String get videoCountText; int get level; String? get officialTitle;
/// Create a copy of SearchUserItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchUserItemCopyWith<SearchUserItem> get copyWith => _$SearchUserItemCopyWithImpl<SearchUserItem>(this as SearchUserItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchUserItem&&(identical(other.mid, mid) || other.mid == mid)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.sign, sign) || other.sign == sign)&&(identical(other.fansText, fansText) || other.fansText == fansText)&&(identical(other.videoCountText, videoCountText) || other.videoCountText == videoCountText)&&(identical(other.level, level) || other.level == level)&&(identical(other.officialTitle, officialTitle) || other.officialTitle == officialTitle));
}


@override
int get hashCode => Object.hash(runtimeType,mid,name,avatarUrl,sign,fansText,videoCountText,level,officialTitle);

@override
String toString() {
  return 'SearchUserItem(mid: $mid, name: $name, avatarUrl: $avatarUrl, sign: $sign, fansText: $fansText, videoCountText: $videoCountText, level: $level, officialTitle: $officialTitle)';
}


}

/// @nodoc
abstract mixin class $SearchUserItemCopyWith<$Res>  {
  factory $SearchUserItemCopyWith(SearchUserItem value, $Res Function(SearchUserItem) _then) = _$SearchUserItemCopyWithImpl;
@useResult
$Res call({
 int mid, String name, String avatarUrl, String sign, String fansText, String videoCountText, int level, String? officialTitle
});




}
/// @nodoc
class _$SearchUserItemCopyWithImpl<$Res>
    implements $SearchUserItemCopyWith<$Res> {
  _$SearchUserItemCopyWithImpl(this._self, this._then);

  final SearchUserItem _self;
  final $Res Function(SearchUserItem) _then;

/// Create a copy of SearchUserItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mid = null,Object? name = null,Object? avatarUrl = null,Object? sign = null,Object? fansText = null,Object? videoCountText = null,Object? level = null,Object? officialTitle = freezed,}) {
  return _then(_self.copyWith(
mid: null == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,sign: null == sign ? _self.sign : sign // ignore: cast_nullable_to_non_nullable
as String,fansText: null == fansText ? _self.fansText : fansText // ignore: cast_nullable_to_non_nullable
as String,videoCountText: null == videoCountText ? _self.videoCountText : videoCountText // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,officialTitle: freezed == officialTitle ? _self.officialTitle : officialTitle // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchUserItem].
extension SearchUserItemPatterns on SearchUserItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchUserItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchUserItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchUserItem value)  $default,){
final _that = this;
switch (_that) {
case _SearchUserItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchUserItem value)?  $default,){
final _that = this;
switch (_that) {
case _SearchUserItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int mid,  String name,  String avatarUrl,  String sign,  String fansText,  String videoCountText,  int level,  String? officialTitle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchUserItem() when $default != null:
return $default(_that.mid,_that.name,_that.avatarUrl,_that.sign,_that.fansText,_that.videoCountText,_that.level,_that.officialTitle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int mid,  String name,  String avatarUrl,  String sign,  String fansText,  String videoCountText,  int level,  String? officialTitle)  $default,) {final _that = this;
switch (_that) {
case _SearchUserItem():
return $default(_that.mid,_that.name,_that.avatarUrl,_that.sign,_that.fansText,_that.videoCountText,_that.level,_that.officialTitle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int mid,  String name,  String avatarUrl,  String sign,  String fansText,  String videoCountText,  int level,  String? officialTitle)?  $default,) {final _that = this;
switch (_that) {
case _SearchUserItem() when $default != null:
return $default(_that.mid,_that.name,_that.avatarUrl,_that.sign,_that.fansText,_that.videoCountText,_that.level,_that.officialTitle);case _:
  return null;

}
}

}

/// @nodoc


class _SearchUserItem implements SearchUserItem {
  const _SearchUserItem({required this.mid, required this.name, required this.avatarUrl, required this.sign, required this.fansText, required this.videoCountText, required this.level, this.officialTitle});
  

@override final  int mid;
@override final  String name;
@override final  String avatarUrl;
@override final  String sign;
@override final  String fansText;
@override final  String videoCountText;
@override final  int level;
@override final  String? officialTitle;

/// Create a copy of SearchUserItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchUserItemCopyWith<_SearchUserItem> get copyWith => __$SearchUserItemCopyWithImpl<_SearchUserItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchUserItem&&(identical(other.mid, mid) || other.mid == mid)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.sign, sign) || other.sign == sign)&&(identical(other.fansText, fansText) || other.fansText == fansText)&&(identical(other.videoCountText, videoCountText) || other.videoCountText == videoCountText)&&(identical(other.level, level) || other.level == level)&&(identical(other.officialTitle, officialTitle) || other.officialTitle == officialTitle));
}


@override
int get hashCode => Object.hash(runtimeType,mid,name,avatarUrl,sign,fansText,videoCountText,level,officialTitle);

@override
String toString() {
  return 'SearchUserItem(mid: $mid, name: $name, avatarUrl: $avatarUrl, sign: $sign, fansText: $fansText, videoCountText: $videoCountText, level: $level, officialTitle: $officialTitle)';
}


}

/// @nodoc
abstract mixin class _$SearchUserItemCopyWith<$Res> implements $SearchUserItemCopyWith<$Res> {
  factory _$SearchUserItemCopyWith(_SearchUserItem value, $Res Function(_SearchUserItem) _then) = __$SearchUserItemCopyWithImpl;
@override @useResult
$Res call({
 int mid, String name, String avatarUrl, String sign, String fansText, String videoCountText, int level, String? officialTitle
});




}
/// @nodoc
class __$SearchUserItemCopyWithImpl<$Res>
    implements _$SearchUserItemCopyWith<$Res> {
  __$SearchUserItemCopyWithImpl(this._self, this._then);

  final _SearchUserItem _self;
  final $Res Function(_SearchUserItem) _then;

/// Create a copy of SearchUserItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mid = null,Object? name = null,Object? avatarUrl = null,Object? sign = null,Object? fansText = null,Object? videoCountText = null,Object? level = null,Object? officialTitle = freezed,}) {
  return _then(_SearchUserItem(
mid: null == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,sign: null == sign ? _self.sign : sign // ignore: cast_nullable_to_non_nullable
as String,fansText: null == fansText ? _self.fansText : fansText // ignore: cast_nullable_to_non_nullable
as String,videoCountText: null == videoCountText ? _self.videoCountText : videoCountText // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,officialTitle: freezed == officialTitle ? _self.officialTitle : officialTitle // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
