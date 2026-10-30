// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bili_subtitle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BiliSubtitleTrack {

 String get id; String get language; String get label; String get url; bool get isTranslated;
/// Create a copy of BiliSubtitleTrack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BiliSubtitleTrackCopyWith<BiliSubtitleTrack> get copyWith => _$BiliSubtitleTrackCopyWithImpl<BiliSubtitleTrack>(this as BiliSubtitleTrack, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BiliSubtitleTrack&&(identical(other.id, id) || other.id == id)&&(identical(other.language, language) || other.language == language)&&(identical(other.label, label) || other.label == label)&&(identical(other.url, url) || other.url == url)&&(identical(other.isTranslated, isTranslated) || other.isTranslated == isTranslated));
}


@override
int get hashCode => Object.hash(runtimeType,id,language,label,url,isTranslated);

@override
String toString() {
  return 'BiliSubtitleTrack(id: $id, language: $language, label: $label, url: $url, isTranslated: $isTranslated)';
}


}

/// @nodoc
abstract mixin class $BiliSubtitleTrackCopyWith<$Res>  {
  factory $BiliSubtitleTrackCopyWith(BiliSubtitleTrack value, $Res Function(BiliSubtitleTrack) _then) = _$BiliSubtitleTrackCopyWithImpl;
@useResult
$Res call({
 String id, String language, String label, String url, bool isTranslated
});




}
/// @nodoc
class _$BiliSubtitleTrackCopyWithImpl<$Res>
    implements $BiliSubtitleTrackCopyWith<$Res> {
  _$BiliSubtitleTrackCopyWithImpl(this._self, this._then);

  final BiliSubtitleTrack _self;
  final $Res Function(BiliSubtitleTrack) _then;

/// Create a copy of BiliSubtitleTrack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? language = null,Object? label = null,Object? url = null,Object? isTranslated = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,isTranslated: null == isTranslated ? _self.isTranslated : isTranslated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BiliSubtitleTrack].
extension BiliSubtitleTrackPatterns on BiliSubtitleTrack {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BiliSubtitleTrack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BiliSubtitleTrack() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BiliSubtitleTrack value)  $default,){
final _that = this;
switch (_that) {
case _BiliSubtitleTrack():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BiliSubtitleTrack value)?  $default,){
final _that = this;
switch (_that) {
case _BiliSubtitleTrack() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String language,  String label,  String url,  bool isTranslated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BiliSubtitleTrack() when $default != null:
return $default(_that.id,_that.language,_that.label,_that.url,_that.isTranslated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String language,  String label,  String url,  bool isTranslated)  $default,) {final _that = this;
switch (_that) {
case _BiliSubtitleTrack():
return $default(_that.id,_that.language,_that.label,_that.url,_that.isTranslated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String language,  String label,  String url,  bool isTranslated)?  $default,) {final _that = this;
switch (_that) {
case _BiliSubtitleTrack() when $default != null:
return $default(_that.id,_that.language,_that.label,_that.url,_that.isTranslated);case _:
  return null;

}
}

}

/// @nodoc


class _BiliSubtitleTrack implements BiliSubtitleTrack {
  const _BiliSubtitleTrack({required this.id, required this.language, required this.label, required this.url, this.isTranslated = false});
  

@override final  String id;
@override final  String language;
@override final  String label;
@override final  String url;
@override@JsonKey() final  bool isTranslated;

/// Create a copy of BiliSubtitleTrack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BiliSubtitleTrackCopyWith<_BiliSubtitleTrack> get copyWith => __$BiliSubtitleTrackCopyWithImpl<_BiliSubtitleTrack>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BiliSubtitleTrack&&(identical(other.id, id) || other.id == id)&&(identical(other.language, language) || other.language == language)&&(identical(other.label, label) || other.label == label)&&(identical(other.url, url) || other.url == url)&&(identical(other.isTranslated, isTranslated) || other.isTranslated == isTranslated));
}


@override
int get hashCode => Object.hash(runtimeType,id,language,label,url,isTranslated);

@override
String toString() {
  return 'BiliSubtitleTrack(id: $id, language: $language, label: $label, url: $url, isTranslated: $isTranslated)';
}


}

/// @nodoc
abstract mixin class _$BiliSubtitleTrackCopyWith<$Res> implements $BiliSubtitleTrackCopyWith<$Res> {
  factory _$BiliSubtitleTrackCopyWith(_BiliSubtitleTrack value, $Res Function(_BiliSubtitleTrack) _then) = __$BiliSubtitleTrackCopyWithImpl;
@override @useResult
$Res call({
 String id, String language, String label, String url, bool isTranslated
});




}
/// @nodoc
class __$BiliSubtitleTrackCopyWithImpl<$Res>
    implements _$BiliSubtitleTrackCopyWith<$Res> {
  __$BiliSubtitleTrackCopyWithImpl(this._self, this._then);

  final _BiliSubtitleTrack _self;
  final $Res Function(_BiliSubtitleTrack) _then;

/// Create a copy of BiliSubtitleTrack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? language = null,Object? label = null,Object? url = null,Object? isTranslated = null,}) {
  return _then(_BiliSubtitleTrack(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,isTranslated: null == isTranslated ? _self.isTranslated : isTranslated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$BiliSubtitleLine {

 int get startMs; int get endMs; String get text;
/// Create a copy of BiliSubtitleLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BiliSubtitleLineCopyWith<BiliSubtitleLine> get copyWith => _$BiliSubtitleLineCopyWithImpl<BiliSubtitleLine>(this as BiliSubtitleLine, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BiliSubtitleLine&&(identical(other.startMs, startMs) || other.startMs == startMs)&&(identical(other.endMs, endMs) || other.endMs == endMs)&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,startMs,endMs,text);

@override
String toString() {
  return 'BiliSubtitleLine(startMs: $startMs, endMs: $endMs, text: $text)';
}


}

/// @nodoc
abstract mixin class $BiliSubtitleLineCopyWith<$Res>  {
  factory $BiliSubtitleLineCopyWith(BiliSubtitleLine value, $Res Function(BiliSubtitleLine) _then) = _$BiliSubtitleLineCopyWithImpl;
@useResult
$Res call({
 int startMs, int endMs, String text
});




}
/// @nodoc
class _$BiliSubtitleLineCopyWithImpl<$Res>
    implements $BiliSubtitleLineCopyWith<$Res> {
  _$BiliSubtitleLineCopyWithImpl(this._self, this._then);

  final BiliSubtitleLine _self;
  final $Res Function(BiliSubtitleLine) _then;

/// Create a copy of BiliSubtitleLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startMs = null,Object? endMs = null,Object? text = null,}) {
  return _then(_self.copyWith(
startMs: null == startMs ? _self.startMs : startMs // ignore: cast_nullable_to_non_nullable
as int,endMs: null == endMs ? _self.endMs : endMs // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BiliSubtitleLine].
extension BiliSubtitleLinePatterns on BiliSubtitleLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BiliSubtitleLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BiliSubtitleLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BiliSubtitleLine value)  $default,){
final _that = this;
switch (_that) {
case _BiliSubtitleLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BiliSubtitleLine value)?  $default,){
final _that = this;
switch (_that) {
case _BiliSubtitleLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int startMs,  int endMs,  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BiliSubtitleLine() when $default != null:
return $default(_that.startMs,_that.endMs,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int startMs,  int endMs,  String text)  $default,) {final _that = this;
switch (_that) {
case _BiliSubtitleLine():
return $default(_that.startMs,_that.endMs,_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int startMs,  int endMs,  String text)?  $default,) {final _that = this;
switch (_that) {
case _BiliSubtitleLine() when $default != null:
return $default(_that.startMs,_that.endMs,_that.text);case _:
  return null;

}
}

}

/// @nodoc


class _BiliSubtitleLine implements BiliSubtitleLine {
  const _BiliSubtitleLine({required this.startMs, required this.endMs, required this.text});
  

@override final  int startMs;
@override final  int endMs;
@override final  String text;

/// Create a copy of BiliSubtitleLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BiliSubtitleLineCopyWith<_BiliSubtitleLine> get copyWith => __$BiliSubtitleLineCopyWithImpl<_BiliSubtitleLine>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BiliSubtitleLine&&(identical(other.startMs, startMs) || other.startMs == startMs)&&(identical(other.endMs, endMs) || other.endMs == endMs)&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,startMs,endMs,text);

@override
String toString() {
  return 'BiliSubtitleLine(startMs: $startMs, endMs: $endMs, text: $text)';
}


}

/// @nodoc
abstract mixin class _$BiliSubtitleLineCopyWith<$Res> implements $BiliSubtitleLineCopyWith<$Res> {
  factory _$BiliSubtitleLineCopyWith(_BiliSubtitleLine value, $Res Function(_BiliSubtitleLine) _then) = __$BiliSubtitleLineCopyWithImpl;
@override @useResult
$Res call({
 int startMs, int endMs, String text
});




}
/// @nodoc
class __$BiliSubtitleLineCopyWithImpl<$Res>
    implements _$BiliSubtitleLineCopyWith<$Res> {
  __$BiliSubtitleLineCopyWithImpl(this._self, this._then);

  final _BiliSubtitleLine _self;
  final $Res Function(_BiliSubtitleLine) _then;

/// Create a copy of BiliSubtitleLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startMs = null,Object? endMs = null,Object? text = null,}) {
  return _then(_BiliSubtitleLine(
startMs: null == startMs ? _self.startMs : startMs // ignore: cast_nullable_to_non_nullable
as int,endMs: null == endMs ? _self.endMs : endMs // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
