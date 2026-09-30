import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/storage/preferences_provider.dart';
import '../../../bible/domain/entities/search_result.dart';
import '../../../bible/domain/search_query_builder.dart';
import '../../../bible/presentation/providers/bible_providers.dart';
import '../../data/ai_chat_history_store.dart';
import '../../data/ai_client.dart';
import '../../data/multi_bible_search.dart';
import '../../domain/ai_chat_session.dart';
import 'ai_history_screen.dart';

final RegExp _bibleReferencePattern = _buildBibleReferencePattern();

const Map<String, int> _bibleBookIds = {
  'Genesis': 1,
  'Exodus': 2,
  'Leviticus': 3,
  'Numbers': 4,
  'Deuteronomy': 5,
  'Joshua': 6,
  'Judges': 7,
  'Ruth': 8,
  '1 Samuel': 9,
  '2 Samuel': 10,
  '1 Kings': 11,
  '2 Kings': 12,
  '1 Chronicles': 13,
  '2 Chronicles': 14,
  'Ezra': 15,
  'Nehemiah': 16,
  'Esther': 17,
  'Job': 18,
  'Psalms': 19,
  'Proverbs': 20,
  'Ecclesiastes': 21,
  'Song of Solomon': 22,
  'Isaiah': 23,
  'Jeremiah': 24,
  'Lamentations': 25,
  'Ezekiel': 26,
  'Daniel': 27,
  'Hosea': 28,
  'Joel': 29,
  'Amos': 30,
  'Obadiah': 31,
  'Jonah': 32,
  'Micah': 33,
  'Nahum': 34,
  'Habakkuk': 35,
  'Zephaniah': 36,
  'Haggai': 37,
  'Zechariah': 38,
  'Malachi': 39,
  'Matthew': 40,
  'Mark': 41,
  'Luke': 42,
  'John': 43,
  'Acts': 44,
  'Romans': 45,
  '1 Corinthians': 46,
  '2 Corinthians': 47,
  'Galatians': 48,
  'Ephesians': 49,
  'Philippians': 50,
  'Colossians': 51,
  '1 Thessalonians': 52,
  '2 Thessalonians': 53,
  '1 Timothy': 54,
  '2 Timothy': 55,
  'Titus': 56,
  'Philemon': 57,
  'Hebrews': 58,
  'James': 59,
  '1 Peter': 60,
  '2 Peter': 61,
  '1 John': 62,
  '2 John': 63,
  '3 John': 64,
  'Jude': 65,
  'Revelation': 66,
};

const Map<String, String> _bibleBookAliases = {
  'Psalm': 'Psalms',
  'Psalms': 'Psalms',
  'Song of Songs': 'Song of Solomon',
  'Song of Solomon': 'Song of Solomon',
};

RegExp _buildBibleReferencePattern() {
  final books = [
    ..._bibleBookIds.keys,
    ..._bibleBookAliases.keys,
  ].toSet().toList()
    ..sort((a, b) => b.length.compareTo(a.length));
  final escaped = books.map(RegExp.escape).join('|');
  return RegExp(
    '(?<![\\w])($escaped)\\s+(\\d+):(\\d+)(?:-(\\d+))?',
    caseSensitive: false,
  );
}

class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});

  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen> {
  static const _maxHistoryMessages = AiChatHistoryStore.maxMessagesPerSession;
  static final _idRandom = Random();

  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_StudyMessage>[];
  bool _busy = false;
  late final _store = AiChatHistoryStore(ref.read(sharedPreferencesProvider));
  final _aiClient = MultiProviderAiClient();
  String? _sessionId;

  @override
  void initState() {
    super.initState();
    _loadSession(_store.currentSessionId);
  }

  void _loadSession(String? sessionId) {
    _messages.clear();
    _sessionId = sessionId;
    if (sessionId != null) {
      final matches = _store.loadSessions().where((s) => s.id == sessionId);
      final session = matches.isEmpty ? null : matches.first;
      if (session != null) {
        for (final message in session.messages) {
          _messages.add(
            _StudyMessage(
              text: message.text,
              isUser: message.isUser,
              results: const [],
            ),
          );
        }
      }
    }
  }

  Future<void> _persistHistory() async {
    _sessionId ??=
        '${DateTime.now().microsecondsSinceEpoch}'
        // Use a decimal literal, not `1 << 32`: on web, Dart's `<<` wraps to
        // 32 bits and evaluates to 0, which crashes `nextInt`.
        '${_idRandom.nextInt(4294967296)}';
    await _store.setCurrentSessionId(_sessionId);
    final sessions = _store.loadSessions()
      ..removeWhere((s) => s.id == _sessionId);
    sessions.add(
      AiChatSession(
        id: _sessionId!,
        updatedAt: DateTime.now(),
        messages: _messages
            .take(_maxHistoryMessages)
            .map((m) => AiChatMessageData(text: m.text, isUser: m.isUser))
            .toList(growable: false),
      ),
    );
    await _store.saveSessions(sessions);
  }

  Future<void> _openHistory() async {
    final result = await context.push<String>(AppRoutes.aiHistory);
    if (!mounted || result == null) return;
    setState(() {
      if (result == aiHistoryNewSessionResult) {
        _messages.clear();
        _sessionId = null;
        unawaited(_store.setCurrentSessionId(null));
      } else {
        _loadSession(result);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _ask([String? suggested]) async {
    final question = (suggested ?? _controller.text).trim();
    if (question.isEmpty || _busy) return;
    _controller.clear();
    setState(() {
      _busy = true;
      _messages.add(_StudyMessage.user(question));
    });
    unawaited(_persistHistory());
    _scrollToEnd();

    try {
      final repository = await ref.read(bibleRepositoryProvider.future);
      final searchTopic = normalizeBibleSearchTopic(question);
      final fts = buildFtsQuery(searchTopic);
      final results = fts == null
          ? const <SearchResult>[]
          : (await repository.searchDetailed(fts, limit: 8)).hits;
      final translation = await ref.read(currentTranslationProvider.future);
      final answer = await _aiAnswer(
        question,
        results,
        translation.abbreviation,
        searchTopic: searchTopic,
      );
      if (!mounted) return;
      setState(() => _messages.add(_StudyMessage.assistant(answer, results)));
      unawaited(_persistHistory());
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _messages.add(
          _StudyMessage.assistant(
            'I could not search the selected Bible edition. Please try again.\n\n$error',
            const [],
          ),
        ),
      );
      unawaited(_persistHistory());
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        _scrollToEnd();
      }
    }
  }

  /// Asks the configured AI providers, grounding the answer in search hits
  /// from all 5 bundled bibles; falls back to the plain search summary on
  /// failure or when no provider key is configured.
  Future<String> _aiAnswer(
    String question,
    List<SearchResult> results,
    String abbreviation,
    {String? searchTopic}
  ) async {
    final currentContext = results
        .take(5)
        .map((r) => '${r.reference}: ${r.text}')
        .join('\n');
    final otherTranslations = await searchAllTranslations(
      ref,
      searchTopic ?? normalizeBibleSearchTopic(question),
    );
    final otherContext = otherTranslations
        .where((t) => t.abbreviation != abbreviation)
        .map(
          (t) =>
              '[${t.abbreviation}]\n'
              '${t.hits.map((r) => '${r.reference}: ${r.text}').join('\n')}',
        )
        .join('\n\n');
    final prompt =
        'You are helping a user study the Bible. The passages below are real search hits from the app. Use them as supporting evidence, not as a rigid limitation on your answer.\n\n'
        'Question: $question\n\n'
        'Primary edition ($abbreviation) passages:\n'
        '${currentContext.isEmpty ? '(none found)' : currentContext}\n\n'
        'Other editions:\n'
        '${otherContext.isEmpty ? '(none found)' : otherContext}\n\n'
        'Please answer clearly and faithfully in Markdown. If the passages are sparse, still give a careful general Bible-based explanation and then point the user to related readings in the app. Finish with:\n'
        '1. Key theme words: 2–5 short words\n'
        '2. Suggested passages to read in this app: 3 references\n'
        '3. Brief note: read the actual Bible text in the app for deeper study.';
    try {
      return await _aiClient.ask(prompt, systemPrompt: bibleStudySystemPrompt);
    } on AiUnavailableException {
      return _localAnswer(question, results, abbreviation);
    }
  }

  String _localAnswer(
    String question,
    List<SearchResult> results,
    String abbreviation,
  ) {
    if (results.isEmpty) {
      return '### No direct match found\n\nI could not find matching passages in $abbreviation. Try a topic or phrase such as “faith”, “forgiveness”, or “love”.\n\n**Suggested passages to read in the app:** look up “faith”, “love”, or “forgiveness” in the current Bible edition and read the surrounding verses.';
    }
    final lead = question.toLowerCase().contains('compare')
        ? 'Here are the closest passages I found for comparison in $abbreviation:'
        : 'Here are the closest passages I found in $abbreviation. Read the cited passages in context:';
    final keyWords = _extractThemeWords(question, results);
    final suggestions = results.take(3).map((result) => result.reference).join(', ');
    return '### Bible passages\n\n$lead\n\n${results.take(3).map((result) => '**${result.reference}**  \n${result.text}').join('\n\n')}\n\n**Key theme words:** $keyWords\n\n**Suggested passages to read in this app:** $suggestions\n\nRead the actual Bible text in the app for deeper study.';
  }

  String _extractThemeWords(String question, List<SearchResult> results) {
    final words = <String>[];
    final normalized = question.toLowerCase();
    if (normalized.contains('faith')) words.add('faith');
    if (normalized.contains('love')) words.add('love');
    if (normalized.contains('forgiveness')) words.add('forgiveness');
    if (normalized.contains('hope')) words.add('hope');
    if (normalized.contains('grace')) words.add('grace');
    if (normalized.contains('compare')) words.add('comparison');
    if (words.isEmpty) {
      for (final r in results.take(3)) {
        final text = r.text.toLowerCase();
        if (text.contains('love')) words.add('love');
        if (text.contains('faith')) words.add('faith');
        if (text.contains('hope')) words.add('hope');
        if (text.contains('grace')) words.add('grace');
        if (words.length >= 3) break;
      }
    }
    if (words.isEmpty) return 'study, reflection, scripture';
    return words.take(4).join(', ');
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      'Explain faith',
      'Find verses about forgiveness',
      'Compare love and patience',
    ];
    return Scaffold(
      appBar: AppBar(
        title: const SizedBox.shrink(),
        actions: [
          IconButton(
            tooltip: 'Chat history',
            icon: const Icon(Icons.history),
            onPressed: _openHistory,
          ),
          IconButton(
            tooltip: 'Clear conversation',
            icon: const Icon(Icons.delete_outline),
            onPressed: _messages.isEmpty
                ? null
                : () {
                    setState(_messages.clear);
                    if (_sessionId != null) {
                      unawaited(_store.deleteSession(_sessionId!));
                      _sessionId = null;
                    }
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_messages.isEmpty)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 42,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Ask about the Bible',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'I search the selected edition first and show the passages behind each answer.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  for (final suggestion in suggestions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: OutlinedButton.icon(
                        onPressed: () => _ask(suggestion),
                        icon: const Icon(Icons.search),
                        label: Text(suggestion),
                      ),
                    ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                itemCount: _messages.length + (_busy ? 1 : 0),
                itemBuilder: (context, index) => _MessageBubble(
                  message: index < _messages.length
                      ? _messages[index]
                      : const _StudyMessage.typing(),
                  onOpenResult: (result) => context.push(
                    AppRoutes.reader(
                      result.book.id,
                      result.chapter,
                      verse: result.verse,
                    ),
                  ),
                  onOpenBibleLink: (link) => context.push(
                    AppRoutes.reader(
                      link.bookId,
                      link.chapter,
                      verse: link.verse,
                    ),
                  ),
                ),
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _ask(),
                      decoration: const InputDecoration(
                        hintText: 'Ask a Bible question',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Ask',
                    onPressed: _busy ? null : _ask,
                    icon: _busy
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_upward),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudyMessage {
  const _StudyMessage({
    required this.text,
    required this.isUser,
    required this.results,
    this.isTyping = false,
  });
  const _StudyMessage.user(String text)
    : this(text: text, isUser: true, results: const []);
  const _StudyMessage.assistant(String text, List<SearchResult> results)
    : this(text: text, isUser: false, results: results);
  const _StudyMessage.typing()
    : this(text: '', isUser: false, results: const [], isTyping: true);

  final String text;
  final bool isUser;
  final List<SearchResult> results;
  final bool isTyping;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.onOpenResult,
    required this.onOpenBibleLink,
  });
  final _StudyMessage message;
  final ValueChanged<SearchResult> onOpenResult;
  final ValueChanged<_BibleLinkTarget> onOpenBibleLink;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 620),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: message.isUser
              ? scheme.primaryContainer
              : scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.isTyping)
              const _TypingDots()
            else if (message.isUser)
              Text(message.text)
            else
              _FormattedAssistantText(
                text: message.text,
                onOpenBibleLink: onOpenBibleLink,
              ),
            if (!message.isUser && message.results.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (final result in message.results.take(5))
                TextButton.icon(
                  onPressed: () => onOpenResult(result),
                  icon: const Icon(Icons.menu_book_outlined, size: 18),
                  label: Text(result.reference),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        Widget dot(int index) {
          final t = (_controller.value * 3 - index).clamp(0.0, 1.0);
          final opacity = 0.35 + (0.65 * (t <= 0.5 ? t * 2 : (1 - t) * 2));
          final size = 8.0 + 3.0 * (t <= 0.5 ? t * 2 : (1 - t) * 2);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [dot(0), dot(1), dot(2)],
          ),
        );
      },
    );
  }
}

String _normalizeBookName(String book) {
  final trimmed = book.trim();
  return _bibleBookAliases[trimmed] ?? trimmed;
}

class _BibleLinkTarget {
  const _BibleLinkTarget({
    required this.bookId,
    required this.chapter,
    required this.verse,
  });

  final int bookId;
  final int chapter;
  final int verse;
}

class _FormattedAssistantText extends StatelessWidget {
  const _FormattedAssistantText({
    required this.text,
    required this.onOpenBibleLink,
  });

  final String text;
  final ValueChanged<_BibleLinkTarget> onOpenBibleLink;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1.45,
          color: scheme.onSurface,
        ) ??
        TextStyle(color: scheme.onSurface, height: 1.45);
    final heading1 = Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          height: 1.15,
          color: scheme.onSurface,
        ) ??
        base.copyWith(fontSize: 22, fontWeight: FontWeight.w800);
    final heading2 = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          height: 1.2,
          color: scheme.onSurface,
        ) ??
        base.copyWith(fontSize: 18, fontWeight: FontWeight.w800);
    final heading3 = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          height: 1.25,
          color: scheme.onSurface,
        ) ??
        base.copyWith(fontSize: 16, fontWeight: FontWeight.w700);
    final link = base.copyWith(
      color: scheme.primary,
      decoration: TextDecoration.underline,
      decorationColor: scheme.primary,
    );

    final blocks = _buildAssistantBlocks(
      text,
      baseStyle: base,
      heading1Style: heading1,
      heading2Style: heading2,
      heading3Style: heading3,
      linkStyle: link,
      onOpenBibleLink: onOpenBibleLink,
      scheme: scheme,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks,
    );
  }
}

List<Widget> _buildAssistantBlocks(
  String text, {
  required TextStyle baseStyle,
  required TextStyle heading1Style,
  required TextStyle heading2Style,
  required TextStyle heading3Style,
  required TextStyle linkStyle,
  required ValueChanged<_BibleLinkTarget> onOpenBibleLink,
  required ColorScheme scheme,
}) {
  final lines = text.split('\n');
  final widgets = <Widget>[];
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final trimmed = line.trim();
    if (trimmed.isEmpty) {
      widgets.add(const SizedBox(height: 8));
      continue;
    }
    if (trimmed == '---' || trimmed == '***') {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Divider(color: scheme.outlineVariant, height: 1),
        ),
      );
      continue;
    }

    final heading = RegExp(r'^(#{1,6})\s+(.*)$').firstMatch(trimmed);
    if (heading != null) {
      final level = heading.group(1)!.length;
      final title = heading.group(2)!;
      final style = level <= 1
          ? heading1Style
          : level == 2
              ? heading2Style
              : heading3Style;
      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: level <= 2 ? 6 : 4),
          child: RichText(
            text: TextSpan(
              style: style,
              children: _buildInlineSpans(
                title,
                style,
                linkStyle,
                onOpenBibleLink,
              ),
            ),
          ),
        ),
      );
      continue;
    }

    final bullet = RegExp(r'^([-*])\s+(.*)$').firstMatch(trimmed);
    if (bullet != null) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ', style: baseStyle),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: baseStyle,
                    children: _buildInlineSpans(
                      bullet.group(2)!,
                      baseStyle,
                      linkStyle,
                      onOpenBibleLink,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      continue;
    }

    final numbered = RegExp(r'^(\d+)\.\s+(.*)$').firstMatch(trimmed);
    if (numbered != null) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${numbered.group(1)}. ', style: baseStyle),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: baseStyle,
                    children: _buildInlineSpans(
                      numbered.group(2)!,
                      baseStyle,
                      linkStyle,
                      onOpenBibleLink,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      continue;
    }

    widgets.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: RichText(
          text: TextSpan(
            style: baseStyle,
            children: _buildInlineSpans(
              line,
              baseStyle,
              linkStyle,
              onOpenBibleLink,
            ),
          ),
        ),
      ),
    );
  }
  return widgets;
}

List<InlineSpan> _buildInlineSpans(
  String text,
  TextStyle baseStyle,
  TextStyle linkStyle,
  ValueChanged<_BibleLinkTarget> onOpenBibleLink,
) {
  final spans = <InlineSpan>[];
  var index = 0;
  while (index < text.length) {
    final ref = _bibleReferencePattern.matchAsPrefix(text.substring(index));
    if (ref != null) {
      final absolute = index;
      final matchText = ref.group(0)!;
      final book = _normalizeBookName(ref.group(1)!);
      final bookId = _bibleBookIds[book];
      if (bookId != null) {
        final chapter = int.parse(ref.group(2)!);
        final verse = int.parse(ref.group(3)!);
        final linkTarget = _BibleLinkTarget(
          bookId: bookId,
          chapter: chapter,
          verse: verse,
        );
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: _BibleReferenceLink(
              text: matchText,
              style: linkStyle,
              onTap: () => onOpenBibleLink(linkTarget),
            ),
          ),
        );
        index = absolute + matchText.length;
        continue;
      }
    }

    if (text.startsWith('**', index)) {
      final end = text.indexOf('**', index + 2);
      if (end != -1) {
        final inner = text.substring(index + 2, end);
        spans.addAll(
          _buildInlineSpans(
            inner,
            baseStyle.copyWith(fontWeight: FontWeight.w700),
            linkStyle.copyWith(fontWeight: FontWeight.w700),
            onOpenBibleLink,
          ),
        );
        index = end + 2;
        continue;
      }
    }

    if (text[index] == '*' && !text.startsWith('**', index)) {
      final end = text.indexOf('*', index + 1);
      if (end != -1) {
        final inner = text.substring(index + 1, end);
        spans.addAll(
          _buildInlineSpans(
            inner,
            baseStyle.copyWith(fontStyle: FontStyle.italic),
            linkStyle.copyWith(fontStyle: FontStyle.italic),
            onOpenBibleLink,
          ),
        );
        index = end + 1;
        continue;
      }
    }

    var next = text.length;
    final refMatch = _bibleReferencePattern.firstMatch(text.substring(index));
    if (refMatch != null) {
      next = index + refMatch.start;
    }
    final bold = text.indexOf('**', index);
    if (bold != -1 && bold < next) next = bold;
    final italic = text.indexOf('*', index);
    if (italic != -1 && italic < next) next = italic;
    if (next == index) next++;
    spans.add(TextSpan(text: text.substring(index, next), style: baseStyle));
    index = next;
  }
  return spans;
}

class _BibleReferenceLink extends StatelessWidget {
  const _BibleReferenceLink({
    required this.text,
    required this.style,
    required this.onTap,
  });

  final String text;
  final TextStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(text, style: style),
    );
  }
}
