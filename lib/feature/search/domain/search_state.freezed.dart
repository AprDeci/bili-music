// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchState {

 String get query; String? get submittedQuery; List<String> get recentKeywords; List<SearchResultItem> get results; bool get isLoading; bool get isLoadingMore; int get currentPage; bool get hasMore; String? get errorMessage; String? get loadMoreErrorMessage;
/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchStateCopyWith<SearchState> get copyWith => _$SearchStateCopyWithImpl<SearchState>(this as SearchState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchState&&(identical(other.query, query) || other.query == query)&&(identical(other.submittedQuery, submittedQuery) || other.submittedQuery == submittedQuery)&&const DeepCollectionEquality().equals(other.recentKeywords, recentKeywords)&&const DeepCollectionEquality().equals(other.results, results)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.loadMoreErrorMessage, loadMoreErrorMessage) || other.loadMoreErrorMessage == loadMoreErrorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,query,submittedQuery,const DeepCollectionEquality().hash(recentKeywords),const DeepCollectionEquality().hash(results),isLoading,isLoadingMore,currentPage,hasMore,errorMessage,loadMoreErrorMessage);

@override
String toString() {
  return 'SearchState(query: $query, submittedQuery: $submittedQuery, recentKeywords: $recentKeywords, results: $results, isLoading: $isLoading, isLoadingMore: $isLoadingMore, currentPage: $currentPage, hasMore: $hasMore, errorMessage: $errorMessage, loadMoreErrorMessage: $loadMoreErrorMessage)';
}


}

/// @nodoc
abstract mixin class $SearchStateCopyWith<$Res>  {
  factory $SearchStateCopyWith(SearchState value, $Res Function(SearchState) _then) = _$SearchStateCopyWithImpl;
@useResult
$Res call({
 String query, String? submittedQuery, List<String> recentKeywords, List<SearchResultItem> results, bool isLoading, bool isLoadingMore, int currentPage, bool hasMore, String? errorMessage, String? loadMoreErrorMessage
});




}
/// @nodoc
class _$SearchStateCopyWithImpl<$Res>
    implements $SearchStateCopyWith<$Res> {
  _$SearchStateCopyWithImpl(this._self, this._then);

  final SearchState _self;
  final $Res Function(SearchState) _then;

/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? submittedQuery = freezed,Object? recentKeywords = null,Object? results = null,Object? isLoading = null,Object? isLoadingMore = null,Object? currentPage = null,Object? hasMore = null,Object? errorMessage = freezed,Object? loadMoreErrorMessage = freezed,}) {
  return _then(_self.copyWith(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,submittedQuery: freezed == submittedQuery ? _self.submittedQuery : submittedQuery // ignore: cast_nullable_to_non_nullable
as String?,recentKeywords: null == recentKeywords ? _self.recentKeywords : recentKeywords // ignore: cast_nullable_to_non_nullable
as List<String>,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<SearchResultItem>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,loadMoreErrorMessage: freezed == loadMoreErrorMessage ? _self.loadMoreErrorMessage : loadMoreErrorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchState].
extension SearchStatePatterns on SearchState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchState value)  $default,){
final _that = this;
switch (_that) {
case _SearchState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchState value)?  $default,){
final _that = this;
switch (_that) {
case _SearchState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query,  String? submittedQuery,  List<String> recentKeywords,  List<SearchResultItem> results,  bool isLoading,  bool isLoadingMore,  int currentPage,  bool hasMore,  String? errorMessage,  String? loadMoreErrorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchState() when $default != null:
return $default(_that.query,_that.submittedQuery,_that.recentKeywords,_that.results,_that.isLoading,_that.isLoadingMore,_that.currentPage,_that.hasMore,_that.errorMessage,_that.loadMoreErrorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query,  String? submittedQuery,  List<String> recentKeywords,  List<SearchResultItem> results,  bool isLoading,  bool isLoadingMore,  int currentPage,  bool hasMore,  String? errorMessage,  String? loadMoreErrorMessage)  $default,) {final _that = this;
switch (_that) {
case _SearchState():
return $default(_that.query,_that.submittedQuery,_that.recentKeywords,_that.results,_that.isLoading,_that.isLoadingMore,_that.currentPage,_that.hasMore,_that.errorMessage,_that.loadMoreErrorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query,  String? submittedQuery,  List<String> recentKeywords,  List<SearchResultItem> results,  bool isLoading,  bool isLoadingMore,  int currentPage,  bool hasMore,  String? errorMessage,  String? loadMoreErrorMessage)?  $default,) {final _that = this;
switch (_that) {
case _SearchState() when $default != null:
return $default(_that.query,_that.submittedQuery,_that.recentKeywords,_that.results,_that.isLoading,_that.isLoadingMore,_that.currentPage,_that.hasMore,_that.errorMessage,_that.loadMoreErrorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _SearchState implements SearchState {
  const _SearchState({this.query = '', this.submittedQuery, final  List<String> recentKeywords = const <String>[], final  List<SearchResultItem> results = const <SearchResultItem>[], this.isLoading = false, this.isLoadingMore = false, this.currentPage = 0, this.hasMore = false, this.errorMessage, this.loadMoreErrorMessage}): _recentKeywords = recentKeywords,_results = results;
  

@override@JsonKey() final  String query;
@override final  String? submittedQuery;
 final  List<String> _recentKeywords;
@override@JsonKey() List<String> get recentKeywords {
  if (_recentKeywords is EqualUnmodifiableListView) return _recentKeywords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentKeywords);
}

 final  List<SearchResultItem> _results;
@override@JsonKey() List<SearchResultItem> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isLoadingMore;
@override@JsonKey() final  int currentPage;
@override@JsonKey() final  bool hasMore;
@override final  String? errorMessage;
@override final  String? loadMoreErrorMessage;

/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchStateCopyWith<_SearchState> get copyWith => __$SearchStateCopyWithImpl<_SearchState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchState&&(identical(other.query, query) || other.query == query)&&(identical(other.submittedQuery, submittedQuery) || other.submittedQuery == submittedQuery)&&const DeepCollectionEquality().equals(other._recentKeywords, _recentKeywords)&&const DeepCollectionEquality().equals(other._results, _results)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.loadMoreErrorMessage, loadMoreErrorMessage) || other.loadMoreErrorMessage == loadMoreErrorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,query,submittedQuery,const DeepCollectionEquality().hash(_recentKeywords),const DeepCollectionEquality().hash(_results),isLoading,isLoadingMore,currentPage,hasMore,errorMessage,loadMoreErrorMessage);

@override
String toString() {
  return 'SearchState(query: $query, submittedQuery: $submittedQuery, recentKeywords: $recentKeywords, results: $results, isLoading: $isLoading, isLoadingMore: $isLoadingMore, currentPage: $currentPage, hasMore: $hasMore, errorMessage: $errorMessage, loadMoreErrorMessage: $loadMoreErrorMessage)';
}


}

/// @nodoc
abstract mixin class _$SearchStateCopyWith<$Res> implements $SearchStateCopyWith<$Res> {
  factory _$SearchStateCopyWith(_SearchState value, $Res Function(_SearchState) _then) = __$SearchStateCopyWithImpl;
@override @useResult
$Res call({
 String query, String? submittedQuery, List<String> recentKeywords, List<SearchResultItem> results, bool isLoading, bool isLoadingMore, int currentPage, bool hasMore, String? errorMessage, String? loadMoreErrorMessage
});




}
/// @nodoc
class __$SearchStateCopyWithImpl<$Res>
    implements _$SearchStateCopyWith<$Res> {
  __$SearchStateCopyWithImpl(this._self, this._then);

  final _SearchState _self;
  final $Res Function(_SearchState) _then;

/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? submittedQuery = freezed,Object? recentKeywords = null,Object? results = null,Object? isLoading = null,Object? isLoadingMore = null,Object? currentPage = null,Object? hasMore = null,Object? errorMessage = freezed,Object? loadMoreErrorMessage = freezed,}) {
  return _then(_SearchState(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,submittedQuery: freezed == submittedQuery ? _self.submittedQuery : submittedQuery // ignore: cast_nullable_to_non_nullable
as String?,recentKeywords: null == recentKeywords ? _self._recentKeywords : recentKeywords // ignore: cast_nullable_to_non_nullable
as List<String>,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<SearchResultItem>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,loadMoreErrorMessage: freezed == loadMoreErrorMessage ? _self.loadMoreErrorMessage : loadMoreErrorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
