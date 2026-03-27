// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bili_auth_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BiliQrCodeSession {

 String get url; String get qrcodeKey;
/// Create a copy of BiliQrCodeSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BiliQrCodeSessionCopyWith<BiliQrCodeSession> get copyWith => _$BiliQrCodeSessionCopyWithImpl<BiliQrCodeSession>(this as BiliQrCodeSession, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BiliQrCodeSession&&(identical(other.url, url) || other.url == url)&&(identical(other.qrcodeKey, qrcodeKey) || other.qrcodeKey == qrcodeKey));
}


@override
int get hashCode => Object.hash(runtimeType,url,qrcodeKey);

@override
String toString() {
  return 'BiliQrCodeSession(url: $url, qrcodeKey: $qrcodeKey)';
}


}

/// @nodoc
abstract mixin class $BiliQrCodeSessionCopyWith<$Res>  {
  factory $BiliQrCodeSessionCopyWith(BiliQrCodeSession value, $Res Function(BiliQrCodeSession) _then) = _$BiliQrCodeSessionCopyWithImpl;
@useResult
$Res call({
 String url, String qrcodeKey
});




}
/// @nodoc
class _$BiliQrCodeSessionCopyWithImpl<$Res>
    implements $BiliQrCodeSessionCopyWith<$Res> {
  _$BiliQrCodeSessionCopyWithImpl(this._self, this._then);

  final BiliQrCodeSession _self;
  final $Res Function(BiliQrCodeSession) _then;

/// Create a copy of BiliQrCodeSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? qrcodeKey = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,qrcodeKey: null == qrcodeKey ? _self.qrcodeKey : qrcodeKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BiliQrCodeSession].
extension BiliQrCodeSessionPatterns on BiliQrCodeSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BiliQrCodeSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BiliQrCodeSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BiliQrCodeSession value)  $default,){
final _that = this;
switch (_that) {
case _BiliQrCodeSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BiliQrCodeSession value)?  $default,){
final _that = this;
switch (_that) {
case _BiliQrCodeSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  String qrcodeKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BiliQrCodeSession() when $default != null:
return $default(_that.url,_that.qrcodeKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  String qrcodeKey)  $default,) {final _that = this;
switch (_that) {
case _BiliQrCodeSession():
return $default(_that.url,_that.qrcodeKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  String qrcodeKey)?  $default,) {final _that = this;
switch (_that) {
case _BiliQrCodeSession() when $default != null:
return $default(_that.url,_that.qrcodeKey);case _:
  return null;

}
}

}

/// @nodoc


class _BiliQrCodeSession implements BiliQrCodeSession {
  const _BiliQrCodeSession({required this.url, required this.qrcodeKey});
  

@override final  String url;
@override final  String qrcodeKey;

/// Create a copy of BiliQrCodeSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BiliQrCodeSessionCopyWith<_BiliQrCodeSession> get copyWith => __$BiliQrCodeSessionCopyWithImpl<_BiliQrCodeSession>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BiliQrCodeSession&&(identical(other.url, url) || other.url == url)&&(identical(other.qrcodeKey, qrcodeKey) || other.qrcodeKey == qrcodeKey));
}


@override
int get hashCode => Object.hash(runtimeType,url,qrcodeKey);

@override
String toString() {
  return 'BiliQrCodeSession(url: $url, qrcodeKey: $qrcodeKey)';
}


}

/// @nodoc
abstract mixin class _$BiliQrCodeSessionCopyWith<$Res> implements $BiliQrCodeSessionCopyWith<$Res> {
  factory _$BiliQrCodeSessionCopyWith(_BiliQrCodeSession value, $Res Function(_BiliQrCodeSession) _then) = __$BiliQrCodeSessionCopyWithImpl;
@override @useResult
$Res call({
 String url, String qrcodeKey
});




}
/// @nodoc
class __$BiliQrCodeSessionCopyWithImpl<$Res>
    implements _$BiliQrCodeSessionCopyWith<$Res> {
  __$BiliQrCodeSessionCopyWithImpl(this._self, this._then);

  final _BiliQrCodeSession _self;
  final $Res Function(_BiliQrCodeSession) _then;

/// Create a copy of BiliQrCodeSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? qrcodeKey = null,}) {
  return _then(_BiliQrCodeSession(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,qrcodeKey: null == qrcodeKey ? _self.qrcodeKey : qrcodeKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$BiliAuthState {

 BiliQrLoginStatus get status; BiliQrCodeSession? get qrSession; BiliSession? get session; String? get message; int? get lastPollCode;
/// Create a copy of BiliAuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BiliAuthStateCopyWith<BiliAuthState> get copyWith => _$BiliAuthStateCopyWithImpl<BiliAuthState>(this as BiliAuthState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BiliAuthState&&(identical(other.status, status) || other.status == status)&&(identical(other.qrSession, qrSession) || other.qrSession == qrSession)&&(identical(other.session, session) || other.session == session)&&(identical(other.message, message) || other.message == message)&&(identical(other.lastPollCode, lastPollCode) || other.lastPollCode == lastPollCode));
}


@override
int get hashCode => Object.hash(runtimeType,status,qrSession,session,message,lastPollCode);

@override
String toString() {
  return 'BiliAuthState(status: $status, qrSession: $qrSession, session: $session, message: $message, lastPollCode: $lastPollCode)';
}


}

/// @nodoc
abstract mixin class $BiliAuthStateCopyWith<$Res>  {
  factory $BiliAuthStateCopyWith(BiliAuthState value, $Res Function(BiliAuthState) _then) = _$BiliAuthStateCopyWithImpl;
@useResult
$Res call({
 BiliQrLoginStatus status, BiliQrCodeSession? qrSession, BiliSession? session, String? message, int? lastPollCode
});


$BiliQrCodeSessionCopyWith<$Res>? get qrSession;$BiliSessionCopyWith<$Res>? get session;

}
/// @nodoc
class _$BiliAuthStateCopyWithImpl<$Res>
    implements $BiliAuthStateCopyWith<$Res> {
  _$BiliAuthStateCopyWithImpl(this._self, this._then);

  final BiliAuthState _self;
  final $Res Function(BiliAuthState) _then;

/// Create a copy of BiliAuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? qrSession = freezed,Object? session = freezed,Object? message = freezed,Object? lastPollCode = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BiliQrLoginStatus,qrSession: freezed == qrSession ? _self.qrSession : qrSession // ignore: cast_nullable_to_non_nullable
as BiliQrCodeSession?,session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as BiliSession?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,lastPollCode: freezed == lastPollCode ? _self.lastPollCode : lastPollCode // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of BiliAuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BiliQrCodeSessionCopyWith<$Res>? get qrSession {
    if (_self.qrSession == null) {
    return null;
  }

  return $BiliQrCodeSessionCopyWith<$Res>(_self.qrSession!, (value) {
    return _then(_self.copyWith(qrSession: value));
  });
}/// Create a copy of BiliAuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BiliSessionCopyWith<$Res>? get session {
    if (_self.session == null) {
    return null;
  }

  return $BiliSessionCopyWith<$Res>(_self.session!, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}


/// Adds pattern-matching-related methods to [BiliAuthState].
extension BiliAuthStatePatterns on BiliAuthState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BiliAuthState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BiliAuthState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BiliAuthState value)  $default,){
final _that = this;
switch (_that) {
case _BiliAuthState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BiliAuthState value)?  $default,){
final _that = this;
switch (_that) {
case _BiliAuthState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BiliQrLoginStatus status,  BiliQrCodeSession? qrSession,  BiliSession? session,  String? message,  int? lastPollCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BiliAuthState() when $default != null:
return $default(_that.status,_that.qrSession,_that.session,_that.message,_that.lastPollCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BiliQrLoginStatus status,  BiliQrCodeSession? qrSession,  BiliSession? session,  String? message,  int? lastPollCode)  $default,) {final _that = this;
switch (_that) {
case _BiliAuthState():
return $default(_that.status,_that.qrSession,_that.session,_that.message,_that.lastPollCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BiliQrLoginStatus status,  BiliQrCodeSession? qrSession,  BiliSession? session,  String? message,  int? lastPollCode)?  $default,) {final _that = this;
switch (_that) {
case _BiliAuthState() when $default != null:
return $default(_that.status,_that.qrSession,_that.session,_that.message,_that.lastPollCode);case _:
  return null;

}
}

}

/// @nodoc


class _BiliAuthState extends BiliAuthState {
  const _BiliAuthState({this.status = BiliQrLoginStatus.initial, this.qrSession, this.session, this.message, this.lastPollCode}): super._();
  

@override@JsonKey() final  BiliQrLoginStatus status;
@override final  BiliQrCodeSession? qrSession;
@override final  BiliSession? session;
@override final  String? message;
@override final  int? lastPollCode;

/// Create a copy of BiliAuthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BiliAuthStateCopyWith<_BiliAuthState> get copyWith => __$BiliAuthStateCopyWithImpl<_BiliAuthState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BiliAuthState&&(identical(other.status, status) || other.status == status)&&(identical(other.qrSession, qrSession) || other.qrSession == qrSession)&&(identical(other.session, session) || other.session == session)&&(identical(other.message, message) || other.message == message)&&(identical(other.lastPollCode, lastPollCode) || other.lastPollCode == lastPollCode));
}


@override
int get hashCode => Object.hash(runtimeType,status,qrSession,session,message,lastPollCode);

@override
String toString() {
  return 'BiliAuthState(status: $status, qrSession: $qrSession, session: $session, message: $message, lastPollCode: $lastPollCode)';
}


}

/// @nodoc
abstract mixin class _$BiliAuthStateCopyWith<$Res> implements $BiliAuthStateCopyWith<$Res> {
  factory _$BiliAuthStateCopyWith(_BiliAuthState value, $Res Function(_BiliAuthState) _then) = __$BiliAuthStateCopyWithImpl;
@override @useResult
$Res call({
 BiliQrLoginStatus status, BiliQrCodeSession? qrSession, BiliSession? session, String? message, int? lastPollCode
});


@override $BiliQrCodeSessionCopyWith<$Res>? get qrSession;@override $BiliSessionCopyWith<$Res>? get session;

}
/// @nodoc
class __$BiliAuthStateCopyWithImpl<$Res>
    implements _$BiliAuthStateCopyWith<$Res> {
  __$BiliAuthStateCopyWithImpl(this._self, this._then);

  final _BiliAuthState _self;
  final $Res Function(_BiliAuthState) _then;

/// Create a copy of BiliAuthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? qrSession = freezed,Object? session = freezed,Object? message = freezed,Object? lastPollCode = freezed,}) {
  return _then(_BiliAuthState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BiliQrLoginStatus,qrSession: freezed == qrSession ? _self.qrSession : qrSession // ignore: cast_nullable_to_non_nullable
as BiliQrCodeSession?,session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as BiliSession?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,lastPollCode: freezed == lastPollCode ? _self.lastPollCode : lastPollCode // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of BiliAuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BiliQrCodeSessionCopyWith<$Res>? get qrSession {
    if (_self.qrSession == null) {
    return null;
  }

  return $BiliQrCodeSessionCopyWith<$Res>(_self.qrSession!, (value) {
    return _then(_self.copyWith(qrSession: value));
  });
}/// Create a copy of BiliAuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BiliSessionCopyWith<$Res>? get session {
    if (_self.session == null) {
    return null;
  }

  return $BiliSessionCopyWith<$Res>(_self.session!, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}

// dart format on
