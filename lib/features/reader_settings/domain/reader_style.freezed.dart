// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reader_style.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReaderStyle {

 double get fontSize; ReaderFont get font; double get lineHeight; ReaderTheme get theme;
/// Create a copy of ReaderStyle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReaderStyleCopyWith<ReaderStyle> get copyWith => _$ReaderStyleCopyWithImpl<ReaderStyle>(this as ReaderStyle, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReaderStyle&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.font, font) || other.font == font)&&(identical(other.lineHeight, lineHeight) || other.lineHeight == lineHeight)&&(identical(other.theme, theme) || other.theme == theme));
}


@override
int get hashCode => Object.hash(runtimeType,fontSize,font,lineHeight,theme);

@override
String toString() {
  return 'ReaderStyle(fontSize: $fontSize, font: $font, lineHeight: $lineHeight, theme: $theme)';
}


}

/// @nodoc
abstract mixin class $ReaderStyleCopyWith<$Res>  {
  factory $ReaderStyleCopyWith(ReaderStyle value, $Res Function(ReaderStyle) _then) = _$ReaderStyleCopyWithImpl;
@useResult
$Res call({
 double fontSize, ReaderFont font, double lineHeight, ReaderTheme theme
});




}
/// @nodoc
class _$ReaderStyleCopyWithImpl<$Res>
    implements $ReaderStyleCopyWith<$Res> {
  _$ReaderStyleCopyWithImpl(this._self, this._then);

  final ReaderStyle _self;
  final $Res Function(ReaderStyle) _then;

/// Create a copy of ReaderStyle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fontSize = null,Object? font = null,Object? lineHeight = null,Object? theme = null,}) {
  return _then(_self.copyWith(
fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double,font: null == font ? _self.font : font // ignore: cast_nullable_to_non_nullable
as ReaderFont,lineHeight: null == lineHeight ? _self.lineHeight : lineHeight // ignore: cast_nullable_to_non_nullable
as double,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as ReaderTheme,
  ));
}

}


/// Adds pattern-matching-related methods to [ReaderStyle].
extension ReaderStylePatterns on ReaderStyle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReaderStyle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReaderStyle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReaderStyle value)  $default,){
final _that = this;
switch (_that) {
case _ReaderStyle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReaderStyle value)?  $default,){
final _that = this;
switch (_that) {
case _ReaderStyle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double fontSize,  ReaderFont font,  double lineHeight,  ReaderTheme theme)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReaderStyle() when $default != null:
return $default(_that.fontSize,_that.font,_that.lineHeight,_that.theme);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double fontSize,  ReaderFont font,  double lineHeight,  ReaderTheme theme)  $default,) {final _that = this;
switch (_that) {
case _ReaderStyle():
return $default(_that.fontSize,_that.font,_that.lineHeight,_that.theme);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double fontSize,  ReaderFont font,  double lineHeight,  ReaderTheme theme)?  $default,) {final _that = this;
switch (_that) {
case _ReaderStyle() when $default != null:
return $default(_that.fontSize,_that.font,_that.lineHeight,_that.theme);case _:
  return null;

}
}

}

/// @nodoc


class _ReaderStyle extends ReaderStyle {
  const _ReaderStyle({this.fontSize = 20.0, this.font = ReaderFont.serif, this.lineHeight = 1.7, this.theme = ReaderTheme.system}): super._();
  

@override@JsonKey() final  double fontSize;
@override@JsonKey() final  ReaderFont font;
@override@JsonKey() final  double lineHeight;
@override@JsonKey() final  ReaderTheme theme;

/// Create a copy of ReaderStyle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReaderStyleCopyWith<_ReaderStyle> get copyWith => __$ReaderStyleCopyWithImpl<_ReaderStyle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReaderStyle&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.font, font) || other.font == font)&&(identical(other.lineHeight, lineHeight) || other.lineHeight == lineHeight)&&(identical(other.theme, theme) || other.theme == theme));
}


@override
int get hashCode => Object.hash(runtimeType,fontSize,font,lineHeight,theme);

@override
String toString() {
  return 'ReaderStyle(fontSize: $fontSize, font: $font, lineHeight: $lineHeight, theme: $theme)';
}


}

/// @nodoc
abstract mixin class _$ReaderStyleCopyWith<$Res> implements $ReaderStyleCopyWith<$Res> {
  factory _$ReaderStyleCopyWith(_ReaderStyle value, $Res Function(_ReaderStyle) _then) = __$ReaderStyleCopyWithImpl;
@override @useResult
$Res call({
 double fontSize, ReaderFont font, double lineHeight, ReaderTheme theme
});




}
/// @nodoc
class __$ReaderStyleCopyWithImpl<$Res>
    implements _$ReaderStyleCopyWith<$Res> {
  __$ReaderStyleCopyWithImpl(this._self, this._then);

  final _ReaderStyle _self;
  final $Res Function(_ReaderStyle) _then;

/// Create a copy of ReaderStyle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fontSize = null,Object? font = null,Object? lineHeight = null,Object? theme = null,}) {
  return _then(_ReaderStyle(
fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double,font: null == font ? _self.font : font // ignore: cast_nullable_to_non_nullable
as ReaderFont,lineHeight: null == lineHeight ? _self.lineHeight : lineHeight // ignore: cast_nullable_to_non_nullable
as double,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as ReaderTheme,
  ));
}


}

// dart format on
