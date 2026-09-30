import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/services.dart';

import 'bundled_bibles.dart';

/// Uses drift's WASM sqlite3 build (unlike the legacy sql.js backend, it has
/// FTS5 compiled in, which the Bible search feature requires) with a
/// versioned per-translation database name so bumping [BundledBibles.
/// bundledDbVersion] re-imports the asset instead of serving a stale copy.
QueryExecutor openBibleExecutor(String path) {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName:
          'bible_${_safeName(path)}_v${BundledBibles.bundledDbVersion}',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
      initializeDatabase: () async {
        final data = await rootBundle.load(path);
        return data.buffer.asUint8List();
      },
    );
    return result.resolvedExecutor;
  });
}

String _safeName(String path) => path.split('/').last.replaceAll('.', '_');
