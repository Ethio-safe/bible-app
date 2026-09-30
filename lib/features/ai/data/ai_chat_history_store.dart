import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/ai_chat_session.dart';

/// Persists AI chat conversations as a list of sessions in [SharedPreferences].
class AiChatHistoryStore {
  AiChatHistoryStore(this._prefs);

  static const _sessionsKey = 'ai_chat_sessions';
  static const _currentSessionIdKey = 'ai_current_session_id';
  static const maxMessagesPerSession = 100;
  static const maxSessions = 50;

  final SharedPreferences _prefs;

  List<AiChatSession> loadSessions() {
    final stored = _prefs.getStringList(_sessionsKey);
    if (stored == null) return <AiChatSession>[];
    final sessions = <AiChatSession>[];
    for (final encoded in stored) {
      try {
        final value = jsonDecode(encoded);
        if (value is Map<String, dynamic>) {
          sessions.add(AiChatSession.fromJson(value));
        }
      } on FormatException {
        // Ignore entries written by an older or interrupted save.
      }
    }
    sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sessions;
  }

  Future<void> saveSessions(List<AiChatSession> sessions) async {
    final trimmed =
        (sessions.toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)))
            .take(maxSessions)
            .map((s) => jsonEncode(s.toJson()))
            .toList(growable: false);
    await _prefs.setStringList(_sessionsKey, trimmed);
  }

  String? get currentSessionId => _prefs.getString(_currentSessionIdKey);

  Future<void> setCurrentSessionId(String? id) async {
    if (id == null) {
      await _prefs.remove(_currentSessionIdKey);
    } else {
      await _prefs.setString(_currentSessionIdKey, id);
    }
  }

  Future<void> deleteSession(String id) async {
    final sessions = loadSessions()..removeWhere((s) => s.id == id);
    await saveSessions(sessions);
    if (currentSessionId == id) await setCurrentSessionId(null);
  }

  Future<void> clearAll() async {
    await _prefs.remove(_sessionsKey);
    await _prefs.remove(_currentSessionIdKey);
  }
}
