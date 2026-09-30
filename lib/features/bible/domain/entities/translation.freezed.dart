// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'translation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Translation {

/// Stable key, also the DB file name stem (e.g. `kjv`).
 String get key; String get abbreviation; String get name; String get language; String get license; String get source; String get qualityNotes; String get sourceUrl;
/// Create a copy of Translation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranslationCopyWith<Translation> get copyWith => _$TranslationCopyWithImpl<Translation>(this as Translation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Translation&&(identical(other.key, key) || other.key == key)&&(identical(other.abbreviation, abbreviation) || other.abbreviation == abbreviation)&&(identical(other.name, name) || other.name == name)&&(identical(other.language, language) || other.language == language)&&(identical(other.license, license) || other.license == license)&&(identical(other.source, source) || other.source == source)&&(identical(other.qualityNotes, qualityNotes) || other.qualityNotes == qualityNotes)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl));
}


@override
int get hashCode => Object.hash(runtimeType,key,abbreviation,name,language,license,source,qualityNotes,sourceUrl);

@override
String toString() {
  return 'Translation(key: $key, abbreviation: $abbreviation, name: $name, language: $language, license: $license, source: $source, qualityNotes: $qualityNotes, sourceUrl: $sourceUrl)';
}


}

/// @nodoc
abstract mixin class $TranslationCopyWith<$Res>  {
  factory $TranslationCopyWith(Translation value, $Res Function(Translation) _then) = _$TranslationCopyWithImpl;
@useResult
$Res call({
 String key, String abbreviation, String name, String language, String license, String source, String qualityNotes, String sourceUrl
});




}
/// @nodoc
class _$TranslationCopyWithImpl<$Res>
    implements $TranslationCopyWith<$Res> {
  _$TranslationCopyWithImpl(this._self, this._then);

  final Translation _self;
  final $Res Function(Translation) _then;

/// Create a copy of Translation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? abbreviation = null,Object? name = null,Object? language = null,Object? license = null,Object? source = null,Object? qualityNotes = null,Object? sourceUrl = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,abbreviation: null == abbreviation ? _self.abbreviation : abbreviation // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,license: null == license ? _self.license : license // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,qualityNotes: null == qualityNotes ? _self.qualityNotes : qualityNotes // ignore: cast_nullable_to_non_nullable
as String,sourceUrl: null == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Translation].
extension TranslationPatterns on Translation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Translation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Translation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Translation value)  $default,){
final _that = this;
switch (_that) {
case _Translation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Translation value)?  $default,){
final _that = this;
switch (_that) {
case _Translation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String abbreviation,  String name,  String language,  String license,  String source,  String qualityNotes,  String sourceUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Translation() when $default != null:
return $default(_that.key,_that.abbreviation,_that.name,_that.language,_that.license,_that.source,_that.qualityNotes,_that.sourceUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String abbreviation,  String name,  String language,  String license,  String source,  String qualityNotes,  String sourceUrl)  $default,) {final _that = this;
switch (_that) {
case _Translation():
return $default(_that.key,_that.abbreviation,_that.name,_that.language,_that.license,_that.source,_that.qualityNotes,_that.sourceUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String abbreviation,  String name,  String language,  String license,  String source,  String qualityNotes,  String sourceUrl)?  $default,) {final _that = this;
switch (_that) {
case _Translation() when $default != null:
return $default(_that.key,_that.abbreviation,_that.name,_that.language,_that.license,_that.source,_that.qualityNotes,_that.sourceUrl);case _:
  return null;

}
}

}

/// @nodoc


class _Translation extends Translation {
  const _Translation({required this.key, required this.abbreviation, required this.name, required this.language, required this.license, this.source = '', this.qualityNotes = '', this.sourceUrl = ''}): super._();
  

/// Stable key, also the DB file name stem (e.g. `kjv`).
@override final  String key;
@override final  String abbreviation;
@override final  String name;
@override final  String language;
@override final  String license;
@override@JsonKey() final  String source;
@override@JsonKey() final  String qualityNotes;
@override@JsonKey() final  String sourceUrl;

/// Create a copy of Translation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranslationCopyWith<_Translation> get copyWith => __$TranslationCopyWithImpl<_Translation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Translation&&(identical(other.key, key) || other.key == key)&&(identical(other.abbreviation, abbreviation) || other.abbreviation == abbreviation)&&(identical(other.name, name) || other.name == name)&&(identical(other.language, language) || other.language == language)&&(identical(other.license, license) || other.license == license)&&(identical(other.source, source) || other.source == source)&&(identical(other.qualityNotes, qualityNotes) || other.qualityNotes == qualityNotes)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl));
}


@override
int get hashCode => Object.hash(runtimeType,key,abbreviation,name,language,license,source,qualityNotes,sourceUrl);

@override
String toString() {
  return 'Translation(key: $key, abbreviation: $abbreviation, name: $name, language: $language, license: $license, source: $source, qualityNotes: $qualityNotes, sourceUrl: $sourceUrl)';
}


}

/// @nodoc
abstract mixin class _$TranslationCopyWith<$Res> implements $TranslationCopyWith<$Res> {
  factory _$TranslationCopyWith(_Translation value, $Res Function(_Translation) _then) = __$TranslationCopyWithImpl;
@override @useResult
$Res call({
 String key, String abbreviation, String name, String language, String license, String source, String qualityNotes, String sourceUrl
});




}
/// @nodoc
class __$TranslationCopyWithImpl<$Res>
    implements _$TranslationCopyWith<$Res> {
  __$TranslationCopyWithImpl(this._self, this._then);

  final _Translation _self;
  final $Res Function(_Translation) _then;

/// Create a copy of Translation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? abbreviation = null,Object? name = null,Object? language = null,Object? license = null,Object? source = null,Object? qualityNotes = null,Object? sourceUrl = null,}) {
  return _then(_Translation(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,abbreviation: null == abbreviation ? _self.abbreviation : abbreviation // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,license: null == license ? _self.license : license // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,qualityNotes: null == qualityNotes ? _self.qualityNotes : qualityNotes // ignore: cast_nullable_to_non_nullable
as String,sourceUrl: null == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
