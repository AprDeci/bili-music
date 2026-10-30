// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listening_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ListeningProgress {

 String get accountId; int get aid; String get bvid; int get cid; int get page; int get positionMs; int get durationMs; int get updatedAtMs; bool get completed; bool get pendingSync; String? get collectionId;
/// Create a copy of ListeningProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListeningProgressCopyWith<ListeningProgress> get copyWith => _$ListeningProgressCopyWithImpl<ListeningProgress>(this as ListeningProgress, _$identity);

  /// Serializes this ListeningProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListeningProgress&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.aid, aid) || other.aid == aid)&&(identical(other.bvid, bvid) || other.bvid == bvid)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.page, page) || other.page == page)&&(identical(other.positionMs, positionMs) || other.positionMs == positionMs)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.pendingSync, pendingSync) || other.pendingSync == pendingSync)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountId,aid,bvid,cid,page,positionMs,durationMs,updatedAtMs,completed,pendingSync,collectionId);

@override
String toString() {
  return 'ListeningProgress(accountId: $accountId, aid: $aid, bvid: $bvid, cid: $cid, page: $page, positionMs: $positionMs, durationMs: $durationMs, updatedAtMs: $updatedAtMs, completed: $completed, pendingSync: $pendingSync, collectionId: $collectionId)';
}


}

/// @nodoc
abstract mixin class $ListeningProgressCopyWith<$Res>  {
  factory $ListeningProgressCopyWith(ListeningProgress value, $Res Function(ListeningProgress) _then) = _$ListeningProgressCopyWithImpl;
@useResult
$Res call({
 String accountId, int aid, String bvid, int cid, int page, int positionMs, int durationMs, int updatedAtMs, bool completed, bool pendingSync, String? collectionId
});




}
/// @nodoc
class _$ListeningProgressCopyWithImpl<$Res>
    implements $ListeningProgressCopyWith<$Res> {
  _$ListeningProgressCopyWithImpl(this._self, this._then);

  final ListeningProgress _self;
  final $Res Function(ListeningProgress) _then;

/// Create a copy of ListeningProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accountId = null,Object? aid = null,Object? bvid = null,Object? cid = null,Object? page = null,Object? positionMs = null,Object? durationMs = null,Object? updatedAtMs = null,Object? completed = null,Object? pendingSync = null,Object? collectionId = freezed,}) {
  return _then(_self.copyWith(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,aid: null == aid ? _self.aid : aid // ignore: cast_nullable_to_non_nullable
as int,bvid: null == bvid ? _self.bvid : bvid // ignore: cast_nullable_to_non_nullable
as String,cid: null == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,positionMs: null == positionMs ? _self.positionMs : positionMs // ignore: cast_nullable_to_non_nullable
as int,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,pendingSync: null == pendingSync ? _self.pendingSync : pendingSync // ignore: cast_nullable_to_non_nullable
as bool,collectionId: freezed == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ListeningProgress].
extension ListeningProgressPatterns on ListeningProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListeningProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListeningProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListeningProgress value)  $default,){
final _that = this;
switch (_that) {
case _ListeningProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListeningProgress value)?  $default,){
final _that = this;
switch (_that) {
case _ListeningProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accountId,  int aid,  String bvid,  int cid,  int page,  int positionMs,  int durationMs,  int updatedAtMs,  bool completed,  bool pendingSync,  String? collectionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListeningProgress() when $default != null:
return $default(_that.accountId,_that.aid,_that.bvid,_that.cid,_that.page,_that.positionMs,_that.durationMs,_that.updatedAtMs,_that.completed,_that.pendingSync,_that.collectionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accountId,  int aid,  String bvid,  int cid,  int page,  int positionMs,  int durationMs,  int updatedAtMs,  bool completed,  bool pendingSync,  String? collectionId)  $default,) {final _that = this;
switch (_that) {
case _ListeningProgress():
return $default(_that.accountId,_that.aid,_that.bvid,_that.cid,_that.page,_that.positionMs,_that.durationMs,_that.updatedAtMs,_that.completed,_that.pendingSync,_that.collectionId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accountId,  int aid,  String bvid,  int cid,  int page,  int positionMs,  int durationMs,  int updatedAtMs,  bool completed,  bool pendingSync,  String? collectionId)?  $default,) {final _that = this;
switch (_that) {
case _ListeningProgress() when $default != null:
return $default(_that.accountId,_that.aid,_that.bvid,_that.cid,_that.page,_that.positionMs,_that.durationMs,_that.updatedAtMs,_that.completed,_that.pendingSync,_that.collectionId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListeningProgress extends ListeningProgress {
  const _ListeningProgress({required this.accountId, required this.aid, required this.bvid, required this.cid, this.page = 1, this.positionMs = 0, this.durationMs = 0, this.updatedAtMs = 0, this.completed = false, this.pendingSync = false, this.collectionId}): super._();
  factory _ListeningProgress.fromJson(Map<String, dynamic> json) => _$ListeningProgressFromJson(json);

@override final  String accountId;
@override final  int aid;
@override final  String bvid;
@override final  int cid;
@override@JsonKey() final  int page;
@override@JsonKey() final  int positionMs;
@override@JsonKey() final  int durationMs;
@override@JsonKey() final  int updatedAtMs;
@override@JsonKey() final  bool completed;
@override@JsonKey() final  bool pendingSync;
@override final  String? collectionId;

/// Create a copy of ListeningProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListeningProgressCopyWith<_ListeningProgress> get copyWith => __$ListeningProgressCopyWithImpl<_ListeningProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListeningProgressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListeningProgress&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.aid, aid) || other.aid == aid)&&(identical(other.bvid, bvid) || other.bvid == bvid)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.page, page) || other.page == page)&&(identical(other.positionMs, positionMs) || other.positionMs == positionMs)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.updatedAtMs, updatedAtMs) || other.updatedAtMs == updatedAtMs)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.pendingSync, pendingSync) || other.pendingSync == pendingSync)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountId,aid,bvid,cid,page,positionMs,durationMs,updatedAtMs,completed,pendingSync,collectionId);

@override
String toString() {
  return 'ListeningProgress(accountId: $accountId, aid: $aid, bvid: $bvid, cid: $cid, page: $page, positionMs: $positionMs, durationMs: $durationMs, updatedAtMs: $updatedAtMs, completed: $completed, pendingSync: $pendingSync, collectionId: $collectionId)';
}


}

/// @nodoc
abstract mixin class _$ListeningProgressCopyWith<$Res> implements $ListeningProgressCopyWith<$Res> {
  factory _$ListeningProgressCopyWith(_ListeningProgress value, $Res Function(_ListeningProgress) _then) = __$ListeningProgressCopyWithImpl;
@override @useResult
$Res call({
 String accountId, int aid, String bvid, int cid, int page, int positionMs, int durationMs, int updatedAtMs, bool completed, bool pendingSync, String? collectionId
});




}
/// @nodoc
class __$ListeningProgressCopyWithImpl<$Res>
    implements _$ListeningProgressCopyWith<$Res> {
  __$ListeningProgressCopyWithImpl(this._self, this._then);

  final _ListeningProgress _self;
  final $Res Function(_ListeningProgress) _then;

/// Create a copy of ListeningProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accountId = null,Object? aid = null,Object? bvid = null,Object? cid = null,Object? page = null,Object? positionMs = null,Object? durationMs = null,Object? updatedAtMs = null,Object? completed = null,Object? pendingSync = null,Object? collectionId = freezed,}) {
  return _then(_ListeningProgress(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,aid: null == aid ? _self.aid : aid // ignore: cast_nullable_to_non_nullable
as int,bvid: null == bvid ? _self.bvid : bvid // ignore: cast_nullable_to_non_nullable
as String,cid: null == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,positionMs: null == positionMs ? _self.positionMs : positionMs // ignore: cast_nullable_to_non_nullable
as int,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,updatedAtMs: null == updatedAtMs ? _self.updatedAtMs : updatedAtMs // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,pendingSync: null == pendingSync ? _self.pendingSync : pendingSync // ignore: cast_nullable_to_non_nullable
as bool,collectionId: freezed == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
