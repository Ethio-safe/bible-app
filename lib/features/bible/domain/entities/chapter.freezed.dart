// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chapter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChapterId {

 int get bookId; int get chapter;
/// Create a copy of ChapterId
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChapterIdCopyWith<ChapterId> get copyWith => _$ChapterIdCopyWithImpl<ChapterId>(this as ChapterId, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChapterId&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.chapter, chapter) || other.chapter == chapter));
}


@override
int get hashCode => Object.hash(runtimeType,bookId,chapter);

@override
String toString() {
  return 'ChapterId(bookId: $bookId, chapter: $chapter)';
}


}

/// @nodoc
abstract mixin class $ChapterIdCopyWith<$Res>  {
  factory $ChapterIdCopyWith(ChapterId value, $Res Function(ChapterId) _then) = _$ChapterIdCopyWithImpl;
@useResult
$Res call({
 int bookId, int chapter
});




}
/// @nodoc
class _$ChapterIdCopyWithImpl<$Res>
    implements $ChapterIdCopyWith<$Res> {
  _$ChapterIdCopyWithImpl(this._self, this._then);

  final ChapterId _self;
  final $Res Function(ChapterId) _then;

/// Create a copy of ChapterId
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookId = null,Object? chapter = null,}) {
  return _then(_self.copyWith(
bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,chapter: null == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChapterId].
extension ChapterIdPatterns on ChapterId {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChapterId value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChapterId() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChapterId value)  $default,){
final _that = this;
switch (_that) {
case _ChapterId():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChapterId value)?  $default,){
final _that = this;
switch (_that) {
case _ChapterId() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int bookId,  int chapter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChapterId() when $default != null:
return $default(_that.bookId,_that.chapter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int bookId,  int chapter)  $default,) {final _that = this;
switch (_that) {
case _ChapterId():
return $default(_that.bookId,_that.chapter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int bookId,  int chapter)?  $default,) {final _that = this;
switch (_that) {
case _ChapterId() when $default != null:
return $default(_that.bookId,_that.chapter);case _:
  return null;

}
}

}

/// @nodoc


class _ChapterId extends ChapterId {
  const _ChapterId({required this.bookId, required this.chapter}): super._();
  

@override final  int bookId;
@override final  int chapter;

/// Create a copy of ChapterId
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChapterIdCopyWith<_ChapterId> get copyWith => __$ChapterIdCopyWithImpl<_ChapterId>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChapterId&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.chapter, chapter) || other.chapter == chapter));
}


@override
int get hashCode => Object.hash(runtimeType,bookId,chapter);

@override
String toString() {
  return 'ChapterId(bookId: $bookId, chapter: $chapter)';
}


}

/// @nodoc
abstract mixin class _$ChapterIdCopyWith<$Res> implements $ChapterIdCopyWith<$Res> {
  factory _$ChapterIdCopyWith(_ChapterId value, $Res Function(_ChapterId) _then) = __$ChapterIdCopyWithImpl;
@override @useResult
$Res call({
 int bookId, int chapter
});




}
/// @nodoc
class __$ChapterIdCopyWithImpl<$Res>
    implements _$ChapterIdCopyWith<$Res> {
  __$ChapterIdCopyWithImpl(this._self, this._then);

  final _ChapterId _self;
  final $Res Function(_ChapterId) _then;

/// Create a copy of ChapterId
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookId = null,Object? chapter = null,}) {
  return _then(_ChapterId(
bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as int,chapter: null == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$Chapter {

 Book get book; int get number; List<Verse> get verses; bool get isPassage; String get sourceNotes; String get sourceNotice;
/// Create a copy of Chapter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChapterCopyWith<Chapter> get copyWith => _$ChapterCopyWithImpl<Chapter>(this as Chapter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Chapter&&(identical(other.book, book) || other.book == book)&&(identical(other.number, number) || other.number == number)&&const DeepCollectionEquality().equals(other.verses, verses)&&(identical(other.isPassage, isPassage) || other.isPassage == isPassage)&&(identical(other.sourceNotes, sourceNotes) || other.sourceNotes == sourceNotes)&&(identical(other.sourceNotice, sourceNotice) || other.sourceNotice == sourceNotice));
}


@override
int get hashCode => Object.hash(runtimeType,book,number,const DeepCollectionEquality().hash(verses),isPassage,sourceNotes,sourceNotice);

@override
String toString() {
  return 'Chapter(book: $book, number: $number, verses: $verses, isPassage: $isPassage, sourceNotes: $sourceNotes, sourceNotice: $sourceNotice)';
}


}

/// @nodoc
abstract mixin class $ChapterCopyWith<$Res>  {
  factory $ChapterCopyWith(Chapter value, $Res Function(Chapter) _then) = _$ChapterCopyWithImpl;
@useResult
$Res call({
 Book book, int number, List<Verse> verses, bool isPassage, String sourceNotes, String sourceNotice
});


$BookCopyWith<$Res> get book;

}
/// @nodoc
class _$ChapterCopyWithImpl<$Res>
    implements $ChapterCopyWith<$Res> {
  _$ChapterCopyWithImpl(this._self, this._then);

  final Chapter _self;
  final $Res Function(Chapter) _then;

/// Create a copy of Chapter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? book = null,Object? number = null,Object? verses = null,Object? isPassage = null,Object? sourceNotes = null,Object? sourceNotice = null,}) {
  return _then(_self.copyWith(
book: null == book ? _self.book : book // ignore: cast_nullable_to_non_nullable
as Book,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,verses: null == verses ? _self.verses : verses // ignore: cast_nullable_to_non_nullable
as List<Verse>,isPassage: null == isPassage ? _self.isPassage : isPassage // ignore: cast_nullable_to_non_nullable
as bool,sourceNotes: null == sourceNotes ? _self.sourceNotes : sourceNotes // ignore: cast_nullable_to_non_nullable
as String,sourceNotice: null == sourceNotice ? _self.sourceNotice : sourceNotice // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of Chapter
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookCopyWith<$Res> get book {
  
  return $BookCopyWith<$Res>(_self.book, (value) {
    return _then(_self.copyWith(book: value));
  });
}
}


/// Adds pattern-matching-related methods to [Chapter].
extension ChapterPatterns on Chapter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Chapter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Chapter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Chapter value)  $default,){
final _that = this;
switch (_that) {
case _Chapter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Chapter value)?  $default,){
final _that = this;
switch (_that) {
case _Chapter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Book book,  int number,  List<Verse> verses,  bool isPassage,  String sourceNotes,  String sourceNotice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Chapter() when $default != null:
return $default(_that.book,_that.number,_that.verses,_that.isPassage,_that.sourceNotes,_that.sourceNotice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Book book,  int number,  List<Verse> verses,  bool isPassage,  String sourceNotes,  String sourceNotice)  $default,) {final _that = this;
switch (_that) {
case _Chapter():
return $default(_that.book,_that.number,_that.verses,_that.isPassage,_that.sourceNotes,_that.sourceNotice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Book book,  int number,  List<Verse> verses,  bool isPassage,  String sourceNotes,  String sourceNotice)?  $default,) {final _that = this;
switch (_that) {
case _Chapter() when $default != null:
return $default(_that.book,_that.number,_that.verses,_that.isPassage,_that.sourceNotes,_that.sourceNotice);case _:
  return null;

}
}

}

/// @nodoc


class _Chapter extends Chapter {
  const _Chapter({required this.book, required this.number, required final  List<Verse> verses, this.isPassage = false, this.sourceNotes = '', this.sourceNotice = ''}): _verses = verses,super._();
  

@override final  Book book;
@override final  int number;
 final  List<Verse> _verses;
@override List<Verse> get verses {
  if (_verses is EqualUnmodifiableListView) return _verses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_verses);
}

@override@JsonKey() final  bool isPassage;
@override@JsonKey() final  String sourceNotes;
@override@JsonKey() final  String sourceNotice;

/// Create a copy of Chapter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChapterCopyWith<_Chapter> get copyWith => __$ChapterCopyWithImpl<_Chapter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Chapter&&(identical(other.book, book) || other.book == book)&&(identical(other.number, number) || other.number == number)&&const DeepCollectionEquality().equals(other._verses, _verses)&&(identical(other.isPassage, isPassage) || other.isPassage == isPassage)&&(identical(other.sourceNotes, sourceNotes) || other.sourceNotes == sourceNotes)&&(identical(other.sourceNotice, sourceNotice) || other.sourceNotice == sourceNotice));
}


@override
int get hashCode => Object.hash(runtimeType,book,number,const DeepCollectionEquality().hash(_verses),isPassage,sourceNotes,sourceNotice);

@override
String toString() {
  return 'Chapter(book: $book, number: $number, verses: $verses, isPassage: $isPassage, sourceNotes: $sourceNotes, sourceNotice: $sourceNotice)';
}


}

/// @nodoc
abstract mixin class _$ChapterCopyWith<$Res> implements $ChapterCopyWith<$Res> {
  factory _$ChapterCopyWith(_Chapter value, $Res Function(_Chapter) _then) = __$ChapterCopyWithImpl;
@override @useResult
$Res call({
 Book book, int number, List<Verse> verses, bool isPassage, String sourceNotes, String sourceNotice
});


@override $BookCopyWith<$Res> get book;

}
/// @nodoc
class __$ChapterCopyWithImpl<$Res>
    implements _$ChapterCopyWith<$Res> {
  __$ChapterCopyWithImpl(this._self, this._then);

  final _Chapter _self;
  final $Res Function(_Chapter) _then;

/// Create a copy of Chapter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? book = null,Object? number = null,Object? verses = null,Object? isPassage = null,Object? sourceNotes = null,Object? sourceNotice = null,}) {
  return _then(_Chapter(
book: null == book ? _self.book : book // ignore: cast_nullable_to_non_nullable
as Book,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,verses: null == verses ? _self._verses : verses // ignore: cast_nullable_to_non_nullable
as List<Verse>,isPassage: null == isPassage ? _self.isPassage : isPassage // ignore: cast_nullable_to_non_nullable
as bool,sourceNotes: null == sourceNotes ? _self.sourceNotes : sourceNotes // ignore: cast_nullable_to_non_nullable
as String,sourceNotice: null == sourceNotice ? _self.sourceNotice : sourceNotice // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of Chapter
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookCopyWith<$Res> get book {
  
  return $BookCopyWith<$Res>(_self.book, (value) {
    return _then(_self.copyWith(book: value));
  });
}
}

// dart format on
