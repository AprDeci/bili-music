// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment_target.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CommentTarget {

 int get oid; int get type; int? get aid; String? get bvid; String? get title; String? get coverUrl;
/// Create a copy of CommentTarget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentTargetCopyWith<CommentTarget> get copyWith => _$CommentTargetCopyWithImpl<CommentTarget>(this as CommentTarget, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentTarget&&(identical(other.oid, oid) || other.oid == oid)&&(identical(other.type, type) || other.type == type)&&(identical(other.aid, aid) || other.aid == aid)&&(identical(other.bvid, bvid) || other.bvid == bvid)&&(identical(other.title, title) || other.title == title)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl));
}


@override
int get hashCode => Object.hash(runtimeType,oid,type,aid,bvid,title,coverUrl);

@override
String toString() {
  return 'CommentTarget(oid: $oid, type: $type, aid: $aid, bvid: $bvid, title: $title, coverUrl: $coverUrl)';
}


}

/// @nodoc
abstract mixin class $CommentTargetCopyWith<$Res>  {
  factory $CommentTargetCopyWith(CommentTarget value, $Res Function(CommentTarget) _then) = _$CommentTargetCopyWithImpl;
@useResult
$Res call({
 int oid, int type, int? aid, String? bvid, String? title, String? coverUrl
});




}
/// @nodoc
class _$CommentTargetCopyWithImpl<$Res>
    implements $CommentTargetCopyWith<$Res> {
  _$CommentTargetCopyWithImpl(this._self, this._then);

  final CommentTarget _self;
  final $Res Function(CommentTarget) _then;

/// Create a copy of CommentTarget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? oid = null,Object? type = null,Object? aid = freezed,Object? bvid = freezed,Object? title = freezed,Object? coverUrl = freezed,}) {
  return _then(_self.copyWith(
oid: null == oid ? _self.oid : oid // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,aid: freezed == aid ? _self.aid : aid // ignore: cast_nullable_to_non_nullable
as int?,bvid: freezed == bvid ? _self.bvid : bvid // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CommentTarget].
extension CommentTargetPatterns on CommentTarget {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommentTarget value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentTarget() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommentTarget value)  $default,){
final _that = this;
switch (_that) {
case _CommentTarget():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommentTarget value)?  $default,){
final _that = this;
switch (_that) {
case _CommentTarget() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int oid,  int type,  int? aid,  String? bvid,  String? title,  String? coverUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentTarget() when $default != null:
return $default(_that.oid,_that.type,_that.aid,_that.bvid,_that.title,_that.coverUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int oid,  int type,  int? aid,  String? bvid,  String? title,  String? coverUrl)  $default,) {final _that = this;
switch (_that) {
case _CommentTarget():
return $default(_that.oid,_that.type,_that.aid,_that.bvid,_that.title,_that.coverUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int oid,  int type,  int? aid,  String? bvid,  String? title,  String? coverUrl)?  $default,) {final _that = this;
switch (_that) {
case _CommentTarget() when $default != null:
return $default(_that.oid,_that.type,_that.aid,_that.bvid,_that.title,_that.coverUrl);case _:
  return null;

}
}

}

/// @nodoc


class _CommentTarget extends CommentTarget {
  const _CommentTarget({required this.oid, required this.type, this.aid, this.bvid, this.title, this.coverUrl}): super._();
  

@override final  int oid;
@override final  int type;
@override final  int? aid;
@override final  String? bvid;
@override final  String? title;
@override final  String? coverUrl;

/// Create a copy of CommentTarget
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentTargetCopyWith<_CommentTarget> get copyWith => __$CommentTargetCopyWithImpl<_CommentTarget>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentTarget&&(identical(other.oid, oid) || other.oid == oid)&&(identical(other.type, type) || other.type == type)&&(identical(other.aid, aid) || other.aid == aid)&&(identical(other.bvid, bvid) || other.bvid == bvid)&&(identical(other.title, title) || other.title == title)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl));
}


@override
int get hashCode => Object.hash(runtimeType,oid,type,aid,bvid,title,coverUrl);

@override
String toString() {
  return 'CommentTarget(oid: $oid, type: $type, aid: $aid, bvid: $bvid, title: $title, coverUrl: $coverUrl)';
}


}

/// @nodoc
abstract mixin class _$CommentTargetCopyWith<$Res> implements $CommentTargetCopyWith<$Res> {
  factory _$CommentTargetCopyWith(_CommentTarget value, $Res Function(_CommentTarget) _then) = __$CommentTargetCopyWithImpl;
@override @useResult
$Res call({
 int oid, int type, int? aid, String? bvid, String? title, String? coverUrl
});




}
/// @nodoc
class __$CommentTargetCopyWithImpl<$Res>
    implements _$CommentTargetCopyWith<$Res> {
  __$CommentTargetCopyWithImpl(this._self, this._then);

  final _CommentTarget _self;
  final $Res Function(_CommentTarget) _then;

/// Create a copy of CommentTarget
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? oid = null,Object? type = null,Object? aid = freezed,Object? bvid = freezed,Object? title = freezed,Object? coverUrl = freezed,}) {
  return _then(_CommentTarget(
oid: null == oid ? _self.oid : oid // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,aid: freezed == aid ? _self.aid : aid // ignore: cast_nullable_to_non_nullable
as int?,bvid: freezed == bvid ? _self.bvid : bvid // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
