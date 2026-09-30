import 'dart:io';

import 'package:drift/backends.dart';
import 'package:drift/native.dart';

QueryExecutor openBibleExecutor(String path) {
  return NativeDatabase.createInBackground(
    File(path),
    enableMigrations: false,
    setup: (db) => db.execute('PRAGMA query_only = 1;'),
  );
}
