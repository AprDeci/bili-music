// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download_task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DownloadTask {

 PlayableItem get item; DownloadTaskStatus get status; int get receivedBytes; int get totalBytes; String? get errorMessage;
/// Create a copy of DownloadTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadTaskCopyWith<DownloadTask> get copyWith => _$DownloadTaskCopyWithImpl<DownloadTask>(this as DownloadTask, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadTask&&(identical(other.item, item) || other.item == item)&&(identical(other.status, status) || other.status == status)&&(identical(other.receivedBytes, receivedBytes) || other.receivedBytes == receivedBytes)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,item,status,receivedBytes,totalBytes,errorMessage);

@override
String toString() {
  return 'DownloadTask(item: $item, status: $status, receivedBytes: $receivedBytes, totalBytes: $totalBytes, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $DownloadTaskCopyWith<$Res>  {
  factory $DownloadTaskCopyWith(DownloadTask value, $Res Function(DownloadTask) _then) = _$DownloadTaskCopyWithImpl;
@useResult
$Res call({
 PlayableItem item, DownloadTaskStatus status, int receivedBytes, int totalBytes, String? errorMessage
});


$PlayableItemCopyWith<$Res> get item;

}
/// @nodoc
class _$DownloadTaskCopyWithImpl<$Res>
    implements $DownloadTaskCopyWith<$Res> {
  _$DownloadTaskCopyWithImpl(this._self, this._then);

  final DownloadTask _self;
  final $Res Function(DownloadTask) _then;

/// Create a copy of DownloadTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? item = null,Object? status = null,Object? receivedBytes = null,Object? totalBytes = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as PlayableItem,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DownloadTaskStatus,receivedBytes: null == receivedBytes ? _self.receivedBytes : receivedBytes // ignore: cast_nullable_to_non_nullable
as int,totalBytes: null == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of DownloadTask
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayableItemCopyWith<$Res> get item {
  
  return $PlayableItemCopyWith<$Res>(_self.item, (value) {
    return _then(_self.copyWith(item: value));
  });
}
}


/// Adds pattern-matching-related methods to [DownloadTask].
extension DownloadTaskPatterns on DownloadTask {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DownloadTask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DownloadTask() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DownloadTask value)  $default,){
final _that = this;
switch (_that) {
case _DownloadTask():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DownloadTask value)?  $default,){
final _that = this;
switch (_that) {
case _DownloadTask() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PlayableItem item,  DownloadTaskStatus status,  int receivedBytes,  int totalBytes,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DownloadTask() when $default != null:
return $default(_that.item,_that.status,_that.receivedBytes,_that.totalBytes,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PlayableItem item,  DownloadTaskStatus status,  int receivedBytes,  int totalBytes,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _DownloadTask():
return $default(_that.item,_that.status,_that.receivedBytes,_that.totalBytes,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PlayableItem item,  DownloadTaskStatus status,  int receivedBytes,  int totalBytes,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _DownloadTask() when $default != null:
return $default(_that.item,_that.status,_that.receivedBytes,_that.totalBytes,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _DownloadTask extends DownloadTask {
  const _DownloadTask({required this.item, this.status = DownloadTaskStatus.queued, this.receivedBytes = 0, this.totalBytes = 0, this.errorMessage}): super._();
  

@override final  PlayableItem item;
@override@JsonKey() final  DownloadTaskStatus status;
@override@JsonKey() final  int receivedBytes;
@override@JsonKey() final  int totalBytes;
@override final  String? errorMessage;

/// Create a copy of DownloadTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DownloadTaskCopyWith<_DownloadTask> get copyWith => __$DownloadTaskCopyWithImpl<_DownloadTask>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DownloadTask&&(identical(other.item, item) || other.item == item)&&(identical(other.status, status) || other.status == status)&&(identical(other.receivedBytes, receivedBytes) || other.receivedBytes == receivedBytes)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,item,status,receivedBytes,totalBytes,errorMessage);

@override
String toString() {
  return 'DownloadTask(item: $item, status: $status, receivedBytes: $receivedBytes, totalBytes: $totalBytes, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$DownloadTaskCopyWith<$Res> implements $DownloadTaskCopyWith<$Res> {
  factory _$DownloadTaskCopyWith(_DownloadTask value, $Res Function(_DownloadTask) _then) = __$DownloadTaskCopyWithImpl;
@override @useResult
$Res call({
 PlayableItem item, DownloadTaskStatus status, int receivedBytes, int totalBytes, String? errorMessage
});


@override $PlayableItemCopyWith<$Res> get item;

}
/// @nodoc
class __$DownloadTaskCopyWithImpl<$Res>
    implements _$DownloadTaskCopyWith<$Res> {
  __$DownloadTaskCopyWithImpl(this._self, this._then);

  final _DownloadTask _self;
  final $Res Function(_DownloadTask) _then;

/// Create a copy of DownloadTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? item = null,Object? status = null,Object? receivedBytes = null,Object? totalBytes = null,Object? errorMessage = freezed,}) {
  return _then(_DownloadTask(
item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as PlayableItem,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DownloadTaskStatus,receivedBytes: null == receivedBytes ? _self.receivedBytes : receivedBytes // ignore: cast_nullable_to_non_nullable
as int,totalBytes: null == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of DownloadTask
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayableItemCopyWith<$Res> get item {
  
  return $PlayableItemCopyWith<$Res>(_self.item, (value) {
    return _then(_self.copyWith(item: value));
  });
}
}

// dart format on
