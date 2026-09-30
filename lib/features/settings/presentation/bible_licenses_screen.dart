import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../bible/presentation/providers/bible_providers.dart';

/// Attribution and quality notices from each bundled database.
class BibleLicensesScreen extends ConsumerWidget {
  const BibleLicensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final translations = ref.watch(translationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Bible text sources')),
      body: translations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Source information unavailable: $e')),
        data: (entries) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'These texts are stored on your device for offline reading. '
              'Sources, licenses and quality limitations differ by edition.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            for (final e in entries) ...[
              Text(
                '${e.name} (${e.abbreviation})',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}
