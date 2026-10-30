// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_subtitle_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlayerSubtitleState {

 String? get stableId; List<BiliSubtitleTrack> get tracks; String? get selectedTrackId; String? get pendingTrackId; List<BiliSubtitleLine> get lines; int get offsetMs; bool get isDiscovering; String? get errorMessage;
/// Create a copy of PlayerSubtitleState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerSubtitleStateCopyWith<PlayerSubtitleState> get copyWith => _$PlayerSubtitleStateCopyWithImpl<PlayerSubtitleState>(this as PlayerSubtitleState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerSubtitleState&&(identical(other.stableId, stableId) || other.stableId == stableId)&&const DeepCollectionEquality().equals(other.tracks, tracks)&&(identical(other.selectedTrackId, selectedTrackId) || other.selectedTrackId == selectedTrackId)&&(identical(other.pendingTrackId, pendingTrackId) || other.pendingTrackId == pendingTrackId)&&const DeepCollectionEquality().equals(other.lines, lines)&&(identical(other.offsetMs, offsetMs) || other.offsetMs == offsetMs)&&(identical(other.isDiscovering, isDiscovering) || other.isDiscovering == isDiscovering)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,stableId,const DeepCollectionEquality().hash(tracks),selectedTrackId,pendingTrackId,const DeepCollectionEquality().hash(lines),offsetMs,isDiscovering,errorMessage);

@override
String toString() {
  return 'PlayerSubtitleState(stableId: $stableId, tracks: $tracks, selectedTrackId: $selectedTrackId, pendingTrackId: $pendingTrackId, lines: $lines, offsetMs: $offsetMs, isDiscovering: $isDiscovering, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $PlayerSubtitleStateCopyWith<$Res>  {
  factory $PlayerSubtitleStateCopyWith(PlayerSubtitleState value, $Res Function(PlayerSubtitleState) _then) = _$PlayerSubtitleStateCopyWithImpl;
@useResult
$Res call({
 String? stableId, List<BiliSubtitleTrack> tracks, String? selectedTrackId, String? pendingTrackId, List<BiliSubtitleLine> lines, int offsetMs, bool isDiscovering, String? errorMessage
});




}
/// @nodoc
class _$PlayerSubtitleStateCopyWithImpl<$Res>
    implements $PlayerSubtitleStateCopyWith<$Res> {
  _$PlayerSubtitleStateCopyWithImpl(this._self, this._then);

  final PlayerSubtitleState _self;
  final $Res Function(PlayerSubtitleState) _then;

/// Create a copy of PlayerSubtitleState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stableId = freezed,Object? tracks = null,Object? selectedTrackId = freezed,Object? pendingTrackId = freezed,Object? lines = null,Object? offsetMs = null,Object? isDiscovering = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
stableId: freezed == stableId ? _self.stableId : stableId // ignore: cast_nullable_to_non_nullable
as String?,tracks: null == tracks ? _self.tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<BiliSubtitleTrack>,selectedTrackId: freezed == selectedTrackId ? _self.selectedTrackId : selectedTrackId // ignore: cast_nullable_to_non_nullable
as String?,pendingTrackId: freezed == pendingTrackId ? _self.pendingTrackId : pendingTrackId // ignore: cast_nullable_to_non_nullable
as String?,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<BiliSubtitleLine>,offsetMs: null == offsetMs ? _self.offsetMs : offsetMs // ignore: cast_nullable_to_non_nullable
as int,isDiscovering: null == isDiscovering ? _self.isDiscovering : isDiscovering // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayerSubtitleState].
extension PlayerSubtitleStatePatterns on PlayerSubtitleState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerSubtitleState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerSubtitleState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerSubtitleState value)  $default,){
final _that = this;
switch (_that) {
case _PlayerSubtitleState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerSubtitleState value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerSubtitleState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? stableId,  List<BiliSubtitleTrack> tracks,  String? selectedTrackId,  String? pendingTrackId,  List<BiliSubtitleLine> lines,  int offsetMs,  bool isDiscovering,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerSubtitleState() when $default != null:
return $default(_that.stableId,_that.tracks,_that.selectedTrackId,_that.pendingTrackId,_that.lines,_that.offsetMs,_that.isDiscovering,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? stableId,  List<BiliSubtitleTrack> tracks,  String? selectedTrackId,  String? pendingTrackId,  List<BiliSubtitleLine> lines,  int offsetMs,  bool isDiscovering,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _PlayerSubtitleState():
return $default(_that.stableId,_that.tracks,_that.selectedTrackId,_that.pendingTrackId,_that.lines,_that.offsetMs,_that.isDiscovering,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? stableId,  List<BiliSubtitleTrack> tracks,  String? selectedTrackId,  String? pendingTrackId,  List<BiliSubtitleLine> lines,  int offsetMs,  bool isDiscovering,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _PlayerSubtitleState() when $default != null:
return $default(_that.stableId,_that.tracks,_that.selectedTrackId,_that.pendingTrackId,_that.lines,_that.offsetMs,_that.isDiscovering,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _PlayerSubtitleState extends PlayerSubtitleState {
  const _PlayerSubtitleState({this.stableId, final  List<BiliSubtitleTrack> tracks = const <BiliSubtitleTrack>[], this.selectedTrackId, this.pendingTrackId, final  List<BiliSubtitleLine> lines = const <BiliSubtitleLine>[], this.offsetMs = 0, this.isDiscovering = false, this.errorMessage}): _tracks = tracks,_lines = lines,super._();
  

@override final  String? stableId;
 final  List<BiliSubtitleTrack> _tracks;
@override@JsonKey() List<BiliSubtitleTrack> get tracks {
  if (_tracks is EqualUnmodifiableListView) return _tracks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tracks);
}

@override final  String? selectedTrackId;
@override final  String? pendingTrackId;
 final  List<BiliSubtitleLine> _lines;
@override@JsonKey() List<BiliSubtitleLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override@JsonKey() final  int offsetMs;
@override@JsonKey() final  bool isDiscovering;
@override final  String? errorMessage;

/// Create a copy of PlayerSubtitleState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerSubtitleStateCopyWith<_PlayerSubtitleState> get copyWith => __$PlayerSubtitleStateCopyWithImpl<_PlayerSubtitleState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerSubtitleState&&(identical(other.stableId, stableId) || other.stableId == stableId)&&const DeepCollectionEquality().equals(other._tracks, _tracks)&&(identical(other.selectedTrackId, selectedTrackId) || other.selectedTrackId == selectedTrackId)&&(identical(other.pendingTrackId, pendingTrackId) || other.pendingTrackId == pendingTrackId)&&const DeepCollectionEquality().equals(other._lines, _lines)&&(identical(other.offsetMs, offsetMs) || other.offsetMs == offsetMs)&&(identical(other.isDiscovering, isDiscovering) || other.isDiscovering == isDiscovering)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,stableId,const DeepCollectionEquality().hash(_tracks),selectedTrackId,pendingTrackId,const DeepCollectionEquality().hash(_lines),offsetMs,isDiscovering,errorMessage);

@override
String toString() {
  return 'PlayerSubtitleState(stableId: $stableId, tracks: $tracks, selectedTrackId: $selectedTrackId, pendingTrackId: $pendingTrackId, lines: $lines, offsetMs: $offsetMs, isDiscovering: $isDiscovering, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$PlayerSubtitleStateCopyWith<$Res> implements $PlayerSubtitleStateCopyWith<$Res> {
  factory _$PlayerSubtitleStateCopyWith(_PlayerSubtitleState value, $Res Function(_PlayerSubtitleState) _then) = __$PlayerSubtitleStateCopyWithImpl;
@override @useResult
$Res call({
 String? stableId, List<BiliSubtitleTrack> tracks, String? selectedTrackId, String? pendingTrackId, List<BiliSubtitleLine> lines, int offsetMs, bool isDiscovering, String? errorMessage
});




}
/// @nodoc
class __$PlayerSubtitleStateCopyWithImpl<$Res>
    implements _$PlayerSubtitleStateCopyWith<$Res> {
  __$PlayerSubtitleStateCopyWithImpl(this._self, this._then);

  final _PlayerSubtitleState _self;
  final $Res Function(_PlayerSubtitleState) _then;

/// Create a copy of PlayerSubtitleState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stableId = freezed,Object? tracks = null,Object? selectedTrackId = freezed,Object? pendingTrackId = freezed,Object? lines = null,Object? offsetMs = null,Object? isDiscovering = null,Object? errorMessage = freezed,}) {
  return _then(_PlayerSubtitleState(
stableId: freezed == stableId ? _self.stableId : stableId // ignore: cast_nullable_to_non_nullable
as String?,tracks: null == tracks ? _self._tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<BiliSubtitleTrack>,selectedTrackId: freezed == selectedTrackId ? _self.selectedTrackId : selectedTrackId // ignore: cast_nullable_to_non_nullable
as String?,pendingTrackId: freezed == pendingTrackId ? _self.pendingTrackId : pendingTrackId // ignore: cast_nullable_to_non_nullable
as String?,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<BiliSubtitleLine>,offsetMs: null == offsetMs ? _self.offsetMs : offsetMs // ignore: cast_nullable_to_non_nullable
as int,isDiscovering: null == isDiscovering ? _self.isDiscovering : isDiscovering // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
