import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/bible_providers.dart';

Future<void> showTranslationPicker(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const FractionallySizedBox(
        heightFactor: 0.8,
        child: _TranslationPickerSheet(),
      ),
    );

/// Compact chip showing the current translation; tapping opens a picker.
class TranslationChip extends ConsumerWidget {
  const TranslationChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(currentTranslationKeyProvider);
    return ActionChip(
      label: Text(current.toUpperCase()),
      avatar: const Icon(Icons.translate, size: 16),
      onPressed: () => showTranslationPicker(context),
    );
  }
}

class _TranslationPickerSheet extends ConsumerWidget {
  const _TranslationPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translations = ref.watch(translationsProvider);
    final current = ref.watch(currentTranslationKeyProvider);

    return SafeArea(
      child: translations.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) =>
            Padding(padding: const EdgeInsets.all(24), child: Text('$e')),
        data: (list) => ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Translation',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            RadioGroup<String>(
              groupValue: current,
              onChanged: (key) async {
                if (key == null) return;
                await ref.read(currentTranslationKeyProvider.notifier).set(key);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final t in list)
                    RadioListTile<String>(
                      value: t.key,
                      title: Text(t.abbreviation),
                      subtitle: Text('${t.name}\n${t.languageLabel}'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
