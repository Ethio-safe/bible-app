class RandomVerse {
  const RandomVerse({
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.reference,
  });

  final String book;
  final int chapter;
  final int verse;
  final String text;
  final String reference;

  factory RandomVerse.fromJson(Map<String, dynamic> json) => RandomVerse(
        book: json['book'] as String,
        chapter: json['chapter'] as int,
        verse: json['verse'] as int,
        text: json['text'] as String,
        reference: json['reference'] as String,
      );

  Map<String, dynamic> toJson() => {
        'book': book,
        'chapter': chapter,
        'verse': verse,
        'text': text,
        'reference': reference,
      };
}
