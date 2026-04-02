// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CommentState {

 CommentTarget get target; CommentSort get sort; List<CommentItem> get items; List<CommentItem> get hotItems; List<CommentSort> get supportedSorts; CommentItem? get topItem; bool get isLoading; bool get isRefreshing; bool get isLoadingMore; int get currentPage; bool get hasMore; String? get nextOffset; String? get sortTitle; bool get isEnd; bool get hasFolded; bool get isFolded; bool get isReadOnly; String? get noticeText; String? get errorMessage; String? get loadMoreErrorMessage;
/// Create a copy of CommentState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentStateCopyWith<CommentState> get copyWith => _$CommentStateCopyWithImpl<CommentState>(this as CommentState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentState&&(identical(other.target, target) || other.target == target)&&(identical(other.sort, sort) || other.sort == sort)&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.hotItems, hotItems)&&const DeepCollectionEquality().equals(other.supportedSorts, supportedSorts)&&(identical(other.topItem, topItem) || other.topItem == topItem)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.nextOffset, nextOffset) || other.nextOffset == nextOffset)&&(identical(other.sortTitle, sortTitle) || other.sortTitle == sortTitle)&&(identical(other.isEnd, isEnd) || other.isEnd == isEnd)&&(identical(other.hasFolded, hasFolded) || other.hasFolded == hasFolded)&&(identical(other.isFolded, isFolded) || other.isFolded == isFolded)&&(identical(other.isReadOnly, isReadOnly) || other.isReadOnly == isReadOnly)&&(identical(other.noticeText, noticeText) || other.noticeText == noticeText)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.loadMoreErrorMessage, loadMoreErrorMessage) || other.loadMoreErrorMessage == loadMoreErrorMessage));
}


@override
int get hashCode => Object.hashAll([runtimeType,target,sort,const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(hotItems),const DeepCollectionEquality().hash(supportedSorts),topItem,isLoading,isRefreshing,isLoadingMore,currentPage,hasMore,nextOffset,sortTitle,isEnd,hasFolded,isFolded,isReadOnly,noticeText,errorMessage,loadMoreErrorMessage]);

@override
String toString() {
  return 'CommentState(target: $target, sort: $sort, items: $items, hotItems: $hotItems, supportedSorts: $supportedSorts, topItem: $topItem, isLoading: $isLoading, isRefreshing: $isRefreshing, isLoadingMore: $isLoadingMore, currentPage: $currentPage, hasMore: $hasMore, nextOffset: $nextOffset, sortTitle: $sortTitle, isEnd: $isEnd, hasFolded: $hasFolded, isFolded: $isFolded, isReadOnly: $isReadOnly, noticeText: $noticeText, errorMessage: $errorMessage, loadMoreErrorMessage: $loadMoreErrorMessage)';
}


}

/// @nodoc
abstract mixin class $CommentStateCopyWith<$Res>  {
  factory $CommentStateCopyWith(CommentState value, $Res Function(CommentState) _then) = _$CommentStateCopyWithImpl;
@useResult
$Res call({
 CommentTarget target, CommentSort sort, List<CommentItem> items, List<CommentItem> hotItems, List<CommentSort> supportedSorts, CommentItem? topItem, bool isLoading, bool isRefreshing, bool isLoadingMore, int currentPage, bool hasMore, String? nextOffset, String? sortTitle, bool isEnd, bool hasFolded, bool isFolded, bool isReadOnly, String? noticeText, String? errorMessage, String? loadMoreErrorMessage
});


$CommentTargetCopyWith<$Res> get target;$CommentItemCopyWith<$Res>? get topItem;

}
/// @nodoc
class _$CommentStateCopyWithImpl<$Res>
    implements $CommentStateCopyWith<$Res> {
  _$CommentStateCopyWithImpl(this._self, this._then);

  final CommentState _self;
  final $Res Function(CommentState) _then;

/// Create a copy of CommentState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? target = null,Object? sort = null,Object? items = null,Object? hotItems = null,Object? supportedSorts = null,Object? topItem = freezed,Object? isLoading = null,Object? isRefreshing = null,Object? isLoadingMore = null,Object? currentPage = null,Object? hasMore = null,Object? nextOffset = freezed,Object? sortTitle = freezed,Object? isEnd = null,Object? hasFolded = null,Object? isFolded = null,Object? isReadOnly = null,Object? noticeText = freezed,Object? errorMessage = freezed,Object? loadMoreErrorMessage = freezed,}) {
  return _then(_self.copyWith(
target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as CommentTarget,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as CommentSort,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CommentItem>,hotItems: null == hotItems ? _self.hotItems : hotItems // ignore: cast_nullable_to_non_nullable
as List<CommentItem>,supportedSorts: null == supportedSorts ? _self.supportedSorts : supportedSorts // ignore: cast_nullable_to_non_nullable
as List<CommentSort>,topItem: freezed == topItem ? _self.topItem : topItem // ignore: cast_nullable_to_non_nullable
as CommentItem?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,nextOffset: freezed == nextOffset ? _self.nextOffset : nextOffset // ignore: cast_nullable_to_non_nullable
as String?,sortTitle: freezed == sortTitle ? _self.sortTitle : sortTitle // ignore: cast_nullable_to_non_nullable
as String?,isEnd: null == isEnd ? _self.isEnd : isEnd // ignore: cast_nullable_to_non_nullable
as bool,hasFolded: null == hasFolded ? _self.hasFolded : hasFolded // ignore: cast_nullable_to_non_nullable
as bool,isFolded: null == isFolded ? _self.isFolded : isFolded // ignore: cast_nullable_to_non_nullable
as bool,isReadOnly: null == isReadOnly ? _self.isReadOnly : isReadOnly // ignore: cast_nullable_to_non_nullable
as bool,noticeText: freezed == noticeText ? _self.noticeText : noticeText // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,loadMoreErrorMessage: freezed == loadMoreErrorMessage ? _self.loadMoreErrorMessage : loadMoreErrorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CommentState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentTargetCopyWith<$Res> get target {
  
  return $CommentTargetCopyWith<$Res>(_self.target, (value) {
    return _then(_self.copyWith(target: value));
  });
}/// Create a copy of CommentState
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


/// Adds pattern-matching-related methods to [CommentState].
extension CommentStatePatterns on CommentState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommentState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommentState value)  $default,){
final _that = this;
switch (_that) {
case _CommentState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommentState value)?  $default,){
final _that = this;
switch (_that) {
case _CommentState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CommentTarget target,  CommentSort sort,  List<CommentItem> items,  List<CommentItem> hotItems,  List<CommentSort> supportedSorts,  CommentItem? topItem,  bool isLoading,  bool isRefreshing,  bool isLoadingMore,  int currentPage,  bool hasMore,  String? nextOffset,  String? sortTitle,  bool isEnd,  bool hasFolded,  bool isFolded,  bool isReadOnly,  String? noticeText,  String? errorMessage,  String? loadMoreErrorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentState() when $default != null:
return $default(_that.target,_that.sort,_that.items,_that.hotItems,_that.supportedSorts,_that.topItem,_that.isLoading,_that.isRefreshing,_that.isLoadingMore,_that.currentPage,_that.hasMore,_that.nextOffset,_that.sortTitle,_that.isEnd,_that.hasFolded,_that.isFolded,_that.isReadOnly,_that.noticeText,_that.errorMessage,_that.loadMoreErrorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CommentTarget target,  CommentSort sort,  List<CommentItem> items,  List<CommentItem> hotItems,  List<CommentSort> supportedSorts,  CommentItem? topItem,  bool isLoading,  bool isRefreshing,  bool isLoadingMore,  int currentPage,  bool hasMore,  String? nextOffset,  String? sortTitle,  bool isEnd,  bool hasFolded,  bool isFolded,  bool isReadOnly,  String? noticeText,  String? errorMessage,  String? loadMoreErrorMessage)  $default,) {final _that = this;
switch (_that) {
case _CommentState():
return $default(_that.target,_that.sort,_that.items,_that.hotItems,_that.supportedSorts,_that.topItem,_that.isLoading,_that.isRefreshing,_that.isLoadingMore,_that.currentPage,_that.hasMore,_that.nextOffset,_that.sortTitle,_that.isEnd,_that.hasFolded,_that.isFolded,_that.isReadOnly,_that.noticeText,_that.errorMessage,_that.loadMoreErrorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CommentTarget target,  CommentSort sort,  List<CommentItem> items,  List<CommentItem> hotItems,  List<CommentSort> supportedSorts,  CommentItem? topItem,  bool isLoading,  bool isRefreshing,  bool isLoadingMore,  int currentPage,  bool hasMore,  String? nextOffset,  String? sortTitle,  bool isEnd,  bool hasFolded,  bool isFolded,  bool isReadOnly,  String? noticeText,  String? errorMessage,  String? loadMoreErrorMessage)?  $default,) {final _that = this;
switch (_that) {
case _CommentState() when $default != null:
return $default(_that.target,_that.sort,_that.items,_that.hotItems,_that.supportedSorts,_that.topItem,_that.isLoading,_that.isRefreshing,_that.isLoadingMore,_that.currentPage,_that.hasMore,_that.nextOffset,_that.sortTitle,_that.isEnd,_that.hasFolded,_that.isFolded,_that.isReadOnly,_that.noticeText,_that.errorMessage,_that.loadMoreErrorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _CommentState implements CommentState {
  const _CommentState({required this.target, this.sort = CommentSort.time, final  List<CommentItem> items = const <CommentItem>[], final  List<CommentItem> hotItems = const <CommentItem>[], final  List<CommentSort> supportedSorts = const <CommentSort>[], this.topItem, this.isLoading = false, this.isRefreshing = false, this.isLoadingMore = false, this.currentPage = 0, this.hasMore = false, this.nextOffset, this.sortTitle, this.isEnd = false, this.hasFolded = false, this.isFolded = false, this.isReadOnly = false, this.noticeText, this.errorMessage, this.loadMoreErrorMessage}): _items = items,_hotItems = hotItems,_supportedSorts = supportedSorts;
  

@override final  CommentTarget target;
@override@JsonKey() final  CommentSort sort;
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

 final  List<CommentSort> _supportedSorts;
@override@JsonKey() List<CommentSort> get supportedSorts {
  if (_supportedSorts is EqualUnmodifiableListView) return _supportedSorts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_supportedSorts);
}

@override final  CommentItem? topItem;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isRefreshing;
@override@JsonKey() final  bool isLoadingMore;
@override@JsonKey() final  int currentPage;
@override@JsonKey() final  bool hasMore;
@override final  String? nextOffset;
@override final  String? sortTitle;
@override@JsonKey() final  bool isEnd;
@override@JsonKey() final  bool hasFolded;
@override@JsonKey() final  bool isFolded;
@override@JsonKey() final  bool isReadOnly;
@override final  String? noticeText;
@override final  String? errorMessage;
@override final  String? loadMoreErrorMessage;

/// Create a copy of CommentState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentStateCopyWith<_CommentState> get copyWith => __$CommentStateCopyWithImpl<_CommentState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentState&&(identical(other.target, target) || other.target == target)&&(identical(other.sort, sort) || other.sort == sort)&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._hotItems, _hotItems)&&const DeepCollectionEquality().equals(other._supportedSorts, _supportedSorts)&&(identical(other.topItem, topItem) || other.topItem == topItem)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.nextOffset, nextOffset) || other.nextOffset == nextOffset)&&(identical(other.sortTitle, sortTitle) || other.sortTitle == sortTitle)&&(identical(other.isEnd, isEnd) || other.isEnd == isEnd)&&(identical(other.hasFolded, hasFolded) || other.hasFolded == hasFolded)&&(identical(other.isFolded, isFolded) || other.isFolded == isFolded)&&(identical(other.isReadOnly, isReadOnly) || other.isReadOnly == isReadOnly)&&(identical(other.noticeText, noticeText) || other.noticeText == noticeText)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.loadMoreErrorMessage, loadMoreErrorMessage) || other.loadMoreErrorMessage == loadMoreErrorMessage));
}


@override
int get hashCode => Object.hashAll([runtimeType,target,sort,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_hotItems),const DeepCollectionEquality().hash(_supportedSorts),topItem,isLoading,isRefreshing,isLoadingMore,currentPage,hasMore,nextOffset,sortTitle,isEnd,hasFolded,isFolded,isReadOnly,noticeText,errorMessage,loadMoreErrorMessage]);

@override
String toString() {
  return 'CommentState(target: $target, sort: $sort, items: $items, hotItems: $hotItems, supportedSorts: $supportedSorts, topItem: $topItem, isLoading: $isLoading, isRefreshing: $isRefreshing, isLoadingMore: $isLoadingMore, currentPage: $currentPage, hasMore: $hasMore, nextOffset: $nextOffset, sortTitle: $sortTitle, isEnd: $isEnd, hasFolded: $hasFolded, isFolded: $isFolded, isReadOnly: $isReadOnly, noticeText: $noticeText, errorMessage: $errorMessage, loadMoreErrorMessage: $loadMoreErrorMessage)';
}


}

/// @nodoc
abstract mixin class _$CommentStateCopyWith<$Res> implements $CommentStateCopyWith<$Res> {
  factory _$CommentStateCopyWith(_CommentState value, $Res Function(_CommentState) _then) = __$CommentStateCopyWithImpl;
@override @useResult
$Res call({
 CommentTarget target, CommentSort sort, List<CommentItem> items, List<CommentItem> hotItems, List<CommentSort> supportedSorts, CommentItem? topItem, bool isLoading, bool isRefreshing, bool isLoadingMore, int currentPage, bool hasMore, String? nextOffset, String? sortTitle, bool isEnd, bool hasFolded, bool isFolded, bool isReadOnly, String? noticeText, String? errorMessage, String? loadMoreErrorMessage
});


@override $CommentTargetCopyWith<$Res> get target;@override $CommentItemCopyWith<$Res>? get topItem;

}
/// @nodoc
class __$CommentStateCopyWithImpl<$Res>
    implements _$CommentStateCopyWith<$Res> {
  __$CommentStateCopyWithImpl(this._self, this._then);

  final _CommentState _self;
  final $Res Function(_CommentState) _then;

/// Create a copy of CommentState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? target = null,Object? sort = null,Object? items = null,Object? hotItems = null,Object? supportedSorts = null,Object? topItem = freezed,Object? isLoading = null,Object? isRefreshing = null,Object? isLoadingMore = null,Object? currentPage = null,Object? hasMore = null,Object? nextOffset = freezed,Object? sortTitle = freezed,Object? isEnd = null,Object? hasFolded = null,Object? isFolded = null,Object? isReadOnly = null,Object? noticeText = freezed,Object? errorMessage = freezed,Object? loadMoreErrorMessage = freezed,}) {
  return _then(_CommentState(
target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as CommentTarget,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as CommentSort,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CommentItem>,hotItems: null == hotItems ? _self._hotItems : hotItems // ignore: cast_nullable_to_non_nullable
as List<CommentItem>,supportedSorts: null == supportedSorts ? _self._supportedSorts : supportedSorts // ignore: cast_nullable_to_non_nullable
as List<CommentSort>,topItem: freezed == topItem ? _self.topItem : topItem // ignore: cast_nullable_to_non_nullable
as CommentItem?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,nextOffset: freezed == nextOffset ? _self.nextOffset : nextOffset // ignore: cast_nullable_to_non_nullable
as String?,sortTitle: freezed == sortTitle ? _self.sortTitle : sortTitle // ignore: cast_nullable_to_non_nullable
as String?,isEnd: null == isEnd ? _self.isEnd : isEnd // ignore: cast_nullable_to_non_nullable
as bool,hasFolded: null == hasFolded ? _self.hasFolded : hasFolded // ignore: cast_nullable_to_non_nullable
as bool,isFolded: null == isFolded ? _self.isFolded : isFolded // ignore: cast_nullable_to_non_nullable
as bool,isReadOnly: null == isReadOnly ? _self.isReadOnly : isReadOnly // ignore: cast_nullable_to_non_nullable
as bool,noticeText: freezed == noticeText ? _self.noticeText : noticeText // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,loadMoreErrorMessage: freezed == loadMoreErrorMessage ? _self.loadMoreErrorMessage : loadMoreErrorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CommentState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentTargetCopyWith<$Res> get target {
  
  return $CommentTargetCopyWith<$Res>(_self.target, (value) {
    return _then(_self.copyWith(target: value));
  });
}/// Create a copy of CommentState
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
