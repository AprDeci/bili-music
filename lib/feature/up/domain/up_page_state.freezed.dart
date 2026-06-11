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

 UpProfile? get profile; List<UpVideoItem> get videos; int get videoPage; bool get hasMoreVideos; bool get isLoadingVideosMore; List<UpCollection> get collections; int get collectionPage; bool get hasMoreCollections; bool get isLoadingCollectionsMore; UpPageTab get selectedTab; bool get isRefreshing; String? get profileError; String? get videoError; String? get collectionError; String? get videoLoadMoreError; String? get collectionLoadMoreError;
/// Create a copy of UpPageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpPageStateCopyWith<UpPageState> get copyWith => _$UpPageStateCopyWithImpl<UpPageState>(this as UpPageState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpPageState&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other.videos, videos)&&(identical(other.videoPage, videoPage) || other.videoPage == videoPage)&&(identical(other.hasMoreVideos, hasMoreVideos) || other.hasMoreVideos == hasMoreVideos)&&(identical(other.isLoadingVideosMore, isLoadingVideosMore) || other.isLoadingVideosMore == isLoadingVideosMore)&&const DeepCollectionEquality().equals(other.collections, collections)&&(identical(other.collectionPage, collectionPage) || other.collectionPage == collectionPage)&&(identical(other.hasMoreCollections, hasMoreCollections) || other.hasMoreCollections == hasMoreCollections)&&(identical(other.isLoadingCollectionsMore, isLoadingCollectionsMore) || other.isLoadingCollectionsMore == isLoadingCollectionsMore)&&(identical(other.selectedTab, selectedTab) || other.selectedTab == selectedTab)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.profileError, profileError) || other.profileError == profileError)&&(identical(other.videoError, videoError) || other.videoError == videoError)&&(identical(other.collectionError, collectionError) || other.collectionError == collectionError)&&(identical(other.videoLoadMoreError, videoLoadMoreError) || other.videoLoadMoreError == videoLoadMoreError)&&(identical(other.collectionLoadMoreError, collectionLoadMoreError) || other.collectionLoadMoreError == collectionLoadMoreError));
}


@override
int get hashCode => Object.hash(runtimeType,profile,const DeepCollectionEquality().hash(videos),videoPage,hasMoreVideos,isLoadingVideosMore,const DeepCollectionEquality().hash(collections),collectionPage,hasMoreCollections,isLoadingCollectionsMore,selectedTab,isRefreshing,profileError,videoError,collectionError,videoLoadMoreError,collectionLoadMoreError);

@override
String toString() {
  return 'UpPageState(profile: $profile, videos: $videos, videoPage: $videoPage, hasMoreVideos: $hasMoreVideos, isLoadingVideosMore: $isLoadingVideosMore, collections: $collections, collectionPage: $collectionPage, hasMoreCollections: $hasMoreCollections, isLoadingCollectionsMore: $isLoadingCollectionsMore, selectedTab: $selectedTab, isRefreshing: $isRefreshing, profileError: $profileError, videoError: $videoError, collectionError: $collectionError, videoLoadMoreError: $videoLoadMoreError, collectionLoadMoreError: $collectionLoadMoreError)';
}


}

/// @nodoc
abstract mixin class $UpPageStateCopyWith<$Res>  {
  factory $UpPageStateCopyWith(UpPageState value, $Res Function(UpPageState) _then) = _$UpPageStateCopyWithImpl;
@useResult
$Res call({
 UpProfile? profile, List<UpVideoItem> videos, int videoPage, bool hasMoreVideos, bool isLoadingVideosMore, List<UpCollection> collections, int collectionPage, bool hasMoreCollections, bool isLoadingCollectionsMore, UpPageTab selectedTab, bool isRefreshing, String? profileError, String? videoError, String? collectionError, String? videoLoadMoreError, String? collectionLoadMoreError
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
@pragma('vm:prefer-inline') @override $Res call({Object? profile = freezed,Object? videos = null,Object? videoPage = null,Object? hasMoreVideos = null,Object? isLoadingVideosMore = null,Object? collections = null,Object? collectionPage = null,Object? hasMoreCollections = null,Object? isLoadingCollectionsMore = null,Object? selectedTab = null,Object? isRefreshing = null,Object? profileError = freezed,Object? videoError = freezed,Object? collectionError = freezed,Object? videoLoadMoreError = freezed,Object? collectionLoadMoreError = freezed,}) {
  return _then(_self.copyWith(
profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UpProfile?,videos: null == videos ? _self.videos : videos // ignore: cast_nullable_to_non_nullable
as List<UpVideoItem>,videoPage: null == videoPage ? _self.videoPage : videoPage // ignore: cast_nullable_to_non_nullable
as int,hasMoreVideos: null == hasMoreVideos ? _self.hasMoreVideos : hasMoreVideos // ignore: cast_nullable_to_non_nullable
as bool,isLoadingVideosMore: null == isLoadingVideosMore ? _self.isLoadingVideosMore : isLoadingVideosMore // ignore: cast_nullable_to_non_nullable
as bool,collections: null == collections ? _self.collections : collections // ignore: cast_nullable_to_non_nullable
as List<UpCollection>,collectionPage: null == collectionPage ? _self.collectionPage : collectionPage // ignore: cast_nullable_to_non_nullable
as int,hasMoreCollections: null == hasMoreCollections ? _self.hasMoreCollections : hasMoreCollections // ignore: cast_nullable_to_non_nullable
as bool,isLoadingCollectionsMore: null == isLoadingCollectionsMore ? _self.isLoadingCollectionsMore : isLoadingCollectionsMore // ignore: cast_nullable_to_non_nullable
as bool,selectedTab: null == selectedTab ? _self.selectedTab : selectedTab // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UpProfile? profile,  List<UpVideoItem> videos,  int videoPage,  bool hasMoreVideos,  bool isLoadingVideosMore,  List<UpCollection> collections,  int collectionPage,  bool hasMoreCollections,  bool isLoadingCollectionsMore,  UpPageTab selectedTab,  bool isRefreshing,  String? profileError,  String? videoError,  String? collectionError,  String? videoLoadMoreError,  String? collectionLoadMoreError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpPageState() when $default != null:
return $default(_that.profile,_that.videos,_that.videoPage,_that.hasMoreVideos,_that.isLoadingVideosMore,_that.collections,_that.collectionPage,_that.hasMoreCollections,_that.isLoadingCollectionsMore,_that.selectedTab,_that.isRefreshing,_that.profileError,_that.videoError,_that.collectionError,_that.videoLoadMoreError,_that.collectionLoadMoreError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UpProfile? profile,  List<UpVideoItem> videos,  int videoPage,  bool hasMoreVideos,  bool isLoadingVideosMore,  List<UpCollection> collections,  int collectionPage,  bool hasMoreCollections,  bool isLoadingCollectionsMore,  UpPageTab selectedTab,  bool isRefreshing,  String? profileError,  String? videoError,  String? collectionError,  String? videoLoadMoreError,  String? collectionLoadMoreError)  $default,) {final _that = this;
switch (_that) {
case _UpPageState():
return $default(_that.profile,_that.videos,_that.videoPage,_that.hasMoreVideos,_that.isLoadingVideosMore,_that.collections,_that.collectionPage,_that.hasMoreCollections,_that.isLoadingCollectionsMore,_that.selectedTab,_that.isRefreshing,_that.profileError,_that.videoError,_that.collectionError,_that.videoLoadMoreError,_that.collectionLoadMoreError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UpProfile? profile,  List<UpVideoItem> videos,  int videoPage,  bool hasMoreVideos,  bool isLoadingVideosMore,  List<UpCollection> collections,  int collectionPage,  bool hasMoreCollections,  bool isLoadingCollectionsMore,  UpPageTab selectedTab,  bool isRefreshing,  String? profileError,  String? videoError,  String? collectionError,  String? videoLoadMoreError,  String? collectionLoadMoreError)?  $default,) {final _that = this;
switch (_that) {
case _UpPageState() when $default != null:
return $default(_that.profile,_that.videos,_that.videoPage,_that.hasMoreVideos,_that.isLoadingVideosMore,_that.collections,_that.collectionPage,_that.hasMoreCollections,_that.isLoadingCollectionsMore,_that.selectedTab,_that.isRefreshing,_that.profileError,_that.videoError,_that.collectionError,_that.videoLoadMoreError,_that.collectionLoadMoreError);case _:
  return null;

}
}

}

/// @nodoc


class _UpPageState implements UpPageState {
  const _UpPageState({this.profile, final  List<UpVideoItem> videos = const <UpVideoItem>[], this.videoPage = 0, this.hasMoreVideos = false, this.isLoadingVideosMore = false, final  List<UpCollection> collections = const <UpCollection>[], this.collectionPage = 0, this.hasMoreCollections = false, this.isLoadingCollectionsMore = false, this.selectedTab = UpPageTab.videos, this.isRefreshing = false, this.profileError, this.videoError, this.collectionError, this.videoLoadMoreError, this.collectionLoadMoreError}): _videos = videos,_collections = collections;
  

@override final  UpProfile? profile;
 final  List<UpVideoItem> _videos;
@override@JsonKey() List<UpVideoItem> get videos {
  if (_videos is EqualUnmodifiableListView) return _videos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_videos);
}

@override@JsonKey() final  int videoPage;
@override@JsonKey() final  bool hasMoreVideos;
@override@JsonKey() final  bool isLoadingVideosMore;
 final  List<UpCollection> _collections;
@override@JsonKey() List<UpCollection> get collections {
  if (_collections is EqualUnmodifiableListView) return _collections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_collections);
}

@override@JsonKey() final  int collectionPage;
@override@JsonKey() final  bool hasMoreCollections;
@override@JsonKey() final  bool isLoadingCollectionsMore;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpPageState&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other._videos, _videos)&&(identical(other.videoPage, videoPage) || other.videoPage == videoPage)&&(identical(other.hasMoreVideos, hasMoreVideos) || other.hasMoreVideos == hasMoreVideos)&&(identical(other.isLoadingVideosMore, isLoadingVideosMore) || other.isLoadingVideosMore == isLoadingVideosMore)&&const DeepCollectionEquality().equals(other._collections, _collections)&&(identical(other.collectionPage, collectionPage) || other.collectionPage == collectionPage)&&(identical(other.hasMoreCollections, hasMoreCollections) || other.hasMoreCollections == hasMoreCollections)&&(identical(other.isLoadingCollectionsMore, isLoadingCollectionsMore) || other.isLoadingCollectionsMore == isLoadingCollectionsMore)&&(identical(other.selectedTab, selectedTab) || other.selectedTab == selectedTab)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.profileError, profileError) || other.profileError == profileError)&&(identical(other.videoError, videoError) || other.videoError == videoError)&&(identical(other.collectionError, collectionError) || other.collectionError == collectionError)&&(identical(other.videoLoadMoreError, videoLoadMoreError) || other.videoLoadMoreError == videoLoadMoreError)&&(identical(other.collectionLoadMoreError, collectionLoadMoreError) || other.collectionLoadMoreError == collectionLoadMoreError));
}


@override
int get hashCode => Object.hash(runtimeType,profile,const DeepCollectionEquality().hash(_videos),videoPage,hasMoreVideos,isLoadingVideosMore,const DeepCollectionEquality().hash(_collections),collectionPage,hasMoreCollections,isLoadingCollectionsMore,selectedTab,isRefreshing,profileError,videoError,collectionError,videoLoadMoreError,collectionLoadMoreError);

@override
String toString() {
  return 'UpPageState(profile: $profile, videos: $videos, videoPage: $videoPage, hasMoreVideos: $hasMoreVideos, isLoadingVideosMore: $isLoadingVideosMore, collections: $collections, collectionPage: $collectionPage, hasMoreCollections: $hasMoreCollections, isLoadingCollectionsMore: $isLoadingCollectionsMore, selectedTab: $selectedTab, isRefreshing: $isRefreshing, profileError: $profileError, videoError: $videoError, collectionError: $collectionError, videoLoadMoreError: $videoLoadMoreError, collectionLoadMoreError: $collectionLoadMoreError)';
}


}

/// @nodoc
abstract mixin class _$UpPageStateCopyWith<$Res> implements $UpPageStateCopyWith<$Res> {
  factory _$UpPageStateCopyWith(_UpPageState value, $Res Function(_UpPageState) _then) = __$UpPageStateCopyWithImpl;
@override @useResult
$Res call({
 UpProfile? profile, List<UpVideoItem> videos, int videoPage, bool hasMoreVideos, bool isLoadingVideosMore, List<UpCollection> collections, int collectionPage, bool hasMoreCollections, bool isLoadingCollectionsMore, UpPageTab selectedTab, bool isRefreshing, String? profileError, String? videoError, String? collectionError, String? videoLoadMoreError, String? collectionLoadMoreError
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
@override @pragma('vm:prefer-inline') $Res call({Object? profile = freezed,Object? videos = null,Object? videoPage = null,Object? hasMoreVideos = null,Object? isLoadingVideosMore = null,Object? collections = null,Object? collectionPage = null,Object? hasMoreCollections = null,Object? isLoadingCollectionsMore = null,Object? selectedTab = null,Object? isRefreshing = null,Object? profileError = freezed,Object? videoError = freezed,Object? collectionError = freezed,Object? videoLoadMoreError = freezed,Object? collectionLoadMoreError = freezed,}) {
  return _then(_UpPageState(
profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UpProfile?,videos: null == videos ? _self._videos : videos // ignore: cast_nullable_to_non_nullable
as List<UpVideoItem>,videoPage: null == videoPage ? _self.videoPage : videoPage // ignore: cast_nullable_to_non_nullable
as int,hasMoreVideos: null == hasMoreVideos ? _self.hasMoreVideos : hasMoreVideos // ignore: cast_nullable_to_non_nullable
as bool,isLoadingVideosMore: null == isLoadingVideosMore ? _self.isLoadingVideosMore : isLoadingVideosMore // ignore: cast_nullable_to_non_nullable
as bool,collections: null == collections ? _self._collections : collections // ignore: cast_nullable_to_non_nullable
as List<UpCollection>,collectionPage: null == collectionPage ? _self.collectionPage : collectionPage // ignore: cast_nullable_to_non_nullable
as int,hasMoreCollections: null == hasMoreCollections ? _self.hasMoreCollections : hasMoreCollections // ignore: cast_nullable_to_non_nullable
as bool,isLoadingCollectionsMore: null == isLoadingCollectionsMore ? _self.isLoadingCollectionsMore : isLoadingCollectionsMore // ignore: cast_nullable_to_non_nullable
as bool,selectedTab: null == selectedTab ? _self.selectedTab : selectedTab // ignore: cast_nullable_to_non_nullable
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
