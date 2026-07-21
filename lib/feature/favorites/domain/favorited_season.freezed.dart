// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorited_season.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FavoritedSeason {

 int get seasonId; int get mid; String get title; String get coverUrl; String? get description; int get total; int get favoritedAtEpochMs; int get updatedAtEpochMs; int get lastSyncedAtEpochMs;
/// Create a copy of FavoritedSeason
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoritedSeasonCopyWith<FavoritedSeason> get copyWith => _$FavoritedSeasonCopyWithImpl<FavoritedSeason>(this as FavoritedSeason, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoritedSeason&&(identical(other.seasonId, seasonId) || other.seasonId == seasonId)&&(identical(other.mid, mid) || other.mid == mid)&&(identical(other.title, title) || other.title == title)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.total, total) || other.total == total)&&(identical(other.favoritedAtEpochMs, favoritedAtEpochMs) || other.favoritedAtEpochMs == favoritedAtEpochMs)&&(identical(other.updatedAtEpochMs, updatedAtEpochMs) || other.updatedAtEpochMs == updatedAtEpochMs)&&(identical(other.lastSyncedAtEpochMs, lastSyncedAtEpochMs) || other.lastSyncedAtEpochMs == lastSyncedAtEpochMs));
}


@override
int get hashCode => Object.hash(runtimeType,seasonId,mid,title,coverUrl,description,total,favoritedAtEpochMs,updatedAtEpochMs,lastSyncedAtEpochMs);

@override
String toString() {
  return 'FavoritedSeason(seasonId: $seasonId, mid: $mid, title: $title, coverUrl: $coverUrl, description: $description, total: $total, favoritedAtEpochMs: $favoritedAtEpochMs, updatedAtEpochMs: $updatedAtEpochMs, lastSyncedAtEpochMs: $lastSyncedAtEpochMs)';
}


}

/// @nodoc
abstract mixin class $FavoritedSeasonCopyWith<$Res>  {
  factory $FavoritedSeasonCopyWith(FavoritedSeason value, $Res Function(FavoritedSeason) _then) = _$FavoritedSeasonCopyWithImpl;
@useResult
$Res call({
 int seasonId, int mid, String title, String coverUrl, String? description, int total, int favoritedAtEpochMs, int updatedAtEpochMs, int lastSyncedAtEpochMs
});




}
/// @nodoc
class _$FavoritedSeasonCopyWithImpl<$Res>
    implements $FavoritedSeasonCopyWith<$Res> {
  _$FavoritedSeasonCopyWithImpl(this._self, this._then);

  final FavoritedSeason _self;
  final $Res Function(FavoritedSeason) _then;

/// Create a copy of FavoritedSeason
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? seasonId = null,Object? mid = null,Object? title = null,Object? coverUrl = null,Object? description = freezed,Object? total = null,Object? favoritedAtEpochMs = null,Object? updatedAtEpochMs = null,Object? lastSyncedAtEpochMs = null,}) {
  return _then(_self.copyWith(
seasonId: null == seasonId ? _self.seasonId : seasonId // ignore: cast_nullable_to_non_nullable
as int,mid: null == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,favoritedAtEpochMs: null == favoritedAtEpochMs ? _self.favoritedAtEpochMs : favoritedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int,updatedAtEpochMs: null == updatedAtEpochMs ? _self.updatedAtEpochMs : updatedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int,lastSyncedAtEpochMs: null == lastSyncedAtEpochMs ? _self.lastSyncedAtEpochMs : lastSyncedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FavoritedSeason].
extension FavoritedSeasonPatterns on FavoritedSeason {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavoritedSeason value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavoritedSeason() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavoritedSeason value)  $default,){
final _that = this;
switch (_that) {
case _FavoritedSeason():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavoritedSeason value)?  $default,){
final _that = this;
switch (_that) {
case _FavoritedSeason() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int seasonId,  int mid,  String title,  String coverUrl,  String? description,  int total,  int favoritedAtEpochMs,  int updatedAtEpochMs,  int lastSyncedAtEpochMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavoritedSeason() when $default != null:
return $default(_that.seasonId,_that.mid,_that.title,_that.coverUrl,_that.description,_that.total,_that.favoritedAtEpochMs,_that.updatedAtEpochMs,_that.lastSyncedAtEpochMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int seasonId,  int mid,  String title,  String coverUrl,  String? description,  int total,  int favoritedAtEpochMs,  int updatedAtEpochMs,  int lastSyncedAtEpochMs)  $default,) {final _that = this;
switch (_that) {
case _FavoritedSeason():
return $default(_that.seasonId,_that.mid,_that.title,_that.coverUrl,_that.description,_that.total,_that.favoritedAtEpochMs,_that.updatedAtEpochMs,_that.lastSyncedAtEpochMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int seasonId,  int mid,  String title,  String coverUrl,  String? description,  int total,  int favoritedAtEpochMs,  int updatedAtEpochMs,  int lastSyncedAtEpochMs)?  $default,) {final _that = this;
switch (_that) {
case _FavoritedSeason() when $default != null:
return $default(_that.seasonId,_that.mid,_that.title,_that.coverUrl,_that.description,_that.total,_that.favoritedAtEpochMs,_that.updatedAtEpochMs,_that.lastSyncedAtEpochMs);case _:
  return null;

}
}

}

/// @nodoc


class _FavoritedSeason implements FavoritedSeason {
  const _FavoritedSeason({required this.seasonId, required this.mid, required this.title, required this.coverUrl, this.description, required this.total, required this.favoritedAtEpochMs, required this.updatedAtEpochMs, required this.lastSyncedAtEpochMs});
  

@override final  int seasonId;
@override final  int mid;
@override final  String title;
@override final  String coverUrl;
@override final  String? description;
@override final  int total;
@override final  int favoritedAtEpochMs;
@override final  int updatedAtEpochMs;
@override final  int lastSyncedAtEpochMs;

/// Create a copy of FavoritedSeason
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoritedSeasonCopyWith<_FavoritedSeason> get copyWith => __$FavoritedSeasonCopyWithImpl<_FavoritedSeason>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavoritedSeason&&(identical(other.seasonId, seasonId) || other.seasonId == seasonId)&&(identical(other.mid, mid) || other.mid == mid)&&(identical(other.title, title) || other.title == title)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.total, total) || other.total == total)&&(identical(other.favoritedAtEpochMs, favoritedAtEpochMs) || other.favoritedAtEpochMs == favoritedAtEpochMs)&&(identical(other.updatedAtEpochMs, updatedAtEpochMs) || other.updatedAtEpochMs == updatedAtEpochMs)&&(identical(other.lastSyncedAtEpochMs, lastSyncedAtEpochMs) || other.lastSyncedAtEpochMs == lastSyncedAtEpochMs));
}


@override
int get hashCode => Object.hash(runtimeType,seasonId,mid,title,coverUrl,description,total,favoritedAtEpochMs,updatedAtEpochMs,lastSyncedAtEpochMs);

@override
String toString() {
  return 'FavoritedSeason(seasonId: $seasonId, mid: $mid, title: $title, coverUrl: $coverUrl, description: $description, total: $total, favoritedAtEpochMs: $favoritedAtEpochMs, updatedAtEpochMs: $updatedAtEpochMs, lastSyncedAtEpochMs: $lastSyncedAtEpochMs)';
}


}

/// @nodoc
abstract mixin class _$FavoritedSeasonCopyWith<$Res> implements $FavoritedSeasonCopyWith<$Res> {
  factory _$FavoritedSeasonCopyWith(_FavoritedSeason value, $Res Function(_FavoritedSeason) _then) = __$FavoritedSeasonCopyWithImpl;
@override @useResult
$Res call({
 int seasonId, int mid, String title, String coverUrl, String? description, int total, int favoritedAtEpochMs, int updatedAtEpochMs, int lastSyncedAtEpochMs
});




}
/// @nodoc
class __$FavoritedSeasonCopyWithImpl<$Res>
    implements _$FavoritedSeasonCopyWith<$Res> {
  __$FavoritedSeasonCopyWithImpl(this._self, this._then);

  final _FavoritedSeason _self;
  final $Res Function(_FavoritedSeason) _then;

/// Create a copy of FavoritedSeason
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? seasonId = null,Object? mid = null,Object? title = null,Object? coverUrl = null,Object? description = freezed,Object? total = null,Object? favoritedAtEpochMs = null,Object? updatedAtEpochMs = null,Object? lastSyncedAtEpochMs = null,}) {
  return _then(_FavoritedSeason(
seasonId: null == seasonId ? _self.seasonId : seasonId // ignore: cast_nullable_to_non_nullable
as int,mid: null == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,favoritedAtEpochMs: null == favoritedAtEpochMs ? _self.favoritedAtEpochMs : favoritedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int,updatedAtEpochMs: null == updatedAtEpochMs ? _self.updatedAtEpochMs : updatedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int,lastSyncedAtEpochMs: null == lastSyncedAtEpochMs ? _self.lastSyncedAtEpochMs : lastSyncedAtEpochMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
