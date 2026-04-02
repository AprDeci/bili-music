// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'persisted_playback_queue.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PersistedPlaybackQueue {

 List<PersistedPlayableItem> get queue; int? get currentQueueIndex; PlayerQueueMode get queueMode; String? get queueSourceLabel; int get resumePositionMs; int? get savedAtEpochMs;
/// Create a copy of PersistedPlaybackQueue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersistedPlaybackQueueCopyWith<PersistedPlaybackQueue> get copyWith => _$PersistedPlaybackQueueCopyWithImpl<PersistedPlaybackQueue>(this as PersistedPlaybackQueue, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersistedPlaybackQueue&&const DeepCollectionEquality().equals(other.queue, queue)&&(identical(other.currentQueueIndex, currentQueueIndex) || other.currentQueueIndex == currentQueueIndex)&&(identical(other.queueMode, queueMode) || other.queueMode == queueMode)&&(identical(other.queueSourceLabel, queueSourceLabel) || other.queueSourceLabel == queueSourceLabel)&&(identical(other.resumePositionMs, resumePositionMs) || other.resumePositionMs == resumePositionMs)&&(identical(other.savedAtEpochMs, savedAtEpochMs) || other.savedAtEpochMs == savedAtEpochMs));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(queue),currentQueueIndex,queueMode,queueSourceLabel,resumePositionMs,savedAtEpochMs);

@override
String toString() {
  return 'PersistedPlaybackQueue(queue: $queue, currentQueueIndex: $currentQueueIndex, queueMode: $queueMode, queueSourceLabel: $queueSourceLabel, resumePositionMs: $resumePositionMs, savedAtEpochMs: $savedAtEpochMs)';
}


}

/// @nodoc
abstract mixin class $PersistedPlaybackQueueCopyWith<$Res>  {
  factory $PersistedPlaybackQueueCopyWith(PersistedPlaybackQueue value, $Res Function(PersistedPlaybackQueue) _then) = _$PersistedPlaybackQueueCopyWithImpl;
@useResult
$Res call({
 List<PersistedPlayableItem> queue, int? currentQueueIndex, PlayerQueueMode queueMode, String? queueSourceLabel, int resumePositionMs, int? savedAtEpochMs
});




}
/// @nodoc
class _$PersistedPlaybackQueueCopyWithImpl<$Res>
    implements $PersistedPlaybackQueueCopyWith<$Res> {
  _$PersistedPlaybackQueueCopyWithImpl(this._self, this._then);

  final PersistedPlaybackQueue _self;
  final $Res Function(PersistedPlaybackQueue) _then;

/// Create a copy of PersistedPlaybackQueue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? queue = null,Object? currentQueueIndex = freezed,Object? queueMode = null,Object? queueSourceLabel = freezed,Object? resumePositionMs = null,Object? savedAtEpochMs = freezed,}) {
  return _then(_self.copyWith(
queue: null == queue ? _self.queue : queue // ignore: cast_nullable_to_non_nullable
as List<PersistedPlayableItem>,currentQueueIndex: freezed == currentQueueIndex ? _self.currentQueueIndex : currentQueueIndex // ignore: cast_nullable_to_non_nullable
as int?,queueMode: null == queueMode ? _self.queueMode : queueMode // ignore: cast_nullable_to_non_nullable
as PlayerQueueMode,queueSourceLabel: freezed == queueSourceLabel ? _self.queueSourceLabel : queueSourceLabel // ignore: cast_nullable_to_non_nullable
as String?,resumePositionMs: null == resumePositionMs ? _self.resumePositionMs : resumePositionMs // ignore: cast_nullable_to_non_nullable
as int,savedAtEpochMs: freezed == savedAtEpochMs ? _self.savedAtEpochMs : savedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [PersistedPlaybackQueue].
extension PersistedPlaybackQueuePatterns on PersistedPlaybackQueue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersistedPlaybackQueue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersistedPlaybackQueue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersistedPlaybackQueue value)  $default,){
final _that = this;
switch (_that) {
case _PersistedPlaybackQueue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersistedPlaybackQueue value)?  $default,){
final _that = this;
switch (_that) {
case _PersistedPlaybackQueue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PersistedPlayableItem> queue,  int? currentQueueIndex,  PlayerQueueMode queueMode,  String? queueSourceLabel,  int resumePositionMs,  int? savedAtEpochMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersistedPlaybackQueue() when $default != null:
return $default(_that.queue,_that.currentQueueIndex,_that.queueMode,_that.queueSourceLabel,_that.resumePositionMs,_that.savedAtEpochMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PersistedPlayableItem> queue,  int? currentQueueIndex,  PlayerQueueMode queueMode,  String? queueSourceLabel,  int resumePositionMs,  int? savedAtEpochMs)  $default,) {final _that = this;
switch (_that) {
case _PersistedPlaybackQueue():
return $default(_that.queue,_that.currentQueueIndex,_that.queueMode,_that.queueSourceLabel,_that.resumePositionMs,_that.savedAtEpochMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PersistedPlayableItem> queue,  int? currentQueueIndex,  PlayerQueueMode queueMode,  String? queueSourceLabel,  int resumePositionMs,  int? savedAtEpochMs)?  $default,) {final _that = this;
switch (_that) {
case _PersistedPlaybackQueue() when $default != null:
return $default(_that.queue,_that.currentQueueIndex,_that.queueMode,_that.queueSourceLabel,_that.resumePositionMs,_that.savedAtEpochMs);case _:
  return null;

}
}

}

/// @nodoc


class _PersistedPlaybackQueue extends PersistedPlaybackQueue {
  const _PersistedPlaybackQueue({final  List<PersistedPlayableItem> queue = const <PersistedPlayableItem>[], this.currentQueueIndex, this.queueMode = PlayerQueueMode.sequence, this.queueSourceLabel, this.resumePositionMs = 0, this.savedAtEpochMs}): _queue = queue,super._();
  

 final  List<PersistedPlayableItem> _queue;
@override@JsonKey() List<PersistedPlayableItem> get queue {
  if (_queue is EqualUnmodifiableListView) return _queue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_queue);
}

@override final  int? currentQueueIndex;
@override@JsonKey() final  PlayerQueueMode queueMode;
@override final  String? queueSourceLabel;
@override@JsonKey() final  int resumePositionMs;
@override final  int? savedAtEpochMs;

/// Create a copy of PersistedPlaybackQueue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersistedPlaybackQueueCopyWith<_PersistedPlaybackQueue> get copyWith => __$PersistedPlaybackQueueCopyWithImpl<_PersistedPlaybackQueue>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersistedPlaybackQueue&&const DeepCollectionEquality().equals(other._queue, _queue)&&(identical(other.currentQueueIndex, currentQueueIndex) || other.currentQueueIndex == currentQueueIndex)&&(identical(other.queueMode, queueMode) || other.queueMode == queueMode)&&(identical(other.queueSourceLabel, queueSourceLabel) || other.queueSourceLabel == queueSourceLabel)&&(identical(other.resumePositionMs, resumePositionMs) || other.resumePositionMs == resumePositionMs)&&(identical(other.savedAtEpochMs, savedAtEpochMs) || other.savedAtEpochMs == savedAtEpochMs));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_queue),currentQueueIndex,queueMode,queueSourceLabel,resumePositionMs,savedAtEpochMs);

@override
String toString() {
  return 'PersistedPlaybackQueue(queue: $queue, currentQueueIndex: $currentQueueIndex, queueMode: $queueMode, queueSourceLabel: $queueSourceLabel, resumePositionMs: $resumePositionMs, savedAtEpochMs: $savedAtEpochMs)';
}


}

/// @nodoc
abstract mixin class _$PersistedPlaybackQueueCopyWith<$Res> implements $PersistedPlaybackQueueCopyWith<$Res> {
  factory _$PersistedPlaybackQueueCopyWith(_PersistedPlaybackQueue value, $Res Function(_PersistedPlaybackQueue) _then) = __$PersistedPlaybackQueueCopyWithImpl;
@override @useResult
$Res call({
 List<PersistedPlayableItem> queue, int? currentQueueIndex, PlayerQueueMode queueMode, String? queueSourceLabel, int resumePositionMs, int? savedAtEpochMs
});




}
/// @nodoc
class __$PersistedPlaybackQueueCopyWithImpl<$Res>
    implements _$PersistedPlaybackQueueCopyWith<$Res> {
  __$PersistedPlaybackQueueCopyWithImpl(this._self, this._then);

  final _PersistedPlaybackQueue _self;
  final $Res Function(_PersistedPlaybackQueue) _then;

/// Create a copy of PersistedPlaybackQueue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? queue = null,Object? currentQueueIndex = freezed,Object? queueMode = null,Object? queueSourceLabel = freezed,Object? resumePositionMs = null,Object? savedAtEpochMs = freezed,}) {
  return _then(_PersistedPlaybackQueue(
queue: null == queue ? _self._queue : queue // ignore: cast_nullable_to_non_nullable
as List<PersistedPlayableItem>,currentQueueIndex: freezed == currentQueueIndex ? _self.currentQueueIndex : currentQueueIndex // ignore: cast_nullable_to_non_nullable
as int?,queueMode: null == queueMode ? _self.queueMode : queueMode // ignore: cast_nullable_to_non_nullable
as PlayerQueueMode,queueSourceLabel: freezed == queueSourceLabel ? _self.queueSourceLabel : queueSourceLabel // ignore: cast_nullable_to_non_nullable
as String?,resumePositionMs: null == resumePositionMs ? _self.resumePositionMs : resumePositionMs // ignore: cast_nullable_to_non_nullable
as int,savedAtEpochMs: freezed == savedAtEpochMs ? _self.savedAtEpochMs : savedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$PersistedPlayableItem {

 int get aid; String get bvid; String get title; String get author; String get coverUrl; int? get cid; int? get page; String? get pageTitle; String? get durationText; String? get playCountText; String? get danmakuCountText; String? get likeCountText; String? get coinCountText; String? get favoriteCountText; String? get shareCountText; int? get replyCount; String? get replyCountText; String? get publishTimeText; String? get description;
/// Create a copy of PersistedPlayableItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersistedPlayableItemCopyWith<PersistedPlayableItem> get copyWith => _$PersistedPlayableItemCopyWithImpl<PersistedPlayableItem>(this as PersistedPlayableItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersistedPlayableItem&&(identical(other.aid, aid) || other.aid == aid)&&(identical(other.bvid, bvid) || other.bvid == bvid)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageTitle, pageTitle) || other.pageTitle == pageTitle)&&(identical(other.durationText, durationText) || other.durationText == durationText)&&(identical(other.playCountText, playCountText) || other.playCountText == playCountText)&&(identical(other.danmakuCountText, danmakuCountText) || other.danmakuCountText == danmakuCountText)&&(identical(other.likeCountText, likeCountText) || other.likeCountText == likeCountText)&&(identical(other.coinCountText, coinCountText) || other.coinCountText == coinCountText)&&(identical(other.favoriteCountText, favoriteCountText) || other.favoriteCountText == favoriteCountText)&&(identical(other.shareCountText, shareCountText) || other.shareCountText == shareCountText)&&(identical(other.replyCount, replyCount) || other.replyCount == replyCount)&&(identical(other.replyCountText, replyCountText) || other.replyCountText == replyCountText)&&(identical(other.publishTimeText, publishTimeText) || other.publishTimeText == publishTimeText)&&(identical(other.description, description) || other.description == description));
}


@override
int get hashCode => Object.hashAll([runtimeType,aid,bvid,title,author,coverUrl,cid,page,pageTitle,durationText,playCountText,danmakuCountText,likeCountText,coinCountText,favoriteCountText,shareCountText,replyCount,replyCountText,publishTimeText,description]);

@override
String toString() {
  return 'PersistedPlayableItem(aid: $aid, bvid: $bvid, title: $title, author: $author, coverUrl: $coverUrl, cid: $cid, page: $page, pageTitle: $pageTitle, durationText: $durationText, playCountText: $playCountText, danmakuCountText: $danmakuCountText, likeCountText: $likeCountText, coinCountText: $coinCountText, favoriteCountText: $favoriteCountText, shareCountText: $shareCountText, replyCount: $replyCount, replyCountText: $replyCountText, publishTimeText: $publishTimeText, description: $description)';
}


}

/// @nodoc
abstract mixin class $PersistedPlayableItemCopyWith<$Res>  {
  factory $PersistedPlayableItemCopyWith(PersistedPlayableItem value, $Res Function(PersistedPlayableItem) _then) = _$PersistedPlayableItemCopyWithImpl;
@useResult
$Res call({
 int aid, String bvid, String title, String author, String coverUrl, int? cid, int? page, String? pageTitle, String? durationText, String? playCountText, String? danmakuCountText, String? likeCountText, String? coinCountText, String? favoriteCountText, String? shareCountText, int? replyCount, String? replyCountText, String? publishTimeText, String? description
});




}
/// @nodoc
class _$PersistedPlayableItemCopyWithImpl<$Res>
    implements $PersistedPlayableItemCopyWith<$Res> {
  _$PersistedPlayableItemCopyWithImpl(this._self, this._then);

  final PersistedPlayableItem _self;
  final $Res Function(PersistedPlayableItem) _then;

/// Create a copy of PersistedPlayableItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? aid = null,Object? bvid = null,Object? title = null,Object? author = null,Object? coverUrl = null,Object? cid = freezed,Object? page = freezed,Object? pageTitle = freezed,Object? durationText = freezed,Object? playCountText = freezed,Object? danmakuCountText = freezed,Object? likeCountText = freezed,Object? coinCountText = freezed,Object? favoriteCountText = freezed,Object? shareCountText = freezed,Object? replyCount = freezed,Object? replyCountText = freezed,Object? publishTimeText = freezed,Object? description = freezed,}) {
  return _then(_self.copyWith(
aid: null == aid ? _self.aid : aid // ignore: cast_nullable_to_non_nullable
as int,bvid: null == bvid ? _self.bvid : bvid // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,cid: freezed == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as int?,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,pageTitle: freezed == pageTitle ? _self.pageTitle : pageTitle // ignore: cast_nullable_to_non_nullable
as String?,durationText: freezed == durationText ? _self.durationText : durationText // ignore: cast_nullable_to_non_nullable
as String?,playCountText: freezed == playCountText ? _self.playCountText : playCountText // ignore: cast_nullable_to_non_nullable
as String?,danmakuCountText: freezed == danmakuCountText ? _self.danmakuCountText : danmakuCountText // ignore: cast_nullable_to_non_nullable
as String?,likeCountText: freezed == likeCountText ? _self.likeCountText : likeCountText // ignore: cast_nullable_to_non_nullable
as String?,coinCountText: freezed == coinCountText ? _self.coinCountText : coinCountText // ignore: cast_nullable_to_non_nullable
as String?,favoriteCountText: freezed == favoriteCountText ? _self.favoriteCountText : favoriteCountText // ignore: cast_nullable_to_non_nullable
as String?,shareCountText: freezed == shareCountText ? _self.shareCountText : shareCountText // ignore: cast_nullable_to_non_nullable
as String?,replyCount: freezed == replyCount ? _self.replyCount : replyCount // ignore: cast_nullable_to_non_nullable
as int?,replyCountText: freezed == replyCountText ? _self.replyCountText : replyCountText // ignore: cast_nullable_to_non_nullable
as String?,publishTimeText: freezed == publishTimeText ? _self.publishTimeText : publishTimeText // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PersistedPlayableItem].
extension PersistedPlayableItemPatterns on PersistedPlayableItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersistedPlayableItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersistedPlayableItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersistedPlayableItem value)  $default,){
final _that = this;
switch (_that) {
case _PersistedPlayableItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersistedPlayableItem value)?  $default,){
final _that = this;
switch (_that) {
case _PersistedPlayableItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int aid,  String bvid,  String title,  String author,  String coverUrl,  int? cid,  int? page,  String? pageTitle,  String? durationText,  String? playCountText,  String? danmakuCountText,  String? likeCountText,  String? coinCountText,  String? favoriteCountText,  String? shareCountText,  int? replyCount,  String? replyCountText,  String? publishTimeText,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersistedPlayableItem() when $default != null:
return $default(_that.aid,_that.bvid,_that.title,_that.author,_that.coverUrl,_that.cid,_that.page,_that.pageTitle,_that.durationText,_that.playCountText,_that.danmakuCountText,_that.likeCountText,_that.coinCountText,_that.favoriteCountText,_that.shareCountText,_that.replyCount,_that.replyCountText,_that.publishTimeText,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int aid,  String bvid,  String title,  String author,  String coverUrl,  int? cid,  int? page,  String? pageTitle,  String? durationText,  String? playCountText,  String? danmakuCountText,  String? likeCountText,  String? coinCountText,  String? favoriteCountText,  String? shareCountText,  int? replyCount,  String? replyCountText,  String? publishTimeText,  String? description)  $default,) {final _that = this;
switch (_that) {
case _PersistedPlayableItem():
return $default(_that.aid,_that.bvid,_that.title,_that.author,_that.coverUrl,_that.cid,_that.page,_that.pageTitle,_that.durationText,_that.playCountText,_that.danmakuCountText,_that.likeCountText,_that.coinCountText,_that.favoriteCountText,_that.shareCountText,_that.replyCount,_that.replyCountText,_that.publishTimeText,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int aid,  String bvid,  String title,  String author,  String coverUrl,  int? cid,  int? page,  String? pageTitle,  String? durationText,  String? playCountText,  String? danmakuCountText,  String? likeCountText,  String? coinCountText,  String? favoriteCountText,  String? shareCountText,  int? replyCount,  String? replyCountText,  String? publishTimeText,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _PersistedPlayableItem() when $default != null:
return $default(_that.aid,_that.bvid,_that.title,_that.author,_that.coverUrl,_that.cid,_that.page,_that.pageTitle,_that.durationText,_that.playCountText,_that.danmakuCountText,_that.likeCountText,_that.coinCountText,_that.favoriteCountText,_that.shareCountText,_that.replyCount,_that.replyCountText,_that.publishTimeText,_that.description);case _:
  return null;

}
}

}

/// @nodoc


class _PersistedPlayableItem extends PersistedPlayableItem {
  const _PersistedPlayableItem({required this.aid, required this.bvid, required this.title, required this.author, required this.coverUrl, this.cid, this.page, this.pageTitle, this.durationText, this.playCountText, this.danmakuCountText, this.likeCountText, this.coinCountText, this.favoriteCountText, this.shareCountText, this.replyCount, this.replyCountText, this.publishTimeText, this.description}): super._();
  

@override final  int aid;
@override final  String bvid;
@override final  String title;
@override final  String author;
@override final  String coverUrl;
@override final  int? cid;
@override final  int? page;
@override final  String? pageTitle;
@override final  String? durationText;
@override final  String? playCountText;
@override final  String? danmakuCountText;
@override final  String? likeCountText;
@override final  String? coinCountText;
@override final  String? favoriteCountText;
@override final  String? shareCountText;
@override final  int? replyCount;
@override final  String? replyCountText;
@override final  String? publishTimeText;
@override final  String? description;

/// Create a copy of PersistedPlayableItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersistedPlayableItemCopyWith<_PersistedPlayableItem> get copyWith => __$PersistedPlayableItemCopyWithImpl<_PersistedPlayableItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersistedPlayableItem&&(identical(other.aid, aid) || other.aid == aid)&&(identical(other.bvid, bvid) || other.bvid == bvid)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageTitle, pageTitle) || other.pageTitle == pageTitle)&&(identical(other.durationText, durationText) || other.durationText == durationText)&&(identical(other.playCountText, playCountText) || other.playCountText == playCountText)&&(identical(other.danmakuCountText, danmakuCountText) || other.danmakuCountText == danmakuCountText)&&(identical(other.likeCountText, likeCountText) || other.likeCountText == likeCountText)&&(identical(other.coinCountText, coinCountText) || other.coinCountText == coinCountText)&&(identical(other.favoriteCountText, favoriteCountText) || other.favoriteCountText == favoriteCountText)&&(identical(other.shareCountText, shareCountText) || other.shareCountText == shareCountText)&&(identical(other.replyCount, replyCount) || other.replyCount == replyCount)&&(identical(other.replyCountText, replyCountText) || other.replyCountText == replyCountText)&&(identical(other.publishTimeText, publishTimeText) || other.publishTimeText == publishTimeText)&&(identical(other.description, description) || other.description == description));
}


@override
int get hashCode => Object.hashAll([runtimeType,aid,bvid,title,author,coverUrl,cid,page,pageTitle,durationText,playCountText,danmakuCountText,likeCountText,coinCountText,favoriteCountText,shareCountText,replyCount,replyCountText,publishTimeText,description]);

@override
String toString() {
  return 'PersistedPlayableItem(aid: $aid, bvid: $bvid, title: $title, author: $author, coverUrl: $coverUrl, cid: $cid, page: $page, pageTitle: $pageTitle, durationText: $durationText, playCountText: $playCountText, danmakuCountText: $danmakuCountText, likeCountText: $likeCountText, coinCountText: $coinCountText, favoriteCountText: $favoriteCountText, shareCountText: $shareCountText, replyCount: $replyCount, replyCountText: $replyCountText, publishTimeText: $publishTimeText, description: $description)';
}


}

/// @nodoc
abstract mixin class _$PersistedPlayableItemCopyWith<$Res> implements $PersistedPlayableItemCopyWith<$Res> {
  factory _$PersistedPlayableItemCopyWith(_PersistedPlayableItem value, $Res Function(_PersistedPlayableItem) _then) = __$PersistedPlayableItemCopyWithImpl;
@override @useResult
$Res call({
 int aid, String bvid, String title, String author, String coverUrl, int? cid, int? page, String? pageTitle, String? durationText, String? playCountText, String? danmakuCountText, String? likeCountText, String? coinCountText, String? favoriteCountText, String? shareCountText, int? replyCount, String? replyCountText, String? publishTimeText, String? description
});




}
/// @nodoc
class __$PersistedPlayableItemCopyWithImpl<$Res>
    implements _$PersistedPlayableItemCopyWith<$Res> {
  __$PersistedPlayableItemCopyWithImpl(this._self, this._then);

  final _PersistedPlayableItem _self;
  final $Res Function(_PersistedPlayableItem) _then;

/// Create a copy of PersistedPlayableItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? aid = null,Object? bvid = null,Object? title = null,Object? author = null,Object? coverUrl = null,Object? cid = freezed,Object? page = freezed,Object? pageTitle = freezed,Object? durationText = freezed,Object? playCountText = freezed,Object? danmakuCountText = freezed,Object? likeCountText = freezed,Object? coinCountText = freezed,Object? favoriteCountText = freezed,Object? shareCountText = freezed,Object? replyCount = freezed,Object? replyCountText = freezed,Object? publishTimeText = freezed,Object? description = freezed,}) {
  return _then(_PersistedPlayableItem(
aid: null == aid ? _self.aid : aid // ignore: cast_nullable_to_non_nullable
as int,bvid: null == bvid ? _self.bvid : bvid // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,cid: freezed == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as int?,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,pageTitle: freezed == pageTitle ? _self.pageTitle : pageTitle // ignore: cast_nullable_to_non_nullable
as String?,durationText: freezed == durationText ? _self.durationText : durationText // ignore: cast_nullable_to_non_nullable
as String?,playCountText: freezed == playCountText ? _self.playCountText : playCountText // ignore: cast_nullable_to_non_nullable
as String?,danmakuCountText: freezed == danmakuCountText ? _self.danmakuCountText : danmakuCountText // ignore: cast_nullable_to_non_nullable
as String?,likeCountText: freezed == likeCountText ? _self.likeCountText : likeCountText // ignore: cast_nullable_to_non_nullable
as String?,coinCountText: freezed == coinCountText ? _self.coinCountText : coinCountText // ignore: cast_nullable_to_non_nullable
as String?,favoriteCountText: freezed == favoriteCountText ? _self.favoriteCountText : favoriteCountText // ignore: cast_nullable_to_non_nullable
as String?,shareCountText: freezed == shareCountText ? _self.shareCountText : shareCountText // ignore: cast_nullable_to_non_nullable
as String?,replyCount: freezed == replyCount ? _self.replyCount : replyCount // ignore: cast_nullable_to_non_nullable
as int?,replyCountText: freezed == replyCountText ? _self.replyCountText : replyCountText // ignore: cast_nullable_to_non_nullable
as String?,publishTimeText: freezed == publishTimeText ? _self.publishTimeText : publishTimeText // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
