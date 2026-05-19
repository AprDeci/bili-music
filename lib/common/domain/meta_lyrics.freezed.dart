// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meta_lyrics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MetaLyrics {

 String? get lyric; String? get translatedLyric; String? get romanizedLyric; String? get karaokeLyric; String? get karaokeTranslatedLyric;
/// Create a copy of MetaLyrics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MetaLyricsCopyWith<MetaLyrics> get copyWith => _$MetaLyricsCopyWithImpl<MetaLyrics>(this as MetaLyrics, _$identity);

  /// Serializes this MetaLyrics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MetaLyrics&&(identical(other.lyric, lyric) || other.lyric == lyric)&&(identical(other.translatedLyric, translatedLyric) || other.translatedLyric == translatedLyric)&&(identical(other.romanizedLyric, romanizedLyric) || other.romanizedLyric == romanizedLyric)&&(identical(other.karaokeLyric, karaokeLyric) || other.karaokeLyric == karaokeLyric)&&(identical(other.karaokeTranslatedLyric, karaokeTranslatedLyric) || other.karaokeTranslatedLyric == karaokeTranslatedLyric));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lyric,translatedLyric,romanizedLyric,karaokeLyric,karaokeTranslatedLyric);

@override
String toString() {
  return 'MetaLyrics(lyric: $lyric, translatedLyric: $translatedLyric, romanizedLyric: $romanizedLyric, karaokeLyric: $karaokeLyric, karaokeTranslatedLyric: $karaokeTranslatedLyric)';
}


}

/// @nodoc
abstract mixin class $MetaLyricsCopyWith<$Res>  {
  factory $MetaLyricsCopyWith(MetaLyrics value, $Res Function(MetaLyrics) _then) = _$MetaLyricsCopyWithImpl;
@useResult
$Res call({
 String? lyric, String? translatedLyric, String? romanizedLyric, String? karaokeLyric, String? karaokeTranslatedLyric
});




}
/// @nodoc
class _$MetaLyricsCopyWithImpl<$Res>
    implements $MetaLyricsCopyWith<$Res> {
  _$MetaLyricsCopyWithImpl(this._self, this._then);

  final MetaLyrics _self;
  final $Res Function(MetaLyrics) _then;

/// Create a copy of MetaLyrics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lyric = freezed,Object? translatedLyric = freezed,Object? romanizedLyric = freezed,Object? karaokeLyric = freezed,Object? karaokeTranslatedLyric = freezed,}) {
  return _then(_self.copyWith(
lyric: freezed == lyric ? _self.lyric : lyric // ignore: cast_nullable_to_non_nullable
as String?,translatedLyric: freezed == translatedLyric ? _self.translatedLyric : translatedLyric // ignore: cast_nullable_to_non_nullable
as String?,romanizedLyric: freezed == romanizedLyric ? _self.romanizedLyric : romanizedLyric // ignore: cast_nullable_to_non_nullable
as String?,karaokeLyric: freezed == karaokeLyric ? _self.karaokeLyric : karaokeLyric // ignore: cast_nullable_to_non_nullable
as String?,karaokeTranslatedLyric: freezed == karaokeTranslatedLyric ? _self.karaokeTranslatedLyric : karaokeTranslatedLyric // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MetaLyrics].
extension MetaLyricsPatterns on MetaLyrics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MetaLyrics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MetaLyrics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MetaLyrics value)  $default,){
final _that = this;
switch (_that) {
case _MetaLyrics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MetaLyrics value)?  $default,){
final _that = this;
switch (_that) {
case _MetaLyrics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? lyric,  String? translatedLyric,  String? romanizedLyric,  String? karaokeLyric,  String? karaokeTranslatedLyric)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MetaLyrics() when $default != null:
return $default(_that.lyric,_that.translatedLyric,_that.romanizedLyric,_that.karaokeLyric,_that.karaokeTranslatedLyric);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? lyric,  String? translatedLyric,  String? romanizedLyric,  String? karaokeLyric,  String? karaokeTranslatedLyric)  $default,) {final _that = this;
switch (_that) {
case _MetaLyrics():
return $default(_that.lyric,_that.translatedLyric,_that.romanizedLyric,_that.karaokeLyric,_that.karaokeTranslatedLyric);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? lyric,  String? translatedLyric,  String? romanizedLyric,  String? karaokeLyric,  String? karaokeTranslatedLyric)?  $default,) {final _that = this;
switch (_that) {
case _MetaLyrics() when $default != null:
return $default(_that.lyric,_that.translatedLyric,_that.romanizedLyric,_that.karaokeLyric,_that.karaokeTranslatedLyric);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MetaLyrics extends MetaLyrics {
  const _MetaLyrics({this.lyric, this.translatedLyric, this.romanizedLyric, this.karaokeLyric, this.karaokeTranslatedLyric}): super._();
  factory _MetaLyrics.fromJson(Map<String, dynamic> json) => _$MetaLyricsFromJson(json);

@override final  String? lyric;
@override final  String? translatedLyric;
@override final  String? romanizedLyric;
@override final  String? karaokeLyric;
@override final  String? karaokeTranslatedLyric;

/// Create a copy of MetaLyrics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MetaLyricsCopyWith<_MetaLyrics> get copyWith => __$MetaLyricsCopyWithImpl<_MetaLyrics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MetaLyricsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MetaLyrics&&(identical(other.lyric, lyric) || other.lyric == lyric)&&(identical(other.translatedLyric, translatedLyric) || other.translatedLyric == translatedLyric)&&(identical(other.romanizedLyric, romanizedLyric) || other.romanizedLyric == romanizedLyric)&&(identical(other.karaokeLyric, karaokeLyric) || other.karaokeLyric == karaokeLyric)&&(identical(other.karaokeTranslatedLyric, karaokeTranslatedLyric) || other.karaokeTranslatedLyric == karaokeTranslatedLyric));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lyric,translatedLyric,romanizedLyric,karaokeLyric,karaokeTranslatedLyric);

@override
String toString() {
  return 'MetaLyrics(lyric: $lyric, translatedLyric: $translatedLyric, romanizedLyric: $romanizedLyric, karaokeLyric: $karaokeLyric, karaokeTranslatedLyric: $karaokeTranslatedLyric)';
}


}

/// @nodoc
abstract mixin class _$MetaLyricsCopyWith<$Res> implements $MetaLyricsCopyWith<$Res> {
  factory _$MetaLyricsCopyWith(_MetaLyrics value, $Res Function(_MetaLyrics) _then) = __$MetaLyricsCopyWithImpl;
@override @useResult
$Res call({
 String? lyric, String? translatedLyric, String? romanizedLyric, String? karaokeLyric, String? karaokeTranslatedLyric
});




}
/// @nodoc
class __$MetaLyricsCopyWithImpl<$Res>
    implements _$MetaLyricsCopyWith<$Res> {
  __$MetaLyricsCopyWithImpl(this._self, this._then);

  final _MetaLyrics _self;
  final $Res Function(_MetaLyrics) _then;

/// Create a copy of MetaLyrics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lyric = freezed,Object? translatedLyric = freezed,Object? romanizedLyric = freezed,Object? karaokeLyric = freezed,Object? karaokeTranslatedLyric = freezed,}) {
  return _then(_MetaLyrics(
lyric: freezed == lyric ? _self.lyric : lyric // ignore: cast_nullable_to_non_nullable
as String?,translatedLyric: freezed == translatedLyric ? _self.translatedLyric : translatedLyric // ignore: cast_nullable_to_non_nullable
as String?,romanizedLyric: freezed == romanizedLyric ? _self.romanizedLyric : romanizedLyric // ignore: cast_nullable_to_non_nullable
as String?,karaokeLyric: freezed == karaokeLyric ? _self.karaokeLyric : karaokeLyric // ignore: cast_nullable_to_non_nullable
as String?,karaokeTranslatedLyric: freezed == karaokeTranslatedLyric ? _self.karaokeTranslatedLyric : karaokeTranslatedLyric // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
