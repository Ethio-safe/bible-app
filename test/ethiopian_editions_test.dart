import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bible/core/database/bible_database.dart';
import 'package:bible/core/database/bundled_bibles.dart';
import 'package:bible/core/storage/preferences_provider.dart';
import 'package:bible/features/annotations/domain/entities/annotations.dart';
import 'package:bible/features/annotations/presentation/providers/verse_lookup_provider.dart';
import 'package:bible/features/bible/data/datasources/bible_mappers.dart';
import 'package:bible/features/bible/data/repositories/drift_bible_repository.dart';
import 'package:bible/features/bible/domain/entities/book.dart';
import 'package:bible/features/bible/domain/entities/chapter.dart';
import 'package:bible/features/bible/presentation/providers/bible_providers.dart';
import 'package:bible/features/bible/presentation/providers/chapter_index_provider.dart';
import 'package:bible/features/bible/presentation/providers/reading_position_provider.dart';
import 'package:bible/features/bible/presentation/screens/reader_screen.dart';
import 'package:bible/features/bible/presentation/widgets/chapter_navigator_sheet.dart';
import 'package:bible/features/bible/presentation/widgets/translation_chip.dart';
import 'package:bible/features/settings/presentation/bible_licenses_screen.dart';
import 'package:bible/features/votd/domain/edition_verse_pool.dart';
import 'package:bible/features/votd/domain/verse_pool.dart';

const extra = Book(
  id: 2081,
  name: 'Extra study book',
  abbreviation: 'Extra',
  testament: Testament.oldTestament,
  chapterCount: 2,
);
const genesis = Book(
  id: 1,
  name: 'Genesis',
  abbreviation: 'Gen',
  testament: Testament.oldTestament,
  chapterCount: 2,
);
final english = translationFromMeta('eot_en', {
  'name': 'Ethiopian English study collection',
  'abbreviation': 'EOT-EN',
  'language': 'en',
  'source': 'Multiple educational sources',
  'quality_notes': 'Coverage and numbering vary by source.',
  'license': 'See individual source terms',
  'source_url': 'https://example.org/sources',
});

Future<BibleDatabase> fixture({String? mapping, bool includeNt = true}) async {
  final db = BibleDatabase(NativeDatabase.memory());
  await db.customStatement(
    'CREATE VIRTUAL TABLE verses_fts USING fts5(text, content=verses, content_rowid=id)',
  );
  if (mapping != null) {
    await db.customStatement('INSERT INTO meta VALUES (?, ?)', [
      'canonical_book_ids',
      mapping,
    ]);
  }
  await db.customStatement(
    "INSERT INTO books VALUES (2081, 'Extra study book', 'Extra', 'OT', 2)",
  );
  await db.customStatement(
    "INSERT INTO verses VALUES (1, 2081, 2, 1, 'Extra study text')",
  );
  if (includeNt) {
    await db.customStatement(
      "INSERT INTO books VALUES (2043, 'John edition', 'Jn', 'NT', 3)",
    );
    await db.customStatement(
      "INSERT INTO verses VALUES (2, 2043, 3, 16, 'God loved the world')",
    );
  }
  await db.customStatement(
    "INSERT INTO verses_fts(verses_fts) VALUES ('rebuild')",
  );
  return db;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'catalog includes five offline databases and bumped install version',
    () {
      expect(BundledBibles.files.keys, [
        'kjv',
        'web',
        'asv',
        'eot_am',
        'eot_en',
      ]);
      expect(BundledBibles.assetPath('eot_am'), 'assets/bible/eot_am.db');
      expect(BundledBibles.bundledDbVersion, greaterThan(1));
    },
  );

  test(
    'metadata retains source details internally but hides source notices in the app',
    () {
      expect(english.source, contains('Multiple educational sources'));
      expect(english.sourceNotice, isEmpty);
      expect(
        translationFromMeta('eot_am', {'language': 'am'}).languageLabel,
        'Amharic',
      );
      expect(
        translationFromMeta('eot_am', {}).license,
        isNot(contains('Public Domain')),
      );
    },
  );

  test(
    'repository and search look up namespaced IDs rather than list positions',
    () async {
      final db = await fixture();
      addTearDown(db.close);
      final repo = DriftBibleRepository(translation: english, database: db);
      expect((await repo.getBook(2081))?.name, extra.name);
      expect(await repo.getBook(1), isNull);
      expect(
        (await repo.getChapter(
          const ChapterId(bookId: 2081, chapter: 2),
        )).verses.single.text,
        'Extra study text',
      );
      final hits = await repo.searchDetailed('study');
      expect(hits.hits.single.book.id, 2081);
      expect(hits.hits.single.book.isOldTestament, isTrue);
    },
  );

  test(
    'daily pool maps NT IDs and does not map Ethiopian OT numbering',
    () async {
      final db = await fixture(mapping: jsonEncode({'43': 2043, '19': 2081}));
      addTearDown(db.close);
      final pool = await EditionVersePool.load(db);
      final john = pool.resolve(const PoolVerse(43, 3, 16, VerseTheme.love));
      expect((john.bookId, john.chapter, john.verse), (2043, 3, 16));
      expect(pool.verses.every((v) => v.bookId == 2043), isTrue);
      final fallback = pool.resolve(const PoolVerse(19, 2, 1, VerseTheme.hope));
      expect(fallback.bookId, 2043);
      expect(pool.resolve(john).bookId, 2043);
      // A missing range end is never presented as though the whole range exists.
      expect(
        pool.verses.every((v) => v.endVerse == null || v.endVerse == 16),
        isTrue,
      );
    },
  );

  for (final mapping in [null, 'broken json', '{"43":"2043"}', '{}']) {
    test(
      'missing/malformed canonical map safely falls back: $mapping',
      () async {
        final db = await fixture(mapping: mapping, includeNt: false);
        addTearDown(db.close);
        final pool = await EditionVersePool.load(db);
        final fallback = pool.resolve(
          const PoolVerse(43, 3, 16, VerseTheme.love),
        );
        expect(
          (fallback.bookId, fallback.chapter, fallback.verse),
          (2081, 2, 1),
        );
      },
    );
  }

  test(
    'positions and recents are edition-scoped and preserve legacy KJV preferences',
    () async {
      SharedPreferences.setMockInitialValues({
        'last_read_book': 1,
        'last_read_chapter': 2,
        'recent_chapters': ['1:2'],
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      expect(
        container.read(lastReadChapterProvider),
        const ChapterId(bookId: 1, chapter: 2),
      );
      await container
          .read(currentTranslationKeyProvider.notifier)
          .set('eot_en');
      expect(container.read(lastReadChapterProvider), isNull);
      await container
          .read(lastReadChapterProvider.notifier)
          .set(const ChapterId(bookId: 2081, chapter: 2));
      expect(
        RecentChapters.read(prefs, translation: 'eot_en').single.bookId,
        2081,
      );
      await container
          .read(currentTranslationKeyProvider.notifier)
          .set('eot_am');
      expect(container.read(lastReadChapterProvider), isNull);
      expect(RecentChapters.read(prefs, translation: 'eot_am'), isEmpty);
      await container.read(currentTranslationKeyProvider.notifier).set('kjv');
      expect(
        container.read(lastReadChapterProvider),
        const ChapterId(bookId: 1, chapter: 2),
      );
      expect(prefs.getInt('last_read_book'), 1);
      expect(RecentChapters.read(prefs).single.bookId, 1);
      await container
          .read(currentTranslationKeyProvider.notifier)
          .set('eot_en');
      expect(container.read(lastReadChapterProvider)?.bookId, 2081);
    },
  );

  test(
    'unavailable annotations retain their identity without wrong text',
    () async {
      final db = await fixture();
      addTearDown(db.close);
      final repo = DriftBibleRepository(translation: english, database: db);
      final container = ProviderContainer(
        overrides: [bibleRepositoryProvider.overrideWith((ref) async => repo)],
      );
      addTearDown(container.dispose);
      final lookup = await container.read(
        verseLookupProvider(
          const VerseRef(bookId: 1, chapter: 1, verse: 1),
        ).future,
      );
      expect(lookup.reference, contains('Book 1'));
      expect(lookup.text, contains('Unavailable in this edition'));
      expect(lookup.text, isNot(contains('Extra study text')));
    },
  );

  testWidgets(
    'switching extra book to KJV resets route, title and remembers per edition',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'current_translation': 'eot_en',
        'last_read_book': 1,
        'last_read_chapter': 2,
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          chapterIndexProvider.overrideWith(
            (ref) async => ChapterIndex([
              ref.watch(currentTranslationKeyProvider) == 'kjv'
                  ? genesis
                  : extra,
            ]),
          ),
          // Isolate navigation from annotations / rendering and platform storage.
          for (final book in [1, 2081])
            for (final chapter in [1, 2])
              chapterProvider(
                ChapterId(bookId: book, chapter: chapter),
              ).overrideWith(
                (ref) async => throw StateError('Test chapter placeholder'),
              ),
        ],
      );
      final router = GoRouter(
        initialLocation: '/read/book/2081/chapter/2',
        routes: [
          GoRoute(
            path: '/read/book/:bookId/chapter/:chapter',
            builder: (context, state) => ReaderScreen(
              bookId: int.parse(state.pathParameters['bookId']!),
              chapter: int.parse(state.pathParameters['chapter']!),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Extra study book 2'), findsWidgets);
      await container.read(currentTranslationKeyProvider.notifier).set('kjv');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        router.routeInformationProvider.value.uri.path,
        '/read/book/1/chapter/2',
      );
      expect(find.text('Extra study book 2'), findsNothing);
      expect(find.text('Genesis 2'), findsWidgets);
      expect(
        RecentChapters.read(prefs, translation: 'eot_en').single.bookId,
        2081,
      );
      await container
          .read(currentTranslationKeyProvider.notifier)
          .set('eot_en');
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        '/read/book/2081/chapter/2',
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('namespaced OT book opens OT tab, not NT', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          booksProvider.overrideWith((ref) async => [extra]),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showChapterNavigatorSheet(
                  context,
                  current: const ChapterId(bookId: 2081, chapter: 1),
                ),
                child: const Text('Open books'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open books'));
    await tester.pumpAndSettle();
    final tabs = tester.element(find.byType(TabBar));
    expect(DefaultTabController.of(tabs).index, 0);
    expect(find.text('Extra'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'five edition picker selects Ethiopian editions without a study notice prompt',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final editions = [
        for (final key in ['kjv', 'web', 'asv', 'eot_am'])
          translationFromMeta(key, {'language': key == 'eot_am' ? 'am' : 'en'}),
        english,
      ];
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          translationsProvider.overrideWith((ref) async => editions),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: TranslationChip())),
        ),
      );
      await tester.tap(find.byType(ActionChip));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('EOT-EN'));
      await tester.tap(find.text('EOT-EN'));
      await tester.pumpAndSettle();
      expect(find.text('Study edition source notice'), findsNothing);
      expect(find.textContaining('Coverage and numbering vary'), findsNothing);
      expect(container.read(currentTranslationKeyProvider), 'eot_en');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: BibleLicensesScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.textContaining('Multiple educational sources'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.textContaining('See individual source terms'),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );
}
