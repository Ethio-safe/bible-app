// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verse.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Verse {

 int get bookId; int get chapter; int get number; String get text;
/// Create a copy of Verse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerseCopyWith<Verse> get copyWith => _$VerseCopyWithImpl<Verse>(this as Verse, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Verse&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.number, number) || other.number == number)&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,bookId,chapter,number,text);

@override
String toString() {
  return 'Verse(bookId: $bookId, chapter: $chapter, number: $number, text: $text)';
}


}

/// @nodoc
abstract mixin class $VerseCopyWith<$Res>  {
  factory $VerseCopyWith(Verse value, $Res Function(Verse) _then) = _$VerseCopyWithImpl;
@useResult
$Res call({
 int bookId, int chapter, int number, String text
});




}
/// @nodoc
class _$VerseCopyWithImpl<$Res>
    implements $VerseCopyWith<$Res> {
  _$VerseCopyWithImpl(this._self, this._then);

  final Verse _self;
  final $Res Function(Verse) _then;

/// Create a copy of Verse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookId = null,Object? chapter = null,Object? number = null,Object? text = null,}) {
  return _then(_self.copyWith(
bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,chapter: null == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Verse].
extension VersePatterns on Verse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Verse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Verse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Verse value)  $default,){
final _that = this;
switch (_that) {
case _Verse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Verse value)?  $default,){
final _that = this;
switch (_that) {
case _Verse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int bookId,  int chapter,  int number,  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Verse() when $default != null:
return $default(_that.bookId,_that.chapter,_that.number,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int bookId,  int chapter,  int number,  String text)  $default,) {final _that = this;
switch (_that) {
case _Verse():
return $default(_that.bookId,_that.chapter,_that.number,_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int bookId,  int chapter,  int number,  String text)?  $default,) {final _that = this;
switch (_that) {
case _Verse() when $default != null:
return $default(_that.bookId,_that.chapter,_that.number,_that.text);case _:
  return null;

}
}

}

/// @nodoc


class _Verse extends Verse {
  const _Verse({required this.bookId, required this.chapter, required this.number, required this.text}): super._();
  

@override final  int bookId;
@override final  int chapter;
@override final  int number;
@override final  String text;

/// Create a copy of Verse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerseCopyWith<_Verse> get copyWith => __$VerseCopyWithImpl<_Verse>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Verse&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.number, number) || other.number == number)&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,bookId,chapter,number,text);

@override
String toString() {
  return 'Verse(bookId: $bookId, chapter: $chapter, number: $number, text: $text)';
}


}

/// @nodoc
abstract mixin class _$VerseCopyWith<$Res> implements $VerseCopyWith<$Res> {
  factory _$VerseCopyWith(_Verse value, $Res Function(_Verse) _then) = __$VerseCopyWithImpl;
@override @useResult
$Res call({
 int bookId, int chapter, int number, String text
});




}
/// @nodoc
class __$VerseCopyWithImpl<$Res>
    implements _$VerseCopyWith<$Res> {
  __$VerseCopyWithImpl(this._self, this._then);

  final _Verse _self;
  final $Res Function(_Verse) _then;

/// Create a copy of Verse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookId = null,Object? chapter = null,Object? number = null,Object? text = null,}) {
  return _then(_Verse(
bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,chapter: null == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
