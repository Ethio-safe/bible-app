import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../shared/widgets/async_value_widget.dart';
import '../../data/wallpaper_applier.dart';
import '../../domain/entities/wallpaper_image.dart';
import '../../domain/wallpaper_composer.dart';
import '../providers/wallpaper_providers.dart';
import '../widgets/verse_picker_sheet.dart';

class WallpaperPreviewScreen extends ConsumerStatefulWidget {
  const WallpaperPreviewScreen({super.key});

  @override
  ConsumerState<WallpaperPreviewScreen> createState() =>
      _WallpaperPreviewScreenState();
}

class _WallpaperPreviewScreenState
    extends ConsumerState<WallpaperPreviewScreen> {
  bool _busy = false;

  Size get _deviceSize {
    final view = View.of(context);
    return view.physicalSize;
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _run(Future<void> Function() job) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await job();
    } on GalleryAccessDenied {
      _snack('Photos access is needed to save the wallpaper.');
    } catch (e) {
      _snack('Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _set() async {
    final applier = ref.read(wallpaperApplierProvider);
    WallpaperTarget target = WallpaperTarget.both;
    if (applier.canSetDirectly) {
      final picked = await showModalBottomSheet<WallpaperTarget>(
        context: context,
        showDragHandle: true,
        builder: (_) => const _TargetSheet(),
      );
      if (picked == null) return;
      target = picked;
    }
    await _run(() async {
      final png = await ref.read(previewRendererProvider).render(_deviceSize);
      final outcome = await applier.apply(png, target);
      final state = ref.read(previewControllerProvider);
      final pool = await ref.read(wallpaperPoolProvider.future);
      await pool.markUsed(state.imageId);
      if (!mounted) return;
      if (outcome == ApplyOutcome.applied) {
        _snack('Wallpaper set');
      } else {
        await showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (_) => const _IosGuidanceSheet(),
        );
      }
    });
  }

  Future<void> _save() => _run(() async {
    final png = await ref.read(previewRendererProvider).render(_deviceSize);
    await ref.read(wallpaperApplierProvider).saveToGallery(png);
    _snack('Saved to Photos · $galAlbum');
  });

  Future<void> _share() => _run(() async {
    final png = await ref.read(previewRendererProvider).render(_deviceSize);
    final file = await WallpaperApplier.writeTemp(png);
    final quote = await ref.read(previewQuoteProvider.future);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        text: '${quote.text}\n— ${quote.attribution}',
      ),
    );
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(previewControllerProvider);
    final controller = ref.read(previewControllerProvider.notifier);
    final image = ref.watch(wallpaperImageProvider(state.imageId));
    final quote = ref.watch(previewQuoteProvider);
    final applier = ref.read(wallpaperApplierProvider);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        title: const Text('Preview'),
        actions: [
          IconButton(
            tooltip: state.watermark ? 'Hide watermark' : 'Show watermark',
            icon: Icon(
              state.watermark
                  ? Icons.branding_watermark
                  : Icons.branding_watermark_outlined,
            ),
            onPressed: controller.toggleWatermark,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Center(
                child: AspectRatio(
                  aspectRatio: _deviceSize.width / _deviceSize.height,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: AsyncValueWidget(
                      value: image,
                      data: (img) => img == null
                          ? const ErrorView(message: 'Image not found')
                          : _LivePreview(
                              image: img,
                              quote: quote,
                              template: state.template,
                              watermark: state.watermark,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          _Controls(
            state: state,
            quote: quote,
            busy: _busy,
            canSetDirectly: applier.canSetDirectly,
            onSet: _set,
            onSave: _save,
            onShare: _share,
          ),
        ],
      ),
    );
  }
}

class _LivePreview extends ConsumerWidget {
  const _LivePreview({
    required this.image,
    required this.quote,
    required this.template,
    required this.watermark,
  });

  final WallpaperImage image;
  final AsyncValue<WallpaperQuote> quote;
  final WallpaperTemplate template;
  final bool watermark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decoded = ref.watch(decodedWallpaperImageProvider(image.path));
    final bg = decoded.valueOrNull;
    final q = quote.valueOrNull;
    if (bg == null || q == null) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return CustomPaint(
      painter: _ComposerPainter(
        composer: ref.read(wallpaperComposerProvider),
        image: bg,
        quote: q,
        template: template,
        watermark: watermark,
        physicalSize: View.of(context).physicalSize,
      ),
    );
  }
}

/// Paints the full-resolution composition scaled into the preview box so the
/// preview is pixel-faithful to the exported PNG.
class _ComposerPainter extends CustomPainter {
  _ComposerPainter({
    required this.composer,
    required this.image,
    required this.quote,
    required this.template,
    required this.watermark,
    required this.physicalSize,
  });

  final WallpaperComposer composer;
  final ui.Image image;
  final WallpaperQuote quote;
  final WallpaperTemplate template;
  final bool watermark;
  final Size physicalSize;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / physicalSize.width;
    canvas.save();
    canvas.scale(scale);
    composer.paint(
      canvas,
      WallpaperSpec(
        image: image,
        quote: quote,
        template: template,
        size: physicalSize,
        watermark: watermark,
      ),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ComposerPainter old) =>
      old.image != image ||
      old.quote != quote ||
      old.template != template ||
      old.watermark != watermark ||
      old.physicalSize != physicalSize;
}

class _Controls extends ConsumerWidget {
  const _Controls({
    required this.state,
    required this.quote,
    required this.busy,
    required this.canSetDirectly,
    required this.onSet,
    required this.onSave,
    required this.onShare,
  });

  final PreviewState state;
  final AsyncValue<WallpaperQuote> quote;
  final bool busy;
  final bool canSetDirectly;
  final VoidCallback onSet, onSave, onShare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final controller = ref.read(previewControllerProvider.notifier);
    final language = ref.watch(wallpaperVerseLanguageControllerProvider);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<WallpaperVerseLanguage>(
              segments: const [
                ButtonSegment(
                  value: WallpaperVerseLanguage.english,
                  label: Text('English'),
                ),
                ButtonSegment(
                  value: WallpaperVerseLanguage.amharic,
                  label: Text('አማርኛ'),
                ),
              ],
              selected: {language},
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? scheme.primary
                      : scheme.surfaceContainer,
                ),
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? scheme.onPrimary
                      : scheme.onSurface,
                ),
                side: WidgetStatePropertyAll(
                  BorderSide(color: scheme.outlineVariant),
                ),
              ),
              onSelectionChanged: (selected) => ref
                  .read(wallpaperVerseLanguageControllerProvider.notifier)
                  .set(selected.first),
            ),
            const SizedBox(height: 8),
            // Template picker
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final t in WallpaperTemplate.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(t.label),
                        selected: state.template == t,
                        labelStyle: TextStyle(
                          color: state.template == t
                              ? scheme.onPrimary
                              : scheme.onSurface,
                        ),
                        onSelected: (_) => controller.setTemplate(t),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Verse row
            Row(
              children: [
                Expanded(
                  child: Text(
                    quote.valueOrNull?.reference ?? '…',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.onSurface,
                  ),
                  onPressed: controller.shuffleVerse,
                  icon: const Icon(Icons.casino_outlined, size: 18),
                  label: const Text('Random'),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.onSurface,
                  ),
                  onPressed: () => showVersePickerSheet(context),
                  icon: const Icon(Icons.menu_book_outlined, size: 18),
                  label: const Text('Choose'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: busy ? null : onSet,
                    icon: busy
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.wallpaper),
                    label: Text(
                      canSetDirectly
                          ? 'Set as wallpaper'
                          : 'Save for lock screen',
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Save image',
                  style: IconButton.styleFrom(
                    backgroundColor: scheme.secondaryContainer,
                    foregroundColor: scheme.onSecondaryContainer,
                  ),
                  onPressed: busy ? null : onSave,
                  icon: const Icon(Icons.download_outlined),
                ),
                IconButton.filledTonal(
                  tooltip: 'Share',
                  style: IconButton.styleFrom(
                    backgroundColor: scheme.secondaryContainer,
                    foregroundColor: scheme.onSecondaryContainer,
                  ),
                  onPressed: busy ? null : onShare,
                  icon: const Icon(Icons.ios_share),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetSheet extends StatelessWidget {
  const _TargetSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Lock screen'),
            onTap: () => Navigator.pop(context, WallpaperTarget.lock),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home screen'),
            onTap: () => Navigator.pop(context, WallpaperTarget.home),
          ),
          ListTile(
            leading: const Icon(Icons.smartphone),
            title: const Text('Both'),
            onTap: () => Navigator.pop(context, WallpaperTarget.both),
          ),
        ],
      ),
    );
  }
}

class _IosGuidanceSheet extends StatelessWidget {
  const _IosGuidanceSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const steps = [
      'Open the Photos app and find the image in the "Verse Bible" album.',
      'Tap Share → "Use as Wallpaper".',
      'Adjust and tap Add → "Set as Wallpaper Pair" (or customise the Home Screen).',
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saved to Photos', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'iOS doesn\'t let apps change the lock screen directly. '
              'Set it in three taps:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(radius: 12, child: Text('${i + 1}')),
                    const SizedBox(width: 12),
                    Expanded(child: Text(steps[i])),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
