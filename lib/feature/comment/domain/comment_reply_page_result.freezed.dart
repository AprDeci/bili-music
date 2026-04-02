// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment_reply_page_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CommentReplyPageResult {

 CommentItem get rootItem; List<CommentItem> get items; int get page; int get pageSize; int get totalCount; bool get hasMore; bool get isReadOnly;
/// Create a copy of CommentReplyPageResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentReplyPageResultCopyWith<CommentReplyPageResult> get copyWith => _$CommentReplyPageResultCopyWithImpl<CommentReplyPageResult>(this as CommentReplyPageResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentReplyPageResult&&(identical(other.rootItem, rootItem) || other.rootItem == rootItem)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.isReadOnly, isReadOnly) || other.isReadOnly == isReadOnly));
}


@override
int get hashCode => Object.hash(runtimeType,rootItem,const DeepCollectionEquality().hash(items),page,pageSize,totalCount,hasMore,isReadOnly);

@override
String toString() {
  return 'CommentReplyPageResult(rootItem: $rootItem, items: $items, page: $page, pageSize: $pageSize, totalCount: $totalCount, hasMore: $hasMore, isReadOnly: $isReadOnly)';
}


}

/// @nodoc
abstract mixin class $CommentReplyPageResultCopyWith<$Res>  {
  factory $CommentReplyPageResultCopyWith(CommentReplyPageResult value, $Res Function(CommentReplyPageResult) _then) = _$CommentReplyPageResultCopyWithImpl;
@useResult
$Res call({
 CommentItem rootItem, List<CommentItem> items, int page, int pageSize, int totalCount, bool hasMore, bool isReadOnly
});


$CommentItemCopyWith<$Res> get rootItem;

}
/// @nodoc
class _$CommentReplyPageResultCopyWithImpl<$Res>
    implements $CommentReplyPageResultCopyWith<$Res> {
  _$CommentReplyPageResultCopyWithImpl(this._self, this._then);

  final CommentReplyPageResult _self;
  final $Res Function(CommentReplyPageResult) _then;

/// Create a copy of CommentReplyPageResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rootItem = null,Object? items = null,Object? page = null,Object? pageSize = null,Object? totalCount = null,Object? hasMore = null,Object? isReadOnly = null,}) {
  return _then(_self.copyWith(
rootItem: null == rootItem ? _self.rootItem : rootItem // ignore: cast_nullable_to_non_nullable
as CommentItem,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CommentItem>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isReadOnly: null == isReadOnly ? _self.isReadOnly : isReadOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of CommentReplyPageResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentItemCopyWith<$Res> get rootItem {
  
  return $CommentItemCopyWith<$Res>(_self.rootItem, (value) {
    return _then(_self.copyWith(rootItem: value));
  });
}
}


/// Adds pattern-matching-related methods to [CommentReplyPageResult].
extension CommentReplyPageResultPatterns on CommentReplyPageResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommentReplyPageResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentReplyPageResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommentReplyPageResult value)  $default,){
final _that = this;
switch (_that) {
case _CommentReplyPageResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommentReplyPageResult value)?  $default,){
final _that = this;
switch (_that) {
case _CommentReplyPageResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CommentItem rootItem,  List<CommentItem> items,  int page,  int pageSize,  int totalCount,  bool hasMore,  bool isReadOnly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentReplyPageResult() when $default != null:
return $default(_that.rootItem,_that.items,_that.page,_that.pageSize,_that.totalCount,_that.hasMore,_that.isReadOnly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CommentItem rootItem,  List<CommentItem> items,  int page,  int pageSize,  int totalCount,  bool hasMore,  bool isReadOnly)  $default,) {final _that = this;
switch (_that) {
case _CommentReplyPageResult():
return $default(_that.rootItem,_that.items,_that.page,_that.pageSize,_that.totalCount,_that.hasMore,_that.isReadOnly);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CommentItem rootItem,  List<CommentItem> items,  int page,  int pageSize,  int totalCount,  bool hasMore,  bool isReadOnly)?  $default,) {final _that = this;
switch (_that) {
case _CommentReplyPageResult() when $default != null:
return $default(_that.rootItem,_that.items,_that.page,_that.pageSize,_that.totalCount,_that.hasMore,_that.isReadOnly);case _:
  return null;

}
}

}

/// @nodoc


class _CommentReplyPageResult implements CommentReplyPageResult {
  const _CommentReplyPageResult({required this.rootItem, final  List<CommentItem> items = const <CommentItem>[], required this.page, required this.pageSize, required this.totalCount, required this.hasMore, this.isReadOnly = false}): _items = items;
  

@override final  CommentItem rootItem;
 final  List<CommentItem> _items;
@override@JsonKey() List<CommentItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int page;
@override final  int pageSize;
@override final  int totalCount;
@override final  bool hasMore;
@override@JsonKey() final  bool isReadOnly;

/// Create a copy of CommentReplyPageResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentReplyPageResultCopyWith<_CommentReplyPageResult> get copyWith => __$CommentReplyPageResultCopyWithImpl<_CommentReplyPageResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentReplyPageResult&&(identical(other.rootItem, rootItem) || other.rootItem == rootItem)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.isReadOnly, isReadOnly) || other.isReadOnly == isReadOnly));
}


@override
int get hashCode => Object.hash(runtimeType,rootItem,const DeepCollectionEquality().hash(_items),page,pageSize,totalCount,hasMore,isReadOnly);

@override
String toString() {
  return 'CommentReplyPageResult(rootItem: $rootItem, items: $items, page: $page, pageSize: $pageSize, totalCount: $totalCount, hasMore: $hasMore, isReadOnly: $isReadOnly)';
}


}

/// @nodoc
abstract mixin class _$CommentReplyPageResultCopyWith<$Res> implements $CommentReplyPageResultCopyWith<$Res> {
  factory _$CommentReplyPageResultCopyWith(_CommentReplyPageResult value, $Res Function(_CommentReplyPageResult) _then) = __$CommentReplyPageResultCopyWithImpl;
@override @useResult
$Res call({
 CommentItem rootItem, List<CommentItem> items, int page, int pageSize, int totalCount, bool hasMore, bool isReadOnly
});


@override $CommentItemCopyWith<$Res> get rootItem;

}
/// @nodoc
class __$CommentReplyPageResultCopyWithImpl<$Res>
    implements _$CommentReplyPageResultCopyWith<$Res> {
  __$CommentReplyPageResultCopyWithImpl(this._self, this._then);

  final _CommentReplyPageResult _self;
  final $Res Function(_CommentReplyPageResult) _then;

/// Create a copy of CommentReplyPageResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rootItem = null,Object? items = null,Object? page = null,Object? pageSize = null,Object? totalCount = null,Object? hasMore = null,Object? isReadOnly = null,}) {
  return _then(_CommentReplyPageResult(
rootItem: null == rootItem ? _self.rootItem : rootItem // ignore: cast_nullable_to_non_nullable
as CommentItem,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CommentItem>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isReadOnly: null == isReadOnly ? _self.isReadOnly : isReadOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of CommentReplyPageResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentItemCopyWith<$Res> get rootItem {
  
  return $CommentItemCopyWith<$Res>(_self.rootItem, (value) {
    return _then(_self.copyWith(rootItem: value));
  });
}
}

// dart format on
