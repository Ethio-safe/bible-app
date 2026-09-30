import 'package:drift/backends.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

QueryExecutor openUserDatabaseExecutor() {
  return driftDatabase(
    name: 'user',
    native: DriftNativeOptions(
      databaseDirectory: getApplicationSupportDirectory,
    ),
  );
}
