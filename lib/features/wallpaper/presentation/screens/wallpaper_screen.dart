import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../shared/widgets/async_value_widget.dart';
import '../../../votd/domain/verse_pool.dart';
import '../../domain/entities/wallpaper_image.dart';
import '../providers/wallpaper_providers.dart';

/// Wallpaper tab: gallery of background images in the pool.
class WallpaperScreen extends ConsumerWidget {
  const WallpaperScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text('Wallpaper')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Wallpaper gallery is available in the Android and iOS app.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    final images = ref.watch(wallpaperImagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallpaper'),
        actions: [
          PopupMenuButton<_WallpaperAction>(
            tooltip: 'Wallpaper actions',
            onSelected: (action) {
              if (action == _WallpaperAction.automation) {
                context.push(AppRoutes.automation);
                return;
              }
              final list = images.valueOrNull;
              if (list == null || list.isEmpty) return;
              final img = list[DateTime.now().millisecond % list.length];
              ref
                  .read(previewControllerProvider.notifier)
                  .start(
                    imageId: img.id,
                    source: PoolQuoteSource(randomPoolVerse()),
                  );
              context.push(AppRoutes.wallpaperPreview);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _WallpaperAction.automation,
                child: Text('Automation'),
              ),
              PopupMenuItem(
                value: _WallpaperAction.surprise,
                child: Text('Surprise me'),
              ),
            ],
          ),
        ],
      ),
      body: AsyncValueWidget(
        value: images,
        onRetry: () => ref.invalidate(wallpaperPoolProvider),
        data: (list) => list.isEmpty
            ? const Center(child: Text('No images yet'))
            : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 9 / 16,
                ),
                itemCount: list.length,
                itemBuilder: (context, i) => _Tile(image: list[i]),
              ),
      ),
    );
  }
}

enum _WallpaperAction { automation, surprise }

class _Tile extends ConsumerWidget {
  const _Tile({required this.image});
  final WallpaperImage image;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(image.path),
            fit: BoxFit.cover,
            cacheWidth: 360,
            gaplessPlayback: true,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded || frame != null) return child;
              return const ColoredBox(
                color: Colors.black26,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
            errorBuilder: (context, error, stackTrace) => const ColoredBox(
              color: Colors.black26,
              child: Center(child: Icon(Icons.broken_image_outlined)),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Each image gets its own verse (stable per image) so the
                // gallery isn't the same quote on every background.
                ref
                    .read(previewControllerProvider.notifier)
                    .start(
                      imageId: image.id,
                      source: PoolQuoteSource(
                        versePool[(image.id * 7919) % versePool.length],
                      ),
                    );
                context.push(AppRoutes.wallpaperPreview);
              },
            ),
          ),
          if (image.mood != null)
            Positioned(
              left: 8,
              bottom: 8,
              child: Text(
                image.mood!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white70,
                  shadows: const [Shadow(blurRadius: 4)],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
