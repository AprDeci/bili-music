// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CommentItem {

 int get rpid; int get oid; int get type; int get root; int get parent; int get replyCount; int get likeCount; int get action; DateTime get publishedAt; String get message; String get memberName; String get memberAvatarUrl; bool get isTop; bool get isHidden; List<CommentItem> get replies;
/// Create a copy of CommentItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentItemCopyWith<CommentItem> get copyWith => _$CommentItemCopyWithImpl<CommentItem>(this as CommentItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentItem&&(identical(other.rpid, rpid) || other.rpid == rpid)&&(identical(other.oid, oid) || other.oid == oid)&&(identical(other.type, type) || other.type == type)&&(identical(other.root, root) || other.root == root)&&(identical(other.parent, parent) || other.parent == parent)&&(identical(other.replyCount, replyCount) || other.replyCount == replyCount)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.action, action) || other.action == action)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.message, message) || other.message == message)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.memberAvatarUrl, memberAvatarUrl) || other.memberAvatarUrl == memberAvatarUrl)&&(identical(other.isTop, isTop) || other.isTop == isTop)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden)&&const DeepCollectionEquality().equals(other.replies, replies));
}


@override
int get hashCode => Object.hash(runtimeType,rpid,oid,type,root,parent,replyCount,likeCount,action,publishedAt,message,memberName,memberAvatarUrl,isTop,isHidden,const DeepCollectionEquality().hash(replies));

@override
String toString() {
  return 'CommentItem(rpid: $rpid, oid: $oid, type: $type, root: $root, parent: $parent, replyCount: $replyCount, likeCount: $likeCount, action: $action, publishedAt: $publishedAt, message: $message, memberName: $memberName, memberAvatarUrl: $memberAvatarUrl, isTop: $isTop, isHidden: $isHidden, replies: $replies)';
}


}

/// @nodoc
abstract mixin class $CommentItemCopyWith<$Res>  {
  factory $CommentItemCopyWith(CommentItem value, $Res Function(CommentItem) _then) = _$CommentItemCopyWithImpl;
@useResult
$Res call({
 int rpid, int oid, int type, int root, int parent, int replyCount, int likeCount, int action, DateTime publishedAt, String message, String memberName, String memberAvatarUrl, bool isTop, bool isHidden, List<CommentItem> replies
});




}
/// @nodoc
class _$CommentItemCopyWithImpl<$Res>
    implements $CommentItemCopyWith<$Res> {
  _$CommentItemCopyWithImpl(this._self, this._then);

  final CommentItem _self;
  final $Res Function(CommentItem) _then;

/// Create a copy of CommentItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rpid = null,Object? oid = null,Object? type = null,Object? root = null,Object? parent = null,Object? replyCount = null,Object? likeCount = null,Object? action = null,Object? publishedAt = null,Object? message = null,Object? memberName = null,Object? memberAvatarUrl = null,Object? isTop = null,Object? isHidden = null,Object? replies = null,}) {
  return _then(_self.copyWith(
rpid: null == rpid ? _self.rpid : rpid // ignore: cast_nullable_to_non_nullable
as int,oid: null == oid ? _self.oid : oid // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,root: null == root ? _self.root : root // ignore: cast_nullable_to_non_nullable
as int,parent: null == parent ? _self.parent : parent // ignore: cast_nullable_to_non_nullable
as int,replyCount: null == replyCount ? _self.replyCount : replyCount // ignore: cast_nullable_to_non_nullable
as int,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as int,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,memberAvatarUrl: null == memberAvatarUrl ? _self.memberAvatarUrl : memberAvatarUrl // ignore: cast_nullable_to_non_nullable
as String,isTop: null == isTop ? _self.isTop : isTop // ignore: cast_nullable_to_non_nullable
as bool,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,replies: null == replies ? _self.replies : replies // ignore: cast_nullable_to_non_nullable
as List<CommentItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [CommentItem].
extension CommentItemPatterns on CommentItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommentItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommentItem value)  $default,){
final _that = this;
switch (_that) {
case _CommentItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommentItem value)?  $default,){
final _that = this;
switch (_that) {
case _CommentItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rpid,  int oid,  int type,  int root,  int parent,  int replyCount,  int likeCount,  int action,  DateTime publishedAt,  String message,  String memberName,  String memberAvatarUrl,  bool isTop,  bool isHidden,  List<CommentItem> replies)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentItem() when $default != null:
return $default(_that.rpid,_that.oid,_that.type,_that.root,_that.parent,_that.replyCount,_that.likeCount,_that.action,_that.publishedAt,_that.message,_that.memberName,_that.memberAvatarUrl,_that.isTop,_that.isHidden,_that.replies);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rpid,  int oid,  int type,  int root,  int parent,  int replyCount,  int likeCount,  int action,  DateTime publishedAt,  String message,  String memberName,  String memberAvatarUrl,  bool isTop,  bool isHidden,  List<CommentItem> replies)  $default,) {final _that = this;
switch (_that) {
case _CommentItem():
return $default(_that.rpid,_that.oid,_that.type,_that.root,_that.parent,_that.replyCount,_that.likeCount,_that.action,_that.publishedAt,_that.message,_that.memberName,_that.memberAvatarUrl,_that.isTop,_that.isHidden,_that.replies);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rpid,  int oid,  int type,  int root,  int parent,  int replyCount,  int likeCount,  int action,  DateTime publishedAt,  String message,  String memberName,  String memberAvatarUrl,  bool isTop,  bool isHidden,  List<CommentItem> replies)?  $default,) {final _that = this;
switch (_that) {
case _CommentItem() when $default != null:
return $default(_that.rpid,_that.oid,_that.type,_that.root,_that.parent,_that.replyCount,_that.likeCount,_that.action,_that.publishedAt,_that.message,_that.memberName,_that.memberAvatarUrl,_that.isTop,_that.isHidden,_that.replies);case _:
  return null;

}
}

}

/// @nodoc


class _CommentItem extends CommentItem {
  const _CommentItem({required this.rpid, required this.oid, required this.type, required this.root, required this.parent, required this.replyCount, required this.likeCount, required this.action, required this.publishedAt, required this.message, required this.memberName, required this.memberAvatarUrl, this.isTop = false, this.isHidden = false, final  List<CommentItem> replies = const <CommentItem>[]}): _replies = replies,super._();
  

@override final  int rpid;
@override final  int oid;
@override final  int type;
@override final  int root;
@override final  int parent;
@override final  int replyCount;
@override final  int likeCount;
@override final  int action;
@override final  DateTime publishedAt;
@override final  String message;
@override final  String memberName;
@override final  String memberAvatarUrl;
@override@JsonKey() final  bool isTop;
@override@JsonKey() final  bool isHidden;
 final  List<CommentItem> _replies;
@override@JsonKey() List<CommentItem> get replies {
  if (_replies is EqualUnmodifiableListView) return _replies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_replies);
}


/// Create a copy of CommentItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentItemCopyWith<_CommentItem> get copyWith => __$CommentItemCopyWithImpl<_CommentItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentItem&&(identical(other.rpid, rpid) || other.rpid == rpid)&&(identical(other.oid, oid) || other.oid == oid)&&(identical(other.type, type) || other.type == type)&&(identical(other.root, root) || other.root == root)&&(identical(other.parent, parent) || other.parent == parent)&&(identical(other.replyCount, replyCount) || other.replyCount == replyCount)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.action, action) || other.action == action)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.message, message) || other.message == message)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.memberAvatarUrl, memberAvatarUrl) || other.memberAvatarUrl == memberAvatarUrl)&&(identical(other.isTop, isTop) || other.isTop == isTop)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden)&&const DeepCollectionEquality().equals(other._replies, _replies));
}


@override
int get hashCode => Object.hash(runtimeType,rpid,oid,type,root,parent,replyCount,likeCount,action,publishedAt,message,memberName,memberAvatarUrl,isTop,isHidden,const DeepCollectionEquality().hash(_replies));

@override
String toString() {
  return 'CommentItem(rpid: $rpid, oid: $oid, type: $type, root: $root, parent: $parent, replyCount: $replyCount, likeCount: $likeCount, action: $action, publishedAt: $publishedAt, message: $message, memberName: $memberName, memberAvatarUrl: $memberAvatarUrl, isTop: $isTop, isHidden: $isHidden, replies: $replies)';
}


}

/// @nodoc
abstract mixin class _$CommentItemCopyWith<$Res> implements $CommentItemCopyWith<$Res> {
  factory _$CommentItemCopyWith(_CommentItem value, $Res Function(_CommentItem) _then) = __$CommentItemCopyWithImpl;
@override @useResult
$Res call({
 int rpid, int oid, int type, int root, int parent, int replyCount, int likeCount, int action, DateTime publishedAt, String message, String memberName, String memberAvatarUrl, bool isTop, bool isHidden, List<CommentItem> replies
});




}
/// @nodoc
class __$CommentItemCopyWithImpl<$Res>
    implements _$CommentItemCopyWith<$Res> {
  __$CommentItemCopyWithImpl(this._self, this._then);

  final _CommentItem _self;
  final $Res Function(_CommentItem) _then;

/// Create a copy of CommentItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rpid = null,Object? oid = null,Object? type = null,Object? root = null,Object? parent = null,Object? replyCount = null,Object? likeCount = null,Object? action = null,Object? publishedAt = null,Object? message = null,Object? memberName = null,Object? memberAvatarUrl = null,Object? isTop = null,Object? isHidden = null,Object? replies = null,}) {
  return _then(_CommentItem(
rpid: null == rpid ? _self.rpid : rpid // ignore: cast_nullable_to_non_nullable
as int,oid: null == oid ? _self.oid : oid // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,root: null == root ? _self.root : root // ignore: cast_nullable_to_non_nullable
as int,parent: null == parent ? _self.parent : parent // ignore: cast_nullable_to_non_nullable
as int,replyCount: null == replyCount ? _self.replyCount : replyCount // ignore: cast_nullable_to_non_nullable
as int,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as int,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,memberAvatarUrl: null == memberAvatarUrl ? _self.memberAvatarUrl : memberAvatarUrl // ignore: cast_nullable_to_non_nullable
as String,isTop: null == isTop ? _self.isTop : isTop // ignore: cast_nullable_to_non_nullable
as bool,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,replies: null == replies ? _self._replies : replies // ignore: cast_nullable_to_non_nullable
as List<CommentItem>,
  ));
}


}

// dart format on
