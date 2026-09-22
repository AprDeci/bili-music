// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bili_sms_login_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BiliSmsLoginState {

 BiliSmsLoginStatus get status; String get tel; BiliCaptchaParams? get captcha; String? get captchaKey; int get countdownSeconds; String? get message;
/// Create a copy of BiliSmsLoginState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BiliSmsLoginStateCopyWith<BiliSmsLoginState> get copyWith => _$BiliSmsLoginStateCopyWithImpl<BiliSmsLoginState>(this as BiliSmsLoginState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BiliSmsLoginState&&(identical(other.status, status) || other.status == status)&&(identical(other.tel, tel) || other.tel == tel)&&(identical(other.captcha, captcha) || other.captcha == captcha)&&(identical(other.captchaKey, captchaKey) || other.captchaKey == captchaKey)&&(identical(other.countdownSeconds, countdownSeconds) || other.countdownSeconds == countdownSeconds)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,status,tel,captcha,captchaKey,countdownSeconds,message);

@override
String toString() {
  return 'BiliSmsLoginState(status: $status, tel: $tel, captcha: $captcha, captchaKey: $captchaKey, countdownSeconds: $countdownSeconds, message: $message)';
}


}

/// @nodoc
abstract mixin class $BiliSmsLoginStateCopyWith<$Res>  {
  factory $BiliSmsLoginStateCopyWith(BiliSmsLoginState value, $Res Function(BiliSmsLoginState) _then) = _$BiliSmsLoginStateCopyWithImpl;
@useResult
$Res call({
 BiliSmsLoginStatus status, String tel, BiliCaptchaParams? captcha, String? captchaKey, int countdownSeconds, String? message
});


$BiliCaptchaParamsCopyWith<$Res>? get captcha;

}
/// @nodoc
class _$BiliSmsLoginStateCopyWithImpl<$Res>
    implements $BiliSmsLoginStateCopyWith<$Res> {
  _$BiliSmsLoginStateCopyWithImpl(this._self, this._then);

  final BiliSmsLoginState _self;
  final $Res Function(BiliSmsLoginState) _then;

/// Create a copy of BiliSmsLoginState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? tel = null,Object? captcha = freezed,Object? captchaKey = freezed,Object? countdownSeconds = null,Object? message = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BiliSmsLoginStatus,tel: null == tel ? _self.tel : tel // ignore: cast_nullable_to_non_nullable
as String,captcha: freezed == captcha ? _self.captcha : captcha // ignore: cast_nullable_to_non_nullable
as BiliCaptchaParams?,captchaKey: freezed == captchaKey ? _self.captchaKey : captchaKey // ignore: cast_nullable_to_non_nullable
as String?,countdownSeconds: null == countdownSeconds ? _self.countdownSeconds : countdownSeconds // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of BiliSmsLoginState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BiliCaptchaParamsCopyWith<$Res>? get captcha {
    if (_self.captcha == null) {
    return null;
  }

  return $BiliCaptchaParamsCopyWith<$Res>(_self.captcha!, (value) {
    return _then(_self.copyWith(captcha: value));
  });
}
}


/// Adds pattern-matching-related methods to [BiliSmsLoginState].
extension BiliSmsLoginStatePatterns on BiliSmsLoginState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BiliSmsLoginState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BiliSmsLoginState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BiliSmsLoginState value)  $default,){
final _that = this;
switch (_that) {
case _BiliSmsLoginState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BiliSmsLoginState value)?  $default,){
final _that = this;
switch (_that) {
case _BiliSmsLoginState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BiliSmsLoginStatus status,  String tel,  BiliCaptchaParams? captcha,  String? captchaKey,  int countdownSeconds,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BiliSmsLoginState() when $default != null:
return $default(_that.status,_that.tel,_that.captcha,_that.captchaKey,_that.countdownSeconds,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BiliSmsLoginStatus status,  String tel,  BiliCaptchaParams? captcha,  String? captchaKey,  int countdownSeconds,  String? message)  $default,) {final _that = this;
switch (_that) {
case _BiliSmsLoginState():
return $default(_that.status,_that.tel,_that.captcha,_that.captchaKey,_that.countdownSeconds,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BiliSmsLoginStatus status,  String tel,  BiliCaptchaParams? captcha,  String? captchaKey,  int countdownSeconds,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _BiliSmsLoginState() when $default != null:
return $default(_that.status,_that.tel,_that.captcha,_that.captchaKey,_that.countdownSeconds,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _BiliSmsLoginState extends BiliSmsLoginState {
  const _BiliSmsLoginState({this.status = BiliSmsLoginStatus.idle, this.tel = '', this.captcha, this.captchaKey, this.countdownSeconds = 0, this.message}): super._();
  

@override@JsonKey() final  BiliSmsLoginStatus status;
@override@JsonKey() final  String tel;
@override final  BiliCaptchaParams? captcha;
@override final  String? captchaKey;
@override@JsonKey() final  int countdownSeconds;
@override final  String? message;

/// Create a copy of BiliSmsLoginState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BiliSmsLoginStateCopyWith<_BiliSmsLoginState> get copyWith => __$BiliSmsLoginStateCopyWithImpl<_BiliSmsLoginState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BiliSmsLoginState&&(identical(other.status, status) || other.status == status)&&(identical(other.tel, tel) || other.tel == tel)&&(identical(other.captcha, captcha) || other.captcha == captcha)&&(identical(other.captchaKey, captchaKey) || other.captchaKey == captchaKey)&&(identical(other.countdownSeconds, countdownSeconds) || other.countdownSeconds == countdownSeconds)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,status,tel,captcha,captchaKey,countdownSeconds,message);

@override
String toString() {
  return 'BiliSmsLoginState(status: $status, tel: $tel, captcha: $captcha, captchaKey: $captchaKey, countdownSeconds: $countdownSeconds, message: $message)';
}


}

/// @nodoc
abstract mixin class _$BiliSmsLoginStateCopyWith<$Res> implements $BiliSmsLoginStateCopyWith<$Res> {
  factory _$BiliSmsLoginStateCopyWith(_BiliSmsLoginState value, $Res Function(_BiliSmsLoginState) _then) = __$BiliSmsLoginStateCopyWithImpl;
@override @useResult
$Res call({
 BiliSmsLoginStatus status, String tel, BiliCaptchaParams? captcha, String? captchaKey, int countdownSeconds, String? message
});


@override $BiliCaptchaParamsCopyWith<$Res>? get captcha;

}
/// @nodoc
class __$BiliSmsLoginStateCopyWithImpl<$Res>
    implements _$BiliSmsLoginStateCopyWith<$Res> {
  __$BiliSmsLoginStateCopyWithImpl(this._self, this._then);

  final _BiliSmsLoginState _self;
  final $Res Function(_BiliSmsLoginState) _then;

/// Create a copy of BiliSmsLoginState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? tel = null,Object? captcha = freezed,Object? captchaKey = freezed,Object? countdownSeconds = null,Object? message = freezed,}) {
  return _then(_BiliSmsLoginState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BiliSmsLoginStatus,tel: null == tel ? _self.tel : tel // ignore: cast_nullable_to_non_nullable
as String,captcha: freezed == captcha ? _self.captcha : captcha // ignore: cast_nullable_to_non_nullable
as BiliCaptchaParams?,captchaKey: freezed == captchaKey ? _self.captchaKey : captchaKey // ignore: cast_nullable_to_non_nullable
as String?,countdownSeconds: null == countdownSeconds ? _self.countdownSeconds : countdownSeconds // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of BiliSmsLoginState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BiliCaptchaParamsCopyWith<$Res>? get captcha {
    if (_self.captcha == null) {
    return null;
  }

  return $BiliCaptchaParamsCopyWith<$Res>(_self.captcha!, (value) {
    return _then(_self.copyWith(captcha: value));
  });
}
}

/// @nodoc
mixin _$BiliCaptchaParams {

 String get token; String get gt; String get challenge;
/// Create a copy of BiliCaptchaParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BiliCaptchaParamsCopyWith<BiliCaptchaParams> get copyWith => _$BiliCaptchaParamsCopyWithImpl<BiliCaptchaParams>(this as BiliCaptchaParams, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BiliCaptchaParams&&(identical(other.token, token) || other.token == token)&&(identical(other.gt, gt) || other.gt == gt)&&(identical(other.challenge, challenge) || other.challenge == challenge));
}


@override
int get hashCode => Object.hash(runtimeType,token,gt,challenge);

@override
String toString() {
  return 'BiliCaptchaParams(token: $token, gt: $gt, challenge: $challenge)';
}


}

/// @nodoc
abstract mixin class $BiliCaptchaParamsCopyWith<$Res>  {
  factory $BiliCaptchaParamsCopyWith(BiliCaptchaParams value, $Res Function(BiliCaptchaParams) _then) = _$BiliCaptchaParamsCopyWithImpl;
@useResult
$Res call({
 String token, String gt, String challenge
});




}
/// @nodoc
class _$BiliCaptchaParamsCopyWithImpl<$Res>
    implements $BiliCaptchaParamsCopyWith<$Res> {
  _$BiliCaptchaParamsCopyWithImpl(this._self, this._then);

  final BiliCaptchaParams _self;
  final $Res Function(BiliCaptchaParams) _then;

/// Create a copy of BiliCaptchaParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? gt = null,Object? challenge = null,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,gt: null == gt ? _self.gt : gt // ignore: cast_nullable_to_non_nullable
as String,challenge: null == challenge ? _self.challenge : challenge // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BiliCaptchaParams].
extension BiliCaptchaParamsPatterns on BiliCaptchaParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BiliCaptchaParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BiliCaptchaParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BiliCaptchaParams value)  $default,){
final _that = this;
switch (_that) {
case _BiliCaptchaParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BiliCaptchaParams value)?  $default,){
final _that = this;
switch (_that) {
case _BiliCaptchaParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  String gt,  String challenge)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BiliCaptchaParams() when $default != null:
return $default(_that.token,_that.gt,_that.challenge);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  String gt,  String challenge)  $default,) {final _that = this;
switch (_that) {
case _BiliCaptchaParams():
return $default(_that.token,_that.gt,_that.challenge);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  String gt,  String challenge)?  $default,) {final _that = this;
switch (_that) {
case _BiliCaptchaParams() when $default != null:
return $default(_that.token,_that.gt,_that.challenge);case _:
  return null;

}
}

}

/// @nodoc


class _BiliCaptchaParams implements BiliCaptchaParams {
  const _BiliCaptchaParams({required this.token, required this.gt, required this.challenge});
  

@override final  String token;
@override final  String gt;
@override final  String challenge;

/// Create a copy of BiliCaptchaParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BiliCaptchaParamsCopyWith<_BiliCaptchaParams> get copyWith => __$BiliCaptchaParamsCopyWithImpl<_BiliCaptchaParams>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BiliCaptchaParams&&(identical(other.token, token) || other.token == token)&&(identical(other.gt, gt) || other.gt == gt)&&(identical(other.challenge, challenge) || other.challenge == challenge));
}


@override
int get hashCode => Object.hash(runtimeType,token,gt,challenge);

@override
String toString() {
  return 'BiliCaptchaParams(token: $token, gt: $gt, challenge: $challenge)';
}


}

/// @nodoc
abstract mixin class _$BiliCaptchaParamsCopyWith<$Res> implements $BiliCaptchaParamsCopyWith<$Res> {
  factory _$BiliCaptchaParamsCopyWith(_BiliCaptchaParams value, $Res Function(_BiliCaptchaParams) _then) = __$BiliCaptchaParamsCopyWithImpl;
@override @useResult
$Res call({
 String token, String gt, String challenge
});




}
/// @nodoc
class __$BiliCaptchaParamsCopyWithImpl<$Res>
    implements _$BiliCaptchaParamsCopyWith<$Res> {
  __$BiliCaptchaParamsCopyWithImpl(this._self, this._then);

  final _BiliCaptchaParams _self;
  final $Res Function(_BiliCaptchaParams) _then;

/// Create a copy of BiliCaptchaParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? gt = null,Object? challenge = null,}) {
  return _then(_BiliCaptchaParams(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,gt: null == gt ? _self.gt : gt // ignore: cast_nullable_to_non_nullable
as String,challenge: null == challenge ? _self.challenge : challenge // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$BiliGeetestResult {

 String get challenge; String get validate; String get seccode;
/// Create a copy of BiliGeetestResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BiliGeetestResultCopyWith<BiliGeetestResult> get copyWith => _$BiliGeetestResultCopyWithImpl<BiliGeetestResult>(this as BiliGeetestResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BiliGeetestResult&&(identical(other.challenge, challenge) || other.challenge == challenge)&&(identical(other.validate, validate) || other.validate == validate)&&(identical(other.seccode, seccode) || other.seccode == seccode));
}


@override
int get hashCode => Object.hash(runtimeType,challenge,validate,seccode);

@override
String toString() {
  return 'BiliGeetestResult(challenge: $challenge, validate: $validate, seccode: $seccode)';
}


}

/// @nodoc
abstract mixin class $BiliGeetestResultCopyWith<$Res>  {
  factory $BiliGeetestResultCopyWith(BiliGeetestResult value, $Res Function(BiliGeetestResult) _then) = _$BiliGeetestResultCopyWithImpl;
@useResult
$Res call({
 String challenge, String validate, String seccode
});




}
/// @nodoc
class _$BiliGeetestResultCopyWithImpl<$Res>
    implements $BiliGeetestResultCopyWith<$Res> {
  _$BiliGeetestResultCopyWithImpl(this._self, this._then);

  final BiliGeetestResult _self;
  final $Res Function(BiliGeetestResult) _then;

/// Create a copy of BiliGeetestResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? challenge = null,Object? validate = null,Object? seccode = null,}) {
  return _then(_self.copyWith(
challenge: null == challenge ? _self.challenge : challenge // ignore: cast_nullable_to_non_nullable
as String,validate: null == validate ? _self.validate : validate // ignore: cast_nullable_to_non_nullable
as String,seccode: null == seccode ? _self.seccode : seccode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BiliGeetestResult].
extension BiliGeetestResultPatterns on BiliGeetestResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BiliGeetestResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BiliGeetestResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BiliGeetestResult value)  $default,){
final _that = this;
switch (_that) {
case _BiliGeetestResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BiliGeetestResult value)?  $default,){
final _that = this;
switch (_that) {
case _BiliGeetestResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String challenge,  String validate,  String seccode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BiliGeetestResult() when $default != null:
return $default(_that.challenge,_that.validate,_that.seccode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String challenge,  String validate,  String seccode)  $default,) {final _that = this;
switch (_that) {
case _BiliGeetestResult():
return $default(_that.challenge,_that.validate,_that.seccode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String challenge,  String validate,  String seccode)?  $default,) {final _that = this;
switch (_that) {
case _BiliGeetestResult() when $default != null:
return $default(_that.challenge,_that.validate,_that.seccode);case _:
  return null;

}
}

}

/// @nodoc


class _BiliGeetestResult implements BiliGeetestResult {
  const _BiliGeetestResult({required this.challenge, required this.validate, required this.seccode});
  

@override final  String challenge;
@override final  String validate;
@override final  String seccode;

/// Create a copy of BiliGeetestResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BiliGeetestResultCopyWith<_BiliGeetestResult> get copyWith => __$BiliGeetestResultCopyWithImpl<_BiliGeetestResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BiliGeetestResult&&(identical(other.challenge, challenge) || other.challenge == challenge)&&(identical(other.validate, validate) || other.validate == validate)&&(identical(other.seccode, seccode) || other.seccode == seccode));
}


@override
int get hashCode => Object.hash(runtimeType,challenge,validate,seccode);

@override
String toString() {
  return 'BiliGeetestResult(challenge: $challenge, validate: $validate, seccode: $seccode)';
}


}

/// @nodoc
abstract mixin class _$BiliGeetestResultCopyWith<$Res> implements $BiliGeetestResultCopyWith<$Res> {
  factory _$BiliGeetestResultCopyWith(_BiliGeetestResult value, $Res Function(_BiliGeetestResult) _then) = __$BiliGeetestResultCopyWithImpl;
@override @useResult
$Res call({
 String challenge, String validate, String seccode
});




}
/// @nodoc
class __$BiliGeetestResultCopyWithImpl<$Res>
    implements _$BiliGeetestResultCopyWith<$Res> {
  __$BiliGeetestResultCopyWithImpl(this._self, this._then);

  final _BiliGeetestResult _self;
  final $Res Function(_BiliGeetestResult) _then;

/// Create a copy of BiliGeetestResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? challenge = null,Object? validate = null,Object? seccode = null,}) {
  return _then(_BiliGeetestResult(
challenge: null == challenge ? _self.challenge : challenge // ignore: cast_nullable_to_non_nullable
as String,validate: null == validate ? _self.validate : validate // ignore: cast_nullable_to_non_nullable
as String,seccode: null == seccode ? _self.seccode : seccode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
