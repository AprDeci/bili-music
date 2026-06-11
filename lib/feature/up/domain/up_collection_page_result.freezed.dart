// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'up_collection_page_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpCollectionPageResult {

 List<UpCollection> get items; int get page; bool get hasMore;
/// Create a copy of UpCollectionPageResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpCollectionPageResultCopyWith<UpCollectionPageResult> get copyWith => _$UpCollectionPageResultCopyWithImpl<UpCollectionPageResult>(this as UpCollectionPageResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpCollectionPageResult&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.page, page) || other.page == page)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),page,hasMore);

@override
String toString() {
  return 'UpCollectionPageResult(items: $items, page: $page, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $UpCollectionPageResultCopyWith<$Res>  {
  factory $UpCollectionPageResultCopyWith(UpCollectionPageResult value, $Res Function(UpCollectionPageResult) _then) = _$UpCollectionPageResultCopyWithImpl;
@useResult
$Res call({
 List<UpCollection> items, int page, bool hasMore
});




}
/// @nodoc
class _$UpCollectionPageResultCopyWithImpl<$Res>
    implements $UpCollectionPageResultCopyWith<$Res> {
  _$UpCollectionPageResultCopyWithImpl(this._self, this._then);

  final UpCollectionPageResult _self;
  final $Res Function(UpCollectionPageResult) _then;

/// Create a copy of UpCollectionPageResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? page = null,Object? hasMore = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<UpCollection>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UpCollectionPageResult].
extension UpCollectionPageResultPatterns on UpCollectionPageResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpCollectionPageResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpCollectionPageResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpCollectionPageResult value)  $default,){
final _that = this;
switch (_that) {
case _UpCollectionPageResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpCollectionPageResult value)?  $default,){
final _that = this;
switch (_that) {
case _UpCollectionPageResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<UpCollection> items,  int page,  bool hasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpCollectionPageResult() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<UpCollection> items,  int page,  bool hasMore)  $default,) {final _that = this;
switch (_that) {
case _UpCollectionPageResult():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<UpCollection> items,  int page,  bool hasMore)?  $default,) {final _that = this;
switch (_that) {
case _UpCollectionPageResult() when $default != null:
return $default(_that.items,_that.page,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc


class _UpCollectionPageResult implements UpCollectionPageResult {
  const _UpCollectionPageResult({required final  List<UpCollection> items, required this.page, required this.hasMore}): _items = items;
  

 final  List<UpCollection> _items;
@override List<UpCollection> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int page;
@override final  bool hasMore;

/// Create a copy of UpCollectionPageResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpCollectionPageResultCopyWith<_UpCollectionPageResult> get copyWith => __$UpCollectionPageResultCopyWithImpl<_UpCollectionPageResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpCollectionPageResult&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.page, page) || other.page == page)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),page,hasMore);

@override
String toString() {
  return 'UpCollectionPageResult(items: $items, page: $page, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$UpCollectionPageResultCopyWith<$Res> implements $UpCollectionPageResultCopyWith<$Res> {
  factory _$UpCollectionPageResultCopyWith(_UpCollectionPageResult value, $Res Function(_UpCollectionPageResult) _then) = __$UpCollectionPageResultCopyWithImpl;
@override @useResult
$Res call({
 List<UpCollection> items, int page, bool hasMore
});




}
/// @nodoc
class __$UpCollectionPageResultCopyWithImpl<$Res>
    implements _$UpCollectionPageResultCopyWith<$Res> {
  __$UpCollectionPageResultCopyWithImpl(this._self, this._then);

  final _UpCollectionPageResult _self;
  final $Res Function(_UpCollectionPageResult) _then;

/// Create a copy of UpCollectionPageResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? page = null,Object? hasMore = null,}) {
  return _then(_UpCollectionPageResult(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<UpCollection>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
