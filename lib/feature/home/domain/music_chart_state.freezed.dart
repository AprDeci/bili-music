// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'music_chart_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MusicChartState {

 MusicChartPlatform get platform; List<MusicChartTrack> get tracks; bool get isLoading; String? get errorMessage;
/// Create a copy of MusicChartState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MusicChartStateCopyWith<MusicChartState> get copyWith => _$MusicChartStateCopyWithImpl<MusicChartState>(this as MusicChartState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MusicChartState&&(identical(other.platform, platform) || other.platform == platform)&&const DeepCollectionEquality().equals(other.tracks, tracks)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,platform,const DeepCollectionEquality().hash(tracks),isLoading,errorMessage);

@override
String toString() {
  return 'MusicChartState(platform: $platform, tracks: $tracks, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $MusicChartStateCopyWith<$Res>  {
  factory $MusicChartStateCopyWith(MusicChartState value, $Res Function(MusicChartState) _then) = _$MusicChartStateCopyWithImpl;
@useResult
$Res call({
 MusicChartPlatform platform, List<MusicChartTrack> tracks, bool isLoading, String? errorMessage
});




}
/// @nodoc
class _$MusicChartStateCopyWithImpl<$Res>
    implements $MusicChartStateCopyWith<$Res> {
  _$MusicChartStateCopyWithImpl(this._self, this._then);

  final MusicChartState _self;
  final $Res Function(MusicChartState) _then;

/// Create a copy of MusicChartState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? platform = null,Object? tracks = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as MusicChartPlatform,tracks: null == tracks ? _self.tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<MusicChartTrack>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MusicChartState].
extension MusicChartStatePatterns on MusicChartState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MusicChartState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MusicChartState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MusicChartState value)  $default,){
final _that = this;
switch (_that) {
case _MusicChartState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MusicChartState value)?  $default,){
final _that = this;
switch (_that) {
case _MusicChartState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MusicChartPlatform platform,  List<MusicChartTrack> tracks,  bool isLoading,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MusicChartState() when $default != null:
return $default(_that.platform,_that.tracks,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MusicChartPlatform platform,  List<MusicChartTrack> tracks,  bool isLoading,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _MusicChartState():
return $default(_that.platform,_that.tracks,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MusicChartPlatform platform,  List<MusicChartTrack> tracks,  bool isLoading,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _MusicChartState() when $default != null:
return $default(_that.platform,_that.tracks,_that.isLoading,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _MusicChartState extends MusicChartState {
  const _MusicChartState({this.platform = MusicChartPlatform.netease, final  List<MusicChartTrack> tracks = const <MusicChartTrack>[], this.isLoading = false, this.errorMessage}): _tracks = tracks,super._();
  

@override@JsonKey() final  MusicChartPlatform platform;
 final  List<MusicChartTrack> _tracks;
@override@JsonKey() List<MusicChartTrack> get tracks {
  if (_tracks is EqualUnmodifiableListView) return _tracks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tracks);
}

@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;

/// Create a copy of MusicChartState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MusicChartStateCopyWith<_MusicChartState> get copyWith => __$MusicChartStateCopyWithImpl<_MusicChartState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MusicChartState&&(identical(other.platform, platform) || other.platform == platform)&&const DeepCollectionEquality().equals(other._tracks, _tracks)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,platform,const DeepCollectionEquality().hash(_tracks),isLoading,errorMessage);

@override
String toString() {
  return 'MusicChartState(platform: $platform, tracks: $tracks, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$MusicChartStateCopyWith<$Res> implements $MusicChartStateCopyWith<$Res> {
  factory _$MusicChartStateCopyWith(_MusicChartState value, $Res Function(_MusicChartState) _then) = __$MusicChartStateCopyWithImpl;
@override @useResult
$Res call({
 MusicChartPlatform platform, List<MusicChartTrack> tracks, bool isLoading, String? errorMessage
});




}
/// @nodoc
class __$MusicChartStateCopyWithImpl<$Res>
    implements _$MusicChartStateCopyWith<$Res> {
  __$MusicChartStateCopyWithImpl(this._self, this._then);

  final _MusicChartState _self;
  final $Res Function(_MusicChartState) _then;

/// Create a copy of MusicChartState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platform = null,Object? tracks = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_MusicChartState(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as MusicChartPlatform,tracks: null == tracks ? _self._tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<MusicChartTrack>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
