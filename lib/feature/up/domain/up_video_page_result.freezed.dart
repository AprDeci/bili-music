// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'up_video_page_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpVideoPageResult {

 List<UpVideoItem> get items; int get page; bool get hasMore;
/// Create a copy of UpVideoPageResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpVideoPageResultCopyWith<UpVideoPageResult> get copyWith => _$UpVideoPageResultCopyWithImpl<UpVideoPageResult>(this as UpVideoPageResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpVideoPageResult&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.page, page) || other.page == page)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),page,hasMore);

@override
String toString() {
  return 'UpVideoPageResult(items: $items, page: $page, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $UpVideoPageResultCopyWith<$Res>  {
  factory $UpVideoPageResultCopyWith(UpVideoPageResult value, $Res Function(UpVideoPageResult) _then) = _$UpVideoPageResultCopyWithImpl;
@useResult
$Res call({
 List<UpVideoItem> items, int page, bool hasMore
});




}
/// @nodoc
class _$UpVideoPageResultCopyWithImpl<$Res>
    implements $UpVideoPageResultCopyWith<$Res> {
  _$UpVideoPageResultCopyWithImpl(this._self, this._then);

  final UpVideoPageResult _self;
  final $Res Function(UpVideoPageResult) _then;

/// Create a copy of UpVideoPageResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? page = null,Object? hasMore = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<UpVideoItem>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UpVideoPageResult].
extension UpVideoPageResultPatterns on UpVideoPageResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpVideoPageResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpVideoPageResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpVideoPageResult value)  $default,){
final _that = this;
switch (_that) {
case _UpVideoPageResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpVideoPageResult value)?  $default,){
final _that = this;
switch (_that) {
case _UpVideoPageResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<UpVideoItem> items,  int page,  bool hasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpVideoPageResult() when $default != null:
return $default(_that.items,_that.page,_that.hasMore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<UpVideoItem> items,  int page,  bool hasMore)  $default,) {final _that = this;
switch (_that) {
case _UpVideoPageResult():
return $default(_that.items,_that.page,_that.hasMore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<UpVideoItem> items,  int page,  bool hasMore)?  $default,) {final _that = this;
switch (_that) {
case _UpVideoPageResult() when $default != null:
return $default(_that.items,_that.page,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc


class _UpVideoPageResult implements UpVideoPageResult {
  const _UpVideoPageResult({required final  List<UpVideoItem> items, required this.page, required this.hasMore}): _items = items;
  

 final  List<UpVideoItem> _items;
@override List<UpVideoItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int page;
@override final  bool hasMore;

/// Create a copy of UpVideoPageResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpVideoPageResultCopyWith<_UpVideoPageResult> get copyWith => __$UpVideoPageResultCopyWithImpl<_UpVideoPageResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpVideoPageResult&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.page, page) || other.page == page)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),page,hasMore);

@override
String toString() {
  return 'UpVideoPageResult(items: $items, page: $page, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$UpVideoPageResultCopyWith<$Res> implements $UpVideoPageResultCopyWith<$Res> {
  factory _$UpVideoPageResultCopyWith(_UpVideoPageResult value, $Res Function(_UpVideoPageResult) _then) = __$UpVideoPageResultCopyWithImpl;
@override @useResult
$Res call({
 List<UpVideoItem> items, int page, bool hasMore
});




}
/// @nodoc
class __$UpVideoPageResultCopyWithImpl<$Res>
    implements _$UpVideoPageResultCopyWith<$Res> {
  __$UpVideoPageResultCopyWithImpl(this._self, this._then);

  final _UpVideoPageResult _self;
  final $Res Function(_UpVideoPageResult) _then;

/// Create a copy of UpVideoPageResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? page = null,Object? hasMore = null,}) {
  return _then(_UpVideoPageResult(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<UpVideoItem>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
