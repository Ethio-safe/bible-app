import 'package:drift/backends.dart';
import 'package:drift/web.dart';

QueryExecutor openUserDatabaseExecutor() {
  return WebDatabase('user');
}
