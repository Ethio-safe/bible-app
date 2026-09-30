export 'bible_database_executor_stub.dart'
    if (dart.library.io) 'bible_database_executor_native.dart'
    if (dart.library.html) 'bible_database_executor_web.dart';
