import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../bible/presentation/providers/bible_providers.dart';

import '../../../../app/router.dart';
import '../../domain/entities/annotations.dart';
import '../providers/annotations_providers.dart';
import '../providers/verse_lookup_provider.dart';
import '../widgets/note_editor_sheet.dart';

/// Highlights / Bookmarks / Notes, each with jump-to-verse.
class MyStuffScreen extends StatelessWidget {
  const MyStuffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved')),
      body: const MyStuffBody(),
    );
  }
}

/// Embeddable body: filter chips (All / Highlights / Notes / Bookmarks) over
/// the matching list. Used by the "Saved" tab on the You screen.
class MyStuffBody extends StatefulWidget {
  const MyStuffBody({super.key});

  @override
  State<MyStuffBody> createState() => _MyStuffBodyState();
}

enum _Filter {
  highlights('Highlights', Icons.border_color_outlined),
  notes('Notes', Icons.edit_note),
  bookmarks('Bookmarks', Icons.bookmark_outline);

  const _Filter(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _MyStuffBodyState extends State<MyStuffBody> {
  _Filter _filter = _Filter.highlights;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            children: [
              for (final f in _Filter.values) ...[
                ChoiceChip(
                  avatar: Icon(
                    f.icon,
                    size: 16,
                    color: _filter == f ? scheme.surface : scheme.onSurface,
                  ),
                  label: Text(f.label),
                  selected: _filter == f,
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    color: _filter == f ? scheme.surface : scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() => _filter = f),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        Expanded(
          child: switch (_filter) {
            _Filter.highlights => const _HighlightsTab(),
            _Filter.notes => const _NotesTab(),
            _Filter.bookmarks => const _BookmarksTab(),
          },
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------

class _HighlightsTab extends ConsumerWidget {
  const _HighlightsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(allHighlightsProvider);
    return _ListBody(
      value: items,
      emptyIcon: Icons.border_color_outlined,
      emptyText: 'Tap a verse while reading and pick a colour to highlight it.',
      itemBuilder: (h) => _AnnotationTile(
        verseRef: VerseRef(
          bookId: h.bookId,
          chapter: h.chapter,
          verse: h.verseStart,
        ),
        verseEnd: h.verseEnd,
        leading: Container(
          width: 14,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? h.color.dark
                : h.color.light,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        date: h.createdAt,
        onDelete: () =>
            ref.read(annotationsRepositoryProvider).deleteHighlight(h.id),
      ),
    );
  }
}

class _BookmarksTab extends ConsumerWidget {
  const _BookmarksTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(allBookmarksProvider);
    return _ListBody(
      value: items,
      emptyIcon: Icons.bookmark_outline,
      emptyText: 'Select a single verse and tap Bookmark to save it here.',
      itemBuilder: (b) => _AnnotationTile(
        verseRef: VerseRef(
          bookId: b.bookId,
          chapter: b.chapter,
          verse: b.verse,
        ),
        leading: const Icon(Icons.bookmark),
        date: b.createdAt,
        onDelete: () =>
            ref.read(annotationsRepositoryProvider).deleteBookmark(b.id),
      ),
    );
  }
}

class _NotesTab extends ConsumerWidget {
  const _NotesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(allNotesProvider);
    return _ListBody(
      value: items,
      emptyIcon: Icons.edit_note,
      emptyText: 'Select a verse and tap Note to write your thoughts.',
      itemBuilder: (n) => _AnnotationTile(
        verseRef: VerseRef(
          bookId: n.bookId,
          chapter: n.chapter,
          verse: n.verse,
        ),
        leading: const Icon(Icons.edit_note),
        date: n.updatedAt,
        body: n.body,
        onEdit: (reference, verseText) => showNoteEditorSheet(
          context,
          ref: VerseRef(bookId: n.bookId, chapter: n.chapter, verse: n.verse),
          reference: reference,
          verseText: verseText,
        ),
        onDelete: () =>
            ref.read(annotationsRepositoryProvider).deleteNote(n.id),
      ),
    );
  }
}

// -----------------------------------------------------------------------------

class _ListBody<T> extends StatelessWidget {
  const _ListBody({
    required this.value,
    required this.itemBuilder,
    required this.emptyIcon,
    required this.emptyText,
  });

  final AsyncValue<List<T>> value;
  final Widget Function(T item) itemBuilder;
  final IconData emptyIcon;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (items) {
        if (items.isEmpty) {
          final theme = Theme.of(context);
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(emptyIcon, size: 56, color: theme.colorScheme.outline),
                  const SizedBox(height: 12),
                  Text(
                    emptyText,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
          itemBuilder: (context, i) => itemBuilder(items[i]),
        );
      },
    );
  }
}

class _AnnotationTile extends ConsumerWidget {
  const _AnnotationTile({
    required this.verseRef,
    required this.leading,
    required this.date,
    required this.onDelete,
    this.verseEnd,
    this.body,
    this.onEdit,
  });

  final VerseRef verseRef;
  final int? verseEnd;
  final Widget leading;
  final DateTime date;
  final String? body;
  final void Function(String reference, String verseText)? onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lookup = ref.watch(verseLookupProvider(verseRef, verseEnd: verseEnd));
    final theme = Theme.of(context);
    final reference = lookup.valueOrNull?.reference ?? '…';
    final text = lookup.valueOrNull?.text ?? '';
    final book = ref.watch(bookProvider(verseRef.bookId));
    final available =
        !book.isLoading &&
        book.valueOrNull != null &&
        !lookup.isLoading &&
        !lookup.hasError;

    return Dismissible(
      key: ValueKey('${verseRef.key}-$date'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: theme.colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(Icons.delete, color: theme.colorScheme.onErrorContainer),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        leading: SizedBox(width: 40, child: Center(child: leading)),
        title: Text(
          reference,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (body != null) ...[
              Text(body!, maxLines: 3, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
            ],
            Text(
              text,
              maxLines: body == null ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: onEdit == null
            ? null
            : IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => onEdit!(reference, text),
              ),
        onTap: !available
            ? null
            : () => context.push(
                AppRoutes.reader(
                  verseRef.bookId,
                  verseRef.chapter,
                  verse: verseRef.verse,
                ),
              ),
      ),
    );
  }
}
