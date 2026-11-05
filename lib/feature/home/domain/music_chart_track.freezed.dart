// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'music_chart_track.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MusicChartTrack {

 MusicChartPlatform get platform; int get rank; String get title; String get artist; String get coverUrl; int get durationSeconds;
/// Create a copy of MusicChartTrack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MusicChartTrackCopyWith<MusicChartTrack> get copyWith => _$MusicChartTrackCopyWithImpl<MusicChartTrack>(this as MusicChartTrack, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MusicChartTrack&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,platform,rank,title,artist,coverUrl,durationSeconds);

@override
String toString() {
  return 'MusicChartTrack(platform: $platform, rank: $rank, title: $title, artist: $artist, coverUrl: $coverUrl, durationSeconds: $durationSeconds)';
}


}

/// @nodoc
abstract mixin class $MusicChartTrackCopyWith<$Res>  {
  factory $MusicChartTrackCopyWith(MusicChartTrack value, $Res Function(MusicChartTrack) _then) = _$MusicChartTrackCopyWithImpl;
@useResult
$Res call({
 MusicChartPlatform platform, int rank, String title, String artist, String coverUrl, int durationSeconds
});




}
/// @nodoc
class _$MusicChartTrackCopyWithImpl<$Res>
    implements $MusicChartTrackCopyWith<$Res> {
  _$MusicChartTrackCopyWithImpl(this._self, this._then);

  final MusicChartTrack _self;
  final $Res Function(MusicChartTrack) _then;

/// Create a copy of MusicChartTrack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? platform = null,Object? rank = null,Object? title = null,Object? artist = null,Object? coverUrl = null,Object? durationSeconds = null,}) {
  return _then(_self.copyWith(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as MusicChartPlatform,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MusicChartTrack].
extension MusicChartTrackPatterns on MusicChartTrack {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MusicChartTrack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MusicChartTrack() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MusicChartTrack value)  $default,){
final _that = this;
switch (_that) {
case _MusicChartTrack():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MusicChartTrack value)?  $default,){
final _that = this;
switch (_that) {
case _MusicChartTrack() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MusicChartPlatform platform,  int rank,  String title,  String artist,  String coverUrl,  int durationSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MusicChartTrack() when $default != null:
return $default(_that.platform,_that.rank,_that.title,_that.artist,_that.coverUrl,_that.durationSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MusicChartPlatform platform,  int rank,  String title,  String artist,  String coverUrl,  int durationSeconds)  $default,) {final _that = this;
switch (_that) {
case _MusicChartTrack():
return $default(_that.platform,_that.rank,_that.title,_that.artist,_that.coverUrl,_that.durationSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MusicChartPlatform platform,  int rank,  String title,  String artist,  String coverUrl,  int durationSeconds)?  $default,) {final _that = this;
switch (_that) {
case _MusicChartTrack() when $default != null:
return $default(_that.platform,_that.rank,_that.title,_that.artist,_that.coverUrl,_that.durationSeconds);case _:
  return null;

}
}

}

/// @nodoc


class _MusicChartTrack extends MusicChartTrack {
  const _MusicChartTrack({required this.platform, required this.rank, required this.title, required this.artist, required this.coverUrl, this.durationSeconds = 0}): super._();
  

@override final  MusicChartPlatform platform;
@override final  int rank;
@override final  String title;
@override final  String artist;
@override final  String coverUrl;
@override@JsonKey() final  int durationSeconds;

/// Create a copy of MusicChartTrack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MusicChartTrackCopyWith<_MusicChartTrack> get copyWith => __$MusicChartTrackCopyWithImpl<_MusicChartTrack>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MusicChartTrack&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,platform,rank,title,artist,coverUrl,durationSeconds);

@override
String toString() {
  return 'MusicChartTrack(platform: $platform, rank: $rank, title: $title, artist: $artist, coverUrl: $coverUrl, durationSeconds: $durationSeconds)';
}


}

/// @nodoc
abstract mixin class _$MusicChartTrackCopyWith<$Res> implements $MusicChartTrackCopyWith<$Res> {
  factory _$MusicChartTrackCopyWith(_MusicChartTrack value, $Res Function(_MusicChartTrack) _then) = __$MusicChartTrackCopyWithImpl;
@override @useResult
$Res call({
 MusicChartPlatform platform, int rank, String title, String artist, String coverUrl, int durationSeconds
});




}
/// @nodoc
class __$MusicChartTrackCopyWithImpl<$Res>
    implements _$MusicChartTrackCopyWith<$Res> {
  __$MusicChartTrackCopyWithImpl(this._self, this._then);

  final _MusicChartTrack _self;
  final $Res Function(_MusicChartTrack) _then;

/// Create a copy of MusicChartTrack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platform = null,Object? rank = null,Object? title = null,Object? artist = null,Object? coverUrl = null,Object? durationSeconds = null,}) {
  return _then(_MusicChartTrack(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as MusicChartPlatform,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
