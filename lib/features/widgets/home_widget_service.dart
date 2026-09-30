import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../../core/database/bible_database.dart';
import '../votd/domain/verse_pool.dart';

/// Pushes the current verse (and wallpaper path) to the OS home/lock-screen
/// widget via the `home_widget` bridge.
///
/// iOS: requires a WidgetKit extension target named `VerseWidget` sharing the
/// App Group `group.com.versewall.bible` (see ios/VerseWidget/README.md).
/// Android: an optional AppWidgetProvider `VerseWidgetProvider`.
class HomeWidgetService {
  static const appGroupId = 'group.com.versewall.bible';
  static const iOSWidgetName = 'VerseWidget';
  static const androidWidgetName = 'VerseWidgetProvider';

  static const keyReference = 'widget_reference';
  static const keyText = 'widget_text';
  static const keyImage = 'widget_image';
  static const keyUpdated = 'widget_updated';
  static const keyTranslation = 'widget_translation';

  static bool get supported =>
      !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  static Future<void> init() async {
    if (!supported) return;
    if (Platform.isIOS) {
      await HomeWidget.setAppGroupId(appGroupId);
    }
  }

  /// Daily VOTD path: only writes if the widget has not been updated today
  /// (so a wallpaper rotation earlier today keeps its verse + image), and
  /// preserves whatever image the last rotation stored.
  static Future<void> publishIfStale({
    required BibleDatabase bibleDb,
    required PoolVerse verse,
    required String translation,
  }) async {
    if (!supported) return;
    try {
      await init();
      final raw = await HomeWidget.getWidgetData<String>(keyUpdated);
      final last = raw == null ? null : DateTime.tryParse(raw);
      final now = DateTime.now();
      if (last != null &&
          await HomeWidget.getWidgetData<String>(keyTranslation) ==
              translation &&
          last.year == now.year &&
          last.month == now.month &&
          last.day == now.day) {
        return;
      }
      final image = await HomeWidget.getWidgetData<String>(keyImage);
      await publish(
        bibleDb: bibleDb,
        verse: verse,
        translation: translation,
        imagePath: image,
      );
    } catch (e) {
      debugPrint('home widget daily refresh skipped: $e');
    }
  }

  static Future<void> publish({
    required BibleDatabase bibleDb,
    required PoolVerse verse,
    required String translation,
    String? imagePath,
  }) async {
    if (!supported) return;
    try {
      await init();
      final books = await bibleDb.allBooks();
      final book = books.where((b) => b.id == verse.bookId).firstOrNull;
      if (book == null) return;
      final endVerse = verse.endVerse;
      final ref = StringBuffer(book.name)
        ..write(' ${verse.chapter}:${verse.verse}');
      if (endVerse != null && endVerse != verse.verse) ref.write('-$endVerse');
      ref.write(' $translation');

      final parts = <String>[];
      for (var v = verse.verse; v <= (endVerse ?? verse.verse); v++) {
        final row = await bibleDb.singleVerse(verse.bookId, verse.chapter, v);
        if (row == null || row.body.trim().isEmpty) return;
        parts.add(row.body.trim());
      }

      await HomeWidget.saveWidgetData<String>(keyReference, ref.toString());
      await HomeWidget.saveWidgetData<String>(keyText, parts.join(' '));
      await HomeWidget.saveWidgetData<String>(keyTranslation, translation);
      await HomeWidget.saveWidgetData<String>(keyImage, imagePath ?? '');
      await HomeWidget.saveWidgetData<String>(
        keyUpdated,
        DateTime.now().toIso8601String(),
      );
      await HomeWidget.updateWidget(
        iOSName: iOSWidgetName,
        androidName: androidWidgetName,
        qualifiedAndroidName: 'com.versewall.bible.$androidWidgetName',
      );
    } catch (e) {
      // Widgets are best-effort; never fail the caller.
      debugPrint('home widget update skipped: $e');
    }
  }
}
