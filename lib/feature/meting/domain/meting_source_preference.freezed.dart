// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meting_source_preference.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MetingSourcePreference {

 MetingServer get defaultServer; List<MetingSourceRule> get rules;
/// Create a copy of MetingSourcePreference
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MetingSourcePreferenceCopyWith<MetingSourcePreference> get copyWith => _$MetingSourcePreferenceCopyWithImpl<MetingSourcePreference>(this as MetingSourcePreference, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MetingSourcePreference&&(identical(other.defaultServer, defaultServer) || other.defaultServer == defaultServer)&&const DeepCollectionEquality().equals(other.rules, rules));
}


@override
int get hashCode => Object.hash(runtimeType,defaultServer,const DeepCollectionEquality().hash(rules));

@override
String toString() {
  return 'MetingSourcePreference(defaultServer: $defaultServer, rules: $rules)';
}


}

/// @nodoc
abstract mixin class $MetingSourcePreferenceCopyWith<$Res>  {
  factory $MetingSourcePreferenceCopyWith(MetingSourcePreference value, $Res Function(MetingSourcePreference) _then) = _$MetingSourcePreferenceCopyWithImpl;
@useResult
$Res call({
 MetingServer defaultServer, List<MetingSourceRule> rules
});




}
/// @nodoc
class _$MetingSourcePreferenceCopyWithImpl<$Res>
    implements $MetingSourcePreferenceCopyWith<$Res> {
  _$MetingSourcePreferenceCopyWithImpl(this._self, this._then);

  final MetingSourcePreference _self;
  final $Res Function(MetingSourcePreference) _then;

/// Create a copy of MetingSourcePreference
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? defaultServer = null,Object? rules = null,}) {
  return _then(_self.copyWith(
defaultServer: null == defaultServer ? _self.defaultServer : defaultServer // ignore: cast_nullable_to_non_nullable
as MetingServer,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as List<MetingSourceRule>,
  ));
}

}


/// Adds pattern-matching-related methods to [MetingSourcePreference].
extension MetingSourcePreferencePatterns on MetingSourcePreference {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MetingSourcePreference value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MetingSourcePreference() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MetingSourcePreference value)  $default,){
final _that = this;
switch (_that) {
case _MetingSourcePreference():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MetingSourcePreference value)?  $default,){
final _that = this;
switch (_that) {
case _MetingSourcePreference() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MetingServer defaultServer,  List<MetingSourceRule> rules)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MetingSourcePreference() when $default != null:
return $default(_that.defaultServer,_that.rules);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MetingServer defaultServer,  List<MetingSourceRule> rules)  $default,) {final _that = this;
switch (_that) {
case _MetingSourcePreference():
return $default(_that.defaultServer,_that.rules);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MetingServer defaultServer,  List<MetingSourceRule> rules)?  $default,) {final _that = this;
switch (_that) {
case _MetingSourcePreference() when $default != null:
return $default(_that.defaultServer,_that.rules);case _:
  return null;

}
}

}

/// @nodoc


class _MetingSourcePreference extends MetingSourcePreference {
  const _MetingSourcePreference({this.defaultServer = MetingServer.netease, final  List<MetingSourceRule> rules = const <MetingSourceRule>[]}): _rules = rules,super._();
  

@override@JsonKey() final  MetingServer defaultServer;
 final  List<MetingSourceRule> _rules;
@override@JsonKey() List<MetingSourceRule> get rules {
  if (_rules is EqualUnmodifiableListView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rules);
}


/// Create a copy of MetingSourcePreference
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MetingSourcePreferenceCopyWith<_MetingSourcePreference> get copyWith => __$MetingSourcePreferenceCopyWithImpl<_MetingSourcePreference>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MetingSourcePreference&&(identical(other.defaultServer, defaultServer) || other.defaultServer == defaultServer)&&const DeepCollectionEquality().equals(other._rules, _rules));
}


@override
int get hashCode => Object.hash(runtimeType,defaultServer,const DeepCollectionEquality().hash(_rules));

@override
String toString() {
  return 'MetingSourcePreference(defaultServer: $defaultServer, rules: $rules)';
}


}

/// @nodoc
abstract mixin class _$MetingSourcePreferenceCopyWith<$Res> implements $MetingSourcePreferenceCopyWith<$Res> {
  factory _$MetingSourcePreferenceCopyWith(_MetingSourcePreference value, $Res Function(_MetingSourcePreference) _then) = __$MetingSourcePreferenceCopyWithImpl;
@override @useResult
$Res call({
 MetingServer defaultServer, List<MetingSourceRule> rules
});




}
/// @nodoc
class __$MetingSourcePreferenceCopyWithImpl<$Res>
    implements _$MetingSourcePreferenceCopyWith<$Res> {
  __$MetingSourcePreferenceCopyWithImpl(this._self, this._then);

  final _MetingSourcePreference _self;
  final $Res Function(_MetingSourcePreference) _then;

/// Create a copy of MetingSourcePreference
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? defaultServer = null,Object? rules = null,}) {
  return _then(_MetingSourcePreference(
defaultServer: null == defaultServer ? _self.defaultServer : defaultServer // ignore: cast_nullable_to_non_nullable
as MetingServer,rules: null == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as List<MetingSourceRule>,
  ));
}


}

// dart format on
