// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'metadata_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MetadataState {

 String? get stableId; Metadata? get metadata; String? get errorMessage; String? get searchKeyword; String? get manualSearchError; List<MetingSearchItem> get searchResults; bool get isSearching; bool get isLoading; bool get hasSearched;
/// Create a copy of MetadataState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MetadataStateCopyWith<MetadataState> get copyWith => _$MetadataStateCopyWithImpl<MetadataState>(this as MetadataState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MetadataState&&(identical(other.stableId, stableId) || other.stableId == stableId)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.searchKeyword, searchKeyword) || other.searchKeyword == searchKeyword)&&(identical(other.manualSearchError, manualSearchError) || other.manualSearchError == manualSearchError)&&const DeepCollectionEquality().equals(other.searchResults, searchResults)&&(identical(other.isSearching, isSearching) || other.isSearching == isSearching)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.hasSearched, hasSearched) || other.hasSearched == hasSearched));
}


@override
int get hashCode => Object.hash(runtimeType,stableId,metadata,errorMessage,searchKeyword,manualSearchError,const DeepCollectionEquality().hash(searchResults),isSearching,isLoading,hasSearched);

@override
String toString() {
  return 'MetadataState(stableId: $stableId, metadata: $metadata, errorMessage: $errorMessage, searchKeyword: $searchKeyword, manualSearchError: $manualSearchError, searchResults: $searchResults, isSearching: $isSearching, isLoading: $isLoading, hasSearched: $hasSearched)';
}


}

/// @nodoc
abstract mixin class $MetadataStateCopyWith<$Res>  {
  factory $MetadataStateCopyWith(MetadataState value, $Res Function(MetadataState) _then) = _$MetadataStateCopyWithImpl;
@useResult
$Res call({
 String? stableId, Metadata? metadata, String? errorMessage, String? searchKeyword, String? manualSearchError, List<MetingSearchItem> searchResults, bool isSearching, bool isLoading, bool hasSearched
});


$MetadataCopyWith<$Res>? get metadata;

}
/// @nodoc
class _$MetadataStateCopyWithImpl<$Res>
    implements $MetadataStateCopyWith<$Res> {
  _$MetadataStateCopyWithImpl(this._self, this._then);

  final MetadataState _self;
  final $Res Function(MetadataState) _then;

/// Create a copy of MetadataState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stableId = freezed,Object? metadata = freezed,Object? errorMessage = freezed,Object? searchKeyword = freezed,Object? manualSearchError = freezed,Object? searchResults = null,Object? isSearching = null,Object? isLoading = null,Object? hasSearched = null,}) {
  return _then(_self.copyWith(
stableId: freezed == stableId ? _self.stableId : stableId // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Metadata?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,searchKeyword: freezed == searchKeyword ? _self.searchKeyword : searchKeyword // ignore: cast_nullable_to_non_nullable
as String?,manualSearchError: freezed == manualSearchError ? _self.manualSearchError : manualSearchError // ignore: cast_nullable_to_non_nullable
as String?,searchResults: null == searchResults ? _self.searchResults : searchResults // ignore: cast_nullable_to_non_nullable
as List<MetingSearchItem>,isSearching: null == isSearching ? _self.isSearching : isSearching // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,hasSearched: null == hasSearched ? _self.hasSearched : hasSearched // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of MetadataState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MetadataCopyWith<$Res>? get metadata {
    if (_self.metadata == null) {
    return null;
  }

  return $MetadataCopyWith<$Res>(_self.metadata!, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}


/// Adds pattern-matching-related methods to [MetadataState].
extension MetadataStatePatterns on MetadataState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MetadataState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MetadataState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MetadataState value)  $default,){
final _that = this;
switch (_that) {
case _MetadataState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MetadataState value)?  $default,){
final _that = this;
switch (_that) {
case _MetadataState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? stableId,  Metadata? metadata,  String? errorMessage,  String? searchKeyword,  String? manualSearchError,  List<MetingSearchItem> searchResults,  bool isSearching,  bool isLoading,  bool hasSearched)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MetadataState() when $default != null:
return $default(_that.stableId,_that.metadata,_that.errorMessage,_that.searchKeyword,_that.manualSearchError,_that.searchResults,_that.isSearching,_that.isLoading,_that.hasSearched);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? stableId,  Metadata? metadata,  String? errorMessage,  String? searchKeyword,  String? manualSearchError,  List<MetingSearchItem> searchResults,  bool isSearching,  bool isLoading,  bool hasSearched)  $default,) {final _that = this;
switch (_that) {
case _MetadataState():
return $default(_that.stableId,_that.metadata,_that.errorMessage,_that.searchKeyword,_that.manualSearchError,_that.searchResults,_that.isSearching,_that.isLoading,_that.hasSearched);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? stableId,  Metadata? metadata,  String? errorMessage,  String? searchKeyword,  String? manualSearchError,  List<MetingSearchItem> searchResults,  bool isSearching,  bool isLoading,  bool hasSearched)?  $default,) {final _that = this;
switch (_that) {
case _MetadataState() when $default != null:
return $default(_that.stableId,_that.metadata,_that.errorMessage,_that.searchKeyword,_that.manualSearchError,_that.searchResults,_that.isSearching,_that.isLoading,_that.hasSearched);case _:
  return null;

}
}

}

/// @nodoc


class _MetadataState extends MetadataState {
  const _MetadataState({this.stableId, this.metadata, this.errorMessage, this.searchKeyword, this.manualSearchError, final  List<MetingSearchItem> searchResults = const <MetingSearchItem>[], this.isSearching = false, this.isLoading = false, this.hasSearched = false}): _searchResults = searchResults,super._();
  

@override final  String? stableId;
@override final  Metadata? metadata;
@override final  String? errorMessage;
@override final  String? searchKeyword;
@override final  String? manualSearchError;
 final  List<MetingSearchItem> _searchResults;
@override@JsonKey() List<MetingSearchItem> get searchResults {
  if (_searchResults is EqualUnmodifiableListView) return _searchResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_searchResults);
}

@override@JsonKey() final  bool isSearching;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool hasSearched;

/// Create a copy of MetadataState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MetadataStateCopyWith<_MetadataState> get copyWith => __$MetadataStateCopyWithImpl<_MetadataState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MetadataState&&(identical(other.stableId, stableId) || other.stableId == stableId)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.searchKeyword, searchKeyword) || other.searchKeyword == searchKeyword)&&(identical(other.manualSearchError, manualSearchError) || other.manualSearchError == manualSearchError)&&const DeepCollectionEquality().equals(other._searchResults, _searchResults)&&(identical(other.isSearching, isSearching) || other.isSearching == isSearching)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.hasSearched, hasSearched) || other.hasSearched == hasSearched));
}


@override
int get hashCode => Object.hash(runtimeType,stableId,metadata,errorMessage,searchKeyword,manualSearchError,const DeepCollectionEquality().hash(_searchResults),isSearching,isLoading,hasSearched);

@override
String toString() {
  return 'MetadataState(stableId: $stableId, metadata: $metadata, errorMessage: $errorMessage, searchKeyword: $searchKeyword, manualSearchError: $manualSearchError, searchResults: $searchResults, isSearching: $isSearching, isLoading: $isLoading, hasSearched: $hasSearched)';
}


}

/// @nodoc
abstract mixin class _$MetadataStateCopyWith<$Res> implements $MetadataStateCopyWith<$Res> {
  factory _$MetadataStateCopyWith(_MetadataState value, $Res Function(_MetadataState) _then) = __$MetadataStateCopyWithImpl;
@override @useResult
$Res call({
 String? stableId, Metadata? metadata, String? errorMessage, String? searchKeyword, String? manualSearchError, List<MetingSearchItem> searchResults, bool isSearching, bool isLoading, bool hasSearched
});


@override $MetadataCopyWith<$Res>? get metadata;

}
/// @nodoc
class __$MetadataStateCopyWithImpl<$Res>
    implements _$MetadataStateCopyWith<$Res> {
  __$MetadataStateCopyWithImpl(this._self, this._then);

  final _MetadataState _self;
  final $Res Function(_MetadataState) _then;

/// Create a copy of MetadataState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stableId = freezed,Object? metadata = freezed,Object? errorMessage = freezed,Object? searchKeyword = freezed,Object? manualSearchError = freezed,Object? searchResults = null,Object? isSearching = null,Object? isLoading = null,Object? hasSearched = null,}) {
  return _then(_MetadataState(
stableId: freezed == stableId ? _self.stableId : stableId // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Metadata?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,searchKeyword: freezed == searchKeyword ? _self.searchKeyword : searchKeyword // ignore: cast_nullable_to_non_nullable
as String?,manualSearchError: freezed == manualSearchError ? _self.manualSearchError : manualSearchError // ignore: cast_nullable_to_non_nullable
as String?,searchResults: null == searchResults ? _self._searchResults : searchResults // ignore: cast_nullable_to_non_nullable
as List<MetingSearchItem>,isSearching: null == isSearching ? _self.isSearching : isSearching // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,hasSearched: null == hasSearched ? _self.hasSearched : hasSearched // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of MetadataState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MetadataCopyWith<$Res>? get metadata {
    if (_self.metadata == null) {
    return null;
  }

  return $MetadataCopyWith<$Res>(_self.metadata!, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}

// dart format on
