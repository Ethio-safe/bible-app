// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'annotations.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VerseRef {

 int get bookId; int get chapter; int get verse;
/// Create a copy of VerseRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerseRefCopyWith<VerseRef> get copyWith => _$VerseRefCopyWithImpl<VerseRef>(this as VerseRef, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerseRef&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.verse, verse) || other.verse == verse));
}


@override
int get hashCode => Object.hash(runtimeType,bookId,chapter,verse);

@override
String toString() {
  return 'VerseRef(bookId: $bookId, chapter: $chapter, verse: $verse)';
}


}

/// @nodoc
abstract mixin class $VerseRefCopyWith<$Res>  {
  factory $VerseRefCopyWith(VerseRef value, $Res Function(VerseRef) _then) = _$VerseRefCopyWithImpl;
@useResult
$Res call({
 int bookId, int chapter, int verse
});




}
/// @nodoc
class _$VerseRefCopyWithImpl<$Res>
    implements $VerseRefCopyWith<$Res> {
  _$VerseRefCopyWithImpl(this._self, this._then);

  final VerseRef _self;
  final $Res Function(VerseRef) _then;

/// Create a copy of VerseRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookId = null,Object? chapter = null,Object? verse = null,}) {
  return _then(_self.copyWith(
bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,chapter: null == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int,verse: null == verse ? _self.verse : verse // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [VerseRef].
extension VerseRefPatterns on VerseRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerseRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerseRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerseRef value)  $default,){
final _that = this;
switch (_that) {
case _VerseRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerseRef value)?  $default,){
final _that = this;
switch (_that) {
case _VerseRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int bookId,  int chapter,  int verse)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerseRef() when $default != null:
return $default(_that.bookId,_that.chapter,_that.verse);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int bookId,  int chapter,  int verse)  $default,) {final _that = this;
switch (_that) {
case _VerseRef():
return $default(_that.bookId,_that.chapter,_that.verse);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int bookId,  int chapter,  int verse)?  $default,) {final _that = this;
switch (_that) {
case _VerseRef() when $default != null:
return $default(_that.bookId,_that.chapter,_that.verse);case _:
  return null;

}
}

}

/// @nodoc


class _VerseRef extends VerseRef {
  const _VerseRef({required this.bookId, required this.chapter, required this.verse}): super._();
  

@override final  int bookId;
@override final  int chapter;
@override final  int verse;

/// Create a copy of VerseRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerseRefCopyWith<_VerseRef> get copyWith => __$VerseRefCopyWithImpl<_VerseRef>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerseRef&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.verse, verse) || other.verse == verse));
}


@override
int get hashCode => Object.hash(runtimeType,bookId,chapter,verse);

@override
String toString() {
  return 'VerseRef(bookId: $bookId, chapter: $chapter, verse: $verse)';
}


}

/// @nodoc
abstract mixin class _$VerseRefCopyWith<$Res> implements $VerseRefCopyWith<$Res> {
  factory _$VerseRefCopyWith(_VerseRef value, $Res Function(_VerseRef) _then) = __$VerseRefCopyWithImpl;
@override @useResult
$Res call({
 int bookId, int chapter, int verse
});




}
/// @nodoc
class __$VerseRefCopyWithImpl<$Res>
    implements _$VerseRefCopyWith<$Res> {
  __$VerseRefCopyWithImpl(this._self, this._then);

  final _VerseRef _self;
  final $Res Function(_VerseRef) _then;

/// Create a copy of VerseRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookId = null,Object? chapter = null,Object? verse = null,}) {
  return _then(_VerseRef(
bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,chapter: null == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int,verse: null == verse ? _self.verse : verse // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$Highlight {

 int get id; int get bookId; int get chapter; int get verseStart; int get verseEnd; HighlightColor get color; DateTime get createdAt;
/// Create a copy of Highlight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HighlightCopyWith<Highlight> get copyWith => _$HighlightCopyWithImpl<Highlight>(this as Highlight, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Highlight&&(identical(other.id, id) || other.id == id)&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.verseStart, verseStart) || other.verseStart == verseStart)&&(identical(other.verseEnd, verseEnd) || other.verseEnd == verseEnd)&&(identical(other.color, color) || other.color == color)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,bookId,chapter,verseStart,verseEnd,color,createdAt);

@override
String toString() {
  return 'Highlight(id: $id, bookId: $bookId, chapter: $chapter, verseStart: $verseStart, verseEnd: $verseEnd, color: $color, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $HighlightCopyWith<$Res>  {
  factory $HighlightCopyWith(Highlight value, $Res Function(Highlight) _then) = _$HighlightCopyWithImpl;
@useResult
$Res call({
 int id, int bookId, int chapter, int verseStart, int verseEnd, HighlightColor color, DateTime createdAt
});




}
/// @nodoc
class _$HighlightCopyWithImpl<$Res>
    implements $HighlightCopyWith<$Res> {
  _$HighlightCopyWithImpl(this._self, this._then);

  final Highlight _self;
  final $Res Function(Highlight) _then;

/// Create a copy of Highlight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? bookId = null,Object? chapter = null,Object? verseStart = null,Object? verseEnd = null,Object? color = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,chapter: null == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int,verseStart: null == verseStart ? _self.verseStart : verseStart // ignore: cast_nullable_to_non_nullable
as int,verseEnd: null == verseEnd ? _self.verseEnd : verseEnd // ignore: cast_nullable_to_non_nullable
as int,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as HighlightColor,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Highlight].
extension HighlightPatterns on Highlight {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Highlight value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Highlight() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Highlight value)  $default,){
final _that = this;
switch (_that) {
case _Highlight():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Highlight value)?  $default,){
final _that = this;
switch (_that) {
case _Highlight() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int bookId,  int chapter,  int verseStart,  int verseEnd,  HighlightColor color,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Highlight() when $default != null:
return $default(_that.id,_that.bookId,_that.chapter,_that.verseStart,_that.verseEnd,_that.color,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int bookId,  int chapter,  int verseStart,  int verseEnd,  HighlightColor color,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Highlight():
return $default(_that.id,_that.bookId,_that.chapter,_that.verseStart,_that.verseEnd,_that.color,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int bookId,  int chapter,  int verseStart,  int verseEnd,  HighlightColor color,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Highlight() when $default != null:
return $default(_that.id,_that.bookId,_that.chapter,_that.verseStart,_that.verseEnd,_that.color,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _Highlight extends Highlight {
  const _Highlight({required this.id, required this.bookId, required this.chapter, required this.verseStart, required this.verseEnd, required this.color, required this.createdAt}): super._();
  

@override final  int id;
@override final  int bookId;
@override final  int chapter;
@override final  int verseStart;
@override final  int verseEnd;
@override final  HighlightColor color;
@override final  DateTime createdAt;

/// Create a copy of Highlight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HighlightCopyWith<_Highlight> get copyWith => __$HighlightCopyWithImpl<_Highlight>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Highlight&&(identical(other.id, id) || other.id == id)&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.verseStart, verseStart) || other.verseStart == verseStart)&&(identical(other.verseEnd, verseEnd) || other.verseEnd == verseEnd)&&(identical(other.color, color) || other.color == color)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,bookId,chapter,verseStart,verseEnd,color,createdAt);

@override
String toString() {
  return 'Highlight(id: $id, bookId: $bookId, chapter: $chapter, verseStart: $verseStart, verseEnd: $verseEnd, color: $color, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$HighlightCopyWith<$Res> implements $HighlightCopyWith<$Res> {
  factory _$HighlightCopyWith(_Highlight value, $Res Function(_Highlight) _then) = __$HighlightCopyWithImpl;
@override @useResult
$Res call({
 int id, int bookId, int chapter, int verseStart, int verseEnd, HighlightColor color, DateTime createdAt
});




}
/// @nodoc
class __$HighlightCopyWithImpl<$Res>
    implements _$HighlightCopyWith<$Res> {
  __$HighlightCopyWithImpl(this._self, this._then);

  final _Highlight _self;
  final $Res Function(_Highlight) _then;

/// Create a copy of Highlight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? bookId = null,Object? chapter = null,Object? verseStart = null,Object? verseEnd = null,Object? color = null,Object? createdAt = null,}) {
  return _then(_Highlight(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,chapter: null == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int,verseStart: null == verseStart ? _self.verseStart : verseStart // ignore: cast_nullable_to_non_nullable
as int,verseEnd: null == verseEnd ? _self.verseEnd : verseEnd // ignore: cast_nullable_to_non_nullable
as int,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as HighlightColor,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$Bookmark {

 int get id; int get bookId; int get chapter; int get verse; DateTime get createdAt;
/// Create a copy of Bookmark
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookmarkCopyWith<Bookmark> get copyWith => _$BookmarkCopyWithImpl<Bookmark>(this as Bookmark, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bookmark&&(identical(other.id, id) || other.id == id)&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.verse, verse) || other.verse == verse)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,bookId,chapter,verse,createdAt);

@override
String toString() {
  return 'Bookmark(id: $id, bookId: $bookId, chapter: $chapter, verse: $verse, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BookmarkCopyWith<$Res>  {
  factory $BookmarkCopyWith(Bookmark value, $Res Function(Bookmark) _then) = _$BookmarkCopyWithImpl;
@useResult
$Res call({
 int id, int bookId, int chapter, int verse, DateTime createdAt
});




}
/// @nodoc
class _$BookmarkCopyWithImpl<$Res>
    implements $BookmarkCopyWith<$Res> {
  _$BookmarkCopyWithImpl(this._self, this._then);

  final Bookmark _self;
  final $Res Function(Bookmark) _then;

/// Create a copy of Bookmark
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? bookId = null,Object? chapter = null,Object? verse = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,chapter: null == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int,verse: null == verse ? _self.verse : verse // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Bookmark].
extension BookmarkPatterns on Bookmark {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Bookmark value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Bookmark() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Bookmark value)  $default,){
final _that = this;
switch (_that) {
case _Bookmark():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Bookmark value)?  $default,){
final _that = this;
switch (_that) {
case _Bookmark() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int bookId,  int chapter,  int verse,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Bookmark() when $default != null:
return $default(_that.id,_that.bookId,_that.chapter,_that.verse,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int bookId,  int chapter,  int verse,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Bookmark():
return $default(_that.id,_that.bookId,_that.chapter,_that.verse,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int bookId,  int chapter,  int verse,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Bookmark() when $default != null:
return $default(_that.id,_that.bookId,_that.chapter,_that.verse,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _Bookmark implements Bookmark {
  const _Bookmark({required this.id, required this.bookId, required this.chapter, required this.verse, required this.createdAt});
  

@override final  int id;
@override final  int bookId;
@override final  int chapter;
@override final  int verse;
@override final  DateTime createdAt;

/// Create a copy of Bookmark
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookmarkCopyWith<_Bookmark> get copyWith => __$BookmarkCopyWithImpl<_Bookmark>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bookmark&&(identical(other.id, id) || other.id == id)&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.verse, verse) || other.verse == verse)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,bookId,chapter,verse,createdAt);

@override
String toString() {
  return 'Bookmark(id: $id, bookId: $bookId, chapter: $chapter, verse: $verse, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BookmarkCopyWith<$Res> implements $BookmarkCopyWith<$Res> {
  factory _$BookmarkCopyWith(_Bookmark value, $Res Function(_Bookmark) _then) = __$BookmarkCopyWithImpl;
@override @useResult
$Res call({
 int id, int bookId, int chapter, int verse, DateTime createdAt
});




}
/// @nodoc
class __$BookmarkCopyWithImpl<$Res>
    implements _$BookmarkCopyWith<$Res> {
  __$BookmarkCopyWithImpl(this._self, this._then);

  final _Bookmark _self;
  final $Res Function(_Bookmark) _then;

/// Create a copy of Bookmark
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? bookId = null,Object? chapter = null,Object? verse = null,Object? createdAt = null,}) {
  return _then(_Bookmark(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,chapter: null == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int,verse: null == verse ? _self.verse : verse // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$Note {

 int get id; int get bookId; int get chapter; int get verse; String get body; DateTime get updatedAt;
/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteCopyWith<Note> get copyWith => _$NoteCopyWithImpl<Note>(this as Note, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Note&&(identical(other.id, id) || other.id == id)&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.verse, verse) || other.verse == verse)&&(identical(other.body, body) || other.body == body)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,bookId,chapter,verse,body,updatedAt);

@override
String toString() {
  return 'Note(id: $id, bookId: $bookId, chapter: $chapter, verse: $verse, body: $body, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $NoteCopyWith<$Res>  {
  factory $NoteCopyWith(Note value, $Res Function(Note) _then) = _$NoteCopyWithImpl;
@useResult
$Res call({
 int id, int bookId, int chapter, int verse, String body, DateTime updatedAt
});




}
/// @nodoc
class _$NoteCopyWithImpl<$Res>
    implements $NoteCopyWith<$Res> {
  _$NoteCopyWithImpl(this._self, this._then);

  final Note _self;
  final $Res Function(Note) _then;

/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? bookId = null,Object? chapter = null,Object? verse = null,Object? body = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,chapter: null == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int,verse: null == verse ? _self.verse : verse // ignore: cast_nullable_to_non_nullable
as int,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Note].
extension NotePatterns on Note {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Note value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Note() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Note value)  $default,){
final _that = this;
switch (_that) {
case _Note():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Note value)?  $default,){
final _that = this;
switch (_that) {
case _Note() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int bookId,  int chapter,  int verse,  String body,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Note() when $default != null:
return $default(_that.id,_that.bookId,_that.chapter,_that.verse,_that.body,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int bookId,  int chapter,  int verse,  String body,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Note():
return $default(_that.id,_that.bookId,_that.chapter,_that.verse,_that.body,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int bookId,  int chapter,  int verse,  String body,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Note() when $default != null:
return $default(_that.id,_that.bookId,_that.chapter,_that.verse,_that.body,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Note implements Note {
  const _Note({required this.id, required this.bookId, required this.chapter, required this.verse, required this.body, required this.updatedAt});
  

@override final  int id;
@override final  int bookId;
@override final  int chapter;
@override final  int verse;
@override final  String body;
@override final  DateTime updatedAt;

/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoteCopyWith<_Note> get copyWith => __$NoteCopyWithImpl<_Note>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Note&&(identical(other.id, id) || other.id == id)&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.verse, verse) || other.verse == verse)&&(identical(other.body, body) || other.body == body)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,bookId,chapter,verse,body,updatedAt);

@override
String toString() {
  return 'Note(id: $id, bookId: $bookId, chapter: $chapter, verse: $verse, body: $body, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$NoteCopyWith<$Res> implements $NoteCopyWith<$Res> {
  factory _$NoteCopyWith(_Note value, $Res Function(_Note) _then) = __$NoteCopyWithImpl;
@override @useResult
$Res call({
 int id, int bookId, int chapter, int verse, String body, DateTime updatedAt
});




}
/// @nodoc
class __$NoteCopyWithImpl<$Res>
    implements _$NoteCopyWith<$Res> {
  __$NoteCopyWithImpl(this._self, this._then);

  final _Note _self;
  final $Res Function(_Note) _then;

/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? bookId = null,Object? chapter = null,Object? verse = null,Object? body = null,Object? updatedAt = null,}) {
  return _then(_Note(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,chapter: null == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int,verse: null == verse ? _self.verse : verse // ignore: cast_nullable_to_non_nullable
as int,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$ReadingPosition {

 String get translation; int get bookId; int get chapter; double get scrollOffset;
/// Create a copy of ReadingPosition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadingPositionCopyWith<ReadingPosition> get copyWith => _$ReadingPositionCopyWithImpl<ReadingPosition>(this as ReadingPosition, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadingPosition&&(identical(other.translation, translation) || other.translation == translation)&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.scrollOffset, scrollOffset) || other.scrollOffset == scrollOffset));
}


@override
int get hashCode => Object.hash(runtimeType,translation,bookId,chapter,scrollOffset);

@override
String toString() {
  return 'ReadingPosition(translation: $translation, bookId: $bookId, chapter: $chapter, scrollOffset: $scrollOffset)';
}


}

/// @nodoc
abstract mixin class $ReadingPositionCopyWith<$Res>  {
  factory $ReadingPositionCopyWith(ReadingPosition value, $Res Function(ReadingPosition) _then) = _$ReadingPositionCopyWithImpl;
@useResult
$Res call({
 String translation, int bookId, int chapter, double scrollOffset
});




}
/// @nodoc
class _$ReadingPositionCopyWithImpl<$Res>
    implements $ReadingPositionCopyWith<$Res> {
  _$ReadingPositionCopyWithImpl(this._self, this._then);

  final ReadingPosition _self;
  final $Res Function(ReadingPosition) _then;

/// Create a copy of ReadingPosition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? translation = null,Object? bookId = null,Object? chapter = null,Object? scrollOffset = null,}) {
  return _then(_self.copyWith(
translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String,bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,chapter: null == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int,scrollOffset: null == scrollOffset ? _self.scrollOffset : scrollOffset // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ReadingPosition].
extension ReadingPositionPatterns on ReadingPosition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReadingPosition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReadingPosition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReadingPosition value)  $default,){
final _that = this;
switch (_that) {
case _ReadingPosition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReadingPosition value)?  $default,){
final _that = this;
switch (_that) {
case _ReadingPosition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String translation,  int bookId,  int chapter,  double scrollOffset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReadingPosition() when $default != null:
return $default(_that.translation,_that.bookId,_that.chapter,_that.scrollOffset);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String translation,  int bookId,  int chapter,  double scrollOffset)  $default,) {final _that = this;
switch (_that) {
case _ReadingPosition():
return $default(_that.translation,_that.bookId,_that.chapter,_that.scrollOffset);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String translation,  int bookId,  int chapter,  double scrollOffset)?  $default,) {final _that = this;
switch (_that) {
case _ReadingPosition() when $default != null:
return $default(_that.translation,_that.bookId,_that.chapter,_that.scrollOffset);case _:
  return null;

}
}

}

/// @nodoc


class _ReadingPosition implements ReadingPosition {
  const _ReadingPosition({required this.translation, required this.bookId, required this.chapter, this.scrollOffset = 0});
  

@override final  String translation;
@override final  int bookId;
@override final  int chapter;
@override@JsonKey() final  double scrollOffset;

/// Create a copy of ReadingPosition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadingPositionCopyWith<_ReadingPosition> get copyWith => __$ReadingPositionCopyWithImpl<_ReadingPosition>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReadingPosition&&(identical(other.translation, translation) || other.translation == translation)&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.scrollOffset, scrollOffset) || other.scrollOffset == scrollOffset));
}


@override
int get hashCode => Object.hash(runtimeType,translation,bookId,chapter,scrollOffset);

@override
String toString() {
  return 'ReadingPosition(translation: $translation, bookId: $bookId, chapter: $chapter, scrollOffset: $scrollOffset)';
}


}

/// @nodoc
abstract mixin class _$ReadingPositionCopyWith<$Res> implements $ReadingPositionCopyWith<$Res> {
  factory _$ReadingPositionCopyWith(_ReadingPosition value, $Res Function(_ReadingPosition) _then) = __$ReadingPositionCopyWithImpl;
@override @useResult
$Res call({
 String translation, int bookId, int chapter, double scrollOffset
});




}
/// @nodoc
class __$ReadingPositionCopyWithImpl<$Res>
    implements _$ReadingPositionCopyWith<$Res> {
  __$ReadingPositionCopyWithImpl(this._self, this._then);

  final _ReadingPosition _self;
  final $Res Function(_ReadingPosition) _then;

/// Create a copy of ReadingPosition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? translation = null,Object? bookId = null,Object? chapter = null,Object? scrollOffset = null,}) {
  return _then(_ReadingPosition(
translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String,bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,chapter: null == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int,scrollOffset: null == scrollOffset ? _self.scrollOffset : scrollOffset // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
