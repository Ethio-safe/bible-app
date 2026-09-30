import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/chapter.dart';

part 'verse_selection_provider.g.dart';

/// Verses currently selected in a chapter (verse numbers). Scoped per chapter
/// so swiping to another page starts with an empty selection.
@riverpod
class VerseSelection extends _$VerseSelection {
  @override
  Set<int> build(ChapterId id) => const {};

  void toggle(int verse) {
    state = state.contains(verse)
        ? ({...state}..remove(verse))
        : {...state, verse};
  }

  void select(Set<int> verses) => state = {...verses};

  void clear() => state = const {};

  bool get isEmpty => state.isEmpty;
}

/// Convenience: sorted list of the selection.
extension VerseSelectionX on Set<int> {
  List<int> get sorted => toList()..sort();

  /// Contiguous ranges, e.g. {1,2,3,7} → [(1,3),(7,7)].
  List<(int, int)> get ranges {
    final s = sorted;
    if (s.isEmpty) return const [];
    final out = <(int, int)>[];
    var start = s.first;
    var prev = s.first;
    for (final v in s.skip(1)) {
      if (v != prev + 1) {
        out.add((start, prev));
        start = v;
      }
      prev = v;
    }
    out.add((start, prev));
    return out;
  }

  /// Human label like "3, 5–7".
  String get label => ranges
      .map((r) => r.$1 == r.$2 ? '${r.$1}' : '${r.$1}–${r.$2}')
      .join(', ');
}
