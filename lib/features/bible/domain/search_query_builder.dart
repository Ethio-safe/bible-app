/// Converts free text typed by the user into a safe FTS5 MATCH expression.
///
/// Rules:
///  * Quoted phrases are preserved:  `"still waters"`  → `"still waters"`
///  * Bare words become prefix terms:  `shep`  → `"shep"*`
///  * Everything else (operators, punctuation) is stripped so user input can
///    never produce an FTS syntax error.
///  * Returns `null` when nothing searchable remains.
String? buildFtsQuery(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;

  final tokens = <String>[];
  final phrase = RegExp(r'"([^"]+)"');
  var rest = trimmed;

  for (final m in phrase.allMatches(trimmed)) {
    final inner = _clean(m.group(1)!);
    if (inner.isNotEmpty) tokens.add('"$inner"');
  }
  rest = trimmed.replaceAll(phrase, ' ');

  final bareWord = RegExp(r"[\p{L}\p{N}]+(?:'[\p{L}\p{N}]+)*", unicode: true);
  for (final match in bareWord.allMatches(rest)) {
    // Prefix match on each word so "lov" finds love/loved/loveth.
    tokens.add('"${match.group(0)!}"*');
  }

  return tokens.isEmpty ? null : tokens.join(' ');
}

/// Reduces a natural-language question to the main Bible topic for retrieval.
///
/// Examples:
///  * `Explain faith` → `faith`
///  * `What is love` → `love`
///  * `Tell me about forgiveness and grace` → `forgiveness grace`
String normalizeBibleSearchTopic(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return trimmed;

  final fillerWords = {
    'explain',
    'define',
    'what',
    'is',
    'are',
    'was',
    'were',
    'tell',
    'me',
    'about',
    'describe',
    'please',
    'show',
    'give',
    'us',
    'the',
    'a',
    'an',
    'of',
    'for',
    'to',
    'in',
    'on',
    'with',
    'and',
    'or',
    'from',
    'bible',
    'scripture',
    'verse',
    'verses',
  };

  final tokens = <String>[];
  final phrase = RegExp(r'"([^"]+)"');
  for (final match in phrase.allMatches(trimmed)) {
    final inner = _clean(match.group(1)!);
    if (inner.isNotEmpty) tokens.add(inner);
  }

  final bareWord = RegExp(r"[\p{L}\p{N}]+(?:'[\p{L}\p{N}]+)*", unicode: true);
  for (final match in bareWord.allMatches(trimmed.replaceAll(phrase, ' '))) {
    final word = match.group(0)!.toLowerCase();
    if (!fillerWords.contains(word)) tokens.add(word);
  }

  return tokens.isEmpty ? trimmed : tokens.join(' ');
}

/// Keep letters, digits and apostrophes; FTS tokenizer handles the rest.
String _clean(String s) => s
    .replaceAll(RegExp(r"[^\p{L}\p{N}' ]", unicode: true), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();
