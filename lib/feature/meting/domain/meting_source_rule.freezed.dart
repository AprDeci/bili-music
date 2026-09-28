// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meting_source_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MetingSourceRule {

 String get keyword; MetingServer get server;
/// Create a copy of MetingSourceRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MetingSourceRuleCopyWith<MetingSourceRule> get copyWith => _$MetingSourceRuleCopyWithImpl<MetingSourceRule>(this as MetingSourceRule, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MetingSourceRule&&(identical(other.keyword, keyword) || other.keyword == keyword)&&(identical(other.server, server) || other.server == server));
}


@override
int get hashCode => Object.hash(runtimeType,keyword,server);

@override
String toString() {
  return 'MetingSourceRule(keyword: $keyword, server: $server)';
}


}

/// @nodoc
abstract mixin class $MetingSourceRuleCopyWith<$Res>  {
  factory $MetingSourceRuleCopyWith(MetingSourceRule value, $Res Function(MetingSourceRule) _then) = _$MetingSourceRuleCopyWithImpl;
@useResult
$Res call({
 String keyword, MetingServer server
});




}
/// @nodoc
class _$MetingSourceRuleCopyWithImpl<$Res>
    implements $MetingSourceRuleCopyWith<$Res> {
  _$MetingSourceRuleCopyWithImpl(this._self, this._then);

  final MetingSourceRule _self;
  final $Res Function(MetingSourceRule) _then;

/// Create a copy of MetingSourceRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? keyword = null,Object? server = null,}) {
  return _then(_self.copyWith(
keyword: null == keyword ? _self.keyword : keyword // ignore: cast_nullable_to_non_nullable
as String,server: null == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as MetingServer,
  ));
}

}


/// Adds pattern-matching-related methods to [MetingSourceRule].
extension MetingSourceRulePatterns on MetingSourceRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MetingSourceRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MetingSourceRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MetingSourceRule value)  $default,){
final _that = this;
switch (_that) {
case _MetingSourceRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MetingSourceRule value)?  $default,){
final _that = this;
switch (_that) {
case _MetingSourceRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String keyword,  MetingServer server)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MetingSourceRule() when $default != null:
return $default(_that.keyword,_that.server);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String keyword,  MetingServer server)  $default,) {final _that = this;
switch (_that) {
case _MetingSourceRule():
return $default(_that.keyword,_that.server);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String keyword,  MetingServer server)?  $default,) {final _that = this;
switch (_that) {
case _MetingSourceRule() when $default != null:
return $default(_that.keyword,_that.server);case _:
  return null;

}
}

}

/// @nodoc


class _MetingSourceRule implements MetingSourceRule {
  const _MetingSourceRule({required this.keyword, required this.server});
  

@override final  String keyword;
@override final  MetingServer server;

/// Create a copy of MetingSourceRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MetingSourceRuleCopyWith<_MetingSourceRule> get copyWith => __$MetingSourceRuleCopyWithImpl<_MetingSourceRule>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MetingSourceRule&&(identical(other.keyword, keyword) || other.keyword == keyword)&&(identical(other.server, server) || other.server == server));
}


@override
int get hashCode => Object.hash(runtimeType,keyword,server);

@override
String toString() {
  return 'MetingSourceRule(keyword: $keyword, server: $server)';
}


}

/// @nodoc
abstract mixin class _$MetingSourceRuleCopyWith<$Res> implements $MetingSourceRuleCopyWith<$Res> {
  factory _$MetingSourceRuleCopyWith(_MetingSourceRule value, $Res Function(_MetingSourceRule) _then) = __$MetingSourceRuleCopyWithImpl;
@override @useResult
$Res call({
 String keyword, MetingServer server
});




}
/// @nodoc
class __$MetingSourceRuleCopyWithImpl<$Res>
    implements _$MetingSourceRuleCopyWith<$Res> {
  __$MetingSourceRuleCopyWithImpl(this._self, this._then);

  final _MetingSourceRule _self;
  final $Res Function(_MetingSourceRule) _then;

/// Create a copy of MetingSourceRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? keyword = null,Object? server = null,}) {
  return _then(_MetingSourceRule(
keyword: null == keyword ? _self.keyword : keyword // ignore: cast_nullable_to_non_nullable
as String,server: null == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as MetingServer,
  ));
}


}

// dart format on
