import 'package:dio/dio.dart';

/// API keys supplied at build/run time, e.g.
/// `flutter run --dart-define-from-file=secrets.json` (see secrets.example.json).
/// Never hard-code real keys here; they must not ship in source control.
class AiApiKeys {
  static const grok = String.fromEnvironment('GROK_KEY');
  static const gemini = String.fromEnvironment('GEMINI_KEY');
  static const openAi = String.fromEnvironment('OPENAI_KEY');
}

const String bibleStudySystemPrompt = '''
You are a professional Bible study assistant. You are careful, reverent, and grounded in Scripture. You are familiar with the major biblical traditions, historical context, and the translations bundled in this app.

Your role is to help the user understand the Bible accurately and practically. Use the passages supplied by the app as your primary source of truth. Never invent verses, chapter numbers, or references. If the context is limited or unclear, say so plainly.

When answering:
- explain the question from the provided Bible passages
- distinguish between what the text says and what may be personal application
- if different editions disagree, acknowledge the difference instead of hiding it
- keep the answer clear, respectful, and concise
- format the answer in Markdown with headings, bold emphasis, and bullet lists when useful
- finish with:
  1. Key theme words: 2–5 short words
  2. Suggested passages to read in this app: 3 references using only the provided context or closely connected references already visible in the app
  3. A brief note that the user should read the actual Bible text in the app for deeper study

If the provided passages are sparse or empty, still answer the question from careful Bible understanding, but clearly label the answer as general guidance and then suggest a few relevant passages the user can open in the app for deeper reading.
''';

/// Thrown when every configured provider failed to answer.
class AiUnavailableException implements Exception {
  const AiUnavailableException(this.message);
  final String message;
  @override
  String toString() => message;
}

abstract class AiProviderClient {
  String get provider;
  bool get isConfigured;
  Future<String> ask(String prompt, {String? systemPrompt});
}

class GrokClient implements AiProviderClient {
  GrokClient({Dio? dio, String? key, String? model})
    : _dio = dio ?? Dio(),
      _key = key ?? AiApiKeys.grok,
      _model =
          model ??
          const String.fromEnvironment(
            'GROK_MODEL',
            defaultValue: 'grok-3-mini',
          );

  final Dio _dio;
  final String _key;
  final String _model;

  @override
  String get provider => 'grok';

  @override
  bool get isConfigured => _key.isNotEmpty;

  @override
  Future<String> ask(String prompt, {String? systemPrompt}) async {
    final messages = <Map<String, String>>[];
    if ((systemPrompt ?? '').trim().isNotEmpty) {
      messages.add({'role': 'system', 'content': systemPrompt!});
    }
    messages.add({'role': 'user', 'content': prompt});

    final res = await _dio.post<Map<String, dynamic>>(
      'https://api.x.ai/v1/chat/completions',
      options: Options(headers: {'Authorization': 'Bearer $_key'}),
      data: {
        'model': _model,
        'messages': messages,
      },
    );
    final choices = res.data?['choices'] as List?;
    final content = (choices?.first as Map?)?['message']?['content'] as String?;
    if (content == null || content.isEmpty) {
      throw const AiUnavailableException('Grok returned an empty response.');
    }
    return content;
  }
}

class GeminiClient implements AiProviderClient {
  GeminiClient({Dio? dio, String? key, String? model})
    : _dio = dio ?? Dio(),
      _key = key ?? AiApiKeys.gemini,
      _model =
          model ??
          const String.fromEnvironment(
            'GEMINI_MODEL',
            // gemini-2.0-flash and gemini-2.5-flash were both retired for
            // new users; Google's API now points new callers at 3.6-flash.
            defaultValue: 'gemini-3.6-flash',
          );

  final Dio _dio;
  final String _key;
  final String _model;

  @override
  String get provider => 'gemini';

  @override
  bool get isConfigured => _key.isNotEmpty;

  @override
  Future<String> ask(String prompt, {String? systemPrompt}) async {
    final payload = <String, dynamic>{
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
    };
    if ((systemPrompt ?? '').trim().isNotEmpty) {
      payload['systemInstruction'] = {
        'parts': [
          {'text': systemPrompt!},
        ],
      };
    }

    final res = await _dio.post<Map<String, dynamic>>(
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent',
      queryParameters: {'key': _key},
      data: payload,
    );
    final candidates = res.data?['candidates'] as List?;
    final parts = (candidates?.first as Map?)?['content']?['parts'] as List?;
    final content = (parts?.first as Map?)?['text'] as String?;
    if (content == null || content.isEmpty) {
      throw const AiUnavailableException('Gemini returned an empty response.');
    }
    return content;
  }
}

class OpenAiClient implements AiProviderClient {
  OpenAiClient({Dio? dio, String? key, String? model})
    : _dio = dio ?? Dio(),
      _key = key ?? AiApiKeys.openAi,
      _model =
          model ??
          const String.fromEnvironment(
            'OPENAI_MODEL',
            defaultValue: 'gpt-4o-mini',
          );

  final Dio _dio;
  final String _key;
  final String _model;

  @override
  String get provider => 'openai';

  @override
  bool get isConfigured => _key.isNotEmpty;

  @override
  Future<String> ask(String prompt, {String? systemPrompt}) async {
    final messages = <Map<String, String>>[];
    if ((systemPrompt ?? '').trim().isNotEmpty) {
      messages.add({'role': 'system', 'content': systemPrompt!});
    }
    messages.add({'role': 'user', 'content': prompt});

    final res = await _dio.post<Map<String, dynamic>>(
      'https://api.openai.com/v1/chat/completions',
      options: Options(headers: {'Authorization': 'Bearer $_key'}),
      data: {
        'model': _model,
        'messages': messages,
      },
    );
    final choices = res.data?['choices'] as List?;
    final content = (choices?.first as Map?)?['message']?['content'] as String?;
    if (content == null || content.isEmpty) {
      throw const AiUnavailableException('OpenAI returned an empty response.');
    }
    return content;
  }
}

/// Tries each configured provider in order and falls through to the next one
/// on any failure (auth error, rate limit, quota exceeded, network error, …).
class MultiProviderAiClient {
  MultiProviderAiClient({List<AiProviderClient>? providers})
    : _providers = providers ?? [GrokClient(), GeminiClient(), OpenAiClient()];

  final List<AiProviderClient> _providers;

  bool get isConfigured => _providers.any((p) => p.isConfigured);

  Future<String> ask(String prompt, {String? systemPrompt}) async {
    final errors = <String>[];
    for (final client in _providers.where((p) => p.isConfigured)) {
      try {
        return await client.ask(prompt, systemPrompt: systemPrompt);
      } catch (error) {
        errors.add('${client.provider}: $error');
      }
    }
    if (errors.isEmpty) {
      throw const AiUnavailableException(
        'No AI provider is configured. Build with --dart-define-from-file=secrets.json.',
      );
    }
    throw AiUnavailableException(
      'All AI providers failed:\n${errors.join('\n')}',
    );
  }
}
