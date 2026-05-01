// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hotkey_binding.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HotkeyBinding {

 HotkeyAction get action; int get keyCode; List<String> get modifiers; bool get enabled;
/// Create a copy of HotkeyBinding
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HotkeyBindingCopyWith<HotkeyBinding> get copyWith => _$HotkeyBindingCopyWithImpl<HotkeyBinding>(this as HotkeyBinding, _$identity);

  /// Serializes this HotkeyBinding to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HotkeyBinding&&(identical(other.action, action) || other.action == action)&&(identical(other.keyCode, keyCode) || other.keyCode == keyCode)&&const DeepCollectionEquality().equals(other.modifiers, modifiers)&&(identical(other.enabled, enabled) || other.enabled == enabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,action,keyCode,const DeepCollectionEquality().hash(modifiers),enabled);

@override
String toString() {
  return 'HotkeyBinding(action: $action, keyCode: $keyCode, modifiers: $modifiers, enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class $HotkeyBindingCopyWith<$Res>  {
  factory $HotkeyBindingCopyWith(HotkeyBinding value, $Res Function(HotkeyBinding) _then) = _$HotkeyBindingCopyWithImpl;
@useResult
$Res call({
 HotkeyAction action, int keyCode, List<String> modifiers, bool enabled
});




}
/// @nodoc
class _$HotkeyBindingCopyWithImpl<$Res>
    implements $HotkeyBindingCopyWith<$Res> {
  _$HotkeyBindingCopyWithImpl(this._self, this._then);

  final HotkeyBinding _self;
  final $Res Function(HotkeyBinding) _then;

/// Create a copy of HotkeyBinding
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? action = null,Object? keyCode = null,Object? modifiers = null,Object? enabled = null,}) {
  return _then(_self.copyWith(
action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as HotkeyAction,keyCode: null == keyCode ? _self.keyCode : keyCode // ignore: cast_nullable_to_non_nullable
as int,modifiers: null == modifiers ? _self.modifiers : modifiers // ignore: cast_nullable_to_non_nullable
as List<String>,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [HotkeyBinding].
extension HotkeyBindingPatterns on HotkeyBinding {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HotkeyBinding value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HotkeyBinding() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HotkeyBinding value)  $default,){
final _that = this;
switch (_that) {
case _HotkeyBinding():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HotkeyBinding value)?  $default,){
final _that = this;
switch (_that) {
case _HotkeyBinding() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HotkeyAction action,  int keyCode,  List<String> modifiers,  bool enabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HotkeyBinding() when $default != null:
return $default(_that.action,_that.keyCode,_that.modifiers,_that.enabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HotkeyAction action,  int keyCode,  List<String> modifiers,  bool enabled)  $default,) {final _that = this;
switch (_that) {
case _HotkeyBinding():
return $default(_that.action,_that.keyCode,_that.modifiers,_that.enabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HotkeyAction action,  int keyCode,  List<String> modifiers,  bool enabled)?  $default,) {final _that = this;
switch (_that) {
case _HotkeyBinding() when $default != null:
return $default(_that.action,_that.keyCode,_that.modifiers,_that.enabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HotkeyBinding extends HotkeyBinding {
  const _HotkeyBinding({required this.action, required this.keyCode, required final  List<String> modifiers, this.enabled = true}): _modifiers = modifiers,super._();
  factory _HotkeyBinding.fromJson(Map<String, dynamic> json) => _$HotkeyBindingFromJson(json);

@override final  HotkeyAction action;
@override final  int keyCode;
 final  List<String> _modifiers;
@override List<String> get modifiers {
  if (_modifiers is EqualUnmodifiableListView) return _modifiers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_modifiers);
}

@override@JsonKey() final  bool enabled;

/// Create a copy of HotkeyBinding
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HotkeyBindingCopyWith<_HotkeyBinding> get copyWith => __$HotkeyBindingCopyWithImpl<_HotkeyBinding>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HotkeyBindingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HotkeyBinding&&(identical(other.action, action) || other.action == action)&&(identical(other.keyCode, keyCode) || other.keyCode == keyCode)&&const DeepCollectionEquality().equals(other._modifiers, _modifiers)&&(identical(other.enabled, enabled) || other.enabled == enabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,action,keyCode,const DeepCollectionEquality().hash(_modifiers),enabled);

@override
String toString() {
  return 'HotkeyBinding(action: $action, keyCode: $keyCode, modifiers: $modifiers, enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class _$HotkeyBindingCopyWith<$Res> implements $HotkeyBindingCopyWith<$Res> {
  factory _$HotkeyBindingCopyWith(_HotkeyBinding value, $Res Function(_HotkeyBinding) _then) = __$HotkeyBindingCopyWithImpl;
@override @useResult
$Res call({
 HotkeyAction action, int keyCode, List<String> modifiers, bool enabled
});




}
/// @nodoc
class __$HotkeyBindingCopyWithImpl<$Res>
    implements _$HotkeyBindingCopyWith<$Res> {
  __$HotkeyBindingCopyWithImpl(this._self, this._then);

  final _HotkeyBinding _self;
  final $Res Function(_HotkeyBinding) _then;

/// Create a copy of HotkeyBinding
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? action = null,Object? keyCode = null,Object? modifiers = null,Object? enabled = null,}) {
  return _then(_HotkeyBinding(
action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as HotkeyAction,keyCode: null == keyCode ? _self.keyCode : keyCode // ignore: cast_nullable_to_non_nullable
as int,modifiers: null == modifiers ? _self._modifiers : modifiers // ignore: cast_nullable_to_non_nullable
as List<String>,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
