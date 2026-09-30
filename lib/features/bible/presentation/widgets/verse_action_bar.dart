import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/router.dart';
import '../../../annotations/domain/entities/annotations.dart';
import '../../../annotations/presentation/providers/annotations_providers.dart';
import '../../../annotations/presentation/widgets/note_editor_sheet.dart';
import '../../../wallpaper/presentation/providers/wallpaper_providers.dart';
import '../../domain/entities/chapter.dart';
import '../providers/bible_providers.dart';
import '../providers/verse_selection_provider.dart';

/// Slides up from the bottom while verses are selected.
class VerseActionBar extends ConsumerWidget {
  const VerseActionBar({super.key, required this.chapter});

  final Chapter chapter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (chapter.isPassage) return const SizedBox.shrink();
    final selection = ref.watch(verseSelectionProvider(chapter.ref));
    final visible = selection.isNotEmpty;

    return AnimatedSlide(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      offset: visible ? Offset.zero : const Offset(0, 1.2),
      child: IgnorePointer(
        ignoring: !visible,
        child: _Bar(chapter: chapter, selection: selection),
      ),
    );
  }
}

class _Bar extends ConsumerWidget {
  const _Bar({required this.chapter, required this.selection});

  final Chapter chapter;
  final Set<int> selection;

  String get _reference => '${chapter.title}:${selection.label}';

  String _selectedText() {
    final verses = chapter.verses.where((v) => selection.contains(v.number));
    return verses.map((v) => '${v.number} ${v.text}').join(' ');
  }

  String _shareText(String translation) =>
      '${_selectedText()}\n\n— $_reference ($translation)';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final repo = ref.read(annotationsRepositoryProvider);
    final selectionNotifier = ref.read(
      verseSelectionProvider(chapter.ref).notifier,
    );
    final bookmarks =
        ref.watch(chapterBookmarksProvider(chapter.ref)).valueOrNull ??
        const [];
    final translation = ref.watch(currentTranslationKeyProvider).toUpperCase();

    final single = selection.length == 1 ? selection.first : null;
    final isBookmarked =
        single != null && bookmarks.any((b) => b.verse == single);

    Future<void> applyHighlight(HighlightColor? color) async {
      for (final (start, end) in selection.ranges) {
        if (color == null) {
          await repo.removeHighlight(
            bookId: chapter.book.id,
            chapter: chapter.number,
            verseStart: start,
            verseEnd: end,
          );
        } else {
          await repo.setHighlight(
            bookId: chapter.book.id,
            chapter: chapter.number,
            verseStart: start,
            verseEnd: end,
            color: color,
          );
        }
      }
      selectionNotifier.clear();
    }

    void snack(String msg) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(msg),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Material(
          elevation: 6,
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _reference,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Clear selection',
                      onPressed: selectionNotifier.clear,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Row(
                  children: [
                    for (final c in HighlightColor.values)
                      _ColorDot(
                        color: theme.brightness == Brightness.dark
                            ? c.dark
                            : c.light,
                        onTap: () => applyHighlight(c),
                      ),
                    _ColorDot(
                      color: Colors.transparent,
                      border: scheme.outline,
                      icon: Icons.format_color_reset_outlined,
                      onTap: () => applyHighlight(null),
                      tooltip: 'Remove highlight',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _Action(
                        icon: isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        label: 'Bookmark',
                        enabled: single != null,
                        onTap: () async {
                          await repo.toggleBookmark(
                            VerseRef(
                              bookId: chapter.book.id,
                              chapter: chapter.number,
                              verse: single!,
                            ),
                          );
                          snack(
                            isBookmarked
                                ? 'Bookmark removed'
                                : 'Bookmarked $_reference',
                          );
                          selectionNotifier.clear();
                        },
                      ),
                      _Action(
                        icon: Icons.edit_note,
                        label: 'Note',
                        enabled: single != null,
                        onTap: () async {
                          final verse = chapter.verses.firstWhere(
                            (v) => v.number == single,
                          );
                          await showNoteEditorSheet(
                            context,
                            ref: VerseRef(
                              bookId: chapter.book.id,
                              chapter: chapter.number,
                              verse: single!,
                            ),
                            reference: _reference,
                            verseText: verse.text,
                          );
                          selectionNotifier.clear();
                        },
                      ),
                      _Action(
                        icon: Icons.copy,
                        label: 'Copy',
                        onTap: () async {
                          await Clipboard.setData(
                            ClipboardData(text: _shareText(translation)),
                          );
                          snack('Copied $_reference');
                          selectionNotifier.clear();
                        },
                      ),
                      _Action(
                        icon: Icons.share,
                        label: 'Share',
                        onTap: () async {
                          await SharePlus.instance.share(
                            ShareParams(
                              text: _shareText(translation),
                              subject: _reference,
                            ),
                          );
                          selectionNotifier.clear();
                        },
                      ),
                      _Action(
                        icon: Icons.wallpaper,
                        label: 'Wallpaper',
                        onTap: () async {
                          final images = await ref.read(
                            wallpaperImagesProvider.future,
                          );
                          if (images.isEmpty || !context.mounted) return;
                          final sorted = selection.toList()..sort();
                          final img =
                              images[DateTime.now().millisecond %
                                  images.length];
                          ref
                              .read(previewControllerProvider.notifier)
                              .start(
                                imageId: img.id,
                                source: RangeQuoteSource(
                                  bookId: chapter.book.id,
                                  chapter: chapter.number,
                                  start: sorted.first,
                                  end: sorted.last,
                                ),
                              );
                          selectionNotifier.clear();
                          await context.push(AppRoutes.wallpaperPreview);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.onTap,
    this.border,
    this.icon,
    this.tooltip,
  });

  final Color color;
  final Color? border;
  final IconData? icon;
  final String? tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dot = InkResponse(
      onTap: onTap,
      radius: 24,
      child: Container(
        width: 34,
        height: 34,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: border == null ? null : Border.all(color: border!),
        ),
        child: icon == null
            ? null
            : Icon(
                icon,
                size: 18,
                color: Theme.of(context).colorScheme.outline,
              ),
      ),
    );
    return tooltip == null ? dot : Tooltip(message: tooltip!, child: dot);
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }
}
