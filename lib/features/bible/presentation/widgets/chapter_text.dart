import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../annotations/presentation/providers/annotations_providers.dart';
import '../../../reader_settings/presentation/reader_style_provider.dart';
import '../../domain/entities/chapter.dart';
import '../providers/verse_selection_provider.dart';

/// Renders a chapter as flowing prose: each verse is a tappable [TextSpan]
/// prefixed by a superscript number. Highlights are drawn as span backgrounds;
/// the current selection as a dotted underline + tint.
///
/// Exposes [verseOffset] so the parent can scroll to a given verse.
class ChapterText extends ConsumerStatefulWidget {
  const ChapterText({super.key, required this.chapter});

  final Chapter chapter;

  @override
  ConsumerState<ChapterText> createState() => ChapterTextState();
}

class ChapterTextState extends ConsumerState<ChapterText> {
  final _paragraphKey = GlobalKey();

  /// Character offset where each verse starts within the rich text.
  final Map<int, int> _verseCharOffsets = {};

  /// Vertical offset (in this widget's coordinates) of the line containing
  /// [verse], or null if not laid out yet.
  double? verseOffset(int verse) {
    final charOffset = _verseCharOffsets[verse];
    final render =
        _paragraphKey.currentContext?.findRenderObject() as RenderParagraph?;
    if (charOffset == null || render == null || !render.hasSize) return null;
    final caret = render.getOffsetForCaret(
      TextPosition(offset: charOffset),
      Rect.zero,
    );
    // Translate from paragraph → ChapterText coordinates.
    final self = context.findRenderObject() as RenderBox?;
    if (self == null) return caret.dy;
    final paragraphTopLeft = render.localToGlobal(Offset.zero, ancestor: self);
    return paragraphTopLeft.dy + caret.dy;
  }

  @override
  Widget build(BuildContext context) {
    final chapter = widget.chapter;
    final style = ref.watch(readerStyleNotifierProvider);
    if (chapter.isPassage) {
      _verseCharOffsets.clear();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Whole-chapter reading passage • verse numbering and verse actions unavailable',
          ),
          const SizedBox(height: 16),
          Text(
            chapter.verses.map((v) => v.text).join('\n\n'),
            style: ReaderTypography.body(context, style),
          ),
        ],
      );
    }
    final selection = ref.watch(verseSelectionProvider(chapter.ref));
    final highlights =
        ref.watch(chapterHighlightsProvider(chapter.ref)).valueOrNull ??
        const [];
    final bookmarks =
        ref.watch(chapterBookmarksProvider(chapter.ref)).valueOrNull ??
        const [];
    final notes =
        ref.watch(chapterNotesProvider(chapter.ref)).valueOrNull ?? const [];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bodyStyle = ReaderTypography.body(context, style);
    final numberStyle = ReaderTypography.verseNumber(context, style);
    final bookmarkedVerses = {for (final b in bookmarks) b.verse};
    final notedVerses = {for (final n in notes) n.verse};

    Color? highlightFor(int verse) {
      for (final h in highlights) {
        if (h.covers(verse)) return isDark ? h.color.dark : h.color.light;
      }
      return null;
    }

    _verseCharOffsets.clear();
    var charCount = 0;
    final spans = <InlineSpan>[];

    for (final v in chapter.verses) {
      final selected = selection.contains(v.number);
      final bg = highlightFor(v.number);
      final recognizer = TapGestureRecognizer()
        ..onTap = () => ref
            .read(verseSelectionProvider(chapter.ref).notifier)
            .toggle(v.number);

      _verseCharOffsets[v.number] = charCount;

      final numberText = '${v.number} ';
      final bodyText = '${v.text} ';
      final marker = StringBuffer();
      if (bookmarkedVerses.contains(v.number)) marker.write('🔖');
      if (notedVerses.contains(v.number)) marker.write('📝');

      spans.add(
        TextSpan(
          text: numberText,
          style: numberStyle.copyWith(backgroundColor: bg),
          recognizer: recognizer,
        ),
      );
      spans.add(
        TextSpan(
          text: bodyText,
          recognizer: recognizer,
          style: bodyStyle.copyWith(
            backgroundColor: bg,
            color: bg != null && !isDark ? const Color(0xFF1F1A14) : null,
            decoration: selected ? TextDecoration.underline : null,
            decorationStyle: TextDecorationStyle.dotted,
            decorationColor: theme.colorScheme.primary,
            decorationThickness: 2,
          ),
        ),
      );
      if (marker.isNotEmpty) {
        spans.add(
          TextSpan(
            text: '$marker ',
            style: bodyStyle.copyWith(fontSize: style.fontSize * 0.6),
          ),
        );
        charCount += marker.length + 1;
      }
      charCount += numberText.length + bodyText.length;
    }

    return Text.rich(
      key: _paragraphKey,
      TextSpan(style: bodyStyle, children: spans),
    );
  }
}
