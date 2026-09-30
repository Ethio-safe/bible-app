// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallpaper_image.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WallpaperImage {

 int get id; String get key; String get path; WallpaperSource get source; bool get isDark; bool get isFavorite; int get width; int get height; String? get mood; DateTime? get lastUsedAt; String? get authorName; String? get authorUrl; String? get sourceUrl; String? get provider;
/// Create a copy of WallpaperImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WallpaperImageCopyWith<WallpaperImage> get copyWith => _$WallpaperImageCopyWithImpl<WallpaperImage>(this as WallpaperImage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WallpaperImage&&(identical(other.id, id) || other.id == id)&&(identical(other.key, key) || other.key == key)&&(identical(other.path, path) || other.path == path)&&(identical(other.source, source) || other.source == source)&&(identical(other.isDark, isDark) || other.isDark == isDark)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.mood, mood) || other.mood == mood)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.authorUrl, authorUrl) || other.authorUrl == authorUrl)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.provider, provider) || other.provider == provider));
}


@override
int get hashCode => Object.hash(runtimeType,id,key,path,source,isDark,isFavorite,width,height,mood,lastUsedAt,authorName,authorUrl,sourceUrl,provider);

@override
String toString() {
  return 'WallpaperImage(id: $id, key: $key, path: $path, source: $source, isDark: $isDark, isFavorite: $isFavorite, width: $width, height: $height, mood: $mood, lastUsedAt: $lastUsedAt, authorName: $authorName, authorUrl: $authorUrl, sourceUrl: $sourceUrl, provider: $provider)';
}


}

/// @nodoc
abstract mixin class $WallpaperImageCopyWith<$Res>  {
  factory $WallpaperImageCopyWith(WallpaperImage value, $Res Function(WallpaperImage) _then) = _$WallpaperImageCopyWithImpl;
@useResult
$Res call({
 int id, String key, String path, WallpaperSource source, bool isDark, bool isFavorite, int width, int height, String? mood, DateTime? lastUsedAt, String? authorName, String? authorUrl, String? sourceUrl, String? provider
});




}
/// @nodoc
class _$WallpaperImageCopyWithImpl<$Res>
    implements $WallpaperImageCopyWith<$Res> {
  _$WallpaperImageCopyWithImpl(this._self, this._then);

  final WallpaperImage _self;
  final $Res Function(WallpaperImage) _then;

/// Create a copy of WallpaperImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? key = null,Object? path = null,Object? source = null,Object? isDark = null,Object? isFavorite = null,Object? width = null,Object? height = null,Object? mood = freezed,Object? lastUsedAt = freezed,Object? authorName = freezed,Object? authorUrl = freezed,Object? sourceUrl = freezed,Object? provider = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as WallpaperSource,isDark: null == isDark ? _self.isDark : isDark // ignore: cast_nullable_to_non_nullable
as bool,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,mood: freezed == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as String?,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,authorName: freezed == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String?,authorUrl: freezed == authorUrl ? _self.authorUrl : authorUrl // ignore: cast_nullable_to_non_nullable
as String?,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WallpaperImage].
extension WallpaperImagePatterns on WallpaperImage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WallpaperImage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WallpaperImage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WallpaperImage value)  $default,){
final _that = this;
switch (_that) {
case _WallpaperImage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WallpaperImage value)?  $default,){
final _that = this;
switch (_that) {
case _WallpaperImage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String key,  String path,  WallpaperSource source,  bool isDark,  bool isFavorite,  int width,  int height,  String? mood,  DateTime? lastUsedAt,  String? authorName,  String? authorUrl,  String? sourceUrl,  String? provider)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WallpaperImage() when $default != null:
return $default(_that.id,_that.key,_that.path,_that.source,_that.isDark,_that.isFavorite,_that.width,_that.height,_that.mood,_that.lastUsedAt,_that.authorName,_that.authorUrl,_that.sourceUrl,_that.provider);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String key,  String path,  WallpaperSource source,  bool isDark,  bool isFavorite,  int width,  int height,  String? mood,  DateTime? lastUsedAt,  String? authorName,  String? authorUrl,  String? sourceUrl,  String? provider)  $default,) {final _that = this;
switch (_that) {
case _WallpaperImage():
return $default(_that.id,_that.key,_that.path,_that.source,_that.isDark,_that.isFavorite,_that.width,_that.height,_that.mood,_that.lastUsedAt,_that.authorName,_that.authorUrl,_that.sourceUrl,_that.provider);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String key,  String path,  WallpaperSource source,  bool isDark,  bool isFavorite,  int width,  int height,  String? mood,  DateTime? lastUsedAt,  String? authorName,  String? authorUrl,  String? sourceUrl,  String? provider)?  $default,) {final _that = this;
switch (_that) {
case _WallpaperImage() when $default != null:
return $default(_that.id,_that.key,_that.path,_that.source,_that.isDark,_that.isFavorite,_that.width,_that.height,_that.mood,_that.lastUsedAt,_that.authorName,_that.authorUrl,_that.sourceUrl,_that.provider);case _:
  return null;

}
}

}

/// @nodoc


class _WallpaperImage extends WallpaperImage {
  const _WallpaperImage({required this.id, required this.key, required this.path, required this.source, required this.isDark, required this.isFavorite, required this.width, required this.height, this.mood, this.lastUsedAt, this.authorName, this.authorUrl, this.sourceUrl, this.provider}): super._();
  

@override final  int id;
@override final  String key;
@override final  String path;
@override final  WallpaperSource source;
@override final  bool isDark;
@override final  bool isFavorite;
@override final  int width;
@override final  int height;
@override final  String? mood;
@override final  DateTime? lastUsedAt;
@override final  String? authorName;
@override final  String? authorUrl;
@override final  String? sourceUrl;
@override final  String? provider;

/// Create a copy of WallpaperImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WallpaperImageCopyWith<_WallpaperImage> get copyWith => __$WallpaperImageCopyWithImpl<_WallpaperImage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WallpaperImage&&(identical(other.id, id) || other.id == id)&&(identical(other.key, key) || other.key == key)&&(identical(other.path, path) || other.path == path)&&(identical(other.source, source) || other.source == source)&&(identical(other.isDark, isDark) || other.isDark == isDark)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.mood, mood) || other.mood == mood)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.authorUrl, authorUrl) || other.authorUrl == authorUrl)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.provider, provider) || other.provider == provider));
}


@override
int get hashCode => Object.hash(runtimeType,id,key,path,source,isDark,isFavorite,width,height,mood,lastUsedAt,authorName,authorUrl,sourceUrl,provider);

@override
String toString() {
  return 'WallpaperImage(id: $id, key: $key, path: $path, source: $source, isDark: $isDark, isFavorite: $isFavorite, width: $width, height: $height, mood: $mood, lastUsedAt: $lastUsedAt, authorName: $authorName, authorUrl: $authorUrl, sourceUrl: $sourceUrl, provider: $provider)';
}


}

/// @nodoc
abstract mixin class _$WallpaperImageCopyWith<$Res> implements $WallpaperImageCopyWith<$Res> {
  factory _$WallpaperImageCopyWith(_WallpaperImage value, $Res Function(_WallpaperImage) _then) = __$WallpaperImageCopyWithImpl;
@override @useResult
$Res call({
 int id, String key, String path, WallpaperSource source, bool isDark, bool isFavorite, int width, int height, String? mood, DateTime? lastUsedAt, String? authorName, String? authorUrl, String? sourceUrl, String? provider
});




}
/// @nodoc
class __$WallpaperImageCopyWithImpl<$Res>
    implements _$WallpaperImageCopyWith<$Res> {
  __$WallpaperImageCopyWithImpl(this._self, this._then);

  final _WallpaperImage _self;
  final $Res Function(_WallpaperImage) _then;

/// Create a copy of WallpaperImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? key = null,Object? path = null,Object? source = null,Object? isDark = null,Object? isFavorite = null,Object? width = null,Object? height = null,Object? mood = freezed,Object? lastUsedAt = freezed,Object? authorName = freezed,Object? authorUrl = freezed,Object? sourceUrl = freezed,Object? provider = freezed,}) {
  return _then(_WallpaperImage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as WallpaperSource,isDark: null == isDark ? _self.isDark : isDark // ignore: cast_nullable_to_non_nullable
as bool,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,mood: freezed == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as String?,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,authorName: freezed == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String?,authorUrl: freezed == authorUrl ? _self.authorUrl : authorUrl // ignore: cast_nullable_to_non_nullable
as String?,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$WallpaperQuote {

 String get text; String get reference; String get translation; int get bookId; int get chapter; int get verse;
/// Create a copy of WallpaperQuote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WallpaperQuoteCopyWith<WallpaperQuote> get copyWith => _$WallpaperQuoteCopyWithImpl<WallpaperQuote>(this as WallpaperQuote, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WallpaperQuote&&(identical(other.text, text) || other.text == text)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.translation, translation) || other.translation == translation)&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.verse, verse) || other.verse == verse));
}


@override
int get hashCode => Object.hash(runtimeType,text,reference,translation,bookId,chapter,verse);

@override
String toString() {
  return 'WallpaperQuote(text: $text, reference: $reference, translation: $translation, bookId: $bookId, chapter: $chapter, verse: $verse)';
}


}

/// @nodoc
abstract mixin class $WallpaperQuoteCopyWith<$Res>  {
  factory $WallpaperQuoteCopyWith(WallpaperQuote value, $Res Function(WallpaperQuote) _then) = _$WallpaperQuoteCopyWithImpl;
@useResult
$Res call({
 String text, String reference, String translation, int bookId, int chapter, int verse
});




}
/// @nodoc
class _$WallpaperQuoteCopyWithImpl<$Res>
    implements $WallpaperQuoteCopyWith<$Res> {
  _$WallpaperQuoteCopyWithImpl(this._self, this._then);

  final WallpaperQuote _self;
  final $Res Function(WallpaperQuote) _then;

/// Create a copy of WallpaperQuote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? reference = null,Object? translation = null,Object? bookId = null,Object? chapter = null,Object? verse = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String,bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,chapter: null == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int,verse: null == verse ? _self.verse : verse // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WallpaperQuote].
extension WallpaperQuotePatterns on WallpaperQuote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WallpaperQuote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WallpaperQuote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WallpaperQuote value)  $default,){
final _that = this;
switch (_that) {
case _WallpaperQuote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WallpaperQuote value)?  $default,){
final _that = this;
switch (_that) {
case _WallpaperQuote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  String reference,  String translation,  int bookId,  int chapter,  int verse)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WallpaperQuote() when $default != null:
return $default(_that.text,_that.reference,_that.translation,_that.bookId,_that.chapter,_that.verse);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  String reference,  String translation,  int bookId,  int chapter,  int verse)  $default,) {final _that = this;
switch (_that) {
case _WallpaperQuote():
return $default(_that.text,_that.reference,_that.translation,_that.bookId,_that.chapter,_that.verse);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  String reference,  String translation,  int bookId,  int chapter,  int verse)?  $default,) {final _that = this;
switch (_that) {
case _WallpaperQuote() when $default != null:
return $default(_that.text,_that.reference,_that.translation,_that.bookId,_that.chapter,_that.verse);case _:
  return null;

}
}

}

/// @nodoc


class _WallpaperQuote extends WallpaperQuote {
  const _WallpaperQuote({required this.text, required this.reference, required this.translation, required this.bookId, required this.chapter, required this.verse}): super._();
  

@override final  String text;
@override final  String reference;
@override final  String translation;
@override final  int bookId;
@override final  int chapter;
@override final  int verse;

/// Create a copy of WallpaperQuote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WallpaperQuoteCopyWith<_WallpaperQuote> get copyWith => __$WallpaperQuoteCopyWithImpl<_WallpaperQuote>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WallpaperQuote&&(identical(other.text, text) || other.text == text)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.translation, translation) || other.translation == translation)&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.verse, verse) || other.verse == verse));
}


@override
int get hashCode => Object.hash(runtimeType,text,reference,translation,bookId,chapter,verse);

@override
String toString() {
  return 'WallpaperQuote(text: $text, reference: $reference, translation: $translation, bookId: $bookId, chapter: $chapter, verse: $verse)';
}


}

/// @nodoc
abstract mixin class _$WallpaperQuoteCopyWith<$Res> implements $WallpaperQuoteCopyWith<$Res> {
  factory _$WallpaperQuoteCopyWith(_WallpaperQuote value, $Res Function(_WallpaperQuote) _then) = __$WallpaperQuoteCopyWithImpl;
@override @useResult
$Res call({
 String text, String reference, String translation, int bookId, int chapter, int verse
});




}
/// @nodoc
class __$WallpaperQuoteCopyWithImpl<$Res>
    implements _$WallpaperQuoteCopyWith<$Res> {
  __$WallpaperQuoteCopyWithImpl(this._self, this._then);

  final _WallpaperQuote _self;
  final $Res Function(_WallpaperQuote) _then;

/// Create a copy of WallpaperQuote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? reference = null,Object? translation = null,Object? bookId = null,Object? chapter = null,Object? verse = null,}) {
  return _then(_WallpaperQuote(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String,bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,chapter: null == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int,verse: null == verse ? _self.verse : verse // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
