import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../domain/reader_style.dart';
import 'reader_style_provider.dart';

/// Live-preview sheet for font size, family, line height and theme.
Future<void> showReaderSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.68,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, controller) =>
          _ReaderSettingsSheet(scrollController: controller),
    ),
  );
}

class _ReaderSettingsSheet extends ConsumerWidget {
  const _ReaderSettingsSheet({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = ref.watch(readerStyleNotifierProvider);
    final notifier = ref.read(readerStyleNotifierProvider.notifier);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Reader settings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton(onPressed: notifier.reset, child: const Text('Reset')),
            ],
          ),
          const SizedBox(height: 8),

          // Preview -----------------------------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '16 ',
                    style: ReaderTypography.verseNumber(context, style),
                  ),
                  const TextSpan(
                    text:
                        'For God so loved the world, that he gave his only '
                        'begotten Son…',
                  ),
                ],
              ),
              style: ReaderTypography.body(context, style),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),

          // Font size ---------------------------------------------------------
          _SliderRow(
            icon: Icons.format_size,
            label: 'Font size',
            valueLabel: style.fontSize.round().toString(),
            value: style.fontSize,
            min: ReaderStyle.minFontSize,
            max: ReaderStyle.maxFontSize,
            divisions: (ReaderStyle.maxFontSize - ReaderStyle.minFontSize)
                .round(),
            onChanged: notifier.setFontSize,
          ),

          // Line height -------------------------------------------------------
          _SliderRow(
            icon: Icons.format_line_spacing,
            label: 'Line spacing',
            valueLabel: style.lineHeight.toStringAsFixed(1),
            value: style.lineHeight,
            min: ReaderStyle.minLineHeight,
            max: ReaderStyle.maxLineHeight,
            divisions: 10,
            onChanged: notifier.setLineHeight,
          ),
          const SizedBox(height: 8),

          // Font family -------------------------------------------------------
          Row(
            children: [
              const Icon(Icons.font_download_outlined, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: SegmentedButton<ReaderFont>(
                  showSelectedIcon: false,
                  segments: [
                    for (final f in ReaderFont.values)
                      ButtonSegment(value: f, label: Text(f.label)),
                  ],
                  selected: {style.font},
                  onSelectionChanged: (s) => notifier.setFont(s.first),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Theme -------------------------------------------------------------
          Row(
            children: [
              const Icon(Icons.palette_outlined, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: SegmentedButton<ReaderTheme>(
                  showSelectedIcon: false,
                  segments: [
                    for (final t in ReaderTheme.values)
                      ButtonSegment(
                        value: t,
                        label: Text(t.label),
                        icon: Icon(switch (t) {
                          ReaderTheme.system => Icons.brightness_auto_outlined,
                          ReaderTheme.light => Icons.light_mode_outlined,
                          ReaderTheme.sepia => Icons.auto_stories_outlined,
                          ReaderTheme.dark => Icons.dark_mode_outlined,
                        }),
                      ),
                  ],
                  selected: {style.theme},
                  onSelectionChanged: (s) => notifier.setTheme(s.first),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.icon,
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            label: valueLabel,
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 36, child: Text(valueLabel, textAlign: TextAlign.end)),
      ],
    );
  }
}
