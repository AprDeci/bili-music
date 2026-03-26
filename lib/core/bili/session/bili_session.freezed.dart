// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bili_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BiliSession {

 String get sessData; String get biliJct; String get dedeUserId; String get refreshToken; String get cookie; int? get mid; String? get uname; String? get face; String? get imgKey; String? get subKey; String? get buvid3;
/// Create a copy of BiliSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BiliSessionCopyWith<BiliSession> get copyWith => _$BiliSessionCopyWithImpl<BiliSession>(this as BiliSession, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BiliSession&&(identical(other.sessData, sessData) || other.sessData == sessData)&&(identical(other.biliJct, biliJct) || other.biliJct == biliJct)&&(identical(other.dedeUserId, dedeUserId) || other.dedeUserId == dedeUserId)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.cookie, cookie) || other.cookie == cookie)&&(identical(other.mid, mid) || other.mid == mid)&&(identical(other.uname, uname) || other.uname == uname)&&(identical(other.face, face) || other.face == face)&&(identical(other.imgKey, imgKey) || other.imgKey == imgKey)&&(identical(other.subKey, subKey) || other.subKey == subKey)&&(identical(other.buvid3, buvid3) || other.buvid3 == buvid3));
}


@override
int get hashCode => Object.hash(runtimeType,sessData,biliJct,dedeUserId,refreshToken,cookie,mid,uname,face,imgKey,subKey,buvid3);

@override
String toString() {
  return 'BiliSession(sessData: $sessData, biliJct: $biliJct, dedeUserId: $dedeUserId, refreshToken: $refreshToken, cookie: $cookie, mid: $mid, uname: $uname, face: $face, imgKey: $imgKey, subKey: $subKey, buvid3: $buvid3)';
}


}

/// @nodoc
abstract mixin class $BiliSessionCopyWith<$Res>  {
  factory $BiliSessionCopyWith(BiliSession value, $Res Function(BiliSession) _then) = _$BiliSessionCopyWithImpl;
@useResult
$Res call({
 String sessData, String biliJct, String dedeUserId, String refreshToken, String cookie, int? mid, String? uname, String? face, String? imgKey, String? subKey, String? buvid3
});




}
/// @nodoc
class _$BiliSessionCopyWithImpl<$Res>
    implements $BiliSessionCopyWith<$Res> {
  _$BiliSessionCopyWithImpl(this._self, this._then);

  final BiliSession _self;
  final $Res Function(BiliSession) _then;

/// Create a copy of BiliSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessData = null,Object? biliJct = null,Object? dedeUserId = null,Object? refreshToken = null,Object? cookie = null,Object? mid = freezed,Object? uname = freezed,Object? face = freezed,Object? imgKey = freezed,Object? subKey = freezed,Object? buvid3 = freezed,}) {
  return _then(BiliSession(
sessData: null == sessData ? _self.sessData : sessData // ignore: cast_nullable_to_non_nullable
as String,biliJct: null == biliJct ? _self.biliJct : biliJct // ignore: cast_nullable_to_non_nullable
as String,dedeUserId: null == dedeUserId ? _self.dedeUserId : dedeUserId // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,cookie: null == cookie ? _self.cookie : cookie // ignore: cast_nullable_to_non_nullable
as String,mid: freezed == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as int?,uname: freezed == uname ? _self.uname : uname // ignore: cast_nullable_to_non_nullable
as String?,face: freezed == face ? _self.face : face // ignore: cast_nullable_to_non_nullable
as String?,imgKey: freezed == imgKey ? _self.imgKey : imgKey // ignore: cast_nullable_to_non_nullable
as String?,subKey: freezed == subKey ? _self.subKey : subKey // ignore: cast_nullable_to_non_nullable
as String?,buvid3: freezed == buvid3 ? _self.buvid3 : buvid3 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BiliSession].
extension BiliSessionPatterns on BiliSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({required TResult orElse(),}){
final _that = this;
switch (_that) {
case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(){
final _that = this;
switch (_that) {
case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(){
final _that = this;
switch (_that) {
case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({required TResult orElse(),}) {final _that = this;
switch (_that) {
case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>() {final _that = this;
switch (_that) {
case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>() {final _that = this;
switch (_that) {
case _:
  return null;

}
}

}

// dart format on
