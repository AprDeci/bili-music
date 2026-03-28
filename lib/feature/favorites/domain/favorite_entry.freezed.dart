// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorite_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FavoriteEntry {

 String get itemId; int get aid; String get bvid; String get title; String get author; String get coverUrl; int? get cid; int? get page; String? get pageTitle; String? get durationText; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of FavoriteEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoriteEntryCopyWith<FavoriteEntry> get copyWith => _$FavoriteEntryCopyWithImpl<FavoriteEntry>(this as FavoriteEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoriteEntry&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.aid, aid) || other.aid == aid)&&(identical(other.bvid, bvid) || other.bvid == bvid)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageTitle, pageTitle) || other.pageTitle == pageTitle)&&(identical(other.durationText, durationText) || other.durationText == durationText)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,itemId,aid,bvid,title,author,coverUrl,cid,page,pageTitle,durationText,createdAt,updatedAt);

@override
String toString() {
  return 'FavoriteEntry(itemId: $itemId, aid: $aid, bvid: $bvid, title: $title, author: $author, coverUrl: $coverUrl, cid: $cid, page: $page, pageTitle: $pageTitle, durationText: $durationText, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FavoriteEntryCopyWith<$Res>  {
  factory $FavoriteEntryCopyWith(FavoriteEntry value, $Res Function(FavoriteEntry) _then) = _$FavoriteEntryCopyWithImpl;
@useResult
$Res call({
 String itemId, int aid, String bvid, String title, String author, String coverUrl, int? cid, int? page, String? pageTitle, String? durationText, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$FavoriteEntryCopyWithImpl<$Res>
    implements $FavoriteEntryCopyWith<$Res> {
  _$FavoriteEntryCopyWithImpl(this._self, this._then);

  final FavoriteEntry _self;
  final $Res Function(FavoriteEntry) _then;

/// Create a copy of FavoriteEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? itemId = null,Object? aid = null,Object? bvid = null,Object? title = null,Object? author = null,Object? coverUrl = null,Object? cid = freezed,Object? page = freezed,Object? pageTitle = freezed,Object? durationText = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,aid: null == aid ? _self.aid : aid // ignore: cast_nullable_to_non_nullable
as int,bvid: null == bvid ? _self.bvid : bvid // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,cid: freezed == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as int?,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,pageTitle: freezed == pageTitle ? _self.pageTitle : pageTitle // ignore: cast_nullable_to_non_nullable
as String?,durationText: freezed == durationText ? _self.durationText : durationText // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FavoriteEntry].
extension FavoriteEntryPatterns on FavoriteEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavoriteEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavoriteEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavoriteEntry value)  $default,){
final _that = this;
switch (_that) {
case _FavoriteEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavoriteEntry value)?  $default,){
final _that = this;
switch (_that) {
case _FavoriteEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String itemId,  int aid,  String bvid,  String title,  String author,  String coverUrl,  int? cid,  int? page,  String? pageTitle,  String? durationText,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavoriteEntry() when $default != null:
return $default(_that.itemId,_that.aid,_that.bvid,_that.title,_that.author,_that.coverUrl,_that.cid,_that.page,_that.pageTitle,_that.durationText,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String itemId,  int aid,  String bvid,  String title,  String author,  String coverUrl,  int? cid,  int? page,  String? pageTitle,  String? durationText,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FavoriteEntry():
return $default(_that.itemId,_that.aid,_that.bvid,_that.title,_that.author,_that.coverUrl,_that.cid,_that.page,_that.pageTitle,_that.durationText,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String itemId,  int aid,  String bvid,  String title,  String author,  String coverUrl,  int? cid,  int? page,  String? pageTitle,  String? durationText,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FavoriteEntry() when $default != null:
return $default(_that.itemId,_that.aid,_that.bvid,_that.title,_that.author,_that.coverUrl,_that.cid,_that.page,_that.pageTitle,_that.durationText,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _FavoriteEntry extends FavoriteEntry {
  const _FavoriteEntry({required this.itemId, required this.aid, required this.bvid, required this.title, required this.author, required this.coverUrl, this.cid, this.page, this.pageTitle, this.durationText, required this.createdAt, required this.updatedAt}): super._();
  

@override final  String itemId;
@override final  int aid;
@override final  String bvid;
@override final  String title;
@override final  String author;
@override final  String coverUrl;
@override final  int? cid;
@override final  int? page;
@override final  String? pageTitle;
@override final  String? durationText;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of FavoriteEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoriteEntryCopyWith<_FavoriteEntry> get copyWith => __$FavoriteEntryCopyWithImpl<_FavoriteEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavoriteEntry&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.aid, aid) || other.aid == aid)&&(identical(other.bvid, bvid) || other.bvid == bvid)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageTitle, pageTitle) || other.pageTitle == pageTitle)&&(identical(other.durationText, durationText) || other.durationText == durationText)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,itemId,aid,bvid,title,author,coverUrl,cid,page,pageTitle,durationText,createdAt,updatedAt);

@override
String toString() {
  return 'FavoriteEntry(itemId: $itemId, aid: $aid, bvid: $bvid, title: $title, author: $author, coverUrl: $coverUrl, cid: $cid, page: $page, pageTitle: $pageTitle, durationText: $durationText, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FavoriteEntryCopyWith<$Res> implements $FavoriteEntryCopyWith<$Res> {
  factory _$FavoriteEntryCopyWith(_FavoriteEntry value, $Res Function(_FavoriteEntry) _then) = __$FavoriteEntryCopyWithImpl;
@override @useResult
$Res call({
 String itemId, int aid, String bvid, String title, String author, String coverUrl, int? cid, int? page, String? pageTitle, String? durationText, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$FavoriteEntryCopyWithImpl<$Res>
    implements _$FavoriteEntryCopyWith<$Res> {
  __$FavoriteEntryCopyWithImpl(this._self, this._then);

  final _FavoriteEntry _self;
  final $Res Function(_FavoriteEntry) _then;

/// Create a copy of FavoriteEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itemId = null,Object? aid = null,Object? bvid = null,Object? title = null,Object? author = null,Object? coverUrl = null,Object? cid = freezed,Object? page = freezed,Object? pageTitle = freezed,Object? durationText = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_FavoriteEntry(
itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,aid: null == aid ? _self.aid : aid // ignore: cast_nullable_to_non_nullable
as int,bvid: null == bvid ? _self.bvid : bvid // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,cid: freezed == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as int?,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,pageTitle: freezed == pageTitle ? _self.pageTitle : pageTitle // ignore: cast_nullable_to_non_nullable
as String?,durationText: freezed == durationText ? _self.durationText : durationText // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
