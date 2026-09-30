import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/random_verse.dart';

abstract class RandomVersesLocalSource {
  Future<List<RandomVerse>> getVerses();
  Future<void> saveVerses(List<RandomVerse> verses);
  Future<void> clearVerses();
}

class RandomVersesLocalSourceImpl implements RandomVersesLocalSource {
  final SharedPreferences prefs;

  RandomVersesLocalSourceImpl(this.prefs);

  static const _key = 'lockscreen_random_verses';

  @override
  Future<List<RandomVerse>> getVerses() async {
    final json = prefs.getString(_key);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List;
      return list.map((e) => RandomVerse.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveVerses(List<RandomVerse> verses) async {
    final json = jsonEncode(verses.map((v) => v.toJson()).toList());
    await prefs.setString(_key, json);
  }

  @override
  Future<void> clearVerses() async {
    await prefs.remove(_key);
  }
}
