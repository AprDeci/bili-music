// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'up_page_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpPageState {

 UpProfile? get profile; PagedState<UpVideoItem> get videoFeed; PagedState<UpCollection> get collectionFeed; UpPageTab get selectedTab; bool get isRefreshing; String? get profileError; String? get videoError; String? get collectionError; String? get videoLoadMoreError; String? get collectionLoadMoreError;
/// Create a copy of UpPageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpPageStateCopyWith<UpPageState> get copyWith => _$UpPageStateCopyWithImpl<UpPageState>(this as UpPageState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpPageState&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.videoFeed, videoFeed) || other.videoFeed == videoFeed)&&(identical(other.collectionFeed, collectionFeed) || other.collectionFeed == collectionFeed)&&(identical(other.selectedTab, selectedTab) || other.selectedTab == selectedTab)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.profileError, profileError) || other.profileError == profileError)&&(identical(other.videoError, videoError) || other.videoError == videoError)&&(identical(other.collectionError, collectionError) || other.collectionError == collectionError)&&(identical(other.videoLoadMoreError, videoLoadMoreError) || other.videoLoadMoreError == videoLoadMoreError)&&(identical(other.collectionLoadMoreError, collectionLoadMoreError) || other.collectionLoadMoreError == collectionLoadMoreError));
}


@override
int get hashCode => Object.hash(runtimeType,profile,videoFeed,collectionFeed,selectedTab,isRefreshing,profileError,videoError,collectionError,videoLoadMoreError,collectionLoadMoreError);

@override
String toString() {
  return 'UpPageState(profile: $profile, videoFeed: $videoFeed, collectionFeed: $collectionFeed, selectedTab: $selectedTab, isRefreshing: $isRefreshing, profileError: $profileError, videoError: $videoError, collectionError: $collectionError, videoLoadMoreError: $videoLoadMoreError, collectionLoadMoreError: $collectionLoadMoreError)';
}


}

/// @nodoc
abstract mixin class $UpPageStateCopyWith<$Res>  {
  factory $UpPageStateCopyWith(UpPageState value, $Res Function(UpPageState) _then) = _$UpPageStateCopyWithImpl;
@useResult
$Res call({
 UpProfile? profile, PagedState<UpVideoItem> videoFeed, PagedState<UpCollection> collectionFeed, UpPageTab selectedTab, bool isRefreshing, String? profileError, String? videoError, String? collectionError, String? videoLoadMoreError, String? collectionLoadMoreError
});


$UpProfileCopyWith<$Res>? get profile;

}
/// @nodoc
class _$UpPageStateCopyWithImpl<$Res>
    implements $UpPageStateCopyWith<$Res> {
  _$UpPageStateCopyWithImpl(this._self, this._then);

  final UpPageState _self;
  final $Res Function(UpPageState) _then;

/// Create a copy of UpPageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profile = freezed,Object? videoFeed = null,Object? collectionFeed = null,Object? selectedTab = null,Object? isRefreshing = null,Object? profileError = freezed,Object? videoError = freezed,Object? collectionError = freezed,Object? videoLoadMoreError = freezed,Object? collectionLoadMoreError = freezed,}) {
  return _then(_self.copyWith(
profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UpProfile?,videoFeed: null == videoFeed ? _self.videoFeed : videoFeed // ignore: cast_nullable_to_non_nullable
as PagedState<UpVideoItem>,collectionFeed: null == collectionFeed ? _self.collectionFeed : collectionFeed // ignore: cast_nullable_to_non_nullable
as PagedState<UpCollection>,selectedTab: null == selectedTab ? _self.selectedTab : selectedTab // ignore: cast_nullable_to_non_nullable
as UpPageTab,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,profileError: freezed == profileError ? _self.profileError : profileError // ignore: cast_nullable_to_non_nullable
as String?,videoError: freezed == videoError ? _self.videoError : videoError // ignore: cast_nullable_to_non_nullable
as String?,collectionError: freezed == collectionError ? _self.collectionError : collectionError // ignore: cast_nullable_to_non_nullable
as String?,videoLoadMoreError: freezed == videoLoadMoreError ? _self.videoLoadMoreError : videoLoadMoreError // ignore: cast_nullable_to_non_nullable
as String?,collectionLoadMoreError: freezed == collectionLoadMoreError ? _self.collectionLoadMoreError : collectionLoadMoreError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of UpPageState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $UpProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [UpPageState].
extension UpPageStatePatterns on UpPageState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpPageState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpPageState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpPageState value)  $default,){
final _that = this;
switch (_that) {
case _UpPageState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpPageState value)?  $default,){
final _that = this;
switch (_that) {
case _UpPageState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UpProfile? profile,  PagedState<UpVideoItem> videoFeed,  PagedState<UpCollection> collectionFeed,  UpPageTab selectedTab,  bool isRefreshing,  String? profileError,  String? videoError,  String? collectionError,  String? videoLoadMoreError,  String? collectionLoadMoreError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpPageState() when $default != null:
return $default(_that.profile,_that.videoFeed,_that.collectionFeed,_that.selectedTab,_that.isRefreshing,_that.profileError,_that.videoError,_that.collectionError,_that.videoLoadMoreError,_that.collectionLoadMoreError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UpProfile? profile,  PagedState<UpVideoItem> videoFeed,  PagedState<UpCollection> collectionFeed,  UpPageTab selectedTab,  bool isRefreshing,  String? profileError,  String? videoError,  String? collectionError,  String? videoLoadMoreError,  String? collectionLoadMoreError)  $default,) {final _that = this;
switch (_that) {
case _UpPageState():
return $default(_that.profile,_that.videoFeed,_that.collectionFeed,_that.selectedTab,_that.isRefreshing,_that.profileError,_that.videoError,_that.collectionError,_that.videoLoadMoreError,_that.collectionLoadMoreError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UpProfile? profile,  PagedState<UpVideoItem> videoFeed,  PagedState<UpCollection> collectionFeed,  UpPageTab selectedTab,  bool isRefreshing,  String? profileError,  String? videoError,  String? collectionError,  String? videoLoadMoreError,  String? collectionLoadMoreError)?  $default,) {final _that = this;
switch (_that) {
case _UpPageState() when $default != null:
return $default(_that.profile,_that.videoFeed,_that.collectionFeed,_that.selectedTab,_that.isRefreshing,_that.profileError,_that.videoError,_that.collectionError,_that.videoLoadMoreError,_that.collectionLoadMoreError);case _:
  return null;

}
}

}

/// @nodoc


class _UpPageState extends UpPageState {
  const _UpPageState({this.profile, this.videoFeed = const PagedState<UpVideoItem>(), this.collectionFeed = const PagedState<UpCollection>(), this.selectedTab = UpPageTab.videos, this.isRefreshing = false, this.profileError, this.videoError, this.collectionError, this.videoLoadMoreError, this.collectionLoadMoreError}): super._();
  

@override final  UpProfile? profile;
@override@JsonKey() final  PagedState<UpVideoItem> videoFeed;
@override@JsonKey() final  PagedState<UpCollection> collectionFeed;
@override@JsonKey() final  UpPageTab selectedTab;
@override@JsonKey() final  bool isRefreshing;
@override final  String? profileError;
@override final  String? videoError;
@override final  String? collectionError;
@override final  String? videoLoadMoreError;
@override final  String? collectionLoadMoreError;

/// Create a copy of UpPageState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpPageStateCopyWith<_UpPageState> get copyWith => __$UpPageStateCopyWithImpl<_UpPageState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpPageState&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.videoFeed, videoFeed) || other.videoFeed == videoFeed)&&(identical(other.collectionFeed, collectionFeed) || other.collectionFeed == collectionFeed)&&(identical(other.selectedTab, selectedTab) || other.selectedTab == selectedTab)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.profileError, profileError) || other.profileError == profileError)&&(identical(other.videoError, videoError) || other.videoError == videoError)&&(identical(other.collectionError, collectionError) || other.collectionError == collectionError)&&(identical(other.videoLoadMoreError, videoLoadMoreError) || other.videoLoadMoreError == videoLoadMoreError)&&(identical(other.collectionLoadMoreError, collectionLoadMoreError) || other.collectionLoadMoreError == collectionLoadMoreError));
}


@override
int get hashCode => Object.hash(runtimeType,profile,videoFeed,collectionFeed,selectedTab,isRefreshing,profileError,videoError,collectionError,videoLoadMoreError,collectionLoadMoreError);

@override
String toString() {
  return 'UpPageState(profile: $profile, videoFeed: $videoFeed, collectionFeed: $collectionFeed, selectedTab: $selectedTab, isRefreshing: $isRefreshing, profileError: $profileError, videoError: $videoError, collectionError: $collectionError, videoLoadMoreError: $videoLoadMoreError, collectionLoadMoreError: $collectionLoadMoreError)';
}


}

/// @nodoc
abstract mixin class _$UpPageStateCopyWith<$Res> implements $UpPageStateCopyWith<$Res> {
  factory _$UpPageStateCopyWith(_UpPageState value, $Res Function(_UpPageState) _then) = __$UpPageStateCopyWithImpl;
@override @useResult
$Res call({
 UpProfile? profile, PagedState<UpVideoItem> videoFeed, PagedState<UpCollection> collectionFeed, UpPageTab selectedTab, bool isRefreshing, String? profileError, String? videoError, String? collectionError, String? videoLoadMoreError, String? collectionLoadMoreError
});


@override $UpProfileCopyWith<$Res>? get profile;

}
/// @nodoc
class __$UpPageStateCopyWithImpl<$Res>
    implements _$UpPageStateCopyWith<$Res> {
  __$UpPageStateCopyWithImpl(this._self, this._then);

  final _UpPageState _self;
  final $Res Function(_UpPageState) _then;

/// Create a copy of UpPageState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profile = freezed,Object? videoFeed = null,Object? collectionFeed = null,Object? selectedTab = null,Object? isRefreshing = null,Object? profileError = freezed,Object? videoError = freezed,Object? collectionError = freezed,Object? videoLoadMoreError = freezed,Object? collectionLoadMoreError = freezed,}) {
  return _then(_UpPageState(
profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UpProfile?,videoFeed: null == videoFeed ? _self.videoFeed : videoFeed // ignore: cast_nullable_to_non_nullable
as PagedState<UpVideoItem>,collectionFeed: null == collectionFeed ? _self.collectionFeed : collectionFeed // ignore: cast_nullable_to_non_nullable
as PagedState<UpCollection>,selectedTab: null == selectedTab ? _self.selectedTab : selectedTab // ignore: cast_nullable_to_non_nullable
as UpPageTab,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,profileError: freezed == profileError ? _self.profileError : profileError // ignore: cast_nullable_to_non_nullable
as String?,videoError: freezed == videoError ? _self.videoError : videoError // ignore: cast_nullable_to_non_nullable
as String?,collectionError: freezed == collectionError ? _self.collectionError : collectionError // ignore: cast_nullable_to_non_nullable
as String?,videoLoadMoreError: freezed == videoLoadMoreError ? _self.videoLoadMoreError : videoLoadMoreError // ignore: cast_nullable_to_non_nullable
as String?,collectionLoadMoreError: freezed == collectionLoadMoreError ? _self.collectionLoadMoreError : collectionLoadMoreError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of UpPageState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UpProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $UpProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}

// dart format on
