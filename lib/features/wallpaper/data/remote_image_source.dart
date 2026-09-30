import 'package:dio/dio.dart';

/// A candidate photo from a remote provider, before download.
class RemotePhoto {
  const RemotePhoto({
    required this.id,
    required this.provider,
    required this.downloadUrl,
    required this.authorName,
    required this.authorUrl,
    required this.sourceUrl,
    this.isDark = true,
    this.downloadTrackingUrl,
  });

  final String id;
  final String provider;

  /// Direct image URL, already sized ≈1080 wide where the API allows.
  final String downloadUrl;
  final String authorName;
  final String authorUrl;
  final String sourceUrl;
  final bool isDark;

  /// Unsplash requires a hit to this endpoint when a photo is used.
  final String? downloadTrackingUrl;

  String get key => '${provider}_$id';
}

abstract class RemoteImageSource {
  String get provider;
  bool get isConfigured;
  Future<List<RemotePhoto>> search(String query, {int count = 10});
  Future<void> reportUsed(RemotePhoto photo) async {}
}

/// API keys supplied at build time:
/// `flutter build apk --dart-define=UNSPLASH_KEY=... --dart-define=PEXELS_KEY=...`
class ApiKeys {
  static const unsplash = String.fromEnvironment('UNSPLASH_KEY');
  static const pexels = String.fromEnvironment('PEXELS_KEY');
}

class UnsplashSource implements RemoteImageSource {
  UnsplashSource({Dio? dio, String? key})
    : _dio = dio ?? Dio(),
      _key = key ?? ApiKeys.unsplash;
  final Dio _dio;
  final String _key;

  @override
  String get provider => 'unsplash';
  @override
  bool get isConfigured => _key.isNotEmpty;

  @override
  Future<List<RemotePhoto>> search(String query, {int count = 10}) async {
    final res = await _dio.get<dynamic>(
      'https://api.unsplash.com/photos/random',
      queryParameters: {
        'query': query,
        'orientation': 'portrait',
        'content_filter': 'high',
        'count': count,
      },
      options: Options(headers: {'Authorization': 'Client-ID $_key'}),
    );
    return parse(res.data);
  }

  /// `/photos/random?count=n` returns a JSON array; `/search/photos` wraps
  /// it in `{results: [...]}`. Accept both.
  static List<RemotePhoto> parse(dynamic data) {
    final List list = switch (data) {
      final List l => l,
      final Map m when m['results'] is List => m['results'] as List,
      _ => const [],
    };
    return [
      for (final p in list.cast<Map<String, dynamic>>())
        RemotePhoto(
          id: p['id'] as String,
          provider: 'unsplash',
          downloadUrl: '${p['urls']['raw']}&w=1080&h=1920&fit=crop&q=80&fm=jpg',
          authorName: p['user']?['name'] as String? ?? 'Unknown',
          authorUrl:
              '${p['user']?['links']?['html'] ?? 'https://unsplash.com'}'
              '?utm_source=bible&utm_medium=referral',
          sourceUrl:
              '${p['links']?['html'] ?? 'https://unsplash.com'}'
              '?utm_source=bible&utm_medium=referral',
          downloadTrackingUrl: p['links']?['download_location'] as String?,
          isDark: _isDark(p['color'] as String?),
        ),
    ];
  }

  @override
  Future<void> reportUsed(RemotePhoto photo) async {
    final url = photo.downloadTrackingUrl;
    if (url == null) return;
    try {
      await _dio.get<void>(
        url,
        options: Options(headers: {'Authorization': 'Client-ID $_key'}),
      );
    } catch (_) {
      /* best effort */
    }
  }
}

class PexelsSource implements RemoteImageSource {
  PexelsSource({Dio? dio, String? key})
    : _dio = dio ?? Dio(),
      _key = key ?? ApiKeys.pexels;
  final Dio _dio;
  final String _key;

  @override
  String get provider => 'pexels';
  @override
  bool get isConfigured => _key.isNotEmpty;

  @override
  Future<List<RemotePhoto>> search(String query, {int count = 10}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      'https://api.pexels.com/v1/search',
      queryParameters: {
        'query': query,
        'orientation': 'portrait',
        'per_page': count,
        'page': 1 + DateTime.now().day % 5,
      },
      options: Options(headers: {'Authorization': _key}),
    );
    final list = (res.data?['photos'] as List? ?? const []);
    return parse(list);
  }

  static List<RemotePhoto> parse(List list) => [
    for (final p in list.cast<Map<String, dynamic>>())
      RemotePhoto(
        id: '${p['id']}',
        provider: 'pexels',
        downloadUrl:
            p['src']?['large2x'] as String? ?? p['src']['large'] as String,
        authorName: p['photographer'] as String? ?? 'Unknown',
        authorUrl: p['photographer_url'] as String? ?? 'https://www.pexels.com',
        sourceUrl: p['url'] as String? ?? 'https://www.pexels.com',
        isDark: _isDark(p['avg_color'] as String?),
      ),
  ];

  /// Pexels has no download-tracking endpoint; attribution is enough.
  @override
  Future<void> reportUsed(RemotePhoto photo) async {}
}

bool _isDark(String? hex) {
  if (hex == null || hex.length < 7) return true;
  final r = int.parse(hex.substring(1, 3), radix: 16);
  final g = int.parse(hex.substring(3, 5), radix: 16);
  final b = int.parse(hex.substring(5, 7), radix: 16);
  return (0.299 * r + 0.587 * g + 0.114 * b) < 140;
}

/// Tries each configured source in turn.
class CompositeImageSource implements RemoteImageSource {
  CompositeImageSource(this.sources);
  final List<RemoteImageSource> sources;

  @override
  String get provider => 'composite';
  @override
  bool get isConfigured => sources.any((s) => s.isConfigured);

  @override
  Future<List<RemotePhoto>> search(String query, {int count = 10}) async {
    Object? lastError;
    for (final s in sources.where((s) => s.isConfigured)) {
      try {
        final r = await s.search(query, count: count);
        if (r.isNotEmpty) return r;
      } catch (e) {
        lastError = e;
      }
    }
    if (lastError != null) throw lastError;
    return const [];
  }

  @override
  Future<void> reportUsed(RemotePhoto photo) async {
    for (final s in sources) {
      if (s.provider == photo.provider) return s.reportUsed(photo);
    }
  }
}
