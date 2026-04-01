// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlayerState {

 PlayableItem? get currentItem; AudioStreamInfo? get audioStream; List<PlayableItem> get availableParts; List<PlayableItem> get queue; int? get currentQueueIndex; String? get queueSourceLabel; PlayerQueueMode get queueMode; bool get isLoading; bool get isReady; bool get isPlaying; bool get isBuffering; Duration get position; Duration get bufferedPosition; Duration? get duration; PlayerStatusHint? get statusHint; String? get errorMessage;
/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerStateCopyWith<PlayerState> get copyWith => _$PlayerStateCopyWithImpl<PlayerState>(this as PlayerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerState&&(identical(other.currentItem, currentItem) || other.currentItem == currentItem)&&(identical(other.audioStream, audioStream) || other.audioStream == audioStream)&&const DeepCollectionEquality().equals(other.availableParts, availableParts)&&const DeepCollectionEquality().equals(other.queue, queue)&&(identical(other.currentQueueIndex, currentQueueIndex) || other.currentQueueIndex == currentQueueIndex)&&(identical(other.queueSourceLabel, queueSourceLabel) || other.queueSourceLabel == queueSourceLabel)&&(identical(other.queueMode, queueMode) || other.queueMode == queueMode)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isReady, isReady) || other.isReady == isReady)&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.isBuffering, isBuffering) || other.isBuffering == isBuffering)&&(identical(other.position, position) || other.position == position)&&(identical(other.bufferedPosition, bufferedPosition) || other.bufferedPosition == bufferedPosition)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.statusHint, statusHint) || other.statusHint == statusHint)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,currentItem,audioStream,const DeepCollectionEquality().hash(availableParts),const DeepCollectionEquality().hash(queue),currentQueueIndex,queueSourceLabel,queueMode,isLoading,isReady,isPlaying,isBuffering,position,bufferedPosition,duration,statusHint,errorMessage);

@override
String toString() {
  return 'PlayerState(currentItem: $currentItem, audioStream: $audioStream, availableParts: $availableParts, queue: $queue, currentQueueIndex: $currentQueueIndex, queueSourceLabel: $queueSourceLabel, queueMode: $queueMode, isLoading: $isLoading, isReady: $isReady, isPlaying: $isPlaying, isBuffering: $isBuffering, position: $position, bufferedPosition: $bufferedPosition, duration: $duration, statusHint: $statusHint, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $PlayerStateCopyWith<$Res>  {
  factory $PlayerStateCopyWith(PlayerState value, $Res Function(PlayerState) _then) = _$PlayerStateCopyWithImpl;
@useResult
$Res call({
 PlayableItem? currentItem, AudioStreamInfo? audioStream, List<PlayableItem> availableParts, List<PlayableItem> queue, int? currentQueueIndex, String? queueSourceLabel, PlayerQueueMode queueMode, bool isLoading, bool isReady, bool isPlaying, bool isBuffering, Duration position, Duration bufferedPosition, Duration? duration, PlayerStatusHint? statusHint, String? errorMessage
});




}
/// @nodoc
class _$PlayerStateCopyWithImpl<$Res>
    implements $PlayerStateCopyWith<$Res> {
  _$PlayerStateCopyWithImpl(this._self, this._then);

  final PlayerState _self;
  final $Res Function(PlayerState) _then;

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentItem = freezed,Object? audioStream = freezed,Object? availableParts = null,Object? queue = null,Object? currentQueueIndex = freezed,Object? queueSourceLabel = freezed,Object? queueMode = null,Object? isLoading = null,Object? isReady = null,Object? isPlaying = null,Object? isBuffering = null,Object? position = null,Object? bufferedPosition = null,Object? duration = freezed,Object? statusHint = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
currentItem: freezed == currentItem ? _self.currentItem : currentItem // ignore: cast_nullable_to_non_nullable
as PlayableItem?,audioStream: freezed == audioStream ? _self.audioStream : audioStream // ignore: cast_nullable_to_non_nullable
as AudioStreamInfo?,availableParts: null == availableParts ? _self.availableParts : availableParts // ignore: cast_nullable_to_non_nullable
as List<PlayableItem>,queue: null == queue ? _self.queue : queue // ignore: cast_nullable_to_non_nullable
as List<PlayableItem>,currentQueueIndex: freezed == currentQueueIndex ? _self.currentQueueIndex : currentQueueIndex // ignore: cast_nullable_to_non_nullable
as int?,queueSourceLabel: freezed == queueSourceLabel ? _self.queueSourceLabel : queueSourceLabel // ignore: cast_nullable_to_non_nullable
as String?,queueMode: null == queueMode ? _self.queueMode : queueMode // ignore: cast_nullable_to_non_nullable
as PlayerQueueMode,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isReady: null == isReady ? _self.isReady : isReady // ignore: cast_nullable_to_non_nullable
as bool,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,isBuffering: null == isBuffering ? _self.isBuffering : isBuffering // ignore: cast_nullable_to_non_nullable
as bool,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,bufferedPosition: null == bufferedPosition ? _self.bufferedPosition : bufferedPosition // ignore: cast_nullable_to_non_nullable
as Duration,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration?,statusHint: freezed == statusHint ? _self.statusHint : statusHint // ignore: cast_nullable_to_non_nullable
as PlayerStatusHint?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayerState].
extension PlayerStatePatterns on PlayerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerState value)  $default,){
final _that = this;
switch (_that) {
case _PlayerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerState value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PlayableItem? currentItem,  AudioStreamInfo? audioStream,  List<PlayableItem> availableParts,  List<PlayableItem> queue,  int? currentQueueIndex,  String? queueSourceLabel,  PlayerQueueMode queueMode,  bool isLoading,  bool isReady,  bool isPlaying,  bool isBuffering,  Duration position,  Duration bufferedPosition,  Duration? duration,  PlayerStatusHint? statusHint,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
return $default(_that.currentItem,_that.audioStream,_that.availableParts,_that.queue,_that.currentQueueIndex,_that.queueSourceLabel,_that.queueMode,_that.isLoading,_that.isReady,_that.isPlaying,_that.isBuffering,_that.position,_that.bufferedPosition,_that.duration,_that.statusHint,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PlayableItem? currentItem,  AudioStreamInfo? audioStream,  List<PlayableItem> availableParts,  List<PlayableItem> queue,  int? currentQueueIndex,  String? queueSourceLabel,  PlayerQueueMode queueMode,  bool isLoading,  bool isReady,  bool isPlaying,  bool isBuffering,  Duration position,  Duration bufferedPosition,  Duration? duration,  PlayerStatusHint? statusHint,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _PlayerState():
return $default(_that.currentItem,_that.audioStream,_that.availableParts,_that.queue,_that.currentQueueIndex,_that.queueSourceLabel,_that.queueMode,_that.isLoading,_that.isReady,_that.isPlaying,_that.isBuffering,_that.position,_that.bufferedPosition,_that.duration,_that.statusHint,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PlayableItem? currentItem,  AudioStreamInfo? audioStream,  List<PlayableItem> availableParts,  List<PlayableItem> queue,  int? currentQueueIndex,  String? queueSourceLabel,  PlayerQueueMode queueMode,  bool isLoading,  bool isReady,  bool isPlaying,  bool isBuffering,  Duration position,  Duration bufferedPosition,  Duration? duration,  PlayerStatusHint? statusHint,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
return $default(_that.currentItem,_that.audioStream,_that.availableParts,_that.queue,_that.currentQueueIndex,_that.queueSourceLabel,_that.queueMode,_that.isLoading,_that.isReady,_that.isPlaying,_that.isBuffering,_that.position,_that.bufferedPosition,_that.duration,_that.statusHint,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _PlayerState extends PlayerState {
  const _PlayerState({this.currentItem, this.audioStream, final  List<PlayableItem> availableParts = const <PlayableItem>[], final  List<PlayableItem> queue = const <PlayableItem>[], this.currentQueueIndex, this.queueSourceLabel, this.queueMode = PlayerQueueMode.sequence, this.isLoading = false, this.isReady = false, this.isPlaying = false, this.isBuffering = false, this.position = Duration.zero, this.bufferedPosition = Duration.zero, this.duration, this.statusHint, this.errorMessage}): _availableParts = availableParts,_queue = queue,super._();
  

@override final  PlayableItem? currentItem;
@override final  AudioStreamInfo? audioStream;
 final  List<PlayableItem> _availableParts;
@override@JsonKey() List<PlayableItem> get availableParts {
  if (_availableParts is EqualUnmodifiableListView) return _availableParts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableParts);
}

 final  List<PlayableItem> _queue;
@override@JsonKey() List<PlayableItem> get queue {
  if (_queue is EqualUnmodifiableListView) return _queue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_queue);
}

@override final  int? currentQueueIndex;
@override final  String? queueSourceLabel;
@override@JsonKey() final  PlayerQueueMode queueMode;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isReady;
@override@JsonKey() final  bool isPlaying;
@override@JsonKey() final  bool isBuffering;
@override@JsonKey() final  Duration position;
@override@JsonKey() final  Duration bufferedPosition;
@override final  Duration? duration;
@override final  PlayerStatusHint? statusHint;
@override final  String? errorMessage;

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerStateCopyWith<_PlayerState> get copyWith => __$PlayerStateCopyWithImpl<_PlayerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerState&&(identical(other.currentItem, currentItem) || other.currentItem == currentItem)&&(identical(other.audioStream, audioStream) || other.audioStream == audioStream)&&const DeepCollectionEquality().equals(other._availableParts, _availableParts)&&const DeepCollectionEquality().equals(other._queue, _queue)&&(identical(other.currentQueueIndex, currentQueueIndex) || other.currentQueueIndex == currentQueueIndex)&&(identical(other.queueSourceLabel, queueSourceLabel) || other.queueSourceLabel == queueSourceLabel)&&(identical(other.queueMode, queueMode) || other.queueMode == queueMode)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isReady, isReady) || other.isReady == isReady)&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.isBuffering, isBuffering) || other.isBuffering == isBuffering)&&(identical(other.position, position) || other.position == position)&&(identical(other.bufferedPosition, bufferedPosition) || other.bufferedPosition == bufferedPosition)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.statusHint, statusHint) || other.statusHint == statusHint)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,currentItem,audioStream,const DeepCollectionEquality().hash(_availableParts),const DeepCollectionEquality().hash(_queue),currentQueueIndex,queueSourceLabel,queueMode,isLoading,isReady,isPlaying,isBuffering,position,bufferedPosition,duration,statusHint,errorMessage);

@override
String toString() {
  return 'PlayerState(currentItem: $currentItem, audioStream: $audioStream, availableParts: $availableParts, queue: $queue, currentQueueIndex: $currentQueueIndex, queueSourceLabel: $queueSourceLabel, queueMode: $queueMode, isLoading: $isLoading, isReady: $isReady, isPlaying: $isPlaying, isBuffering: $isBuffering, position: $position, bufferedPosition: $bufferedPosition, duration: $duration, statusHint: $statusHint, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$PlayerStateCopyWith<$Res> implements $PlayerStateCopyWith<$Res> {
  factory _$PlayerStateCopyWith(_PlayerState value, $Res Function(_PlayerState) _then) = __$PlayerStateCopyWithImpl;
@override @useResult
$Res call({
 PlayableItem? currentItem, AudioStreamInfo? audioStream, List<PlayableItem> availableParts, List<PlayableItem> queue, int? currentQueueIndex, String? queueSourceLabel, PlayerQueueMode queueMode, bool isLoading, bool isReady, bool isPlaying, bool isBuffering, Duration position, Duration bufferedPosition, Duration? duration, PlayerStatusHint? statusHint, String? errorMessage
});




}
/// @nodoc
class __$PlayerStateCopyWithImpl<$Res>
    implements _$PlayerStateCopyWith<$Res> {
  __$PlayerStateCopyWithImpl(this._self, this._then);

  final _PlayerState _self;
  final $Res Function(_PlayerState) _then;

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentItem = freezed,Object? audioStream = freezed,Object? availableParts = null,Object? queue = null,Object? currentQueueIndex = freezed,Object? queueSourceLabel = freezed,Object? queueMode = null,Object? isLoading = null,Object? isReady = null,Object? isPlaying = null,Object? isBuffering = null,Object? position = null,Object? bufferedPosition = null,Object? duration = freezed,Object? statusHint = freezed,Object? errorMessage = freezed,}) {
  return _then(_PlayerState(
currentItem: freezed == currentItem ? _self.currentItem : currentItem // ignore: cast_nullable_to_non_nullable
as PlayableItem?,audioStream: freezed == audioStream ? _self.audioStream : audioStream // ignore: cast_nullable_to_non_nullable
as AudioStreamInfo?,availableParts: null == availableParts ? _self._availableParts : availableParts // ignore: cast_nullable_to_non_nullable
as List<PlayableItem>,queue: null == queue ? _self._queue : queue // ignore: cast_nullable_to_non_nullable
as List<PlayableItem>,currentQueueIndex: freezed == currentQueueIndex ? _self.currentQueueIndex : currentQueueIndex // ignore: cast_nullable_to_non_nullable
as int?,queueSourceLabel: freezed == queueSourceLabel ? _self.queueSourceLabel : queueSourceLabel // ignore: cast_nullable_to_non_nullable
as String?,queueMode: null == queueMode ? _self.queueMode : queueMode // ignore: cast_nullable_to_non_nullable
as PlayerQueueMode,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isReady: null == isReady ? _self.isReady : isReady // ignore: cast_nullable_to_non_nullable
as bool,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,isBuffering: null == isBuffering ? _self.isBuffering : isBuffering // ignore: cast_nullable_to_non_nullable
as bool,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,bufferedPosition: null == bufferedPosition ? _self.bufferedPosition : bufferedPosition // ignore: cast_nullable_to_non_nullable
as Duration,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration?,statusHint: freezed == statusHint ? _self.statusHint : statusHint // ignore: cast_nullable_to_non_nullable
as PlayerStatusHint?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
