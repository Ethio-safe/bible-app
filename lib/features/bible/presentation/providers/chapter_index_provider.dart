import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/book.dart';
import '../../domain/entities/chapter.dart';
import 'bible_providers.dart';

part 'chapter_index_provider.g.dart';

/// Flat, edition-specific chapter order for continuous paging.
class ChapterIndex {
  ChapterIndex(List<Book> books)
    : _ids = [
        for (final b in books)
          for (var c = 1; c <= b.chapterCount; c++)
            ChapterId(bookId: b.id, chapter: c),
      ],
      _books = {for (final b in books) b.id: b} {
    for (var i = 0; i < _ids.length; i++) {
      _positions[_ids[i]] = i;
    }
  }

  final List<ChapterId> _ids;
  final Map<int, Book> _books;
  final Map<ChapterId, int> _positions = {};

  int get length => _ids.length;
  bool contains(ChapterId id) => _positions.containsKey(id);
  ChapterId? validOrFirst(ChapterId? id) =>
      id != null && contains(id) ? id : _ids.firstOrNull;
  ChapterId at(int index) => _ids[index];
  int indexOf(ChapterId id) => _positions[id] ?? 0;
  Book bookOf(ChapterId id) => _books[id.bookId]!;
  String titleOf(ChapterId id) => '${bookOf(id).name} ${id.chapter}';

  String headingOf(ChapterId id) =>
      _bookHeadings[bookOf(id).name] ?? bookOf(id).name;
}

const _bookHeadings = <String, String>{
  'Genesis': 'The Beginning',
  'Exodus': 'The Way Out',
  'Leviticus': 'Holiness and Worship',
  'Numbers': 'The Wilderness Journey',
  'Deuteronomy': 'Remember and Live',
  'Joshua': 'Entering the Promise',
  'Judges': 'The Cycle of Deliverance',
  'Ruth': 'Faithful Love',
  '1 Samuel': 'The Rise of the Kingdom',
  '2 Samuel': 'The Davidic Kingdom',
  '1 Kings': 'A Kingdom Divided',
  '2 Kings': 'The Fall of the Kingdoms',
  '1 Chronicles': 'Remembering the People of God',
  '2 Chronicles': 'The Story of the Temple',
  'Ezra': 'Restoration',
  'Nehemiah': 'Rebuilding the Walls',
  'Esther': 'Courage for Such a Time',
  'Job': 'Faith in Suffering',
  'Psalms': 'Songs for Every Season',
  'Proverbs': 'The Way of Wisdom',
  'Ecclesiastes': 'The Search for Meaning',
  'Song of Solomon': 'The Beauty of Love',
  'Isaiah': 'The Holy One and His Salvation',
  'Jeremiah': 'The Weeping Prophet',
  'Lamentations': 'Hope in the Ruins',
  'Ezekiel': 'A New Heart and Spirit',
  'Daniel': 'Faith in a Foreign Land',
  'Hosea': 'Love That Pursues',
  'Joel': 'The Day of the Lord',
  'Amos': 'Justice Like a River',
  'Obadiah': 'The Lord Reigns',
  'Jonah': 'Mercy for the Nations',
  'Micah': 'What the Lord Requires',
  'Nahum': 'Justice Against Evil',
  'Habakkuk': 'Trust in the Darkness',
  'Zephaniah': 'The Day of Restoration',
  'Haggai': 'Consider Your Ways',
  'Zechariah': 'The King Who Is Coming',
  'Malachi': 'Returning to God',
  'Matthew': 'The King and His Kingdom',
  'Mark': 'The Servant King',
  'Luke': 'Good News for Everyone',
  'John': 'The Enfleshment of the Word',
  'Acts': 'The Spirit and the Church',
  'Romans': 'The Righteousness of God',
  '1 Corinthians': 'A Church Learning to Love',
  '2 Corinthians': 'Strength in Weakness',
  'Galatians': 'Freedom in Christ',
  'Ephesians': 'Life in Christ',
  'Philippians': 'Joy in Christ',
  'Colossians': 'The Supremacy of Christ',
  '1 Thessalonians': 'Hope in His Coming',
  '2 Thessalonians': 'Steadfast Until He Comes',
  '1 Timothy': 'Order in the Household of God',
  '2 Timothy': 'Guard the Good Deposit',
  'Titus': 'Sound Doctrine and Good Works',
  'Philemon': 'The Gospel Reconciles',
  'Hebrews': 'Christ Is Greater',
  'James': 'Faith That Works',
  '1 Peter': 'Hope in Suffering',
  '2 Peter': 'Growing in Grace',
  '1 John': 'Walking in Light and Love',
  '2 John': 'Walking in Truth',
  '3 John': 'Faithful Hospitality',
  'Jude': 'Contend for the Faith',
  'Revelation': 'The Triumph of the Lamb',
};

@riverpod
Future<ChapterIndex> chapterIndex(Ref ref) async {
  final books = await ref.watch(booksProvider.future);
  return ChapterIndex(books);
}
