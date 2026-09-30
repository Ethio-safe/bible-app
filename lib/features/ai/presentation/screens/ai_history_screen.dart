import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/storage/preferences_provider.dart';
import '../../data/ai_chat_history_store.dart';
import '../../domain/ai_chat_session.dart';

/// Sentinel returned when the user wants to start a brand new conversation.
const aiHistoryNewSessionResult = '__new__';

/// Lists saved AI conversations so the user can reopen or delete them.
///
/// Pops with the selected session id, [aiHistoryNewSessionResult] to start a
/// new chat, or null if dismissed without a choice.
class AiHistoryScreen extends ConsumerStatefulWidget {
  const AiHistoryScreen({super.key});

  @override
  ConsumerState<AiHistoryScreen> createState() => _AiHistoryScreenState();
}

class _AiHistoryScreenState extends ConsumerState<AiHistoryScreen> {
  late final _store = AiChatHistoryStore(ref.read(sharedPreferencesProvider));
  final _sessions = <AiChatSession>[];

  @override
  void initState() {
    super.initState();
    _sessions.addAll(_store.loadSessions());
  }

  Future<void> _delete(AiChatSession session) async {
    setState(() => _sessions.removeWhere((s) => s.id == session.id));
    await _store.deleteSession(session.id);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd().add_jm();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat history'),
        actions: [
          IconButton(
            tooltip: 'New chat',
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () =>
                Navigator.of(context).pop(aiHistoryNewSessionResult),
          ),
        ],
      ),
      body: _sessions.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No past conversations yet. Ask the Bible AI a question to start one.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _sessions.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final session = _sessions[index];
                return Dismissible(
                  key: ValueKey(session.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Theme.of(context).colorScheme.errorContainer,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  onDismissed: (_) => _delete(session),
                  child: ListTile(
                    title: Text(
                      session.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${dateFormat.format(session.updatedAt)}\n${session.preview}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    leading: const Icon(Icons.chat_bubble_outline),
                    trailing: IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(session),
                    ),
                    onTap: () => Navigator.of(context).pop(session.id),
                  ),
                );
              },
            ),
    );
  }
}
