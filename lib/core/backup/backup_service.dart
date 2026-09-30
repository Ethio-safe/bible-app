import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

import '../database/database_providers.dart';
import '../database/user_database.dart';

part 'backup_service.g.dart';

class BackupSummary {
  const BackupSummary({
    required this.highlights,
    required this.bookmarks,
    required this.notes,
  });
  final int highlights;
  final int bookmarks;
  final int notes;
  int get total => highlights + bookmarks + notes;
}

/// Exports/imports user annotations as a portable JSON document.
class BackupService {
  BackupService(this._db);
  final UserDatabase _db;

  static const formatVersion = 1;

  Future<Map<String, Object?>> buildDocument() async {
    final (hl, bm, nt) = await (
      _db.allHighlights(),
      _db.allBookmarks(),
      _db.allNotes(),
    ).wait;
    return {
      'app': 'bible',
      'format': formatVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'highlights': [
        for (final h in hl)
          {
            'bookId': h.bookId,
            'chapter': h.chapter,
            'verseStart': h.verseStart,
            'verseEnd': h.verseEnd,
            'color': h.color,
            'createdAt': h.createdAt.toUtc().toIso8601String(),
          },
      ],
      'bookmarks': [
        for (final b in bm)
          {
            'bookId': b.bookId,
            'chapter': b.chapter,
            'verse': b.verse,
            'createdAt': b.createdAt.toUtc().toIso8601String(),
          },
      ],
      'notes': [
        for (final n in nt)
          {
            'bookId': n.bookId,
            'chapter': n.chapter,
            'verse': n.verse,
            'body': n.body,
            'updatedAt': n.updatedAt.toUtc().toIso8601String(),
          },
      ],
    };
  }

  String encode(Map<String, Object?> doc) =>
      const JsonEncoder.withIndent('  ').convert(doc);

  /// Writes the backup to a temp file and opens the system share sheet.
  Future<BackupSummary> exportAndShare() async {
    final doc = await buildDocument();
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now()
        .toIso8601String()
        .split('.')
        .first
        .replaceAll(':', '-');
    final file = File('${dir.path}/verse-bible-backup-$stamp.json');
    await file.writeAsString(encode(doc));
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: 'Verse Bible backup',
      ),
    );
    return BackupSummary(
      highlights: (doc['highlights'] as List).length,
      bookmarks: (doc['bookmarks'] as List).length,
      notes: (doc['notes'] as List).length,
    );
  }

  /// Lets the user pick a JSON file and merges it. Returns null if cancelled.
  Future<int?> pickAndImport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );
    final picked = result?.files.firstOrNull;
    if (picked == null) return null;
    final bytes = picked.bytes ?? await File(picked.path!).readAsBytes();
    return importJson(utf8.decode(bytes));
  }

  /// Parses and merges a backup document. Throws [FormatException] on bad input.
  Future<int> importJson(String json) async {
    final raw = jsonDecode(json);
    if (raw is! Map || raw['app'] != 'bible') {
      throw const FormatException('Not a Bible backup file');
    }
    final format = raw['format'];
    if (format is! int || format > formatVersion) {
      throw FormatException('Unsupported backup format $format');
    }

    DateTime date(Object? v) => v is String
        ? DateTime.tryParse(v)?.toLocal() ?? DateTime.now()
        : DateTime.now();
    int i(Object? v) =>
        v is int ? v : throw const FormatException('Bad number');

    final hl = [
      for (final h in (raw['highlights'] as List? ?? const []))
        HighlightsCompanion.insert(
          bookId: i(h['bookId']),
          chapter: i(h['chapter']),
          verseStart: i(h['verseStart']),
          verseEnd: i(h['verseEnd']),
          color: i(h['color']),
          createdAt: date(h['createdAt']),
        ),
    ];
    final bm = [
      for (final b in (raw['bookmarks'] as List? ?? const []))
        BookmarksCompanion.insert(
          bookId: i(b['bookId']),
          chapter: i(b['chapter']),
          verse: i(b['verse']),
          createdAt: date(b['createdAt']),
        ),
    ];
    final nt = [
      for (final n in (raw['notes'] as List? ?? const []))
        NotesCompanion.insert(
          bookId: i(n['bookId']),
          chapter: i(n['chapter']),
          verse: i(n['verse']),
          body: n['body'] as String? ?? '',
          updatedAt: date(n['updatedAt']),
        ),
    ];
    return _db.importAll(highlightRows: hl, bookmarkRows: bm, noteRows: nt);
  }
}

@riverpod
BackupService backupService(Ref ref) =>
    BackupService(ref.watch(userDatabaseProvider));
