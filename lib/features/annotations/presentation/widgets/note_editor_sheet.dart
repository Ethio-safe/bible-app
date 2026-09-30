import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/annotations.dart';
import '../providers/annotations_providers.dart';

/// Opens a bottom sheet to create/edit/delete the note on [ref].
Future<void> showNoteEditorSheet(
  BuildContext context, {
  required VerseRef ref,
  required String reference,
  required String verseText,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) =>
        _NoteEditor(verseRef: ref, reference: reference, verseText: verseText),
  );
}

class _NoteEditor extends ConsumerStatefulWidget {
  const _NoteEditor({
    required this.verseRef,
    required this.reference,
    required this.verseText,
  });

  final VerseRef verseRef;
  final String reference;
  final String verseText;

  @override
  ConsumerState<_NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends ConsumerState<_NoteEditor> {
  final _controller = TextEditingController();
  Note? _existing;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final note = await ref
        .read(annotationsRepositoryProvider)
        .getNote(widget.verseRef);
    if (!mounted) return;
    setState(() {
      _existing = note;
      _controller.text = note?.body ?? '';
      _loading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final body = _controller.text.trim();
    final repo = ref.read(annotationsRepositoryProvider);
    if (body.isEmpty) {
      if (_existing != null) await repo.deleteNote(_existing!.id);
    } else {
      await repo.saveNote(widget.verseRef, body);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    if (_existing != null) {
      await ref.read(annotationsRepositoryProvider).deleteNote(_existing!.id);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.reference,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.verseText,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            TextField(
              controller: _controller,
              autofocus: true,
              minLines: 4,
              maxLines: 10,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Write your note…',
                border: OutlineInputBorder(),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (_existing != null)
                TextButton.icon(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _loading ? null : _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
