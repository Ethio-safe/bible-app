import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../wallpaper/data/wallpaper_applier.dart';
import '../providers/lockscreen_verses_providers.dart';

class LockscreenVersesScreen extends ConsumerWidget {
  const LockscreenVersesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verses = ref.watch(randomVersesNotifierProvider);
    final wallpaperApplier = WallpaperApplier.forPlatform();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lock Screen Verses'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Random Daily Verses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Shows 10 random verses on lock/unlock',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          verses.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        const Text('Loading verses...'),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    ...verses.asMap().entries.map((entry) {
                      final verse = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            verse.reference,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                verse.text,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(height: 1.4),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    }),
                  ],
                ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final n = ref.read(randomVersesNotifierProvider.notifier);
              await n.refresh();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Verses refreshed')),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Verses'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              if (verses.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No verses to apply')),
                );
                return;
              }

              try {
                final snack = ScaffoldMessenger.of(context);
                final picked = verses[(DateTime.now().millisecondsSinceEpoch % verses.length).toInt()];
                await wallpaperApplier.saveToGallery(
                  Uint8List.fromList(picked.text.codeUnits),
                );
                if (context.mounted) {
                  snack.showSnackBar(
                    SnackBar(content: Text('Selected: ${picked.reference}')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            icon: const Icon(Icons.wallpaper),
            label: const Text('Apply to Lock Screen'),
          ),
        ],
      ),
    );
  }
}
