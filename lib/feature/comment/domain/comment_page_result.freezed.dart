// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment_page_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CommentPageResult {

 List<CommentItem> get items; List<CommentItem> get hotItems; CommentItem? get topItem; int get page; int get pageSize; int get totalCount; bool get hasMore; String? get nextOffset; List<CommentSort> get supportedSorts; String? get sortTitle; bool get isEnd; bool get hasFolded; bool get isFolded; bool get isReadOnly; String? get noticeText;
/// Create a copy of CommentPageResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentPageResultCopyWith<CommentPageResult> get copyWith => _$CommentPageResultCopyWithImpl<CommentPageResult>(this as CommentPageResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentPageResult&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.hotItems, hotItems)&&(identical(other.topItem, topItem) || other.topItem == topItem)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.nextOffset, nextOffset) || other.nextOffset == nextOffset)&&const DeepCollectionEquality().equals(other.supportedSorts, supportedSorts)&&(identical(other.sortTitle, sortTitle) || other.sortTitle == sortTitle)&&(identical(other.isEnd, isEnd) || other.isEnd == isEnd)&&(identical(other.hasFolded, hasFolded) || other.hasFolded == hasFolded)&&(identical(other.isFolded, isFolded) || other.isFolded == isFolded)&&(identical(other.isReadOnly, isReadOnly) || other.isReadOnly == isReadOnly)&&(identical(other.noticeText, noticeText) || other.noticeText == noticeText));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(hotItems),topItem,page,pageSize,totalCount,hasMore,nextOffset,const DeepCollectionEquality().hash(supportedSorts),sortTitle,isEnd,hasFolded,isFolded,isReadOnly,noticeText);

@override
String toString() {
  return 'CommentPageResult(items: $items, hotItems: $hotItems, topItem: $topItem, page: $page, pageSize: $pageSize, totalCount: $totalCount, hasMore: $hasMore, nextOffset: $nextOffset, supportedSorts: $supportedSorts, sortTitle: $sortTitle, isEnd: $isEnd, hasFolded: $hasFolded, isFolded: $isFolded, isReadOnly: $isReadOnly, noticeText: $noticeText)';
}


}

/// @nodoc
abstract mixin class $CommentPageResultCopyWith<$Res>  {
  factory $CommentPageResultCopyWith(CommentPageResult value, $Res Function(CommentPageResult) _then) = _$CommentPageResultCopyWithImpl;
@useResult
$Res call({
 List<CommentItem> items, List<CommentItem> hotItems, CommentItem? topItem, int page, int pageSize, int totalCount, bool hasMore, String? nextOffset, List<CommentSort> supportedSorts, String? sortTitle, bool isEnd, bool hasFolded, bool isFolded, bool isReadOnly, String? noticeText
});


$CommentItemCopyWith<$Res>? get topItem;

}
/// @nodoc
class _$CommentPageResultCopyWithImpl<$Res>
    implements $CommentPageResultCopyWith<$Res> {
  _$CommentPageResultCopyWithImpl(this._self, this._then);

  final CommentPageResult _self;
  final $Res Function(CommentPageResult) _then;

/// Create a copy of CommentPageResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? hotItems = null,Object? topItem = freezed,Object? page = null,Object? pageSize = null,Object? totalCount = null,Object? hasMore = null,Object? nextOffset = freezed,Object? supportedSorts = null,Object? sortTitle = freezed,Object? isEnd = null,Object? hasFolded = null,Object? isFolded = null,Object? isReadOnly = null,Object? noticeText = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CommentItem>,hotItems: null == hotItems ? _self.hotItems : hotItems // ignore: cast_nullable_to_non_nullable
as List<CommentItem>,topItem: freezed == topItem ? _self.topItem : topItem // ignore: cast_nullable_to_non_nullable
as CommentItem?,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,nextOffset: freezed == nextOffset ? _self.nextOffset : nextOffset // ignore: cast_nullable_to_non_nullable
as String?,supportedSorts: null == supportedSorts ? _self.supportedSorts : supportedSorts // ignore: cast_nullable_to_non_nullable
as List<CommentSort>,sortTitle: freezed == sortTitle ? _self.sortTitle : sortTitle // ignore: cast_nullable_to_non_nullable
as String?,isEnd: null == isEnd ? _self.isEnd : isEnd // ignore: cast_nullable_to_non_nullable
as bool,hasFolded: null == hasFolded ? _self.hasFolded : hasFolded // ignore: cast_nullable_to_non_nullable
as bool,isFolded: null == isFolded ? _self.isFolded : isFolded // ignore: cast_nullable_to_non_nullable
as bool,isReadOnly: null == isReadOnly ? _self.isReadOnly : isReadOnly // ignore: cast_nullable_to_non_nullable
as bool,noticeText: freezed == noticeText ? _self.noticeText : noticeText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CommentPageResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentItemCopyWith<$Res>? get topItem {
    if (_self.topItem == null) {
    return null;
  }

  return $CommentItemCopyWith<$Res>(_self.topItem!, (value) {
    return _then(_self.copyWith(topItem: value));
  });
}
}


/// Adds pattern-matching-related methods to [CommentPageResult].
extension CommentPageResultPatterns on CommentPageResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommentPageResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentPageResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommentPageResult value)  $default,){
final _that = this;
switch (_that) {
case _CommentPageResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommentPageResult value)?  $default,){
final _that = this;
switch (_that) {
case _CommentPageResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CommentItem> items,  List<CommentItem> hotItems,  CommentItem? topItem,  int page,  int pageSize,  int totalCount,  bool hasMore,  String? nextOffset,  List<CommentSort> supportedSorts,  String? sortTitle,  bool isEnd,  bool hasFolded,  bool isFolded,  bool isReadOnly,  String? noticeText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentPageResult() when $default != null:
return $default(_that.items,_that.hotItems,_that.topItem,_that.page,_that.pageSize,_that.totalCount,_that.hasMore,_that.nextOffset,_that.supportedSorts,_that.sortTitle,_that.isEnd,_that.hasFolded,_that.isFolded,_that.isReadOnly,_that.noticeText);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CommentItem> items,  List<CommentItem> hotItems,  CommentItem? topItem,  int page,  int pageSize,  int totalCount,  bool hasMore,  String? nextOffset,  List<CommentSort> supportedSorts,  String? sortTitle,  bool isEnd,  bool hasFolded,  bool isFolded,  bool isReadOnly,  String? noticeText)  $default,) {final _that = this;
switch (_that) {
case _CommentPageResult():
return $default(_that.items,_that.hotItems,_that.topItem,_that.page,_that.pageSize,_that.totalCount,_that.hasMore,_that.nextOffset,_that.supportedSorts,_that.sortTitle,_that.isEnd,_that.hasFolded,_that.isFolded,_that.isReadOnly,_that.noticeText);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CommentItem> items,  List<CommentItem> hotItems,  CommentItem? topItem,  int page,  int pageSize,  int totalCount,  bool hasMore,  String? nextOffset,  List<CommentSort> supportedSorts,  String? sortTitle,  bool isEnd,  bool hasFolded,  bool isFolded,  bool isReadOnly,  String? noticeText)?  $default,) {final _that = this;
switch (_that) {
case _CommentPageResult() when $default != null:
return $default(_that.items,_that.hotItems,_that.topItem,_that.page,_that.pageSize,_that.totalCount,_that.hasMore,_that.nextOffset,_that.supportedSorts,_that.sortTitle,_that.isEnd,_that.hasFolded,_that.isFolded,_that.isReadOnly,_that.noticeText);case _:
  return null;

}
}

}

/// @nodoc


class _CommentPageResult implements CommentPageResult {
  const _CommentPageResult({final  List<CommentItem> items = const <CommentItem>[], final  List<CommentItem> hotItems = const <CommentItem>[], this.topItem, required this.page, required this.pageSize, required this.totalCount, required this.hasMore, this.nextOffset, final  List<CommentSort> supportedSorts = const <CommentSort>[], this.sortTitle, this.isEnd = false, this.hasFolded = false, this.isFolded = false, this.isReadOnly = false, this.noticeText}): _items = items,_hotItems = hotItems,_supportedSorts = supportedSorts;
  

 final  List<CommentItem> _items;
@override@JsonKey() List<CommentItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  List<CommentItem> _hotItems;
@override@JsonKey() List<CommentItem> get hotItems {
  if (_hotItems is EqualUnmodifiableListView) return _hotItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hotItems);
}

@override final  CommentItem? topItem;
@override final  int page;
@override final  int pageSize;
@override final  int totalCount;
@override final  bool hasMore;
@override final  String? nextOffset;
 final  List<CommentSort> _supportedSorts;
@override@JsonKey() List<CommentSort> get supportedSorts {
  if (_supportedSorts is EqualUnmodifiableListView) return _supportedSorts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_supportedSorts);
}

@override final  String? sortTitle;
@override@JsonKey() final  bool isEnd;
@override@JsonKey() final  bool hasFolded;
@override@JsonKey() final  bool isFolded;
@override@JsonKey() final  bool isReadOnly;
@override final  String? noticeText;

/// Create a copy of CommentPageResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentPageResultCopyWith<_CommentPageResult> get copyWith => __$CommentPageResultCopyWithImpl<_CommentPageResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentPageResult&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._hotItems, _hotItems)&&(identical(other.topItem, topItem) || other.topItem == topItem)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.nextOffset, nextOffset) || other.nextOffset == nextOffset)&&const DeepCollectionEquality().equals(other._supportedSorts, _supportedSorts)&&(identical(other.sortTitle, sortTitle) || other.sortTitle == sortTitle)&&(identical(other.isEnd, isEnd) || other.isEnd == isEnd)&&(identical(other.hasFolded, hasFolded) || other.hasFolded == hasFolded)&&(identical(other.isFolded, isFolded) || other.isFolded == isFolded)&&(identical(other.isReadOnly, isReadOnly) || other.isReadOnly == isReadOnly)&&(identical(other.noticeText, noticeText) || other.noticeText == noticeText));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_hotItems),topItem,page,pageSize,totalCount,hasMore,nextOffset,const DeepCollectionEquality().hash(_supportedSorts),sortTitle,isEnd,hasFolded,isFolded,isReadOnly,noticeText);

@override
String toString() {
  return 'CommentPageResult(items: $items, hotItems: $hotItems, topItem: $topItem, page: $page, pageSize: $pageSize, totalCount: $totalCount, hasMore: $hasMore, nextOffset: $nextOffset, supportedSorts: $supportedSorts, sortTitle: $sortTitle, isEnd: $isEnd, hasFolded: $hasFolded, isFolded: $isFolded, isReadOnly: $isReadOnly, noticeText: $noticeText)';
}


}

/// @nodoc
abstract mixin class _$CommentPageResultCopyWith<$Res> implements $CommentPageResultCopyWith<$Res> {
  factory _$CommentPageResultCopyWith(_CommentPageResult value, $Res Function(_CommentPageResult) _then) = __$CommentPageResultCopyWithImpl;
@override @useResult
$Res call({
 List<CommentItem> items, List<CommentItem> hotItems, CommentItem? topItem, int page, int pageSize, int totalCount, bool hasMore, String? nextOffset, List<CommentSort> supportedSorts, String? sortTitle, bool isEnd, bool hasFolded, bool isFolded, bool isReadOnly, String? noticeText
});


@override $CommentItemCopyWith<$Res>? get topItem;

}
/// @nodoc
class __$CommentPageResultCopyWithImpl<$Res>
    implements _$CommentPageResultCopyWith<$Res> {
  __$CommentPageResultCopyWithImpl(this._self, this._then);

  final _CommentPageResult _self;
  final $Res Function(_CommentPageResult) _then;

/// Create a copy of CommentPageResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? hotItems = null,Object? topItem = freezed,Object? page = null,Object? pageSize = null,Object? totalCount = null,Object? hasMore = null,Object? nextOffset = freezed,Object? supportedSorts = null,Object? sortTitle = freezed,Object? isEnd = null,Object? hasFolded = null,Object? isFolded = null,Object? isReadOnly = null,Object? noticeText = freezed,}) {
  return _then(_CommentPageResult(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CommentItem>,hotItems: null == hotItems ? _self._hotItems : hotItems // ignore: cast_nullable_to_non_nullable
as List<CommentItem>,topItem: freezed == topItem ? _self.topItem : topItem // ignore: cast_nullable_to_non_nullable
as CommentItem?,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,nextOffset: freezed == nextOffset ? _self.nextOffset : nextOffset // ignore: cast_nullable_to_non_nullable
as String?,supportedSorts: null == supportedSorts ? _self._supportedSorts : supportedSorts // ignore: cast_nullable_to_non_nullable
as List<CommentSort>,sortTitle: freezed == sortTitle ? _self.sortTitle : sortTitle // ignore: cast_nullable_to_non_nullable
as String?,isEnd: null == isEnd ? _self.isEnd : isEnd // ignore: cast_nullable_to_non_nullable
as bool,hasFolded: null == hasFolded ? _self.hasFolded : hasFolded // ignore: cast_nullable_to_non_nullable
as bool,isFolded: null == isFolded ? _self.isFolded : isFolded // ignore: cast_nullable_to_non_nullable
as bool,isReadOnly: null == isReadOnly ? _self.isReadOnly : isReadOnly // ignore: cast_nullable_to_non_nullable
as bool,noticeText: freezed == noticeText ? _self.noticeText : noticeText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CommentPageResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentItemCopyWith<$Res>? get topItem {
    if (_self.topItem == null) {
    return null;
  }

  return $CommentItemCopyWith<$Res>(_self.topItem!, (value) {
    return _then(_self.copyWith(topItem: value));
  });
}
}

// dart format on
