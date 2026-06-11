// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collection_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CollectionDetailState {

 UpCollection? get collection; List<UpCollectionItem> get items; int get page; bool get hasMore; bool get isLoadingMore; String? get error; String? get loadMoreError;
/// Create a copy of CollectionDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CollectionDetailStateCopyWith<CollectionDetailState> get copyWith => _$CollectionDetailStateCopyWithImpl<CollectionDetailState>(this as CollectionDetailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CollectionDetailState&&(identical(other.collection, collection) || other.collection == collection)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.page, page) || other.page == page)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.error, error) || other.error == error)&&(identical(other.loadMoreError, loadMoreError) || other.loadMoreError == loadMoreError));
}


@override
int get hashCode => Object.hash(runtimeType,collection,const DeepCollectionEquality().hash(items),page,hasMore,isLoadingMore,error,loadMoreError);

@override
String toString() {
  return 'CollectionDetailState(collection: $collection, items: $items, page: $page, hasMore: $hasMore, isLoadingMore: $isLoadingMore, error: $error, loadMoreError: $loadMoreError)';
}


}

/// @nodoc
abstract mixin class $CollectionDetailStateCopyWith<$Res>  {
  factory $CollectionDetailStateCopyWith(CollectionDetailState value, $Res Function(CollectionDetailState) _then) = _$CollectionDetailStateCopyWithImpl;
@useResult
$Res call({
 UpCollection? collection, List<UpCollectionItem> items, int page, bool hasMore, bool isLoadingMore, String? error, String? loadMoreError
});


$UpCollectionCopyWith<$Res>? get collection;

}
/// @nodoc
class _$CollectionDetailStateCopyWithImpl<$Res>
    implements $CollectionDetailStateCopyWith<$Res> {
  _$CollectionDetailStateCopyWithImpl(this._self, this._then);

  final CollectionDetailState _self;
  final $Res Function(CollectionDetailState) _then;

/// Create a copy of CollectionDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? collection = freezed,Object? items = null,Object? page = null,Object? hasMore = null,Object? isLoadingMore = null,Object? error = freezed,Object? loadMoreError = freezed,}) {
  return _then(_self.copyWith(
collection: freezed == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as UpCollection?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<UpCollectionItem>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,loadMoreError: freezed == loadMoreError ? _self.loadMoreError : loadMoreError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CollectionDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpCollectionCopyWith<$Res>? get collection {
    if (_self.collection == null) {
    return null;
  }

  return $UpCollectionCopyWith<$Res>(_self.collection!, (value) {
    return _then(_self.copyWith(collection: value));
  });
}
}


/// Adds pattern-matching-related methods to [CollectionDetailState].
extension CollectionDetailStatePatterns on CollectionDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CollectionDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CollectionDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CollectionDetailState value)  $default,){
final _that = this;
switch (_that) {
case _CollectionDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CollectionDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _CollectionDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UpCollection? collection,  List<UpCollectionItem> items,  int page,  bool hasMore,  bool isLoadingMore,  String? error,  String? loadMoreError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CollectionDetailState() when $default != null:
return $default(_that.collection,_that.items,_that.page,_that.hasMore,_that.isLoadingMore,_that.error,_that.loadMoreError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UpCollection? collection,  List<UpCollectionItem> items,  int page,  bool hasMore,  bool isLoadingMore,  String? error,  String? loadMoreError)  $default,) {final _that = this;
switch (_that) {
case _CollectionDetailState():
return $default(_that.collection,_that.items,_that.page,_that.hasMore,_that.isLoadingMore,_that.error,_that.loadMoreError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UpCollection? collection,  List<UpCollectionItem> items,  int page,  bool hasMore,  bool isLoadingMore,  String? error,  String? loadMoreError)?  $default,) {final _that = this;
switch (_that) {
case _CollectionDetailState() when $default != null:
return $default(_that.collection,_that.items,_that.page,_that.hasMore,_that.isLoadingMore,_that.error,_that.loadMoreError);case _:
  return null;

}
}

}

/// @nodoc


class _CollectionDetailState implements CollectionDetailState {
  const _CollectionDetailState({this.collection, final  List<UpCollectionItem> items = const <UpCollectionItem>[], this.page = 0, this.hasMore = false, this.isLoadingMore = false, this.error, this.loadMoreError}): _items = items;
  

@override final  UpCollection? collection;
 final  List<UpCollectionItem> _items;
@override@JsonKey() List<UpCollectionItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  int page;
@override@JsonKey() final  bool hasMore;
@override@JsonKey() final  bool isLoadingMore;
@override final  String? error;
@override final  String? loadMoreError;

/// Create a copy of CollectionDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CollectionDetailStateCopyWith<_CollectionDetailState> get copyWith => __$CollectionDetailStateCopyWithImpl<_CollectionDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CollectionDetailState&&(identical(other.collection, collection) || other.collection == collection)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.page, page) || other.page == page)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.error, error) || other.error == error)&&(identical(other.loadMoreError, loadMoreError) || other.loadMoreError == loadMoreError));
}


@override
int get hashCode => Object.hash(runtimeType,collection,const DeepCollectionEquality().hash(_items),page,hasMore,isLoadingMore,error,loadMoreError);

@override
String toString() {
  return 'CollectionDetailState(collection: $collection, items: $items, page: $page, hasMore: $hasMore, isLoadingMore: $isLoadingMore, error: $error, loadMoreError: $loadMoreError)';
}


}

/// @nodoc
abstract mixin class _$CollectionDetailStateCopyWith<$Res> implements $CollectionDetailStateCopyWith<$Res> {
  factory _$CollectionDetailStateCopyWith(_CollectionDetailState value, $Res Function(_CollectionDetailState) _then) = __$CollectionDetailStateCopyWithImpl;
@override @useResult
$Res call({
 UpCollection? collection, List<UpCollectionItem> items, int page, bool hasMore, bool isLoadingMore, String? error, String? loadMoreError
});


@override $UpCollectionCopyWith<$Res>? get collection;

}
/// @nodoc
class __$CollectionDetailStateCopyWithImpl<$Res>
    implements _$CollectionDetailStateCopyWith<$Res> {
  __$CollectionDetailStateCopyWithImpl(this._self, this._then);

  final _CollectionDetailState _self;
  final $Res Function(_CollectionDetailState) _then;

/// Create a copy of CollectionDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? collection = freezed,Object? items = null,Object? page = null,Object? hasMore = null,Object? isLoadingMore = null,Object? error = freezed,Object? loadMoreError = freezed,}) {
  return _then(_CollectionDetailState(
collection: freezed == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as UpCollection?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<UpCollectionItem>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,loadMoreError: freezed == loadMoreError ? _self.loadMoreError : loadMoreError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CollectionDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpCollectionCopyWith<$Res>? get collection {
    if (_self.collection == null) {
    return null;
  }

  return $UpCollectionCopyWith<$Res>(_self.collection!, (value) {
    return _then(_self.copyWith(collection: value));
  });
}
}

// dart format on
