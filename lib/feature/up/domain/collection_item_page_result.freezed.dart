// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collection_item_page_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CollectionItemPageResult {

 UpCollection get collection; List<UpCollectionItem> get items; int get page; bool get hasMore;
/// Create a copy of CollectionItemPageResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CollectionItemPageResultCopyWith<CollectionItemPageResult> get copyWith => _$CollectionItemPageResultCopyWithImpl<CollectionItemPageResult>(this as CollectionItemPageResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CollectionItemPageResult&&(identical(other.collection, collection) || other.collection == collection)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.page, page) || other.page == page)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}


@override
int get hashCode => Object.hash(runtimeType,collection,const DeepCollectionEquality().hash(items),page,hasMore);

@override
String toString() {
  return 'CollectionItemPageResult(collection: $collection, items: $items, page: $page, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $CollectionItemPageResultCopyWith<$Res>  {
  factory $CollectionItemPageResultCopyWith(CollectionItemPageResult value, $Res Function(CollectionItemPageResult) _then) = _$CollectionItemPageResultCopyWithImpl;
@useResult
$Res call({
 UpCollection collection, List<UpCollectionItem> items, int page, bool hasMore
});


$UpCollectionCopyWith<$Res> get collection;

}
/// @nodoc
class _$CollectionItemPageResultCopyWithImpl<$Res>
    implements $CollectionItemPageResultCopyWith<$Res> {
  _$CollectionItemPageResultCopyWithImpl(this._self, this._then);

  final CollectionItemPageResult _self;
  final $Res Function(CollectionItemPageResult) _then;

/// Create a copy of CollectionItemPageResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? collection = null,Object? items = null,Object? page = null,Object? hasMore = null,}) {
  return _then(_self.copyWith(
collection: null == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as UpCollection,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<UpCollectionItem>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of CollectionItemPageResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpCollectionCopyWith<$Res> get collection {
  
  return $UpCollectionCopyWith<$Res>(_self.collection, (value) {
    return _then(_self.copyWith(collection: value));
  });
}
}


/// Adds pattern-matching-related methods to [CollectionItemPageResult].
extension CollectionItemPageResultPatterns on CollectionItemPageResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CollectionItemPageResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CollectionItemPageResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CollectionItemPageResult value)  $default,){
final _that = this;
switch (_that) {
case _CollectionItemPageResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CollectionItemPageResult value)?  $default,){
final _that = this;
switch (_that) {
case _CollectionItemPageResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UpCollection collection,  List<UpCollectionItem> items,  int page,  bool hasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CollectionItemPageResult() when $default != null:
return $default(_that.collection,_that.items,_that.page,_that.hasMore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UpCollection collection,  List<UpCollectionItem> items,  int page,  bool hasMore)  $default,) {final _that = this;
switch (_that) {
case _CollectionItemPageResult():
return $default(_that.collection,_that.items,_that.page,_that.hasMore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UpCollection collection,  List<UpCollectionItem> items,  int page,  bool hasMore)?  $default,) {final _that = this;
switch (_that) {
case _CollectionItemPageResult() when $default != null:
return $default(_that.collection,_that.items,_that.page,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc


class _CollectionItemPageResult implements CollectionItemPageResult {
  const _CollectionItemPageResult({required this.collection, required final  List<UpCollectionItem> items, required this.page, required this.hasMore}): _items = items;
  

@override final  UpCollection collection;
 final  List<UpCollectionItem> _items;
@override List<UpCollectionItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int page;
@override final  bool hasMore;

/// Create a copy of CollectionItemPageResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CollectionItemPageResultCopyWith<_CollectionItemPageResult> get copyWith => __$CollectionItemPageResultCopyWithImpl<_CollectionItemPageResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CollectionItemPageResult&&(identical(other.collection, collection) || other.collection == collection)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.page, page) || other.page == page)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}


@override
int get hashCode => Object.hash(runtimeType,collection,const DeepCollectionEquality().hash(_items),page,hasMore);

@override
String toString() {
  return 'CollectionItemPageResult(collection: $collection, items: $items, page: $page, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$CollectionItemPageResultCopyWith<$Res> implements $CollectionItemPageResultCopyWith<$Res> {
  factory _$CollectionItemPageResultCopyWith(_CollectionItemPageResult value, $Res Function(_CollectionItemPageResult) _then) = __$CollectionItemPageResultCopyWithImpl;
@override @useResult
$Res call({
 UpCollection collection, List<UpCollectionItem> items, int page, bool hasMore
});


@override $UpCollectionCopyWith<$Res> get collection;

}
/// @nodoc
class __$CollectionItemPageResultCopyWithImpl<$Res>
    implements _$CollectionItemPageResultCopyWith<$Res> {
  __$CollectionItemPageResultCopyWithImpl(this._self, this._then);

  final _CollectionItemPageResult _self;
  final $Res Function(_CollectionItemPageResult) _then;

/// Create a copy of CollectionItemPageResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? collection = null,Object? items = null,Object? page = null,Object? hasMore = null,}) {
  return _then(_CollectionItemPageResult(
collection: null == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as UpCollection,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<UpCollectionItem>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of CollectionItemPageResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpCollectionCopyWith<$Res> get collection {
  
  return $UpCollectionCopyWith<$Res>(_self.collection, (value) {
    return _then(_self.copyWith(collection: value));
  });
}
}

// dart format on
