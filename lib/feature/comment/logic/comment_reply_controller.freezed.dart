// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment_reply_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CommentReplySheetArgs {

 CommentTarget get target; CommentItem get rootItem;
/// Create a copy of CommentReplySheetArgs
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentReplySheetArgsCopyWith<CommentReplySheetArgs> get copyWith => _$CommentReplySheetArgsCopyWithImpl<CommentReplySheetArgs>(this as CommentReplySheetArgs, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentReplySheetArgs&&(identical(other.target, target) || other.target == target)&&(identical(other.rootItem, rootItem) || other.rootItem == rootItem));
}


@override
int get hashCode => Object.hash(runtimeType,target,rootItem);

@override
String toString() {
  return 'CommentReplySheetArgs(target: $target, rootItem: $rootItem)';
}


}

/// @nodoc
abstract mixin class $CommentReplySheetArgsCopyWith<$Res>  {
  factory $CommentReplySheetArgsCopyWith(CommentReplySheetArgs value, $Res Function(CommentReplySheetArgs) _then) = _$CommentReplySheetArgsCopyWithImpl;
@useResult
$Res call({
 CommentTarget target, CommentItem rootItem
});


$CommentTargetCopyWith<$Res> get target;$CommentItemCopyWith<$Res> get rootItem;

}
/// @nodoc
class _$CommentReplySheetArgsCopyWithImpl<$Res>
    implements $CommentReplySheetArgsCopyWith<$Res> {
  _$CommentReplySheetArgsCopyWithImpl(this._self, this._then);

  final CommentReplySheetArgs _self;
  final $Res Function(CommentReplySheetArgs) _then;

/// Create a copy of CommentReplySheetArgs
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? target = null,Object? rootItem = null,}) {
  return _then(_self.copyWith(
target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as CommentTarget,rootItem: null == rootItem ? _self.rootItem : rootItem // ignore: cast_nullable_to_non_nullable
as CommentItem,
  ));
}
/// Create a copy of CommentReplySheetArgs
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentTargetCopyWith<$Res> get target {
  
  return $CommentTargetCopyWith<$Res>(_self.target, (value) {
    return _then(_self.copyWith(target: value));
  });
}/// Create a copy of CommentReplySheetArgs
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentItemCopyWith<$Res> get rootItem {
  
  return $CommentItemCopyWith<$Res>(_self.rootItem, (value) {
    return _then(_self.copyWith(rootItem: value));
  });
}
}


/// Adds pattern-matching-related methods to [CommentReplySheetArgs].
extension CommentReplySheetArgsPatterns on CommentReplySheetArgs {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommentReplySheetArgs value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentReplySheetArgs() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommentReplySheetArgs value)  $default,){
final _that = this;
switch (_that) {
case _CommentReplySheetArgs():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommentReplySheetArgs value)?  $default,){
final _that = this;
switch (_that) {
case _CommentReplySheetArgs() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CommentTarget target,  CommentItem rootItem)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentReplySheetArgs() when $default != null:
return $default(_that.target,_that.rootItem);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CommentTarget target,  CommentItem rootItem)  $default,) {final _that = this;
switch (_that) {
case _CommentReplySheetArgs():
return $default(_that.target,_that.rootItem);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CommentTarget target,  CommentItem rootItem)?  $default,) {final _that = this;
switch (_that) {
case _CommentReplySheetArgs() when $default != null:
return $default(_that.target,_that.rootItem);case _:
  return null;

}
}

}

/// @nodoc


class _CommentReplySheetArgs implements CommentReplySheetArgs {
  const _CommentReplySheetArgs({required this.target, required this.rootItem});
  

@override final  CommentTarget target;
@override final  CommentItem rootItem;

/// Create a copy of CommentReplySheetArgs
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentReplySheetArgsCopyWith<_CommentReplySheetArgs> get copyWith => __$CommentReplySheetArgsCopyWithImpl<_CommentReplySheetArgs>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentReplySheetArgs&&(identical(other.target, target) || other.target == target)&&(identical(other.rootItem, rootItem) || other.rootItem == rootItem));
}


@override
int get hashCode => Object.hash(runtimeType,target,rootItem);

@override
String toString() {
  return 'CommentReplySheetArgs(target: $target, rootItem: $rootItem)';
}


}

/// @nodoc
abstract mixin class _$CommentReplySheetArgsCopyWith<$Res> implements $CommentReplySheetArgsCopyWith<$Res> {
  factory _$CommentReplySheetArgsCopyWith(_CommentReplySheetArgs value, $Res Function(_CommentReplySheetArgs) _then) = __$CommentReplySheetArgsCopyWithImpl;
@override @useResult
$Res call({
 CommentTarget target, CommentItem rootItem
});


@override $CommentTargetCopyWith<$Res> get target;@override $CommentItemCopyWith<$Res> get rootItem;

}
/// @nodoc
class __$CommentReplySheetArgsCopyWithImpl<$Res>
    implements _$CommentReplySheetArgsCopyWith<$Res> {
  __$CommentReplySheetArgsCopyWithImpl(this._self, this._then);

  final _CommentReplySheetArgs _self;
  final $Res Function(_CommentReplySheetArgs) _then;

/// Create a copy of CommentReplySheetArgs
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? target = null,Object? rootItem = null,}) {
  return _then(_CommentReplySheetArgs(
target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as CommentTarget,rootItem: null == rootItem ? _self.rootItem : rootItem // ignore: cast_nullable_to_non_nullable
as CommentItem,
  ));
}

/// Create a copy of CommentReplySheetArgs
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentTargetCopyWith<$Res> get target {
  
  return $CommentTargetCopyWith<$Res>(_self.target, (value) {
    return _then(_self.copyWith(target: value));
  });
}/// Create a copy of CommentReplySheetArgs
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentItemCopyWith<$Res> get rootItem {
  
  return $CommentItemCopyWith<$Res>(_self.rootItem, (value) {
    return _then(_self.copyWith(rootItem: value));
  });
}
}

// dart format on
