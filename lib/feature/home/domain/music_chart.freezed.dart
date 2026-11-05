// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'music_chart.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MusicChart {

 MusicChartPlatform get platform; String get chartId; String get name;
/// Create a copy of MusicChart
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MusicChartCopyWith<MusicChart> get copyWith => _$MusicChartCopyWithImpl<MusicChart>(this as MusicChart, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MusicChart&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.chartId, chartId) || other.chartId == chartId)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,platform,chartId,name);

@override
String toString() {
  return 'MusicChart(platform: $platform, chartId: $chartId, name: $name)';
}


}

/// @nodoc
abstract mixin class $MusicChartCopyWith<$Res>  {
  factory $MusicChartCopyWith(MusicChart value, $Res Function(MusicChart) _then) = _$MusicChartCopyWithImpl;
@useResult
$Res call({
 MusicChartPlatform platform, String chartId, String name
});




}
/// @nodoc
class _$MusicChartCopyWithImpl<$Res>
    implements $MusicChartCopyWith<$Res> {
  _$MusicChartCopyWithImpl(this._self, this._then);

  final MusicChart _self;
  final $Res Function(MusicChart) _then;

/// Create a copy of MusicChart
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? platform = null,Object? chartId = null,Object? name = null,}) {
  return _then(_self.copyWith(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as MusicChartPlatform,chartId: null == chartId ? _self.chartId : chartId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MusicChart].
extension MusicChartPatterns on MusicChart {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MusicChart value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MusicChart() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MusicChart value)  $default,){
final _that = this;
switch (_that) {
case _MusicChart():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MusicChart value)?  $default,){
final _that = this;
switch (_that) {
case _MusicChart() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MusicChartPlatform platform,  String chartId,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MusicChart() when $default != null:
return $default(_that.platform,_that.chartId,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MusicChartPlatform platform,  String chartId,  String name)  $default,) {final _that = this;
switch (_that) {
case _MusicChart():
return $default(_that.platform,_that.chartId,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MusicChartPlatform platform,  String chartId,  String name)?  $default,) {final _that = this;
switch (_that) {
case _MusicChart() when $default != null:
return $default(_that.platform,_that.chartId,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _MusicChart extends MusicChart {
  const _MusicChart({required this.platform, required this.chartId, required this.name}): super._();
  

@override final  MusicChartPlatform platform;
@override final  String chartId;
@override final  String name;

/// Create a copy of MusicChart
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MusicChartCopyWith<_MusicChart> get copyWith => __$MusicChartCopyWithImpl<_MusicChart>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MusicChart&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.chartId, chartId) || other.chartId == chartId)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,platform,chartId,name);

@override
String toString() {
  return 'MusicChart(platform: $platform, chartId: $chartId, name: $name)';
}


}

/// @nodoc
abstract mixin class _$MusicChartCopyWith<$Res> implements $MusicChartCopyWith<$Res> {
  factory _$MusicChartCopyWith(_MusicChart value, $Res Function(_MusicChart) _then) = __$MusicChartCopyWithImpl;
@override @useResult
$Res call({
 MusicChartPlatform platform, String chartId, String name
});




}
/// @nodoc
class __$MusicChartCopyWithImpl<$Res>
    implements _$MusicChartCopyWith<$Res> {
  __$MusicChartCopyWithImpl(this._self, this._then);

  final _MusicChart _self;
  final $Res Function(_MusicChart) _then;

/// Create a copy of MusicChart
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platform = null,Object? chartId = null,Object? name = null,}) {
  return _then(_MusicChart(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as MusicChartPlatform,chartId: null == chartId ? _self.chartId : chartId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
