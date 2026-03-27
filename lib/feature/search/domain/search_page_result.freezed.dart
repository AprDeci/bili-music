// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_page_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchPageResult {

 List<SearchResultItem> get items; int get page; int? get totalPages; bool get hasMore;
/// Create a copy of SearchPageResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchPageResultCopyWith<SearchPageResult> get copyWith => _$SearchPageResultCopyWithImpl<SearchPageResult>(this as SearchPageResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchPageResult&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.page, page) || other.page == page)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),page,totalPages,hasMore);

@override
String toString() {
  return 'SearchPageResult(items: $items, page: $page, totalPages: $totalPages, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $SearchPageResultCopyWith<$Res>  {
  factory $SearchPageResultCopyWith(SearchPageResult value, $Res Function(SearchPageResult) _then) = _$SearchPageResultCopyWithImpl;
@useResult
$Res call({
 List<SearchResultItem> items, int page, int? totalPages, bool hasMore
});




}
/// @nodoc
class _$SearchPageResultCopyWithImpl<$Res>
    implements $SearchPageResultCopyWith<$Res> {
  _$SearchPageResultCopyWithImpl(this._self, this._then);

  final SearchPageResult _self;
  final $Res Function(SearchPageResult) _then;

/// Create a copy of SearchPageResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? page = null,Object? totalPages = freezed,Object? hasMore = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<SearchResultItem>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,totalPages: freezed == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchPageResult].
extension SearchPageResultPatterns on SearchPageResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchPageResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchPageResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchPageResult value)  $default,){
final _that = this;
switch (_that) {
case _SearchPageResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchPageResult value)?  $default,){
final _that = this;
switch (_that) {
case _SearchPageResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SearchResultItem> items,  int page,  int? totalPages,  bool hasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchPageResult() when $default != null:
return $default(_that.items,_that.page,_that.totalPages,_that.hasMore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SearchResultItem> items,  int page,  int? totalPages,  bool hasMore)  $default,) {final _that = this;
switch (_that) {
case _SearchPageResult():
return $default(_that.items,_that.page,_that.totalPages,_that.hasMore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SearchResultItem> items,  int page,  int? totalPages,  bool hasMore)?  $default,) {final _that = this;
switch (_that) {
case _SearchPageResult() when $default != null:
return $default(_that.items,_that.page,_that.totalPages,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc


class _SearchPageResult implements SearchPageResult {
  const _SearchPageResult({final  List<SearchResultItem> items = const <SearchResultItem>[], this.page = 1, this.totalPages, this.hasMore = false}): _items = items;
  

 final  List<SearchResultItem> _items;
@override@JsonKey() List<SearchResultItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  int page;
@override final  int? totalPages;
@override@JsonKey() final  bool hasMore;

/// Create a copy of SearchPageResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchPageResultCopyWith<_SearchPageResult> get copyWith => __$SearchPageResultCopyWithImpl<_SearchPageResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchPageResult&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.page, page) || other.page == page)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),page,totalPages,hasMore);

@override
String toString() {
  return 'SearchPageResult(items: $items, page: $page, totalPages: $totalPages, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$SearchPageResultCopyWith<$Res> implements $SearchPageResultCopyWith<$Res> {
  factory _$SearchPageResultCopyWith(_SearchPageResult value, $Res Function(_SearchPageResult) _then) = __$SearchPageResultCopyWithImpl;
@override @useResult
$Res call({
 List<SearchResultItem> items, int page, int? totalPages, bool hasMore
});




}
/// @nodoc
class __$SearchPageResultCopyWithImpl<$Res>
    implements _$SearchPageResultCopyWith<$Res> {
  __$SearchPageResultCopyWithImpl(this._self, this._then);

  final _SearchPageResult _self;
  final $Res Function(_SearchPageResult) _then;

/// Create a copy of SearchPageResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? page = null,Object? totalPages = freezed,Object? hasMore = null,}) {
  return _then(_SearchPageResult(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<SearchResultItem>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,totalPages: freezed == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
