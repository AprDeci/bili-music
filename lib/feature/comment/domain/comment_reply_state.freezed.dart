// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment_reply_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CommentReplyState {

 CommentTarget get target; CommentItem get rootItem; List<CommentItem> get items; bool get isLoading; bool get isLoadingMore; bool get hasMore; int get currentPage; int get totalCount; bool get isReadOnly; String? get errorMessage; String? get loadMoreErrorMessage;
/// Create a copy of CommentReplyState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentReplyStateCopyWith<CommentReplyState> get copyWith => _$CommentReplyStateCopyWithImpl<CommentReplyState>(this as CommentReplyState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentReplyState&&(identical(other.target, target) || other.target == target)&&(identical(other.rootItem, rootItem) || other.rootItem == rootItem)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.isReadOnly, isReadOnly) || other.isReadOnly == isReadOnly)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.loadMoreErrorMessage, loadMoreErrorMessage) || other.loadMoreErrorMessage == loadMoreErrorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,target,rootItem,const DeepCollectionEquality().hash(items),isLoading,isLoadingMore,hasMore,currentPage,totalCount,isReadOnly,errorMessage,loadMoreErrorMessage);

@override
String toString() {
  return 'CommentReplyState(target: $target, rootItem: $rootItem, items: $items, isLoading: $isLoading, isLoadingMore: $isLoadingMore, hasMore: $hasMore, currentPage: $currentPage, totalCount: $totalCount, isReadOnly: $isReadOnly, errorMessage: $errorMessage, loadMoreErrorMessage: $loadMoreErrorMessage)';
}


}

/// @nodoc
abstract mixin class $CommentReplyStateCopyWith<$Res>  {
  factory $CommentReplyStateCopyWith(CommentReplyState value, $Res Function(CommentReplyState) _then) = _$CommentReplyStateCopyWithImpl;
@useResult
$Res call({
 CommentTarget target, CommentItem rootItem, List<CommentItem> items, bool isLoading, bool isLoadingMore, bool hasMore, int currentPage, int totalCount, bool isReadOnly, String? errorMessage, String? loadMoreErrorMessage
});


$CommentTargetCopyWith<$Res> get target;$CommentItemCopyWith<$Res> get rootItem;

}
/// @nodoc
class _$CommentReplyStateCopyWithImpl<$Res>
    implements $CommentReplyStateCopyWith<$Res> {
  _$CommentReplyStateCopyWithImpl(this._self, this._then);

  final CommentReplyState _self;
  final $Res Function(CommentReplyState) _then;

/// Create a copy of CommentReplyState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? target = null,Object? rootItem = null,Object? items = null,Object? isLoading = null,Object? isLoadingMore = null,Object? hasMore = null,Object? currentPage = null,Object? totalCount = null,Object? isReadOnly = null,Object? errorMessage = freezed,Object? loadMoreErrorMessage = freezed,}) {
  return _then(_self.copyWith(
target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as CommentTarget,rootItem: null == rootItem ? _self.rootItem : rootItem // ignore: cast_nullable_to_non_nullable
as CommentItem,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CommentItem>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,isReadOnly: null == isReadOnly ? _self.isReadOnly : isReadOnly // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,loadMoreErrorMessage: freezed == loadMoreErrorMessage ? _self.loadMoreErrorMessage : loadMoreErrorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CommentReplyState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentTargetCopyWith<$Res> get target {
  
  return $CommentTargetCopyWith<$Res>(_self.target, (value) {
    return _then(_self.copyWith(target: value));
  });
}/// Create a copy of CommentReplyState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentItemCopyWith<$Res> get rootItem {
  
  return $CommentItemCopyWith<$Res>(_self.rootItem, (value) {
    return _then(_self.copyWith(rootItem: value));
  });
}
}


/// Adds pattern-matching-related methods to [CommentReplyState].
extension CommentReplyStatePatterns on CommentReplyState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommentReplyState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentReplyState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommentReplyState value)  $default,){
final _that = this;
switch (_that) {
case _CommentReplyState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommentReplyState value)?  $default,){
final _that = this;
switch (_that) {
case _CommentReplyState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CommentTarget target,  CommentItem rootItem,  List<CommentItem> items,  bool isLoading,  bool isLoadingMore,  bool hasMore,  int currentPage,  int totalCount,  bool isReadOnly,  String? errorMessage,  String? loadMoreErrorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentReplyState() when $default != null:
return $default(_that.target,_that.rootItem,_that.items,_that.isLoading,_that.isLoadingMore,_that.hasMore,_that.currentPage,_that.totalCount,_that.isReadOnly,_that.errorMessage,_that.loadMoreErrorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CommentTarget target,  CommentItem rootItem,  List<CommentItem> items,  bool isLoading,  bool isLoadingMore,  bool hasMore,  int currentPage,  int totalCount,  bool isReadOnly,  String? errorMessage,  String? loadMoreErrorMessage)  $default,) {final _that = this;
switch (_that) {
case _CommentReplyState():
return $default(_that.target,_that.rootItem,_that.items,_that.isLoading,_that.isLoadingMore,_that.hasMore,_that.currentPage,_that.totalCount,_that.isReadOnly,_that.errorMessage,_that.loadMoreErrorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CommentTarget target,  CommentItem rootItem,  List<CommentItem> items,  bool isLoading,  bool isLoadingMore,  bool hasMore,  int currentPage,  int totalCount,  bool isReadOnly,  String? errorMessage,  String? loadMoreErrorMessage)?  $default,) {final _that = this;
switch (_that) {
case _CommentReplyState() when $default != null:
return $default(_that.target,_that.rootItem,_that.items,_that.isLoading,_that.isLoadingMore,_that.hasMore,_that.currentPage,_that.totalCount,_that.isReadOnly,_that.errorMessage,_that.loadMoreErrorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _CommentReplyState implements CommentReplyState {
  const _CommentReplyState({required this.target, required this.rootItem, final  List<CommentItem> items = const <CommentItem>[], this.isLoading = false, this.isLoadingMore = false, this.hasMore = false, this.currentPage = 0, this.totalCount = 0, this.isReadOnly = false, this.errorMessage, this.loadMoreErrorMessage}): _items = items;
  

@override final  CommentTarget target;
@override final  CommentItem rootItem;
 final  List<CommentItem> _items;
@override@JsonKey() List<CommentItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isLoadingMore;
@override@JsonKey() final  bool hasMore;
@override@JsonKey() final  int currentPage;
@override@JsonKey() final  int totalCount;
@override@JsonKey() final  bool isReadOnly;
@override final  String? errorMessage;
@override final  String? loadMoreErrorMessage;

/// Create a copy of CommentReplyState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentReplyStateCopyWith<_CommentReplyState> get copyWith => __$CommentReplyStateCopyWithImpl<_CommentReplyState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentReplyState&&(identical(other.target, target) || other.target == target)&&(identical(other.rootItem, rootItem) || other.rootItem == rootItem)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.isReadOnly, isReadOnly) || other.isReadOnly == isReadOnly)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.loadMoreErrorMessage, loadMoreErrorMessage) || other.loadMoreErrorMessage == loadMoreErrorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,target,rootItem,const DeepCollectionEquality().hash(_items),isLoading,isLoadingMore,hasMore,currentPage,totalCount,isReadOnly,errorMessage,loadMoreErrorMessage);

@override
String toString() {
  return 'CommentReplyState(target: $target, rootItem: $rootItem, items: $items, isLoading: $isLoading, isLoadingMore: $isLoadingMore, hasMore: $hasMore, currentPage: $currentPage, totalCount: $totalCount, isReadOnly: $isReadOnly, errorMessage: $errorMessage, loadMoreErrorMessage: $loadMoreErrorMessage)';
}


}

/// @nodoc
abstract mixin class _$CommentReplyStateCopyWith<$Res> implements $CommentReplyStateCopyWith<$Res> {
  factory _$CommentReplyStateCopyWith(_CommentReplyState value, $Res Function(_CommentReplyState) _then) = __$CommentReplyStateCopyWithImpl;
@override @useResult
$Res call({
 CommentTarget target, CommentItem rootItem, List<CommentItem> items, bool isLoading, bool isLoadingMore, bool hasMore, int currentPage, int totalCount, bool isReadOnly, String? errorMessage, String? loadMoreErrorMessage
});


@override $CommentTargetCopyWith<$Res> get target;@override $CommentItemCopyWith<$Res> get rootItem;

}
/// @nodoc
class __$CommentReplyStateCopyWithImpl<$Res>
    implements _$CommentReplyStateCopyWith<$Res> {
  __$CommentReplyStateCopyWithImpl(this._self, this._then);

  final _CommentReplyState _self;
  final $Res Function(_CommentReplyState) _then;

/// Create a copy of CommentReplyState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? target = null,Object? rootItem = null,Object? items = null,Object? isLoading = null,Object? isLoadingMore = null,Object? hasMore = null,Object? currentPage = null,Object? totalCount = null,Object? isReadOnly = null,Object? errorMessage = freezed,Object? loadMoreErrorMessage = freezed,}) {
  return _then(_CommentReplyState(
target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as CommentTarget,rootItem: null == rootItem ? _self.rootItem : rootItem // ignore: cast_nullable_to_non_nullable
as CommentItem,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CommentItem>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,isReadOnly: null == isReadOnly ? _self.isReadOnly : isReadOnly // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,loadMoreErrorMessage: freezed == loadMoreErrorMessage ? _self.loadMoreErrorMessage : loadMoreErrorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CommentReplyState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentTargetCopyWith<$Res> get target {
  
  return $CommentTargetCopyWith<$Res>(_self.target, (value) {
    return _then(_self.copyWith(target: value));
  });
}/// Create a copy of CommentReplyState
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
